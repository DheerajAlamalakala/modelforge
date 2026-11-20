(() => {
  const project = document.querySelector('#project-select');
  const body = document.querySelector('#runs-body');
  const note = document.querySelector('#runs-message');
  const runFilter = document.querySelector('#run-status-filter');
  const manageRun = document.querySelector('#manage-run-select');
  const metricRun = document.querySelector('#metric-run-select');
  const metricsBody = document.querySelector('#metrics-body');
  const metricsNote = document.querySelector('#metrics-message');
  let currentRuns = [];
  const csrf = window.MF?.csrf || '';
  const cell = (tr, value) => {
    const td=document.createElement('td');
    td.textContent=(value===null || value===undefined || value==='')?'—':String(value);
    tr.append(td); return td;
  };
  const formatMetric = value => value===null || value===undefined ? '—' : Number(value).toFixed(4);

  function putRunsInSelect(select, selected) {
    if (!select) return;
    const first=select.options[0];
    select.replaceChildren(first);
    currentRuns.forEach(run=>{
      const option=document.createElement('option'); option.value=String(run.run_id);
      option.textContent=`#${run.run_id} · ${run.experiment} · ${run.status}`; select.append(option);
    });
    if (selected && currentRuns.some(run=>String(run.run_id)===String(selected))) select.value=String(selected);
    else if (currentRuns.length) select.value=String(currentRuns[0].run_id);
  }

  function fillRunEditor(run) {
    if(!run) return;
    const set=(selector,value)=>{const node=document.querySelector(selector);if(node)node.value=value??'';};
    set('#manage-experiment-select',run.experiment_id);
    set('#manage-node-select',run.node_id);
    set('#manage-status',run.status);
    set('#manage-vram',run.vram_used_gb);
    set('#manage-accuracy',run.accuracy);
    set('#manage-loss',run.loss);
    set('#manage-notes',run.notes);
  }

  function renderRuns() {
    if(!body) return;
    body.replaceChildren();
    const chosen=runFilter?.value || 'all';
    const visible=currentRuns.filter(run=>chosen==='all' || run.status===chosen);
    if(!visible.length) {
      const tr=document.createElement('tr'),td=document.createElement('td'); td.colSpan=9;
      td.textContent=currentRuns.length?'No runs match this status filter.':'No runs in this project yet.';
      tr.append(td);body.append(tr);
    }
    visible.forEach(run=>{
      const tr=document.createElement('tr');
      cell(tr,'#'+run.run_id);cell(tr,run.experiment);cell(tr,run.gpu);
      const statusCell=document.createElement('td'),badge=document.createElement('span');
      badge.className='badge '+run.status;badge.textContent=run.status;statusCell.append(badge);tr.append(statusCell);
      cell(tr,formatMetric(run.accuracy));cell(tr,formatMetric(run.loss));cell(tr,run.started_at);cell(tr,run.ended_at);
      const actions=document.createElement('td'),edit=document.createElement('button'),remove=document.createElement('button');
      edit.type='button';edit.className='small-action';edit.textContent='Edit';
      edit.addEventListener('click',()=>{
        if(manageRun)manageRun.value=String(run.run_id);fillRunEditor(run);
        document.querySelector('#manage-runs')?.scrollIntoView({behavior:'smooth',block:'start'});
      });
      remove.type='button';remove.className='small-action danger-text';remove.textContent='Delete';
      remove.addEventListener('click',async()=>{
        if(!window.confirm(`Delete run #${run.run_id}, its epoch metrics, and its audit history?`))return;
        remove.disabled=true;
        try {
          const data=new FormData();data.append('run_id',String(run.run_id));data.append('_csrf',csrf);
          const response=await fetch('/api.php?action=delete_run',{method:'POST',body:data,headers:{'X-CSRF-Token':csrf}});
          const result=await response.json();if(!response.ok||!result.ok)throw new Error(result.message||'Could not delete the run.');
          if(note)note.textContent=result.message;await loadRuns();await loadMetrics();
        } catch(error){if(note)note.textContent=error.message;remove.disabled=false;}
      });
      actions.className='run-actions';actions.append(edit,remove);tr.append(actions);body.append(tr);
    });
    if(note)note.textContent=`${visible.length} of ${currentRuns.length} run(s).`;
  }

  async function loadMetrics() {
    if(!metricsBody || !metricRun) return;
    const runId=metricRun.value;
    if(!runId){metricsBody.replaceChildren();const tr=document.createElement('tr'),td=document.createElement('td');td.colSpan=3;td.textContent='Choose a run to inspect its epochs.';tr.append(td);metricsBody.append(tr);return;}
    try {
      const response=await fetch('/api.php?action=metrics&run_id='+encodeURIComponent(runId));
      const data=await response.json();if(!response.ok||!data.ok)throw new Error(data.message||'Could not load epoch metrics.');
      metricsBody.replaceChildren();
      if(!data.metrics.length){const tr=document.createElement('tr'),td=document.createElement('td');td.colSpan=3;td.textContent='No epoch metrics recorded yet.';tr.append(td);metricsBody.append(tr);}
      data.metrics.forEach(metric=>{const tr=document.createElement('tr');cell(tr,metric.epoch);cell(tr,formatMetric(metric.loss));cell(tr,formatMetric(metric.accuracy));metricsBody.append(tr);});
      if(metricsNote)metricsNote.textContent=`${data.metrics.length} epoch(s) recorded.`;
    } catch(error){if(metricsNote)metricsNote.textContent=error.message;}
  }

  async function loadRuns() {
    if(!project || !body)return;
    const oldManage=manageRun?.value,oldMetric=metricRun?.value;
    try {
      const response=await fetch('/api.php?action=runs&project_id='+encodeURIComponent(project.value));
      const data=await response.json();if(!response.ok||!data.ok)throw new Error(data.message||'Could not load runs.');
      currentRuns=data.runs;putRunsInSelect(manageRun,oldManage);putRunsInSelect(metricRun,oldMetric);
      renderRuns();
      const selected=currentRuns.find(run=>String(run.run_id)===manageRun?.value);
      if(selected)fillRunEditor(selected);
      await loadMetrics();
    } catch(error){if(note)note.textContent=error.message;}
  }

  project?.addEventListener('change',loadRuns);
  runFilter?.addEventListener('change',renderRuns);
  manageRun?.addEventListener('change',()=>fillRunEditor(currentRuns.find(run=>String(run.run_id)===manageRun.value)));
  metricRun?.addEventListener('change',loadMetrics);
  loadRuns();

  const search=document.querySelector('#experiment-search');
  if(search) {
    let timer;
    const lookup=async term=>{
      try { const response=await fetch('/api.php?action=experiments&q='+encodeURIComponent(term)); return await response.json(); }
      catch { return []; }
    };
    if(window.jQuery?.ui?.autocomplete) {
      window.jQuery(search).autocomplete({minLength:2,source:(req,send)=>lookup(req.term).then(send)});
    } else {
      const list=document.querySelector('#suggestions');
      search.addEventListener('input',()=>{
        clearTimeout(timer);timer=setTimeout(async()=>{
          if(search.value.trim().length<2)return;
          list.replaceChildren(...(await lookup(search.value.trim())).map(value=>{const option=document.createElement('option');option.value=value;return option;}));
        },180);
      });
    }
  }

  document.querySelectorAll('.ajax-form').forEach(form=>form.addEventListener('submit',async event=>{
    event.preventDefault();
    const action=new URL(form.action,location.href).searchParams.get('action');
    const message=form.querySelector('.form-message'),button=form.querySelector('button[type="submit"],button:not([type])');
    if(action==='delete_account' && !window.confirm('This permanently deletes your account and all data owned by it. Continue?'))return;
    if(button)button.disabled=true;if(message)message.textContent='Saving…';
    try {
      const response=await fetch(form.action,{method:'POST',body:new FormData(form),headers:{'X-CSRF-Token':csrf}});
      const data=await response.json();if(!response.ok||!data.ok)throw new Error(data.message||'Could not save.');
      if(message)message.textContent=data.message;
      if(action==='delete_account'){window.location.assign('/login.php');return;}
      if(action==='metric'){
        const selected=metricRun?.value;form.reset();if(metricRun)metricRun.value=selected;await loadMetrics();if(message)message.textContent=data.message;return;
      }
      if(['project','dataset','experiments','run'].includes(action)){setTimeout(()=>location.reload(),450);return;}
      if(action==='run_update'){await loadRuns();if(message)message.textContent=data.message;}
    } catch(error){if(message)message.textContent=error.message;}
    finally {if(button)button.disabled=false;}
  }));
})();
(() => {
  const project = document.querySelector('#project-select');
  const body = document.querySelector('#runs-body');
  const note = document.querySelector('#runs-message');
  const cell = (tr, value) => { const td=document.createElement('td'); td.textContent=(value===null||value==='')?'—':String(value); tr.append(td); };
  async function loadRuns() {
    if (!project || !body) return;
    try {
      const res=await fetch('/api.php?action=runs&project_id='+encodeURIComponent(project.value));
      const data=await res.json();
      if (!res.ok || !data.ok) throw new Error(data.message || 'Could not load runs.');
      body.replaceChildren();
      if (!data.runs.length) { const tr=document.createElement('tr'); const td=document.createElement('td'); td.colSpan=6; td.textContent='No runs in this project yet.'; tr.append(td); body.append(tr); }
      data.runs.forEach(run => {
        const tr=document.createElement('tr'); cell(tr,'#'+run.run_id); cell(tr,run.experiment); cell(tr,run.gpu);
        const td=document.createElement('td'), badge=document.createElement('span'); badge.className='badge '+run.status; badge.textContent=run.status; td.append(badge); tr.append(td);
        cell(tr,run.accuracy===null?null:Number(run.accuracy).toFixed(4)); cell(tr,run.loss===null?null:Number(run.loss).toFixed(4)); body.append(tr);
      });
      if(note) note.textContent=data.runs.length+' run(s).';
    } catch(e) { if(note) note.textContent=e.message; }
  }
  project?.addEventListener('change',loadRuns); loadRuns();

  const search=document.querySelector('#experiment-search');
  if(search) {
    let timer;
    const lookup=async term=>{
      try { const res=await fetch('/api.php?action=experiments&q='+encodeURIComponent(term)); return await res.json(); }
      catch { return []; }
    };
    if(window.jQuery?.ui?.autocomplete) {
      window.jQuery(search).autocomplete({minLength:2,source:(req,send)=>lookup(req.term).then(send)});
    } else {
      const list=document.querySelector('#suggestions');
      search.addEventListener('input',()=>{
        clearTimeout(timer); timer=setTimeout(async()=>{
          if(search.value.trim().length<2)return;
          list.replaceChildren(...(await lookup(search.value.trim())).map(value=>{const o=document.createElement('option');o.value=value;return o;}));
        },180);
      });
    }
  }

  document.querySelectorAll('.ajax-form').forEach(form=>form.addEventListener('submit',async event=>{
    event.preventDefault();
    const message=form.querySelector('.form-message'),button=form.querySelector('button');
    button.disabled=true; message.textContent='Saving…';
    try {
      const res=await fetch(form.action,{method:'POST',body:new FormData(form),headers:{'X-CSRF-Token':window.MF.csrf}});
      const data=await res.json(); if(!res.ok||!data.ok)throw new Error(data.message||'Could not save.');
      message.textContent=data.message; form.reset();
      if(form.action.includes('project')||form.action.includes('dataset')||form.action.includes('experiments') || form.action.includes('action=run')) setTimeout(()=>location.reload(),500);
    } catch(e) { message.textContent=e.message; }
    finally { button.disabled=false; }
  }));
})();



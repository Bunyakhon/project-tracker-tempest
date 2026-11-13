/* Node.js built-in smoke checks. No network, no Supabase project required. */
const fs=require('node:fs');
const assert=require('node:assert/strict');
const path=require('node:path');
const root=path.resolve(__dirname,'..');
const read=name=>fs.readFileSync(path.join(root,name),'utf8');
const names=['index.html','setup.html','app.js','styles.css','template.css','config.js','SETUP.md','README.md','supabase/SETUP.sql'];
names.forEach(name=>assert.ok(fs.statSync(path.join(root,name)).size>50,'missing '+name));
const html=read('index.html');
const js=read('app.js');
const config=read('config.js');
const sql=read('supabase/SETUP.sql');
const setup=read('SETUP.md');
new Function(js);
new Function(config);
const ids=[...html.matchAll(/\bid="([^"]+)"/g)].map(m=>m[1]);
assert.equal(new Set(ids).size,ids.length,'Duplicate HTML ids');
const required=[...js.matchAll(/\$\('([A-Za-z0-9_]+)'\)/g)].map(m=>m[1]);
const missing=[...new Set(required)].filter(id=>!ids.includes(id));
assert.deepEqual(missing,[],'Missing HTML ids referenced by JS');
assert.ok(html.includes('src="config.js"')&&html.includes('src="app.js"'),'Configuration script missing');
assert.ok(html.indexOf('src="config.js"')<html.indexOf('src="app.js"'),'Config must load first');
assert.ok(/YOUR_SUPABASE_URL/.test(config),'Config placeholder missing');
assert.ok(/YOUR_SUPABASE_PUBLISHABLE_KEY/.test(config),'Publishable key placeholder missing');
assert.ok(!/https:\/\/[a-z0-9-]{20}\.supabase\.co/i.test(config+js),'A real Supabase URL is hard-coded');
assert.ok(!/sb_publishable_[a-zA-Z0-9_-]{15,}/.test(config+js),'A real publishable key is hard-coded');
assert.ok(!/service_role\s*:\s*["']/.test(config+js),'Secret configured');
assert.ok(!/CoopConnect|coopconnect-original|68 ข้อ/.test(html+config+js),'Original project data leaked into the template');
assert.ok(/tracker_editors/.test(sql)&&/enable row level security/gi.test(sql),'Missing access control');
for(const table of ['tracker_custom_projects','tracker_custom_weeks','tracker_custom_tasks','tracker_custom_evidence']) {
  assert.ok(sql.includes('public.'+table),'Missing SQL table '+table);
  assert.ok(js.includes(table),'Missing JS table '+table);
}
assert.ok(sql.includes("false, 5242880"),'Evidence bucket must be private and 5 MB');
assert.ok(/on delete restrict/i.test(sql),'Evidence deletion must prevent orphaned file references');
assert.ok(js.includes('createSignedUrl')&&js.includes('.upload('),'Missing upload/render operations');
assert.ok(js.includes('planned_weeks:plannedWeeks'),'Missing automatic week creation');
assert.ok(setup.includes('YOUR_EMAIL@example.com'),'First editor manual approval docs missing');
console.log('PASS: '+names.length+' files, '+ids.length+' HTML IDs, '+new Set(required).size+' JS DOM references, empty independent Supabase config, SQL/RLS/storage contract');

#!/usr/bin/env node
/**
 * design-logo: builds one self-contained offline HTML preview for 6 SVG proposals.
 * Requires Node.js 20+, no npm packages.
 * Run: node scripts/build-gallery.mjs --input /path/round-01 --output /path/gallery.html
 */
import fs from 'node:fs/promises';
import path from 'node:path';
import process from 'node:process';

function argsFrom(argv) {
  const result = {};
  for (let i = 0; i < argv.length; i++) {
    if (argv[i].startsWith('--')) {
      const key = argv[i].slice(2);
      if (key === 'demo') { result.demo = true; continue; }
      if (!['input','output'].includes(key) || !argv[i+1] || argv[i+1].startsWith('--')) throw new Error('参数错误：需要 --input 目录 和 --output HTML 文件');
      result[key] = argv[++i];
    } else throw new Error(`未知参数: ${argv[i]}`);
  }
  if (!result.input || !result.output) throw new Error('用法: node build-gallery.mjs --input <round-dir> --output <gallery.html>');
  return result;
}
function requiredString(v, label) {
  if (typeof v !== 'string' || !v.trim()) throw new Error(`${label} 必须是非空字符串`);
  return v;
}
function validateSvg(svg, filename) {
  if (typeof svg !== 'string' || svg.length < 40 || svg.length > 150_000) throw new Error(`${filename}: SVG 内容为空或过大`);
  if (!/<svg\b[^>]*\bviewBox\s*=\s*["'][^"']+["']/i.test(svg) || !/<\/svg\s*>/i.test(svg)) throw new Error(`${filename}: 必须有 <svg viewBox="..."> 和闭合标签`);
  // Security precaution: avoid active content or external resources, even for local preview.
  const forbidden = /<!doctype\b|<!entity\b|<\?xml-stylesheet|<\s*(script|foreignobject|iframe|object|embed|image|use|style|a|text|animate\w*|set)\b|\bon[a-z]+\s*=|\b(?:href|xlink:href)\s*=|javascript\s*:|data\s*:\s*text\/html/i;
  if (forbidden.test(svg)) throw new Error(`${filename}: 含有不允许的 SVG 标签、事件处理器或外链引用`);
  const tags = [...svg.matchAll(/<\s*([a-zA-Z][a-zA-Z0-9:-]*)\b/g)].map(m => m[1].toLowerCase());
  const allowed = new Set(['svg','g','path','rect','circle','ellipse','line','polyline','polygon','defs','lineargradient','radialgradient','stop','clippath','mask','title','desc']);
  for (const tag of tags) if (!allowed.has(tag)) throw new Error(`${filename}: 不支持 <${tag}>；请使用矢量基本元素`);
  // Local gradient URLs may be used; all other url() references blocked.
  const stripped = svg.replace(/url\(\s*["']?#[-_A-Za-z0-9]+["']?\s*\)/g, '');
  if (/url\s*\(/i.test(stripped)) throw new Error(`${filename}: 禁止外部 url() 引用`);
  return svg;
}
async function main() {
  const {input, output} = argsFrom(process.argv.slice(2));
  const root = path.resolve(input);
  const out = path.resolve(output);
  const manifest = JSON.parse(await fs.readFile(path.join(root, 'candidates.json'), 'utf8'));
  requiredString(manifest.project, 'project');
  if (!Number.isInteger(manifest.round) || manifest.round < 1) throw new Error('round 必须是 >= 1 的整数');
  if (!Array.isArray(manifest.candidates) || manifest.candidates.length !== 6) throw new Error('每轮必须恰好 6 个候选方案');
  let research = null;
  const demoMode = process.argv.includes('--demo');
  if (!demoMode) {
    try { research = JSON.parse(await fs.readFile(path.join(root,'research.json'),'utf8')); }
    catch { throw new Error('研究未完成：缺少 research.json；正式模式需至少 4 个已观察 Logo 案例和 12 个真实 SVG（演示请用 --demo）'); }
    if (research.status === 'incomplete') throw new Error('研究状态尚未完成，不允许正式构建；仅演示预览可以用 --demo');
    if (!Array.isArray(research.keywords) || research.keywords.length < 6) throw new Error('research.keywords 至少 6 项');
    if (!Array.isArray(research.designReferences) || research.designReferences.length < 4) throw new Error('research.designReferences 至少需要 4 个已访问的具体品牌案例');
    const referenceIds=new Set(), referenceUrls=new Set(), caseSites=new Set();
    for (const d of research.designReferences) {
      for (const k of ['id','title','site','sourceUrl','observedAt','principle','whyRelevant','avoidCopying']) requiredString(d[k], `research.designReferences.${k}`);
      if (d.verified !== true) throw new Error(`${d.id}: 案例需要实际打开观察才可标为 verified:true`);
      if (!/^https:\/\/[^/]+\/.+/.test(d.sourceUrl)) throw new Error(`${d.id}: 需要 HTTPS 的具体品牌案例链接，而非站点首页`);
      if (!/^\d{4}-\d{2}-\d{2}$/.test(d.observedAt)) throw new Error(`${d.id}: observedAt 需为 YYYY-MM-DD`);
      if (referenceIds.has(d.id) || referenceUrls.has(d.sourceUrl)) throw new Error(`${d.id}: 案例 ID 或 URL 重复`);
      referenceIds.add(d.id); referenceUrls.add(d.sourceUrl); caseSites.add(d.site.toLowerCase().trim());
    }
    if (caseSites.size < 2) throw new Error('品牌案例必须来自至少两个不同平台');
    if (!Array.isArray(research.librariesReviewed) || !['Tabler Icons','Lucide','SVG Repo'].every(name => research.librariesReviewed.some(x=>x.name === name && x.reviewed === true))) throw new Error('research.librariesReviewed 必须包含已检查的三个图库');
    if (!Array.isArray(research.icons) || research.icons.length < 12) throw new Error('research.icons 必须至少记录 12 个真实图标');
    const urls = new Set(), keys = new Set();
    for (const r of research.icons) {
      for (const k of ['id','name','library','sourceUrl','license','licenseUrl','licenseCheckedAt','svgFile','whyRelevant']) requiredString(r[k],`research.icons.${k}`);
      if (!['Tabler Icons','Lucide','SVG Repo','Iconify'].includes(r.library) || r.verified !== true || r.commercialUse !== true || r.modificationAllowed !== true) throw new Error(`${r.id}: 必须完成逐项授权和 SVG 审核`);
      if (r.library === 'Iconify') {
        requiredString(r.upstreamSourceUrl, `${r.id}.upstreamSourceUrl`);
        requiredString(r.collectionPrefix, `${r.id}.collectionPrefix`);
        if (!/^https:\/\//.test(r.upstreamSourceUrl)) throw new Error(`${r.id}: Iconify 必须记录原始图标集 HTTPS 来源`);
      }
      if (!/^https:\/\//.test(r.sourceUrl) || !/^https:\/\//.test(r.licenseUrl)) throw new Error(`${r.id}: 来源和许可链接必须为 HTTPS`);
      if (urls.has(r.sourceUrl) || keys.has(r.id)) throw new Error(`${r.id}: 图标 ID 或来源 URL 重复`);
      urls.add(r.sourceUrl); keys.add(r.id);
      const resolved = path.resolve(root,r.svgFile);
      if (!resolved.startsWith(root+path.sep)) throw new Error(`${r.id}: svgFile 必须位于本轮目录内`);
      validateSvg(await fs.readFile(resolved,'utf8'),r.svgFile);
    }
  } else {
    for (const fallback of ['research.json','research-progress.json']) {
      try { research = JSON.parse(await fs.readFile(path.join(root,fallback),'utf8')); break; } catch {}
    }
  }
  const ids = ['A','B','C','D','E','F'];
  const candidates = [];
  const fingerprints = new Set();
  for (let i = 0; i < manifest.candidates.length; i++) {
    const candidate = manifest.candidates[i];
    if (candidate.id !== ids[i]) throw new Error(`候选顺序必须是 A–F，位置 ${i+1} 应为 ${ids[i]}`);
    for (const key of ['title','concept','geometry','sourceType','license','modifications','file']) requiredString(candidate[key], `${candidate.id}.${key}`);
    if (!demoMode) {
      if (!Array.isArray(candidate.researchIds) || candidate.researchIds.length < 1 || candidate.researchIds.some(id => !research.icons.some(x=>x.id===id))) throw new Error(`${candidate.id}: 必须通过 researchIds 关联已核查的 SVG`);
      if (!Array.isArray(candidate.designReferenceIds) || candidate.designReferenceIds.length < 1 || candidate.designReferenceIds.some(id => !research.designReferences.some(x=>x.id===id))) throw new Error(`${candidate.id}: 必须通过 designReferenceIds 关联已观察的真实 Logo 案例`);
    }
    if (!['original','modified-open-source'].includes(candidate.sourceType)) throw new Error(`${candidate.id}.sourceType 只支持 original / modified-open-source`);
    if (!Array.isArray(candidate.palette) || candidate.palette.length < 1 || candidate.palette.length > 3 || candidate.palette.some(c => !/^#[0-9a-fA-F]{6}$/.test(c))) throw new Error(`${candidate.id}.palette 应含 1~3 个 HEX 色值`);
    if (candidate.sourceType === 'modified-open-source') {
      if (!/^https:\/\//i.test(candidate.sourceUrl || '')) throw new Error(`${candidate.id}: 外部素材必须提供 HTTPS 来源 URL`);
      if (candidate.license.toLowerCase() === 'original') throw new Error(`${candidate.id}: 外部素材必须提供真实许可证`);
      if (!demoMode) {
        const licensedRefs = research.icons.filter(x=>candidate.researchIds.includes(x.id) && (x.sourceUrl===candidate.sourceUrl || x.upstreamSourceUrl===candidate.sourceUrl));
        if (!licensedRefs.length) throw new Error(`${candidate.id}: 改编作品的 sourceUrl 必须匹配关联的 SVG 研究来源`);
        if (!licensedRefs.some(x=>x.license.trim().toLowerCase()===candidate.license.trim().toLowerCase())) throw new Error(`${candidate.id}: 改编作品的 license 必须与真实来源记录一致`);
      }
    }
    if (!/^[0-9]{2}\.svg$/i.test(candidate.file) || candidate.file !== `${String(i+1).padStart(2,'0')}.svg`) throw new Error(`${candidate.id}: SVG 文件名必须是 ${String(i+1).padStart(2,'0')}.svg`);
    const svg = validateSvg(await fs.readFile(path.join(root,candidate.file),'utf8'), candidate.file);
    const fingerprint = svg.replace(/\s+/g,'').trim();
    if (fingerprints.has(fingerprint)) throw new Error(`${candidate.id}: SVG 与其他方案完全重复，请重新设计`);
    fingerprints.add(fingerprint);
    candidates.push({...candidate, svgBase64:Buffer.from(svg,'utf8').toString('base64')});
  }
  // Reference assets: embed only SVG files actually retrieved and locally validated.
  // In demo mode, optional remote SVG URLs are labelled as online previews, never verified files.
  const researchIcons = research && Array.isArray(research.icons) ? await Promise.all(research.icons.map(async r => {
    let svgBase64 = null;
    if (r.svgFile) {
      const fullPath = path.resolve(root, r.svgFile);
      if (!fullPath.startsWith(root + path.sep)) throw new Error(`${r.id}: SVG 路径越界`);
      try {
        const sourceSvg = await fs.readFile(fullPath,'utf8');
        validateSvg(sourceSvg, r.svgFile);
        svgBase64=Buffer.from(sourceSvg,'utf8').toString('base64');
      } catch(err) { if (!process.argv.includes('--demo')) throw err; }
    }
    const remoteSvgUrl = typeof r.remoteSvgUrl==='string' && /^https:\/\/(cdn\.jsdelivr\.net|www\.svgrepo\.com)\//.test(r.remoteSvgUrl) ? r.remoteSvgUrl : null;
    let schematicBase64 = null;
    if (r.schematicSvgFile && demoMode) {
      const f = path.resolve(root,r.schematicSvgFile);
      if (f.startsWith(root+path.sep)) try { schematicBase64=Buffer.from(validateSvg(await fs.readFile(f,'utf8'),r.schematicSvgFile),'utf8').toString('base64'); } catch {}
    }
    return {id:r.id,name:r.name,library:r.library,sourceUrl:r.sourceUrl,license:r.license,licenseUrl:r.licenseUrl||"",
      verified: r.verified===true, whyRelevant:r.whyRelevant||'', svgBase64,
      schematicBase64,remoteSvgUrl:svgBase64?null:remoteSvgUrl};
  })) : [];
  const designReferences = Array.isArray(research?.designReferences) ? research.designReferences.map(d=>({
    id:d.id,site:d.site,title:d.title,sourceUrl:d.sourceUrl,observedAt:d.observedAt,
    principle:d.principle,whyRelevant:d.whyRelevant,avoidCopying:d.avoidCopying,verified:d.verified===true
  })) : [];
  const safeData = JSON.stringify({demo:demoMode || !research || research.status==='incomplete', researchSummary:research?{
    count:researchIcons.length,libraries:(research.librariesReviewed||[]).map(x=>x.name),
    whyIncomplete:research.whyIncomplete||''}:null,
    researchIcons,designReferences,project:manifest.project,round:manifest.round,brief:manifest.brief||'',candidates
  }).replace(/</g,'\\u003c').replace(/>/g,'\\u003e').replace(/\u2028/g,'\\u2028').replace(/\u2029/g,'\\u2029');
  const html = template().replace('/*__GALLERY_DATA__*/ null', safeData);
  await fs.mkdir(path.dirname(out), {recursive:true});
  await fs.writeFile(out, html, 'utf8');
  console.log((demoMode || !research || research.status==='incomplete')?'⚠ 演示模式：未验证来源，不可用于正式交付':'✓ 品牌案例研究与 SVG 元数据/本地文件结构校验已通过（外部许可仍以人工记录为准）');
  console.log(`✓ 生成完成: ${out}`);
  console.log(`  ${manifest.project} · 第 ${manifest.round} 轮 · 6 个可编辑 SVG · HTML ${Buffer.byteLength(html)/1024|0} KiB`);
}

function template(){return String.raw`<!doctype html>
<html lang="zh-CN">
<head>
<meta charset="utf-8" />
<meta name="viewport" content="width=device-width,initial-scale=1" />
<meta name="color-scheme" content="light" />
<title>Design Logo · 六稿选择</title>
<style>
:root{font-family:Inter,-apple-system,BlinkMacSystemFont,"PingFang SC","Microsoft YaHei",sans-serif;color:#192534;background:#f6f8fb;font-synthesis:none}
*{box-sizing:border-box}body{margin:0}button,textarea{font:inherit}button{cursor:pointer}button:disabled{cursor:not-allowed;opacity:.48}
.container{max-width:1270px;margin:auto;padding:36px 26px 90px}.top{display:flex;justify-content:space-between;align-items:center;gap:20px;margin-bottom:25px}
.brand{display:flex;align-items:center;gap:12px;font-weight:760;letter-spacing:-.04em;font-size:22px}.brandmark{height:35px;width:35px;display:grid;place-items:center;background:#263b53;color:white;border-radius:11px;font-weight:700;font-size:17px;letter-spacing:-.02em}
.pill{border:1px solid #dbe2ea;background:#fff;color:#56677c;padding:9px 13px;border-radius:100px;font-size:12px;font-weight:650}
h1{font-size:clamp(28px,3.6vw,46px);letter-spacing:-.052em;margin:4px 0 10px;line-height:1.15}.subtitle{color:#6e7d8f;line-height:1.75;margin:0;max-width:800px}
.mini-label{font-size:11px;letter-spacing:.16em;font-weight:800;color:#6481a3}.brief{margin-top:23px;background:#fff;border:1px solid #e6ebf1;border-radius:16px;padding:17px 22px;display:flex;align-items:flex-start;gap:13px}.brief b{white-space:nowrap;font-size:13px;color:#344b65}.brief span{color:#66778c;font-size:13px;line-height:1.6}
.row{display:flex;justify-content:space-between;align-items:center;gap:18px;margin:31px 0 14px}.row h2{font-size:19px;margin:0;letter-spacing:-.02em}.row p{font-size:12px;color:#8897a7;margin:4px 0 0}.kbd{border:1px solid #d9e0e8;border-radius:5px;padding:2px 6px;background:#fff;font-size:11px;color:#66798b}
.grid{display:grid;grid-template-columns:repeat(3,minmax(0,1fr));gap:16px}
.logo-card{background:white;border:2px solid #e6ebf1;border-radius:20px;overflow:hidden;position:relative;transition:border .18s,box-shadow .18s,transform .18s;cursor:pointer;min-width:0}
.logo-card:hover{transform:translateY(-2px);box-shadow:0 9px 30px #1d35540c}.logo-card.selected{border-color:#3b6ea8;box-shadow:0 0 0 3px #4169a815,0 13px 35px #2c47621b}
.card-top{display:flex;justify-content:space-between;align-items:center;padding:18px 18px 0}.letter{background:#f2f5f9;border:1px solid #e3e9f0;color:#46607c;font-size:13px;font-weight:750;padding:6px 10px;border-radius:9px}.choose{border:1.5px solid #c7d1dd;border-radius:50%;width:19px;height:19px;position:relative}.selected .choose{border-color:#4169a8;background:#4169a8}.selected .choose:after{content:"";position:absolute;left:5px;top:1px;width:5px;height:9px;border-right:2px solid white;border-bottom:2px solid white;transform:rotate(42deg)}
.stage{height:220px;display:grid;place-items:center;background:radial-gradient(circle at center,#fbfcfe,#fff 65%)}.stage img{width:156px;height:156px;display:block;object-fit:contain;filter:drop-shadow(0 4px 4px #12233a08)}
.variants{display:flex;border-top:1px solid #edf1f5;border-bottom:1px solid #edf1f5}.swatch{height:69px;flex:1;display:flex;align-items:center;justify-content:center;background:#f4f6f8}.swatch.dark{background:#1e2b3b}.swatch img{width:48px;height:48px;object-fit:contain}.small-note{padding:7px 10px;background:#f9fbfd;text-align:center;font-size:10px;color:#8c9aaa;letter-spacing:.04em}
.detail{padding:17px 19px 20px}.name{display:flex;gap:8px;align-items:center;justify-content:space-between}.name h3{font-size:17px;letter-spacing:-.025em;margin:0}.colors{display:flex;gap:5px}.colors i{height:13px;width:13px;border-radius:50%;display:inline-block;border:1px solid #00000012}.desc{color:#7c8b9b;font-size:12px;line-height:1.7;min-height:41px;margin:9px 0}.geom{font-size:11px;font-weight:650;color:#6a829c;background:#f1f5f9;display:inline-block;border-radius:6px;padding:6px 8px}
.actions{display:flex;gap:10px;align-items:center;margin:25px 0 8px;flex-wrap:wrap}.btn{padding:13px 18px;border-radius:11px;font-size:13px;font-weight:750;border:1px solid #d8e1eb;background:#fff;color:#38516d;transition:background .15s}.btn:hover{background:#f3f6fa}.btn.primary{background:#345f90;color:#fff;border-color:#345f90}.btn.primary:hover{background:#294d74}.btn.subtle{background:transparent;border-color:#ccd6e0}.btn svg{vertical-align:-3px;margin-right:6px}.selected-note{font-size:12px;color:#6a7c90;margin:2px 0 15px}
.rights{background:#fff;border:1px solid #e5eaf0;border-radius:17px;padding:19px 22px;margin-top:31px}.rights h4{margin:0 0 8px;font-size:13px}.rights p{font-size:12px;color:#768596;line-height:1.8;margin:0}
.feedback{display:none;margin-top:20px;border:1px solid #dce4ed;border-radius:18px;background:white;padding:21px}.feedback.show{display:block}.feedback h3{font-size:17px;margin:0 0 9px}.feedback>p{font-size:12px;color:#7b8b9e;margin:0 0 17px;line-height:1.8}.checks{display:flex;gap:9px;flex-wrap:wrap;margin-bottom:17px}.check{display:inline-flex;gap:7px;align-items:center;padding:10px 11px;background:#f6f8fb;border:1px solid #e8edf3;border-radius:9px;color:#62768c;font-size:12px;cursor:pointer}.check input{accent-color:#4169a8}textarea{display:block;width:100%;min-height:100px;border:1px solid #dce5ee;border-radius:10px;resize:vertical;padding:13px 14px;outline:none;color:#273d55}textarea:focus{border-color:#6484aa}.hint{font-size:12px;color:#72869b;line-height:1.7;margin:13px 0 0}
.modal{position:fixed;inset:0;background:#142338ae;display:none;align-items:center;justify-content:center;padding:20px;z-index:10}.modal.show{display:flex}.dialog{width:min(640px,100%);background:#fff;border-radius:20px;padding:26px;box-shadow:0 30px 90px #07121d66}.dialog h3{margin:0 0 10px;font-size:21px}.dialog p{font-size:13px;line-height:1.7;color:#61768b}.dialog pre{font-family:ui-monospace,SFMono-Regular,Menlo,monospace;white-space:pre-wrap;overflow:auto;background:#f5f7fa;border:1px solid #e6ecf2;border-radius:10px;padding:14px;max-height:220px;font-size:12px;line-height:1.7}.dialog-footer{display:flex;justify-content:flex-end;gap:9px;flex-wrap:wrap;margin-top:18px}
.toast{position:fixed;left:50%;bottom:30px;transform:translateX(-50%);background:#243d59;color:#fff;padding:12px 17px;border-radius:9px;font-size:13px;box-shadow:0 10px 30px #0003;opacity:0;pointer-events:none;transition:opacity .2s;z-index:20}.toast.on{opacity:1}
@media(max-width:930px){.grid{grid-template-columns:repeat(2,minmax(0,1fr))}.stage{height:190px}}
@media(max-width:600px){.container{padding:23px 15px 80px}.top{margin-bottom:23px}.brand{font-size:18px}.grid{gap:10px}.logo-card{border-radius:15px}.card-top{padding:11px 11px 0}.stage{height:150px}.stage img{width:104px;height:104px}.swatch{height:56px}.swatch img{width:35px;height:35px}.detail{padding:12px}.name h3{font-size:14px}.desc{min-height:62px}.brief{flex-direction:column;gap:5px}.actions .btn{flex:1}.rights{padding:15px}.small-note{font-size:9px}}

.ref-list{display:grid;grid-template-columns:repeat(2,minmax(0,1fr));gap:8px;margin-top:12px}.ref-card{border:1px solid #e0e8ef;border-radius:11px;padding:9px;background:#F8FAFC;min-width:0}.ref-preview{height:65px;display:grid;place-items:center;border-radius:9px;background:white;border:1px dashed #d5e0e9;overflow:hidden}.ref-preview img{height:45px;width:45px;object-fit:contain}.ref-placeholder{text-align:center;font-size:10px;color:#75879B;line-height:1.55;padding:5px}.ref-meta{display:flex;justify-content:space-between;color:#61758c;font-size:10px;margin-top:7px;gap:4px}.ref-name{font-size:11px;font-weight:750;color:#324e6e;margin-top:5px}.ref-note{font-size:10px;color:#8997a7;line-height:1.5;margin-top:4px}.ref-link{display:block;margin-top:6px;color:#3d6c9d;font-size:10px;text-decoration:none}.research-bank{margin:28px 0 0;padding:20px;background:white;border:1px solid #e5ebf1;border-radius:18px}.research-bank h3{margin:0 0 8px;font-size:19px}.research-bank p{color:#6a7f94;font-size:12px;line-height:1.65;margin:0}.research-grid{display:grid;grid-template-columns:repeat(4,minmax(0,1fr));gap:12px;margin-top:16px}.research-item{min-width:0}.research-grid>.ref-card .ref-preview{height:90px}.research-grid>.ref-card .ref-preview img{width:60px;height:60px}.muted-note{font-size:12px;color:#8192a4;margin-top:12px}@media(max-width:1000px){.research-grid{grid-template-columns:repeat(3,minmax(0,1fr))}}@media(max-width:650px){.grid{grid-template-columns:1fr}.research-grid{grid-template-columns:repeat(2,minmax(0,1fr))}.ref-list{grid-template-columns:repeat(2,minmax(0,1fr))}}
.design-grid{display:grid;grid-template-columns:repeat(2,minmax(0,1fr));gap:12px;margin-top:16px}.design-ref{background:#f8fafc;border:1px solid #dce6f0;border-radius:12px;padding:14px;min-width:0}.design-ref h4{font-size:13px;color:#234261;margin:3px 0 7px}.design-ref p{font-size:11px;line-height:1.65;margin:4px 0;color:#6e8091}.design-ref .source{font-size:10px;letter-spacing:.02em;color:#587491}.design-ref a{font-size:11px;color:#315f91;text-decoration:none}.case-tags{font-size:10px;margin:11px 0 5px;color:#687d91}.case-tags a{color:#315f91}.case-small{border-left:2px solid #90abc9;margin-top:9px;padding-left:9px}.case-small p{margin:3px 0;font-size:10px;color:#72859a;line-height:1.55}@media(max-width:650px){.design-grid{grid-template-columns:1fr}}
</style>
</head>
<body>
<div id="researchNotice" style="padding:12px 18px;background:#e7eef6;color:#203f60;font:14px system-ui"></div>
<main class="container">
  <div class="top"><div class="brand"><div class="brandmark">◈</div>Design Logo Studio</div><span class="pill" id="roundTag">第 1 轮 · 6 个设计</span></div>
  <header><div class="mini-label">BRAND IDENTITY · DESIGN EXPLORATION</div><h1 id="projectTitle">品牌设计 · 六稿提案</h1><p class="subtitle">按品牌需求与所选风格探索视觉方向；所有未限定偏好均为无限制自由发挥。点击任意卡片进行选择；六款都不满意，可以留下意见，让 AI 在下一轮重新绘制。</p></header>
  <div class="brief"><b>设计方向</b><span id="briefText"></span></div>
  <div class="row"><div><h2>从六种设计思路中选择</h2><p>真实 SVG · 48px 小尺寸检查 · 浅色／深色预览</p></div><div style="font-size:12px;color:#8a98a8">快捷键 <span class="kbd">1</span> ～ <span class="kbd">6</span></div></div>
  <section class="grid" id="gallery" aria-label="Logo 候选方案"></section>
  <div class="actions"><button class="btn primary" id="chooseBtn" disabled>✓ 确认这一款</button><button class="btn" id="svgBtn" disabled>下载 SVG</button><button class="btn" id="pngBtn" disabled>下载透明 PNG</button><button class="btn subtle" id="regenBtn">↻ 六款都不喜欢，重新生成</button></div>
  <p class="selected-note" id="selectedNote">请选择一款 Logo。选择不会立即覆盖项目图标。</p>
  <section class="research-bank" id="designBank"><h3>品牌 Logo 案例研究</h3><p>案例只用于研究构图与品牌识别方法，版权仍归原权利人；这里仅提供摘要和原始项目链接，<strong>不代表获准下载或改编这些 Logo</strong>。</p><div class="design-grid" id="designGrid"></div><div class="muted-note" id="designBankNote"></div></section>
  <section class="research-bank" id="researchBank"><h3>本轮参考 SVG 素材</h3><p id="researchBankDesc">展示本轮参考图标的 SVG：已取得本地原件则内嵌；否则联网预览原始 SVG，断网可能无法显示。每个参考仍需独立核查授权。</p><div class="research-grid" id="researchGrid"></div><div class="muted-note" id="researchBankNote"></div></section>
  <section class="feedback" id="feedback"><h3>告诉 AI 下一轮怎么改</h3><p>勾选不满意的地方，可补充文字。点击生成指令后，把文字发回正在执行 design-logo 的 AI，它会画六个全新的 SVG 并更新此 HTML 文件。</p>
    <div class="checks">
      <label class="check"><input type="checkbox" value="太复杂，不够极简"/> 太复杂</label>
      <label class="check"><input type="checkbox" value="不够有辨识度，像常规 UI 图标"/> 不够独特</label>
      <label class="check"><input type="checkbox" value="科技感不够理性专业"/> 科技感不够</label>
      <label class="check"><input type="checkbox" value="配色不合适"/> 颜色不合适</label>
      <label class="check"><input type="checkbox" value="不喜欢六款当前的风格或造型"/> 风格或造型不喜欢</label>
      <label class="check"><input type="checkbox" value="业务语义不够明确"/> 功能表达不清楚</label>
    </div>
    <textarea id="feedbackText" placeholder="例如：整体过于像功能按钮；希望更偏数据流的抽象符号，线条更少、不要圆形外框。"></textarea>
    <div class="actions"><button class="btn primary" id="requestBtn">生成并复制重新设计指令</button><button class="btn" id="feedbackJsonBtn">下载反馈 JSON</button><button class="btn subtle" id="closeFeedbackBtn">收起</button></div>
    <p class="hint">本页面为离线 HTML，不直接调用 AI。复制指令并发给当前 AI 后，它会真正生成下一组六款；刷新 HTML 即可查看新稿。</p>
  </section>
  <section class="rights"><h4>素材与使用说明</h4><p>每张卡片均提供素材类型及来源信息。原创 SVG 和经许可二次创作的 SVG 应分别标明；商用许可不等于具有独占商标权。最终商标使用前请核查相似品牌。页面中的 PNG 下载为透明背景草稿；正式上架图需按平台规范处理背景和尺寸。</p></section>
</main>
<div class="modal" id="modal" role="dialog" aria-modal="true" aria-labelledby="modalTitle"><div class="dialog"><h3 id="modalTitle">确认设计</h3><p id="modalHelp"></p><pre id="modalText"></pre><div class="dialog-footer"><button class="btn" id="modalClose">关闭</button><button class="btn primary" id="modalCopy">复制指令</button></div></div></div>
<div class="toast" id="toast" role="status" aria-live="polite"></div>
<script>
'use strict';
const DATA=/*__GALLERY_DATA__*/ null;
const byId=id=>document.getElementById(id);
const key='design-logo:'+DATA.project+':'+DATA.round;
document.getElementById('researchNotice').textContent=DATA.demo?('⚠ 演示模式：未完成品牌案例或 SVG 的真实核查，不能视作正式商业品牌交付'+(DATA.researchSummary?.whyIncomplete?'。原因：'+DATA.researchSummary.whyIncomplete:'')):('✓ 已记录 '+(DATA.designReferences?.length||0)+' 个 Logo 案例和 '+DATA.researchSummary.count+' 个 SVG 素材；构建器校验声明与本地文件，不替代外部版权与商标调查');
const images=DATA.candidates.map(x=>({ ...x, image:'data:image/svg+xml;base64,'+x.svgBase64 }));
const researchIcons=(DATA.researchIcons||[]).map(x=>({...x,image:x.svgBase64?('data:image/svg+xml;base64,'+x.svgBase64):null,schematic:x.schematicBase64?('data:image/svg+xml;base64,'+x.schematicBase64):null}));
const researchMap=new Map(researchIcons.map(x=>[x.id,x]));
const designReferences=(DATA.designReferences||[]);
const designMap=new Map(designReferences.map(x=>[x.id,x]));
let stored=null;try{stored=localStorage.getItem(key)}catch{}
let selected=images.some(x=>x.id===stored)?stored:null;
let modalCopyText='';
let toastTimer;
function textEl(tag, cls, content){const e=document.createElement(tag);if(cls)e.className=cls;e.textContent=content;return e;}
function refCard(ref){const wrap=textEl('div','ref-card','');const prev=textEl('div','ref-preview','');if(ref?.image||ref?.remoteSvgUrl){const img=document.createElement('img');img.src=ref.image||ref.remoteSvgUrl;img.alt=ref.name||ref.id||'参考 SVG';img.loading='lazy';img.referrerPolicy='no-referrer';img.onerror=()=>{if(ref.schematic){img.src=ref.schematic;img.onerror=null;prev.append(textEl('div','ref-placeholder','原创结构示意 · 非源SVG'));}else{prev.replaceChildren(textEl('div','ref-placeholder','源SVG 加载失败 · 点击来源'));}};prev.append(img);}else{prev.append(textEl('div','ref-placeholder','未取得原始 SVG · 查看来源'));}if(!ref?.image){prev.title='仅在线引用，源 SVG 未下载及核验';}wrap.append(prev);const meta=textEl('div','ref-meta','');meta.append(textEl('span','',ref?.library||'参考素材'),textEl('span','',ref?.license||''));wrap.append(meta);wrap.append(textEl('div','ref-name',ref?.name||ref?.id||'未命名素材'));if(ref?.whyRelevant){wrap.append(textEl('div','ref-note',ref.whyRelevant));}const link=document.createElement('a');link.href=ref?.sourceUrl||'#';link.target='_blank';link.rel='noopener noreferrer';link.className='ref-link';link.textContent='查看来源';if(!ref?.sourceUrl) link.style.display='none';wrap.append(link);if(ref?.licenseUrl){const terms=document.createElement('a');terms.href=ref.licenseUrl;terms.target='_blank';terms.rel='noopener noreferrer';terms.className='ref-link';terms.textContent='查看许可证条款';wrap.append(terms);}return wrap;}
function toast(message){const t=byId('toast');t.textContent=message;t.classList.add('on');clearTimeout(toastTimer);toastTimer=setTimeout(()=>t.classList.remove('on'),3200);}
function caseLink(ref){const link=document.createElement('a');link.href=ref.sourceUrl;link.target='_blank';link.rel='noopener noreferrer';link.textContent='查看案例原文';return link}
function renderDesignBank(){
  const grid=byId('designGrid');grid.replaceChildren();
  for(const ref of designReferences){
    const card=textEl('article','design-ref','');card.append(textEl('div','source',ref.site+' · '+(ref.observedAt||'日期待核')));
    card.append(textEl('h4','',ref.title));card.append(textEl('p','','设计方法：'+ref.principle));
    card.append(textEl('p','','与品牌的关联：'+ref.whyRelevant));card.append(textEl('p','','避免照搬：'+ref.avoidCopying));card.append(caseLink(ref));grid.append(card);
  }
  byId('designBankNote').textContent=designReferences.length?('已记录 '+designReferences.length+' 个品牌案例；来源验证为执行 Agent 声明，构建器不具备独立网络审计能力。'):'暂无具体品牌案例研究记录（演示模式）。';
}
function renderResearchBank(){
  const grid=byId('researchGrid'); grid.replaceChildren();
  for(const ref of researchIcons){grid.append(refCard(ref));}
  byId('researchBankNote').textContent=researchIcons.length?('共展示 '+researchIcons.length+' 个参考素材；未下载的 SVG 会尝试联网预览，不表示原始文件已完成审核。'):'当前没有可展示的参考素材。';
}
function paint(){
  byId('projectTitle').textContent=DATA.project+' · 六稿提案';
  byId('roundTag').textContent='第 '+DATA.round+' 轮 · 6 个设计';
  byId('briefText').textContent=DATA.brief||'无限制自由发挥，按品牌需求探索不同风格';
  const target=byId('gallery');target.replaceChildren();
  for(const c of images){
    const card=textEl('article','logo-card'+(selected===c.id?' selected':''),'');card.setAttribute('tabindex','0');card.setAttribute('role','radio');card.setAttribute('aria-checked',selected===c.id?'true':'false');card.setAttribute('aria-label',c.id+'，'+c.title);card.addEventListener('click',()=>select(c.id));card.addEventListener('keydown',e=>{if(e.key==='Enter'||e.key===' '){e.preventDefault();select(c.id);}});
    const top=textEl('div','card-top','');top.append(textEl('span','letter',c.id),textEl('span','choose',''));card.append(top);
    const stage=textEl('div','stage','');const mainImg=document.createElement('img');mainImg.src=c.image;mainImg.alt=c.title;stage.append(mainImg);card.append(stage);
    const variants=textEl('div','variants','');for(const mode of ['light','dark']){const sw=textEl('div','swatch '+(mode==='dark'?'dark':''),'');const img=document.createElement('img');img.src=c.image;img.alt='';sw.append(img);variants.append(sw);}card.append(variants);
    card.append(textEl('div','small-note','48px · LIGHT / DARK'));
    const detail=textEl('div','detail',''),line=textEl('div','name','');line.append(textEl('h3','',c.title));const colors=textEl('div','colors','');for(const p of c.palette){const dot=document.createElement('i');dot.style.background=p;dot.title=p;colors.append(dot);}line.append(colors);detail.append(line,textEl('p','desc',c.concept),textEl('span','geom',c.geometry));
    const source=textEl('div','',c.sourceType==='original'?'原创矢量':('授权改造 · '+c.license));source.style='font-size:10px;color:#9aa8b6;margin-top:12px';detail.append(source); if(c.researchIds?.length){const provenance=textEl('div','','素材研究编号：'+c.researchIds.join('、'));provenance.style='font-size:10px;color:#64748b;margin-top:5px';detail.append(provenance); const refs=textEl('div','ref-list',''); for(const id of c.researchIds.slice(0,3)){const ref=researchMap.get(id); if(ref) refs.append(refCard(ref));} if(refs.childElementCount){detail.append(refs);} }
    if(c.designReferenceIds?.length){const box=textEl('div','case-small','');box.append(textEl('div','case-tags','设计方法参考（非素材授权）：'));for(const id of c.designReferenceIds){const r=designMap.get(id);if(r){const text=textEl('p','',r.site+' · '+r.title+'：'+r.principle+'；不复制：'+r.avoidCopying+' · ');text.append(caseLink(r));box.append(text);}}detail.append(box);}
    if(c.sourceUrl){const origin=document.createElement('a');origin.href=c.sourceUrl;origin.target='_blank';origin.rel='noopener noreferrer';origin.textContent='查看素材来源';origin.style='display:inline-block;margin-left:10px;font-size:10px;color:#4169a8';origin.addEventListener('click',e=>e.stopPropagation());detail.append(origin);}
    card.append(detail);target.append(card);
  }
  const chosen=images.find(x=>x.id===selected);for(const id of ['chooseBtn','svgBtn','pngBtn'])byId(id).disabled=!chosen;
  byId('selectedNote').textContent=chosen?('当前选择：'+chosen.id+' · '+chosen.title+'。可下载源文件，或确认后通知 AI 导出正式素材。'):'请选择一款 Logo。选择不会立即覆盖项目图标。';
  renderDesignBank();
  renderResearchBank();
}
function select(id){selected=id;try{localStorage.setItem(key,id)}catch{}paint();}
function showModal(title,help,body){modalCopyText=body;byId('modalTitle').textContent=title;byId('modalHelp').textContent=help;byId('modalText').textContent=body;byId('modal').classList.add('show');}
function closeModal(){byId('modal').classList.remove('show')}
async function copy(text){try{await navigator.clipboard.writeText(text);toast('已复制，粘贴给你的 AI Agent 即可');return true}catch{showModal('请手动复制以下内容','浏览器可能因为 file:// 协议限制剪贴板访问，请选中下方文本复制。',text);return false}}
function chosen(){return images.find(x=>x.id===selected)}
function confirmPrompt(){const c=chosen();return '执行 design-logo：我确认选择第 '+DATA.round+' 轮的 '+c.id+' 方案「'+c.title+'」。请读取这一轮 candidates.json 的 '+c.id+' 对应 SVG，导出正式 assets/icons 文件（SVG、单色、iOS/Android PNG、许可证），验证文件后交付。产品：'+DATA.project+'。不要使用其他轮次或方案。';}
function downloadBlob(blob,name){const url=URL.createObjectURL(blob);const a=document.createElement('a');a.href=url;a.download=name;document.body.append(a);a.click();a.remove();setTimeout(()=>URL.revokeObjectURL(url),1000);}
function svgString(c){const bytes=atob(c.svgBase64);const array=Uint8Array.from(bytes,ch=>ch.charCodeAt(0));return new TextDecoder().decode(array)}
function downloadSvg(){const c=chosen();if(!c)return;downloadBlob(new Blob([svgString(c)],{type:'image/svg+xml;charset=utf-8'}),DATA.project.replace(/[^a-zA-Z0-9_-]+/g,'-')+'-'+c.id+'.svg')}
async function downloadPng(){const c=chosen();if(!c)return;const img=new Image();img.src=c.image;try{await img.decode();const cv=document.createElement('canvas');cv.width=cv.height=1024;const ctx=cv.getContext('2d');ctx.clearRect(0,0,1024,1024);ctx.drawImage(img,0,0,1024,1024);cv.toBlob(blob=>{if(blob)downloadBlob(blob,'logo-'+c.id+'-transparent-1024.png');else toast('PNG 渲染失败，请先下载 SVG')},'image/png')}catch{toast('PNG 渲染失败，请先下载 SVG')}}
function feedbackPayload(){const reasons=[...document.querySelectorAll('.check input:checked')].map(x=>x.value);const note=byId('feedbackText').value.trim();return {type:'design-logo-regenerate',project:DATA.project,previousRound:DATA.round,nextRound:DATA.round+1,rejectedCandidates:images.map(x=>({id:x.id,title:x.title,geometry:x.geometry})),reasons,notes:note,requirements:['重新分析至少 4 个具体 Logo 案例并记录设计原则','重新构思六种不同轮廓的原创/获许可改造 SVG','不得只换色或微调旧稿','遵循用户已选风格和明确约束；未限定偏好无限制自由发挥，自由发挥时六稿覆盖至少四种视觉家族','保留前一轮文件，生成新 round 文件夹','重建同一个 gallery.html 并提供路径']}}
function feedbackPrompt(){const p=feedbackPayload();return ['执行 design-logo：我不满意第 '+p.previousRound+' 轮的六款设计。请基于以下反馈，真正重新绘制第 '+p.nextRound+' 轮的六款新 SVG。','产品：'+p.project,'不满意的原因：'+(p.reasons.length?p.reasons.join('；'):'未指定，请显著改变上一轮的整体构图'),'补充要求：'+(p.notes||'请优先提升差异化、简洁度和品牌感'),'上一轮方案：'+p.rejectedCandidates.map(x=>x.id+'='+x.title+'（'+x.geometry+'）').join('，'),'要求：先研究具体品牌案例与真实 SVG，记录来源、授权并关联 designReferenceIds/researchIds。六个新稿必须具有不同轮廓，不得仅换色；保留上一轮文件，写入 round-'+String(p.nextRound).padStart(2,'0')+'，更新同一个 gallery.html，最终给我 HTML 文件路径。'].join('\n')}
byId('chooseBtn').onclick=()=>showModal('确认选中方案','此步骤不会自动改写项目文件。复制下面指令，发给当前 AI Agent 完成正式导出。',confirmPrompt());
byId('svgBtn').onclick=downloadSvg;byId('pngBtn').onclick=downloadPng;
byId('regenBtn').onclick=()=>{byId('feedback').classList.add('show');byId('feedback').scrollIntoView({behavior:'smooth',block:'start'})};
byId('closeFeedbackBtn').onclick=()=>byId('feedback').classList.remove('show');
byId('requestBtn').onclick=async()=>{const str=feedbackPrompt();showModal('下一轮重新设计指令','点击复制后，把这段指令发送给 Agent；AI 收到之后才会真正生成第 '+(DATA.round+1)+' 轮六款。',str);await copy(str)};
byId('feedbackJsonBtn').onclick=()=>downloadBlob(new Blob([JSON.stringify(feedbackPayload(),null,2)],{type:'application/json'}),'feedback-round-'+String(DATA.round).padStart(2,'0')+'.json');
byId('modalClose').onclick=closeModal;byId('modalCopy').onclick=()=>copy(modalCopyText);byId('modal').onclick=e=>{if(e.target===byId('modal'))closeModal()};
document.addEventListener('keydown',e=>{if(e.key==='Escape')closeModal();if(!['TEXTAREA','INPUT'].includes(document.activeElement.tagName)&&/^[1-6]$/.test(e.key))select('ABCDEF'[Number(e.key)-1])});
paint();
</script>
</body>
</html>`}
main().catch(err=>{console.error('生成失败:',err.message);process.exitCode=1});

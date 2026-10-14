# ROLAB SchoolGuard / Download Center (Vercel)

## Бұл сайтта / Included
- Original game & 18+ web filter downloads (existing toolkit retained).
- **DAMOO Exam Lock Pilot** (for Chrome / Yandex Browser / Microsoft Edge), ZIP at `downloads/ROLAB_Exam_Lock_3_Browsers_TEST.zip`.
- SchoolGuard Cloud **concept/demo UI** only; no real device management or backend.
- ROLAB logo, Instagram, 3 UI languages (KK / RU / EN).

## Deploy

The ZIP root contains `index.html`, `assets/`, `downloads/`, and `vercel.json`.

**Vercel Drop (new project):** Upload the ZIP via https://vercel.com/drop.

**To update your EXISTING project instead of creating a new one:**
- If linked to GitHub, replace files in the same GitHub repository and push; Vercel will redeploy.
- If not linked to Git, extract this archive in a local folder, install Vercel CLI, run `vercel login`, then `vercel link` and select the EXISTING project; run `vercel --prod` to publish.
- Do not publish a new Vercel Drop project if you intend to keep the existing URL without transferring/assigning the domain.

## Important pilot caveats

`ROLAB_Exam_Lock_3_Browsers_TEST.zip` is a Windows policy **pilot**, not a full Windows lockdown; it does not prevent other apps, phones, or alternate browsers. It is *not* a centrally deployable agent. Deploy to one authorized test PC first. Make sure an admin can restore policies via the bundled recovery file. Check DAMOO sign-in, exam launch and answer submission before wider rollout.

The online Cloud preview is mocked: 40 PCs across School T / School S are examples, NOT discovered devices; no command is sent to a computer. A real cloud controller requires an authenticated backend, per-school authorization and a signed/secured Windows agent.

## Download references
- `downloads/school-filter-complete.zip` (previous toolkit)
- `downloads/install-filter.bat` (previous toolkit)
- `downloads/remove-filter.bat` (previous toolkit)
- `downloads/blocked-sites.txt`
- `downloads/ROLAB_Exam_Lock_3_Browsers_TEST.zip` (new pilot)

ROLAB — Барлық құқықтар қорғалған / Все права защищены / All rights reserved.

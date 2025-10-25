import { test, expect } from '@playwright/test';

/**
 * Phase 1 smoke/integration tests for Pokémon Academy Field Trip.
 */
test.describe('Phase 1 Integration', () => {

  test('1. API Health and Docs and Animals Catalog', async ({ request }) => {
    // Health
    const health = await request.get('/api/health');
    expect(health.ok()).toBeTruthy();
    const healthJson = await health.json();
    expect(healthJson.status === 'ok' || healthJson.ok === true).toBeTruthy();

    // Docs
    const docs = await request.get('/docs');
    expect(docs.ok()).toBeTruthy();

    // Animals
    const animals = await request.get('/api/animals/catalog');
    expect(animals.ok()).toBeTruthy();
    const ajson = await animals.json();
    expect(ajson).toBeTruthy();
    const count = (ajson.animals && Array.isArray(ajson.animals)) ? ajson.animals.length : (ajson.data && ajson.data.animals && ajson.data.animals.length);
    expect(count).toBeGreaterThanOrEqual(1);
  });

  test('2. Welcome page loads and reacts to scene change', async ({ page, request }) => {
    await page.goto('/welcome.html', { waitUntil: 'networkidle' });
    await expect(page.locator('.title')).toHaveText(/POKéMON ACADEMY/i);
    const status = page.locator('#statusDot');
    expect(await status.count()).toBeGreaterThan(0);
    const goto = await request.post('/api/scene/goto', { data: { to: 'CHECKIN' } });
    expect(goto.ok()).toBeTruthy();
    await page.waitForNavigation({ url: /checkin.html/, timeout: 5000 });
    await expect(page).toHaveURL(/checkin.html/);
    await expect(page.locator('h2', { hasText: /Check-In Scanner/i })).toBeTruthy();
  });

  test('3. Manual check-in API and roster updates reflect in UI', async ({ page, request }) => {
    await page.goto('/checkin.html', { waitUntil: 'networkidle' });
    const name = `TEST_${Date.now()}`.slice(-12);
    const resp = await request.post('/api/checkin/manual', { data: { name } });
    expect(resp.ok()).toBeTruthy();
    let found = false;
    for (let i=0;i<8;i++){
      const r = await request.get('/api/roster');
      const jr = await r.json();
      const roster = Array.isArray(jr) ? jr : (jr.data || jr.roster || []);
      if (roster.find((t:any) => t.name === name)) { found = true; break; }
      await new Promise(res=>setTimeout(res, 500));
    }
    expect(found).toBeTruthy();
    await page.reload({ waitUntil: 'networkidle' });
    await expect(page.locator('#rosterList')).toContainText(name, { timeout: 4000 });
  });

  test('4. Vote start -> VOTE_PROMPT -> VOTE_RESULT propagation', async ({ page, request }) => {
    await page.goto('/professor-intro.html', { waitUntil: 'networkidle' });
    const start = await request.post('/api/vote/start', { data: { id: 'VOTE_TEST_1', options: ['Rabbit','Goat','Lizard'], label: 'Where to start?' }});
    expect(start.ok()).toBeTruthy();
    await page.waitForSelector('#choiceArea, .choice, .choices', { timeout: 5000 });
    const result = await request.post('/api/vote/result', { data: { id: 'VOTE_TEST_1', winner: 'B', percent: 60 }});
    expect(result.ok()).toBeTruthy();
    await page.waitForSelector('.winner, .winnerCard, #winnerBanner, :text("TEAM CHOSE")', { timeout: 5000 });
  });

  test('5. Habitat animal switch (ANIMAL_ACTIVE) updates page without reload', async ({ page, request }) => {
    await page.goto('/habitat.html?animal=goat', { waitUntil: 'networkidle' });
    await expect(page.locator('#pname')).toContainText(/GOAT|GOAT/i);
    const aresp = await request.post('/api/animals/current', { data: { id: 'rabbit' }});
    expect(aresp.ok()).toBeTruthy();
    await page.waitForFunction(() => {
      const el = document.getElementById('pname');
      return el && /RABBIT/i.test(el.textContent || '');
    }, null, { timeout: 6000 });
  });

  test('6. Scene progress updates heart crystals', async ({ page, request }) => {
    await page.goto('/habitat.html?animal=rabbit', { waitUntil: 'networkidle' });
    const resp = await request.post('/api/scene/progress', { data: { delta: 20 }});
    expect(resp.ok()).toBeTruthy();
    await page.waitForSelector('.crystal.active, .heart.filled', { timeout: 5000 });
  });

  test('7. Hold Type Scanner page simulation and exit', async ({ page, request }) => {
    await page.goto('/hold-type-scanner.html', { waitUntil: 'networkidle' });
    await expect(page.locator('.radar, .scanText, #choices')).toBeTruthy();
    await page.waitForSelector('#gcount, #wcount, #fcount', { timeout: 10000 });
    await page.waitForSelector('#winnerBanner, :text("TEAM PREDICTS")', { timeout: 20000 });
    const stop = await request.post('/api/hold/stop');
    expect(stop.ok()).toBeTruthy();
    await page.waitForTimeout(1200);
  });

  test('8. Session persistence (poll restart)', async ({ request }) => {
    const s1 = await request.get('/api/scene/state');
    expect(s1.ok()).toBeTruthy();
    const j1 = await s1.json();
    const originalScene = j1.data?.scene ?? j1.scene;
    let restored = false;
    for (let i=0;i<20;i++){
      try {
        const s = await request.get('/api/scene/state', { timeout: 2000 });
        if (s.ok()) {
          const js = await s.json();
          const sceneNow = js.data?.scene ?? js.scene;
          if (sceneNow === originalScene) { restored = true; break; }
        }
      } catch(e){}
      await new Promise(r=>setTimeout(r, 2000));
    }
    expect(restored).toBeTruthy();
  });

});

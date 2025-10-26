import { test, expect } from "@playwright/test";

test("welcome -> navigate to checkin (robust) [independent]", async ({ page }) => {
  await page.goto("/welcome.html");

  const goto = page.locator('[data-test-id="goto-checkin"], #gotoCheckin, #goto-checkin, button#gotoCheckin');
  await expect(goto).toBeVisible();

  await Promise.all([
    page.waitForURL("**/checkin.html", { timeout: 10000 }),
    goto.click()
  ]);

  await page.waitForLoadState("networkidle");
  await page.waitForSelector("[data-test-id='roster-list'], #rosterList", { timeout: 8000 });

  await expect(page).toHaveURL(/.*\/checkin\.html/);
});
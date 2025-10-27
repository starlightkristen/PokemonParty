import { test, expect } from "@playwright/test";

test("welcome -> navigate to checkin", async ({ page }) => {
  await page.goto("/welcome.html");

  const goto = page.locator("[data-test-id=\"goto-checkin\"], #gotoCheckin, #goto-checkin, button#gotoCheckin");
  await expect(goto).toBeVisible();

  await Promise.all([
    page.waitForURL("**/checkin.html", { timeout: 7000 }),
    goto.click()
  ]);

  await expect(page).toHaveURL(/.*\/checkin\.html/);
  await expect(page.locator("[data-test-id=\"roster-list\"], #rosterList")).toBeVisible();
});

import { test, expect } from "@playwright/test";

test("hold scanner shows winner (robust) [independent]", async ({ page }) => {
  await page.goto("/hold-scanner.html");

  await page.waitForLoadState("networkidle");
  await page.waitForSelector("[data-test-id='gcount'], #gcount", { timeout: 8000 });

  const winnerLocator = page.locator("text=/TEAM PREDICTS|WINNER:/i");
  await winnerLocator.waitFor({ timeout: 8000 });
  await expect(winnerLocator).toBeVisible();

  const g = await page.locator("[data-test-id='gcount'], #gcount").innerText();
  expect(g).toMatch(/^\d+$/);
});
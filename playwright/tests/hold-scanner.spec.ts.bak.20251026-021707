import { test, expect } from "@playwright/test";

test("hold scanner shows winner", async ({ page }) => {
  await page.goto("/hold-scanner.html");

  await expect(page.locator("[data-test-id=\"gcount\"], #gcount")).toBeVisible({ timeout: 7000 });

  const winnerLocator = page.locator("text=/TEAM PREDICTS|WINNER:/i");
  await expect(winnerLocator).toBeVisible({ timeout: 7000 });

  const g = await page.locator("[data-test-id=\"gcount\"], #gcount").innerText();
  expect(g).toMatch(/^\d+$/);
});

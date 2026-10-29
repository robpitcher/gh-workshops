<script setup>
import { computed } from 'vue'
import { useNav, useSlideContext } from '@slidev/client'

const { $page, $frontmatter } = useSlideContext()
const { total } = useNav()
const show = computed(() => $page.value > 1)
</script>

<template>
  <div v-if="show" class="gh-footer">
    <div class="gh-footer-inner">
      <div class="gh-footer-left">
        <span class="gh-footer-title">{{ $frontmatter?.ghFooterTitle || 'GitHub Workshop' }}</span>
        <span class="gh-footer-dot">·</span>
        <span v-if="$frontmatter?.ghFooterLabel" class="gh-footer-label">{{ $frontmatter.ghFooterLabel }}</span>
      </div>
      <div class="gh-footer-page">{{ $page }} / {{ total }}</div>
    </div>
    <div class="gh-footer-bar" />
  </div>
</template>

<style>
.gh-footer {
  position: fixed;
  bottom: 0;
  left: 0;
  right: 0;
  z-index: 100;
  pointer-events: none;
}

.gh-footer-inner {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 48px 10px;
}

.gh-footer-left {
  display: flex;
  align-items: center;
  gap: 8px;
}

.gh-footer-title {
  font-size: 11px;
  font-weight: 500;
  color: #30363d;
  font-family: -apple-system,BlinkMacSystemFont,Segoe UI,Helvetica,Arial,sans-serif;
  letter-spacing: .02em;
}

.gh-footer-dot {
  color: #21262d;
  font-size: 11px;
}

.gh-footer-label {
  font-size: 10px;
  color: #30363d;
  font-family: -apple-system,BlinkMacSystemFont,Segoe UI,Helvetica,Arial,sans-serif;
  text-transform: uppercase;
  letter-spacing: .06em;
}

.gh-footer-page {
  font-size: 11px;
  font-weight: 500;
  color: #30363d;
  font-family: ui-monospace,SFMono-Regular,SF Mono,Menlo,Consolas,monospace;
  letter-spacing: .04em;
}

.gh-footer-bar {
  height: 2px;
  background: linear-gradient(90deg,#58a6ff,#a371f7,#8b5cf6);
  opacity: .6;
}
</style>

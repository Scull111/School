/* ==========================================================================
   Scroll Reveal — IntersectionObserver with staggered children
   ========================================================================== */

/**
 * Reads data-stagger attribute and writes --stagger CSS variable so that
 * CSS can apply transition-delay: calc(var(--stagger) * 75ms).
 */
function initStaggerVars() {
  document.querySelectorAll('[data-stagger]').forEach((el) => {
    el.style.setProperty('--stagger', el.dataset.stagger);
  });
}

/**
 * Watches all .reveal elements and adds .visible when they enter the viewport.
 * Threshold 0.12 means the animation fires when ~12% of the element is visible.
 */
function initScrollReveal() {
  const observer = new IntersectionObserver(
    (entries) => {
      entries.forEach((entry) => {
        if (entry.isIntersecting) {
          entry.target.classList.add('visible');
          // Unobserve after reveal so the animation doesn't re-trigger on scroll-up
          observer.unobserve(entry.target);
        }
      });
    },
    { threshold: 0.12, rootMargin: '0px 0px -40px 0px' }
  );

  document.querySelectorAll('.reveal').forEach((el) => observer.observe(el));
}


/* ==========================================================================
   Spotlight Card Effect
   Updates --mouse-x / --mouse-y CSS variables on each .spotlight-card so
   the ::after radial gradient follows the cursor inside the card.
   ========================================================================== */
function initSpotlightCards() {
  const cards = document.querySelectorAll('.spotlight-card');

  cards.forEach((card) => {
    card.addEventListener('mousemove', (e) => {
      const rect = card.getBoundingClientRect();
      const x = ((e.clientX - rect.left) / rect.width) * 100;
      const y = ((e.clientY - rect.top) / rect.height) * 100;
      card.style.setProperty('--mouse-x', `${x}%`);
      card.style.setProperty('--mouse-y', `${y}%`);
    });

    // Reset position when the cursor leaves
    card.addEventListener('mouseleave', () => {
      card.style.setProperty('--mouse-x', '50%');
      card.style.setProperty('--mouse-y', '50%');
    });
  });
}


/* ==========================================================================
   Hero Card — subtle 3D tilt following the cursor
   Uses transform only (hardware-accelerated), respects prefers-reduced-motion
   ========================================================================== */
function initHeroTilt() {
  const prefersReduced = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
  if (prefersReduced) return;

  const card = document.getElementById('hero-card');
  if (!card) return;

  const MAX_TILT = 8; // degrees

  card.addEventListener('mousemove', (e) => {
    const rect = card.getBoundingClientRect();
    // Normalise to -1 … +1
    const cx = ((e.clientX - rect.left) / rect.width - 0.5) * 2;
    const cy = ((e.clientY - rect.top) / rect.height - 0.5) * 2;

    const rotateY = cx * MAX_TILT;
    const rotateX = -cy * MAX_TILT;

    card.style.transform = `perspective(600px) rotateX(${rotateX}deg) rotateY(${rotateY}deg) scale(1.02)`;
  });

  card.addEventListener('mouseleave', () => {
    // Spring back — CSS transition handles the easing
    card.style.transform = '';
  });
}


/* ==========================================================================
   Nav — add shadow + slightly increase opacity on scroll
   ========================================================================== */
function initNavScroll() {
  const nav = document.querySelector('.nav');
  if (!nav) return;

  const handler = () => {
    if (window.scrollY > 20) {
      nav.style.boxShadow = '0 1px 24px rgba(0,0,0,0.35)';
      nav.style.background = 'rgba(14, 14, 14, 0.96)';
    } else {
      nav.style.boxShadow = '';
      nav.style.background = 'rgba(14, 14, 14, 0.88)';
    }
  };

  window.addEventListener('scroll', handler, { passive: true });
}


/* ==========================================================================
   Feature card — staggered entrance already handled by CSS --stagger var.
   This helper nudges sibling cards inside the bento so they each reveal
   in reading order (left-to-right, top-to-bottom) on scroll entry.
   ========================================================================== */
function initFeatureBentoStagger() {
  const grid = document.querySelector('.features__grid');
  if (!grid) return;

  const observer = new IntersectionObserver(
    (entries) => {
      entries.forEach((entry) => {
        if (entry.isIntersecting) {
          // Stagger all children sequentially when the grid enters view
          grid.querySelectorAll('.feature-card').forEach((card, i) => {
            card.style.setProperty('--stagger', String(i));
          });
          observer.unobserve(grid);
        }
      });
    },
    { threshold: 0.05 }
  );

  observer.observe(grid);
}


/* ==========================================================================
   Smooth anchor scroll — override browser default for internal links
   ========================================================================== */
function initSmoothAnchors() {
  document.querySelectorAll('a[href^="#"]').forEach((link) => {
    link.addEventListener('click', (e) => {
      const target = document.querySelector(link.getAttribute('href'));
      if (!target) return;
      e.preventDefault();
      target.scrollIntoView({ behavior: 'smooth', block: 'start' });
    });
  });
}


/* ==========================================================================
   Boot
   ========================================================================== */
document.addEventListener('DOMContentLoaded', () => {
  initStaggerVars();
  initScrollReveal();
  initSpotlightCards();
  initHeroTilt();
  initNavScroll();
  initFeatureBentoStagger();
  initSmoothAnchors();
});

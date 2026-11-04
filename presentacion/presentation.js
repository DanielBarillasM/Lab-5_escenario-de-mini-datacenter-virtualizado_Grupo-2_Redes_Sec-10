(() => {
  const slides = [...document.querySelectorAll('.slide')];
  const output = document.querySelector('nav output');
  const progress = document.querySelector('.progress span');
  let current = Math.max(0, Math.min(slides.length - 1, Number(location.hash.slice(1) || 1) - 1));
  let touchStart = null;

  const render = () => {
    slides.forEach((slide, index) => {
      const active = index === current;
      slide.classList.toggle('active', active);
      slide.setAttribute('aria-hidden', String(!active));
    });
    output.value = `${current + 1} / ${slides.length}`;
    progress.style.width = `${((current + 1) / slides.length) * 100}%`;
    document.title = `${slides[current].dataset.title} - Laboratorio 5`;
    history.replaceState(null, '', `#${current + 1}`);
  };

  const go = (index) => {
    current = Math.max(0, Math.min(slides.length - 1, index));
    render();
  };

  document.querySelector('[data-action="prev"]').addEventListener('click', () => go(current - 1));
  document.querySelector('[data-action="next"]').addEventListener('click', () => go(current + 1));

  document.addEventListener('keydown', async (event) => {
    if (['ArrowRight', 'PageDown', ' '].includes(event.key)) {
      event.preventDefault();
      go(current + 1);
    } else if (['ArrowLeft', 'PageUp'].includes(event.key)) {
      event.preventDefault();
      go(current - 1);
    } else if (event.key === 'Home') {
      go(0);
    } else if (event.key === 'End') {
      go(slides.length - 1);
    } else if (event.key.toLowerCase() === 'f') {
      if (!document.fullscreenElement) await document.documentElement.requestFullscreen();
      else await document.exitFullscreen();
    } else if (event.key.toLowerCase() === 'p') {
      window.print();
    }
  });

  document.addEventListener('touchstart', (event) => {
    touchStart = event.changedTouches[0].clientX;
  }, { passive: true });

  document.addEventListener('touchend', (event) => {
    if (touchStart === null) return;
    const delta = event.changedTouches[0].clientX - touchStart;
    if (Math.abs(delta) > 50) go(current + (delta < 0 ? 1 : -1));
    touchStart = null;
  }, { passive: true });

  render();
})();

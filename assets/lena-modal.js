/*
  LenaModal - the shared behaviour behind both Lena dialogs.

  WHY THIS FILE EXISTS

  The newsletter popup (sections/lena-email-popup.liquid) and the Notify Me dialog
  (snippets/lena-notify-modal.liquid) each carried their own copy of the same ~57 lines:
  the focusable-element query, isOpen, trapTab, takeFocus, releaseFocus, the show/hide
  display toggling, the body scroll lock, and the close-button / backdrop / Escape
  wiring. The copies were identical character for character, including the comment
  explaining why the focus trap was added. Two copies of an accessibility fix is two
  places for it to be half-removed.

  AND ONE BUG THE DUPLICATION CAUSED

  Both copies wrote document.body.style.overflow directly. If both dialogs were ever open
  at once - the popup fires on a timer and on exit intent, so it can land on top of an
  open Notify Me dialog - whichever closed FIRST reset the body to scrollable while the
  other was still on screen. The page scrolled behind an open modal.

  The lock is now a count, held here and shared by every dialog on the page. The body is
  only released when the last open dialog closes. That is the whole reason this is one
  module rather than one copied function.

  WHAT STAYS WITH EACH DIALOG

  Only what is genuinely different: the popup's once-per-visit rules and localStorage
  keys, its delay and exit-intent triggers, and the Notify dialog's category fields and
  window.lenaNotify entry point. Anything shared belongs here instead.

  USAGE

    var modal = LenaModal.create(overlayElement, { onClose: fn });
    modal.open();  modal.close();  modal.isOpen();

  create() returns null if the element is missing, so a caller can bail out on one line.
  onClose is optional and runs after the dialog is hidden.

  LOADING ORDER: loaded with defer from the <head>, so it is ready before DOMContentLoaded.
  Both callers run their own setup inside a DOMContentLoaded listener for that reason - an
  inline script in the body would otherwise run before this file had executed.
*/
window.LenaModal = (function () {
  'use strict';

  // Shared across every dialog on the page. See the note above about why this cannot
  // live inside create().
  var openCount = 0;

  function lockScroll() {
    openCount += 1;
    document.body.style.overflow = 'hidden';
  }

  function unlockScroll() {
    openCount = Math.max(0, openCount - 1);
    if (openCount === 0) {
      document.body.style.overflow = '';
    }
  }

  function create(overlay, options) {
    if (!overlay) return null;
    options = options || {};

    var lastFocus = null;

    // Both overlays declare role="dialog" aria-modal="true", which tells assistive
    // technology the rest of the page is inert. Without a trap, focus stayed behind the
    // dialog and Tab walked out into the page underneath - content the page had just
    // declared did not exist. body overflow:hidden stops the mouse scrolling, not the
    // keyboard.
    function focusable() {
      return overlay.querySelectorAll(
        'button:not([disabled]), [href], input:not([type="hidden"]), select, textarea, [tabindex]:not([tabindex="-1"])'
      );
    }

    function isOpen() {
      return overlay.style.display !== 'none';
    }

    function trapTab(e) {
      if (e.key !== 'Tab') return;
      var f = focusable();
      if (!f.length) return;
      var first = f[0];
      var last = f[f.length - 1];
      if (e.shiftKey && document.activeElement === first) {
        e.preventDefault();
        last.focus();
      } else if (!e.shiftKey && document.activeElement === last) {
        e.preventDefault();
        first.focus();
      }
    }

    function takeFocus() {
      lastFocus = document.activeElement;
      document.addEventListener('keydown', trapTab);
      var target =
        overlay.querySelector('input[type="email"]') || overlay.querySelector('.lena-popup-close');
      if (target) target.focus();
    }

    function releaseFocus() {
      document.removeEventListener('keydown', trapTab);
      if (lastFocus && typeof lastFocus.focus === 'function') lastFocus.focus();
      lastFocus = null;
    }

    function open() {
      if (isOpen()) return;
      overlay.style.display = '';
      lockScroll();
      takeFocus();
    }

    function close() {
      if (!isOpen()) return;
      overlay.style.display = 'none';
      unlockScroll();
      releaseFocus();
      if (typeof options.onClose === 'function') options.onClose();
    }

    var closeBtn = overlay.querySelector('.lena-popup-close');
    if (closeBtn) closeBtn.addEventListener('click', close);

    overlay.addEventListener('click', function (e) {
      if (e.target === overlay) close();
    });

    // Guarded on isOpen: this listener lives for the life of the page, so unguarded it
    // would run on every Escape whether or not the dialog was on screen.
    document.addEventListener('keyup', function (e) {
      if (e.key === 'Escape' && isOpen()) close();
    });

    return { open: open, close: close, isOpen: isOpen, overlay: overlay };
  }

  return { create: create };
})();

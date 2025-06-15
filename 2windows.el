;; 2windows.el - Convenient 2 window creation and reorientation system for GNU Emacs.
;; Copyright (C) 2023-2025 Soumendra Ganguly

;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;; Dependencies: ace-window

(defun sgang-window-is-vertical ()
  "Check if selected window is a vertically
oriented window"
  (interactive)
  (window-full-height-p))

(defun sgang-window-is-horizontal ()
  "Check if selected window is a horizontally
oriented window"
  (interactive)
  (not (window-full-height-p)))

(defun sgang-window-is-left-internal ()
  "Helper function for sgang-window-is-left
and sgang-window-is-right"
  (interactive)
  (let ((current-edge (car (window-edges (selected-window))))
	(other-edge (car (window-edges (next-window)))))
    (<= current-edge other-edge)))

(defun sgang-window-is-left ()
  "Assuming that there are only 2 windows,
return t iff the selected window is vertically
oriented and is the left one; return nil
otherwise"
  (interactive)
  (and (sgang-window-is-vertical)
       (sgang-window-is-left-internal)))

(defun sgang-window-is-right ()
  "Assuming that there are only 2 windows,
return t iff the selected window is vertically
oriented and is the right one; return nil
otherwise"
  (interactive)
  (and (sgang-window-is-vertical)
       (not (sgang-window-is-left-internal))))

(defun sgang-window-is-top-internal ()
  "Helper function for sgang-window-is-top
and sgang-window-is-bottom"
  (interactive)
  (let ((current-top-edge (nth 1 (window-edges (selected-window))))
	(other-top-edge (nth 1 (window-edges (next-window)))))
    (<= current-top-edge other-top-edge)))

(defun sgang-window-is-top ()
  "Assuming that there are only 2 windows,
return t iff the selected window is horizontally
oriented and is the top one; return nil
otherwise"
  (interactive)
  (and (sgang-window-is-horizontal)
       (sgang-window-is-top-internal)))

(defun sgang-window-is-bottom ()
  "Assuming that there are only 2 windows,
return t iff the selected window is horizontally
oriented and is the bottom one; return nil
otherwise"
  (interactive)
  (and (sgang-window-is-horizontal)
       (not (sgang-window-is-top-internal))))

(defun sgang-2-window-reorient ()
  "If current window is:
1. left window: change from vertical to horizontal
   orientation with current window on top
2. top window: swap places with the bottom window
3. bottom window: change from horizontal to vertical
   orientation with current window on right
4. right window: swap places with the left window

In other words, cycle left -> top -> bottom -> right -> left"
  (interactive)
  (if (or (sgang-window-is-top) (sgang-window-is-right))
      ;; started with top or right window
      (ace-swap-window)
    ;; started with left or bottom window
    (let (window-was-vertical other-window-buffer)
      (setq window-was-vertical (sgang-window-is-vertical))
      (setq other-window-buffer (window-buffer (next-window)))
      (delete-other-windows)
      (if window-was-vertical
	  ;; started with left window
	  (split-window-below)
	;; started with bottom window
	(split-window-right))
      (set-window-buffer (next-window) other-window-buffer)
      (if (not window-was-vertical) ; started with bottom window
	  (ace-swap-window)))))

(defun sgang-2-window-delete-others ()
  "use ace-window to select two windows and delete all others;
the 2 windows will be (re)oriented vertically, and the window
that was selected first will be focused and will be on the left;
the two windows are allowed to be the same window"
  (interactive)
  (let (win1 win2 win2buf)
    ;; select the first window
    (message "select the first window")
    (setq win1 (ace-window 1))
    (unless win1 (error "aborting: first window not selected"))
    ;; select the second window
    (message "select the second window")
    (setq win2 (ace-window 1))
    (unless win2 (error "aborting: second window not selected"))
    (setq win2buf (window-buffer win2))
    ;; delete all windows except for the two selected ones
    (delete-other-windows win1)
    (split-window-right)
    (set-window-buffer (next-window) win2buf)))

(defun sgang-2windows ()
  "If there is only 1 window, then create a new window
to the right; if there are 2 windows, then call
sgang-2-window-reorient; if there are > 2 windows,
then call sgang-2-window-delete-others."
  (interactive)
  (cond ((eq (count-windows) 1) (split-window-right))
	((eq (count-windows) 2) (sgang-2-window-reorient))
	(t (sgang-2-window-delete-others))))

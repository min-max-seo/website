# ---------------------------------------------------------------
# add_photos.R
#
# Shrinks NEW photos and copies them into your website's photo
# folder. Safe to run as many times as you like: anything already
# in the destination is skipped, never re-compressed.
#
# HOW TO USE
#   1. Drop your new full-size photos into the staging folder
#      set below (keep it OUTSIDE the website folder).
#   2. Open website.Rproj in RStudio.
#   3. In the Console:   source("add_photos.R")
#   4. It prints ready-to-paste markdown lines at the end.
# ---------------------------------------------------------------

library(magick)

# --- CHECK THESE TWO LINES -------------------------------------

# Where you put the new, full-size photos. Must be outside the
# website folder, or Quarto will publish the big versions too.
staging_dir <- "C:/Users/mseo0/OneDrive/System Folders/Desktop/new_photos"

# The folder your website actually reads from. If you renamed
# photos_small back to photos, leave this as "photos".
# If the site still points at photos_small, change it.
live_dir <- "photos"

# ---------------------------------------------------------------

max_side <- 1200   # longest edge in pixels
quality  <- 78     # 1-100; below ~70 you start to see it

if (!dir.exists(staging_dir)) {
  stop("Staging folder not found:\n  ", staging_dir,
       "\nCreate it, or fix the path above.")
}

files <- list.files(staging_dir, pattern = "\\.(jpe?g|png)$",
                    full.names = TRUE, ignore.case = TRUE)

if (length(files) == 0) stop("No images found in:\n  ", staging_dir)

dir.create(live_dir, showWarnings = FALSE)

added <- character(0)

for (f in files) {
  out <- file.path(live_dir, basename(f))

  if (file.exists(out)) {
    cat("skipped (already on the site):", basename(f), "\n")
    next
  }

  img  <- image_orient(image_read(f))          # fixes sideways phone photos
  info <- image_info(img)

  if (max(info$width, info$height) > max_side) {
    img <- image_scale(img, paste0(max_side, "x", max_side))
  }

  image_write(image_strip(img), out, quality = quality)   # strip = removes GPS/EXIF

  cat(sprintf("added: %-32s %6.0f KB -> %5.0f KB\n",
              basename(f), file.size(f) / 1e3, file.size(out) / 1e3))

  added <- c(added, basename(out))
}

if (length(added) > 0) {
  cat("\n--- Paste into gal.qmd, then edit the captions and groups ---\n\n")
  for (a in added) {
    cat(sprintf('![CAPTION HERE](%s/%s){group="daily" loading="lazy"}\n\n',
                live_dir, a))
  }
  cat("Groups in use: family, daily, academic, music, pets, food\n")
} else {
  cat("\nNothing new to add.\n")
}

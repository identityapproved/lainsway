--- raw.yazi — preview CR2 / odd-photometric TIFF in yazi.
--- yazi's builtin image decoder can't handle CR2 (TIFF-based, "unknown
--- photometric interpretation") or some TIFFs. This decodes them to a cached
--- image, then lets yazi's normal adapter (foot sixel) draw it.
---
--- Deps: dcraw (embedded-JPEG extract, fast), imagemagick `magick` (fallback /
--- TIFF). No chafa needed.

local M = {}

-- shell-quote a path for `sh -c`
function M.q(s)
	return "'" .. s:gsub("'", [['\'']]) .. "'"
end

function M.filled(path)
	local cha = fs.cha(Url(path))
	return cha ~= nil and cha.len > 0
end

function M.cached(url)
	local cha = fs.cha(url)
	return cha ~= nil and cha.len > 0
end

-- run `sh -c "<cmd> > dst"`, return true if dst ends up non-empty
function M.sh_to(cmd, src, dst)
	local full = string.format("%s > %s 2>/dev/null", string.format(cmd, M.q(src)), M.q(dst))
	local out = Command("sh"):arg({ "-c", full }):output()
	return out ~= nil and out.status.success and M.filled(dst)
end

-- CR2/RAW: pull the embedded JPEG preview straight out (no demosaic = fast).
-- NOTE: this dcraw build rejects `--`, so don't pass it.
function M.via_dcraw(src, dst)
	return M.sh_to("dcraw -e -c %s", src, dst)
end

-- exiftool fallback: extract the largest embedded preview JPEG
function M.via_exiftool(src, dst)
	return M.sh_to("exiftool -b -JpgFromRaw %s", src, dst)
		or M.sh_to("exiftool -b -PreviewImage %s", src, dst)
end

-- generic TIFF (and last resort): full decode via ImageMagick to PNG
function M.via_magick(src, dst)
	local out = Command("magick")
		:arg({ src, "-auto-orient", "-quality", "80", "png:" .. dst })
		:stdout(Command.PIPED)
		:stderr(Command.PIPED)
		:output()
	return out ~= nil and out.status.success and M.filled(dst)
end

function M.convert(job, cache)
	local src = tostring(job.file.url)
	local dst = tostring(cache)
	local ext = (src:match("%.([%a%d]+)$") or ""):lower()

	if ext == "tif" or ext == "tiff" then
		return M.via_magick(src, dst)
	end
	-- RAW: embedded-JPEG extract first (fast), then exiftool, then full decode
	return M.via_dcraw(src, dst) or M.via_exiftool(src, dst) or M.via_magick(src, dst)
end

function M:peek(job)
	local cache = ya.file_cache(job)
	if not cache then
		return ya.preview_widget(job, ui.Text("No cache available"):area(job.area))
	end

	if not M.cached(cache) and not M.convert(job, cache) then
		return ya.preview_widget(job, ui.Text("Failed to decode RAW/TIFF"):area(job.area))
	end

	ya.image_show(cache, job.area)
	ya.preview_widget(job, {})
end

function M:seek() end

-- Build the cache ahead of time so peek is instant
function M:preload(job)
	local cache = ya.file_cache(job)
	if cache and not M.cached(cache) then
		M.convert(job, cache)
	end
	return true
end

return M

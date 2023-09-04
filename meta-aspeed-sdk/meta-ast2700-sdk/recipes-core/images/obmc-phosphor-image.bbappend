# image_types_phosphor uses FLASH_UBOOT_OFFSET(384kb) as start offset of uboot-spl and
# FLASH_UBOOT_SPL_SIZE(128kb) as the end offset of uboot-spl. 
# The start offset is larger than the end offset which causes the "image too large" error.
# Therefore,creates do_generate_static task to overwrite the default setting which is from
# image_types_phosphor.bbclass
python do_generate_static() {
    import subprocess

    bb.build.exec_func("do_mk_static_nor_image", d)

    nor_image = os.path.join(d.getVar('IMGDEPLOYDIR', True),
                             '%s.static.mtd' % d.getVar('IMAGE_NAME', True))

    def _append_image(imgpath, start_kb, finish_kb):
        imgsize = os.path.getsize(imgpath)
        maxsize = (finish_kb - start_kb) * 1024
        bb.debug(1, 'Considering file size=' + str(imgsize) + ' name=' + imgpath)
        bb.debug(1, 'Spanning start=' + str(start_kb) + 'K end=' + str(finish_kb) + 'K')
        bb.debug(1, 'Compare needed=' + str(imgsize) + ' available=' + str(maxsize) + ' margin=' + str(maxsize - imgsize))
        if imgsize > maxsize:
            bb.fatal("Image '%s' is too large!" % imgpath)

        subprocess.check_call(['dd', 'bs=1k', 'conv=notrunc',
                               'seek=%d' % start_kb,
                               'if=%s' % imgpath,
                               'of=%s' % nor_image])

    bmcu_fw_binary = d.getVar('BOOTMCU_FW_BINARY', True)
    if bmcu_fw_binary:
        bmcu_ram_start_kb = int(d.getVar('FLASH_BMCU_OFFSET', True))
        bmcu_ram_finish_kb = bmcu_ram_start_kb + int(d.getVar('FLASH_BMCU_SIZE', True))
        _append_image(os.path.join(d.getVar('DEPLOY_DIR_IMAGE', True),
                                   '%s' % (bmcu_fw_binary)),
                      bmcu_ram_start_kb,
                      bmcu_ram_finish_kb)

    uboot_offset = int(d.getVar('FLASH_UBOOT_OFFSET', True))

    spl_binary = d.getVar('SPL_BINARY', True)
    if spl_binary:
        uboot_spl_end_offset = uboot_offset + int(d.getVar('FLASH_UBOOT_SPL_SIZE', True))
        _append_image(os.path.join(d.getVar('DEPLOY_DIR_IMAGE', True),
                                   'u-boot-spl.%s' % d.getVar('UBOOT_SUFFIX',True)),
                      uboot_offset,
                      uboot_spl_end_offset)
        uboot_offset = uboot_spl_end_offset


    _append_image(os.path.join(d.getVar('DEPLOY_DIR_IMAGE', True),
                               'u-boot.%s' % d.getVar('UBOOT_SUFFIX',True)),
                  uboot_offset,
                  int(d.getVar('FLASH_UBOOT_ENV_OFFSET', True)))

    _append_image(os.path.join(d.getVar('DEPLOY_DIR_IMAGE', True),
                               d.getVar('FLASH_KERNEL_IMAGE', True)),
                  int(d.getVar('FLASH_KERNEL_OFFSET', True)),
                  int(d.getVar('FLASH_ROFS_OFFSET', True)))

    _append_image(os.path.join(d.getVar('IMGDEPLOYDIR', True),
                               '%s.%s' % (
                                    d.getVar('IMAGE_LINK_NAME', True),
                                    d.getVar('IMAGE_BASETYPE', True))),
                  int(d.getVar('FLASH_ROFS_OFFSET', True)),
                  int(d.getVar('FLASH_RWFS_OFFSET', True)))

    _append_image(os.path.join(d.getVar('IMGDEPLOYDIR', True),
                               '%s.%s' % (
                                    d.getVar('IMAGE_LINK_NAME', True),
                                    d.getVar('OVERLAY_BASETYPE', True))),
                  int(d.getVar('FLASH_RWFS_OFFSET', True)),
                  int(d.getVar('FLASH_SIZE', True)))

    bb.build.exec_func("do_mk_static_symlinks", d)
}

do_generate_image_uboot_file() {
   image_dst="$1"
   uboot_offset="0"

   if [ ! -z ${SPL_BINARY} ]; then
      dd bs=1k conv=notrunc seek=0 \
         if=${DEPLOY_DIR_IMAGE}/u-boot-spl.${UBOOT_SUFFIX} \
         of=${image_dst}
      uboot_offset=${FLASH_UBOOT_SPL_SIZE}
   fi

   dd bs=1k conv=notrunc seek=${uboot_offset} \
      if=${DEPLOY_DIR_IMAGE}/u-boot.${UBOOT_SUFFIX} \
      of=${image_dst}
}


Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.187]:63538 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934791Ab0KQP11 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 17 Nov 2010 10:27:27 -0500
From: Arnd Bergmann <arnd@arndb.de>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>,
        Nathan Laredo <laredo@gnu.org>, Greg Kroah-Hartman <gregkh@suse.de>,
        Dave Airlie <airlied@linux.ie>, dri-devel@lists.freedesktop.org,
        "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org,
        Alessio Igor Bogani <alessioigorbogani@gmail.com>,
        Jan Kara <jack@suse.cz>
Subject: [PATCH 0/7] BKL removal follow-up
Date: Wed, 17 Nov 2010 16:26:52 +0100
Message-Id: <1290007619-5787-1-git-send-email-arnd@arndb.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Hi Linus,

It seems the v4l and udf code has been worked out now and patches
to kill the BKL there are finally making it upstream.

As promised, here are the patches I did since the kernel summit
to turn off the BKL by default. Given that -rc2 is out now, I don't
know how much of these you still want for 2.6.37, so just pick
the ones you like and I'll send a pull request for the rest
once the 2.6.38 merge window opens.

The patches have been in -next for three days, and I fixed up
the two problems that this has revealed. I would have liked
to give them more testing and wait until you have pulled the
UDF patches, but I'm planning to be offline until next Wednesday.

	Arnd

Arnd Bergmann (7):
  staging/stradis: mark as "depends on BKL"
  drm/i810: remove the BKL
  BKL: remove extraneous #include <smp_lock.h>
  BKL: remove references to lock_kernel from comments
  BKL: disable by default
  BKL: mark lock_kernel as deprecated
  BKL: move CONFIG_BKL to staging

 arch/blackfin/kernel/process.c                     |    1 -
 arch/frv/kernel/process.c                          |    1 -
 arch/h8300/kernel/process.c                        |    1 -
 arch/m68k/kernel/process.c                         |    1 -
 arch/m68knommu/kernel/process.c                    |    1 -
 arch/mn10300/kernel/process.c                      |    1 -
 arch/parisc/hpux/sys_hpux.c                        |    1 -
 arch/parisc/kernel/sys_parisc32.c                  |    1 -
 arch/powerpc/kernel/sys_ppc32.c                    |    1 -
 arch/s390/kernel/compat_linux.c                    |    1 -
 arch/sparc/kernel/leon_smp.c                       |    1 -
 arch/sparc/kernel/sys_sparc32.c                    |    1 -
 arch/sparc/kernel/sys_sparc_32.c                   |    1 -
 arch/sparc/kernel/unaligned_32.c                   |    1 -
 arch/sparc/kernel/windows.c                        |    1 -
 arch/tile/kernel/compat.c                          |    1 -
 arch/tile/kernel/compat_signal.c                   |    1 -
 arch/tile/kernel/signal.c                          |    1 -
 arch/tile/kernel/smpboot.c                         |    1 -
 arch/tile/kernel/sys.c                             |    1 -
 arch/tile/mm/fault.c                               |    1 -
 arch/tile/mm/hugetlbpage.c                         |    1 -
 arch/um/kernel/exec.c                              |    1 -
 arch/x86/ia32/sys_ia32.c                           |    1 -
 arch/x86/kernel/cpuid.c                            |    1 -
 arch/x86/kernel/msr.c                              |    1 -
 block/compat_ioctl.c                               |    1 -
 block/ioctl.c                                      |    1 -
 drivers/block/drbd/drbd_receiver.c                 |    1 -
 drivers/block/drbd/drbd_worker.c                   |    1 -
 drivers/char/agp/frontend.c                        |    1 -
 drivers/char/amiserial.c                           |    1 -
 drivers/char/briq_panel.c                          |    1 -
 drivers/char/hpet.c                                |    1 -
 drivers/char/hw_random/core.c                      |    1 -
 drivers/char/istallion.c                           |    1 -
 drivers/char/serial167.c                           |    1 -
 drivers/char/specialix.c                           |    1 -
 drivers/char/stallion.c                            |    1 -
 drivers/char/sx.c                                  |    1 -
 drivers/char/uv_mmtimer.c                          |    1 -
 drivers/gpu/drm/Kconfig                            |    4 ++--
 drivers/gpu/drm/drm_fops.c                         |    1 -
 drivers/gpu/drm/i810/i810_dma.c                    |   18 +-----------------
 drivers/gpu/drm/i810/i810_drv.c                    |    6 +++++-
 drivers/hid/hidraw.c                               |    1 -
 drivers/hid/usbhid/hiddev.c                        |    1 -
 drivers/infiniband/hw/ipath/ipath_file_ops.c       |    1 -
 drivers/input/input.c                              |    1 -
 drivers/input/serio/serio_raw.c                    |    1 -
 drivers/media/dvb/dvb-core/dvb_ca_en50221.c        |    1 -
 drivers/media/dvb/dvb-core/dvb_frontend.c          |    1 -
 drivers/media/dvb/ngene/ngene-core.c               |    1 -
 drivers/media/dvb/ngene/ngene-dvb.c                |    1 -
 drivers/media/dvb/ngene/ngene-i2c.c                |    1 -
 drivers/media/radio/radio-mr800.c                  |    1 -
 drivers/media/radio/si470x/radio-si470x.h          |    1 -
 drivers/media/video/bt8xx/bttv-driver.c            |    1 -
 drivers/media/video/cx88/cx88-blackbird.c          |    1 -
 drivers/media/video/cx88/cx88-video.c              |    1 -
 drivers/media/video/pwc/pwc-if.c                   |    1 -
 drivers/media/video/s2255drv.c                     |    1 -
 drivers/media/video/saa7134/saa7134-empress.c      |    1 -
 drivers/media/video/saa7164/saa7164.h              |    1 -
 drivers/media/video/usbvision/usbvision-video.c    |    1 -
 drivers/media/video/v4l2-compat-ioctl32.c          |    1 -
 drivers/net/wireless/orinoco/orinoco_usb.c         |    1 -
 drivers/parisc/eisa_eeprom.c                       |    1 -
 drivers/pci/proc.c                                 |    1 -
 drivers/pnp/isapnp/proc.c                          |    1 -
 drivers/s390/block/dasd_eer.c                      |    1 -
 drivers/s390/char/fs3270.c                         |    1 -
 drivers/s390/char/tape_char.c                      |    1 -
 drivers/s390/char/vmlogrdr.c                       |    1 -
 drivers/s390/char/vmur.c                           |    1 -
 drivers/s390/crypto/zcrypt_api.c                   |    1 -
 drivers/scsi/hpsa.c                                |    1 -
 drivers/scsi/pm8001/pm8001_sas.h                   |    1 -
 drivers/scsi/sd.c                                  |    1 -
 drivers/serial/crisv10.c                           |    1 -
 drivers/serial/serial_core.c                       |    1 -
 drivers/staging/Kconfig                            |   11 +++++++++++
 drivers/staging/cx25821/cx25821.h                  |    1 -
 drivers/staging/easycap/easycap.h                  |    1 -
 .../staging/intel_sst/intel_sst_app_interface.c    |    1 -
 drivers/staging/rtl8712/osdep_service.h            |    1 -
 drivers/staging/speakup/buffers.c                  |    1 -
 drivers/staging/stradis/Kconfig                    |    2 +-
 drivers/usb/core/devices.c                         |    1 -
 drivers/usb/core/devio.c                           |    1 -
 drivers/usb/core/file.c                            |    1 -
 drivers/usb/core/inode.c                           |    1 -
 drivers/usb/gadget/f_fs.c                          |    1 -
 drivers/usb/gadget/f_hid.c                         |    1 -
 drivers/usb/host/isp1362-hcd.c                     |    1 -
 drivers/usb/host/uhci-debug.c                      |    1 -
 drivers/usb/mon/mon_bin.c                          |    1 -
 drivers/usb/mon/mon_stat.c                         |    1 -
 drivers/usb/serial/usb-serial.c                    |    1 -
 drivers/video/console/vgacon.c                     |    1 -
 drivers/xen/xenfs/privcmd.c                        |    1 -
 drivers/zorro/proc.c                               |    1 -
 fs/block_dev.c                                     |    1 -
 fs/ceph/inode.c                                    |    1 -
 fs/ceph/mds_client.c                               |    1 -
 fs/compat_ioctl.c                                  |    1 -
 fs/ecryptfs/super.c                                |    1 -
 fs/ext3/super.c                                    |    1 -
 fs/ioctl.c                                         |    1 -
 fs/lockd/clntlock.c                                |    1 -
 fs/lockd/clntproc.c                                |    1 -
 fs/lockd/svc4proc.c                                |    1 -
 fs/lockd/svclock.c                                 |    1 -
 fs/lockd/svcproc.c                                 |    1 -
 fs/locks.c                                         |    1 -
 fs/namespace.c                                     |    1 -
 fs/ncpfs/dir.c                                     |    1 -
 fs/ncpfs/file.c                                    |    1 -
 fs/ncpfs/inode.c                                   |    1 -
 fs/ncpfs/ioctl.c                                   |    1 -
 fs/nfs/callback.c                                  |    1 -
 fs/nfs/delegation.c                                |    1 -
 fs/nfs/super.c                                     |    1 -
 fs/nfsd/nfs4state.c                                |    8 ++++----
 fs/ocfs2/super.c                                   |    1 -
 fs/proc/inode.c                                    |    1 -
 fs/read_write.c                                    |    1 -
 fs/reiserfs/inode.c                                |    1 -
 fs/reiserfs/ioctl.c                                |    1 -
 fs/reiserfs/journal.c                              |    1 -
 fs/reiserfs/super.c                                |    1 -
 include/linux/hardirq.h                            |    1 -
 include/linux/reiserfs_fs.h                        |    1 -
 include/linux/smp_lock.h                           |   15 ++-------------
 include/linux/tty.h                                |    1 -
 init/main.c                                        |    1 -
 kernel/trace/trace.c                               |    1 -
 lib/Kconfig.debug                                  |    9 ---------
 net/irda/af_irda.c                                 |    1 -
 net/irda/irnet/irnet_ppp.c                         |    1 -
 net/sunrpc/svc_xprt.c                              |    1 -
 sound/core/info.c                                  |    1 -
 sound/core/pcm_native.c                            |    1 -
 sound/core/sound.c                                 |    1 -
 sound/sound_core.c                                 |    1 -
 145 files changed, 26 insertions(+), 184 deletions(-)

Cc: Nathan Laredo <laredo@gnu.org>
Cc: Greg Kroah-Hartman <gregkh@suse.de>
Cc: Dave Airlie <airlied@linux.ie>
Cc: dri-devel@lists.freedesktop.org
Cc: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Cc: Alessio Igor Bogani <alessioigorbogani@gmail.com>
Cc: Jan Kara <jack@suse.cz>

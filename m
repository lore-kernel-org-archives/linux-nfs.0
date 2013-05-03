Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:42603 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933295Ab3ECRjl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 3 May 2013 13:39:41 -0400
Date: Fri, 3 May 2013 13:39:40 -0400
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: nfsd changes for 3.10
Message-ID: <20130503173940.GA5715@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Please pull nfsd changes from the for-3.10 branch at:

  git://linux-nfs.org/~bfields/linux.git for-3.10

Highlights include:

	- Some more DRC cleanup and performance work from Jeff Layton

	- A gss-proxy upcall from Simo Sorce: currently krb5 mounts to
	  the server using credentials from Active Directory often fail
	  due to limitations of the svcgssd upcall interface.  This
	  replacement lifts those limitations.  The existing upcall is
	  still supported for backwards compatibility.

	- More NFSv4.1 support: at this point, if a user with a current
	  client who upgrades from 4.0 to 4.1 should see no regressions.
	  In theory we do everything a 4.1 server is required to do.
	  Patches for a couple minor exceptions are ready for 3.11, and
	  with those and some more testing I'd like to turn 4.1 on by
	  default in 3.11.

Note I merged twice from Trond.  I assume that (and that my branch is
based on -rc3, and his on -rc1) explains the unhelpful diffstat.  Let me
know if I screwed up.

There's also a known conflict with the procfs cleanup:

	http://mid.gmane.org/<20130501122227.4c1d5cd6f2f2f98e35706f44@canb.auug.org.au>

--b.

----------------------------------------------------------------
Alexey Khoroshilov (1):
      SUNRPC/cache: add module_put() on error path in cache_open()

Bryan Schumaker (1):
      nfsd: Decode and send 64bit time values

Chuck Lever (2):
      NFSD: Simplify GSS flavor encoding in nfsd4_do_encode_secinfo()
      NFSD: SECINFO doesn't handle unsupported pseudoflavors correctly

Fengguang Wu (2):
      nfsd4: put_client_renew_locked can be static
      SUNRPC: gssp_procedures[] can be static

J. Bruce Fields (38):
      nfsd4: remove BUG_ON
      nfsd4: handle seqid-mutating open errors from xdr decoding
      nfsd4: fix race on client shutdown
      nfsd4: fix use-after-free of 4.1 client on connection loss
      nfsd4: warn on odd create_session state
      nfsd4: STALE_STATEID cleanup
      nfsd4: remove some dprintk's
      nfsd4: destroy_clientid simplification
      nfsd4: clientid lookup cleanup
      nfsd4: fix destroy_session race
      nfsd4: simplify bind_conn_to_session locking
      nfsd4: don't destroy in-use clients
      nfsd4: don't destroy in-use session
      nfsd4: minor cb_recall simplification
      nfsd4: shut down more of delegation earlier
      nfsd4: make del_recall_lru per-network-namespace
      nfsd4: remove unused nfs4_check_deleg argument
      nfsd4: cleanup handling of nfsv4.0 closed stateid's
      nfsd4: remove some redundant comments
      nfsd4: no need for replay_owner in sessions case
      nfsd4: more sessions/open-owner-replay cleanup
      nfsd4: release lockowners on last unlock in 4.1 case
      nfsd4: don't close read-write opens too soon
      nfsd4: cleanup check_forechannel_attrs
      nfsd4: fix forechannel attribute negotiation
      nfsd4: check backchannel attributes on create_session
      nfsd4: clean up validate_stateid
      nfsd4: implement SEQ4_STATUS_RECALLABLE_STATE_REVOKED
      nfsd4: remove unused macro
      Merge Trond's nfs-for-next
      SUNRPC: attempt AF_LOCAL connect on setup
      SUNRPC: allow disabling idle timeout
      nfsd: fix EXDEV checking in rename
      nfsd4: better error return to indicate SSV non-support
      Merge branch 'nfs-for-next' of git://linux-nfs.org/~trondmy/nfs-2.6 into for-3.10
      SUNRPC: define {create,destroy}_use_gss_proxy_proc_entry in !PROC case
      svcrpc: fix gss-proxy to respect user namespaces
      nfsd4: don't remap EISDIR errors in rename

Jeff Layton (7):
      nfsd: eliminate one of the DRC cache searches
      nfsd: break out comparator into separate function
      nfsd: track memory utilization by the DRC
      nfsd: add new reply_cache_stats file in nfsdfs
      nfsd: keep stats on worst hash balancing seen so far
      nfsd: scale up the number of DRC hash buckets with cache size
      nfsd: convert the file_hashtbl to a hlist

Simo Sorce (3):
      SUNRPC: conditionally return endtime from import_sec_context
      SUNRPC: Add RPC based upcall mechanism for RPCGSS auth
      SUNRPC: Use gssproxy upcall for server RPCGSS authentication.

Wei Yongjun (3):
      nfsd: use kmem_cache_free() instead of kfree()
      svcauth_gss: fix error return code in rsc_parse()
      nfsd: make symbol nfsd_reply_cache_shrinker static

Yanchuan Nian (1):
      nfsd: remove unused macro in nfsv4

fanchaoting (3):
      nfsd: don't run get_file if nfs4_preprocess_stateid_op return error
      nfsd: remove /proc/fs/nfs when create /proc/fs/nfs/exports error
      nfsd4: remove some useless code

ycnian@gmail.com (1):
      nfsd: fix bug on nfs4 stateid deallocation

 CREDITS                                            |    6 +-
 Documentation/SubmittingPatches                    |    3 +-
 Documentation/device-mapper/dm-raid.txt            |   44 +-
 Documentation/devicetree/bindings/mfd/ab8500.txt   |    6 +-
 .../devicetree/bindings/tty/serial/of-serial.txt   |    3 +
 Documentation/filesystems/nfs/00-INDEX             |    2 +
 Documentation/filesystems/nfs/rpc-server-gss.txt   |   91 ++
 Documentation/hwmon/adm1275                        |    2 +-
 Documentation/hwmon/adt7410                        |   11 +-
 Documentation/hwmon/jc42                           |    2 +-
 Documentation/hwmon/lineage-pem                    |    2 +-
 Documentation/hwmon/lm25066                        |    2 +-
 Documentation/hwmon/ltc2978                        |    6 +-
 Documentation/hwmon/ltc4261                        |    2 +-
 Documentation/hwmon/max16064                       |    2 +-
 Documentation/hwmon/max16065                       |    2 +-
 Documentation/hwmon/max34440                       |    2 +-
 Documentation/hwmon/max8688                        |    2 +-
 Documentation/hwmon/pmbus                          |    2 +-
 Documentation/hwmon/smm665                         |    2 +-
 Documentation/hwmon/ucd9000                        |    2 +-
 Documentation/hwmon/ucd9200                        |    2 +-
 Documentation/hwmon/zl6100                         |    2 +-
 Documentation/input/alps.txt                       |   67 +-
 Documentation/networking/tuntap.txt                |   77 ++
 Documentation/power/opp.txt                        |   25 +-
 Documentation/printk-formats.txt                   |    2 +-
 Documentation/trace/ftrace.txt                     |    2 +-
 MAINTAINERS                                        |   45 +-
 Makefile                                           |    2 +-
 arch/Kconfig                                       |    7 -
 arch/alpha/Kconfig                                 |    2 +-
 arch/alpha/boot/head.S                             |    1 +
 arch/arm/Kconfig                                   |   13 +-
 arch/arm/Kconfig.debug                             |    2 +-
 arch/arm/boot/Makefile                             |    2 +-
 arch/arm/boot/compressed/Makefile                  |    2 +-
 arch/arm/boot/dts/armada-370-rd.dts                |    8 +
 arch/arm/boot/dts/armada-370-xp.dtsi               |    5 +-
 arch/arm/boot/dts/armada-xp.dtsi                   |    4 +-
 arch/arm/boot/dts/bcm2835.dtsi                     |    2 +-
 arch/arm/boot/dts/dbx5x0.dtsi                      |    3 +-
 arch/arm/boot/dts/dove.dtsi                        |    5 +
 arch/arm/boot/dts/href.dtsi                        |    2 +-
 arch/arm/boot/dts/hrefv60plus.dts                  |    2 +-
 arch/arm/boot/dts/imx53-mba53.dts                  |    3 +-
 arch/arm/boot/dts/kirkwood-dns320.dts              |    2 -
 arch/arm/boot/dts/kirkwood-dns325.dts              |    1 -
 arch/arm/boot/dts/kirkwood-dockstar.dts            |    1 -
 arch/arm/boot/dts/kirkwood-dreamplug.dts           |    1 -
 arch/arm/boot/dts/kirkwood-goflexnet.dts           |    1 -
 arch/arm/boot/dts/kirkwood-ib62x0.dts              |    1 -
 arch/arm/boot/dts/kirkwood-iconnect.dts            |    1 -
 arch/arm/boot/dts/kirkwood-iomega_ix2_200.dts      |    1 -
 arch/arm/boot/dts/kirkwood-km_kirkwood.dts         |    1 -
 arch/arm/boot/dts/kirkwood-lschlv2.dts             |    1 -
 arch/arm/boot/dts/kirkwood-lsxhl.dts               |    1 -
 arch/arm/boot/dts/kirkwood-mplcec4.dts             |    1 -
 arch/arm/boot/dts/kirkwood-ns2-common.dtsi         |    1 -
 arch/arm/boot/dts/kirkwood-nsa310.dts              |    1 -
 arch/arm/boot/dts/kirkwood-openblocks_a6.dts       |    2 -
 arch/arm/boot/dts/kirkwood-topkick.dts             |    1 -
 arch/arm/boot/dts/kirkwood.dtsi                    |    5 +-
 .../dts/orion5x-lacie-ethernet-disk-mini-v2.dts    |    2 +-
 arch/arm/boot/dts/snowball.dts                     |    2 +-
 arch/arm/boot/dts/socfpga.dtsi                     |    3 +
 arch/arm/boot/dts/tegra20.dtsi                     |    1 +
 arch/arm/boot/dts/tegra30.dtsi                     |    1 +
 arch/arm/configs/mxs_defconfig                     |    1 +
 arch/arm/configs/omap2plus_defconfig               |    2 +
 arch/arm/include/asm/mmu.h                         |    8 +-
 arch/arm/include/asm/mmu_context.h                 |    2 +-
 arch/arm/include/asm/tlbflush.h                    |   34 +-
 arch/arm/include/asm/xen/events.h                  |   25 +-
 arch/arm/include/uapi/asm/unistd.h                 |    2 +-
 arch/arm/kernel/asm-offsets.c                      |    2 +-
 arch/arm/kernel/calls.S                            |    2 +-
 arch/arm/kernel/head.S                             |   26 +-
 arch/arm/kernel/hw_breakpoint.c                    |    2 +-
 arch/arm/kernel/perf_event.c                       |    4 +-
 arch/arm/kernel/perf_event_v7.c                    |    2 +-
 arch/arm/kernel/smp.c                              |    1 +
 arch/arm/kernel/smp_tlb.c                          |   12 +
 arch/arm/kernel/smp_twd.c                          |    4 +
 arch/arm/kernel/suspend.c                          |    1 +
 arch/arm/lib/memset.S                              |   85 +-
 arch/arm/mach-at91/board-foxg20.c                  |    1 +
 arch/arm/mach-at91/board-stamp9g20.c               |    1 +
 arch/arm/mach-imx/clk-imx6q.c                      |    2 +-
 arch/arm/mach-imx/headsmp.S                        |   18 +-
 arch/arm/mach-imx/pm-imx6q.c                       |   15 -
 arch/arm/mach-ixp4xx/vulcan-setup.c                |    1 +
 arch/arm/mach-kirkwood/board-dt.c                  |   25 +-
 arch/arm/mach-mxs/icoll.c                          |    2 +-
 arch/arm/mach-mxs/mach-mxs.c                       |   10 +-
 arch/arm/mach-mxs/mm.c                             |    1 +
 arch/arm/mach-mxs/ocotp.c                          |    1 +
 arch/arm/mach-netx/generic.c                       |    2 +-
 arch/arm/mach-netx/include/mach/irqs.h             |   64 +-
 arch/arm/mach-omap1/common.h                       |    2 +
 arch/arm/mach-omap2/Kconfig                        |    6 -
 arch/arm/mach-omap2/board-generic.c                |    2 +
 arch/arm/mach-omap2/board-rx51.c                   |    2 +
 arch/arm/mach-omap2/common.h                       |    1 -
 arch/arm/mach-omap2/gpmc.c                         |    6 +-
 arch/arm/mach-omap2/mux.c                          |    9 +-
 arch/arm/mach-pxa/raumfeld.c                       |    1 +
 arch/arm/mach-spear3xx/spear3xx.c                  |    2 +-
 arch/arm/mm/context.c                              |   29 +-
 arch/arm/mm/dma-mapping.c                          |    5 +-
 arch/arm/mm/idmap.c                                |    1 +
 arch/arm/mm/proc-v7-3level.S                       |    2 +-
 arch/arm/plat-orion/addr-map.c                     |    7 +-
 arch/arm/plat-spear/Kconfig                        |    2 +-
 arch/avr32/Kconfig                                 |    2 +-
 arch/blackfin/Kconfig                              |    2 +-
 arch/cris/Kconfig                                  |    2 +-
 arch/frv/Kconfig                                   |    2 +-
 arch/h8300/Kconfig                                 |    2 +-
 arch/ia64/Kconfig                                  |    2 +-
 arch/ia64/kernel/perfmon.c                         |    1 +
 arch/m32r/Kconfig                                  |    2 +-
 arch/m32r/include/uapi/asm/stat.h                  |    4 +-
 arch/m68k/Kconfig                                  |    2 +-
 arch/m68k/Kconfig.machine                          |    1 -
 arch/m68k/include/asm/MC68328.h                    |   10 +-
 arch/m68k/kernel/setup_no.c                        |    3 +
 arch/m68k/mm/init.c                                |    2 +-
 arch/m68k/platform/coldfire/m528x.c                |    2 +-
 arch/metag/include/asm/elf.h                       |    3 -
 arch/metag/mm/Kconfig                              |    1 +
 arch/microblaze/Kconfig                            |    2 +-
 arch/mips/Kconfig                                  |    2 +-
 arch/mn10300/Kconfig                               |    2 +-
 arch/openrisc/Kconfig                              |    3 +-
 arch/parisc/Kconfig                                |    2 +-
 arch/powerpc/Kconfig                               |    2 +-
 arch/powerpc/crypto/sha1-powerpc-asm.S             |    4 +-
 arch/powerpc/include/asm/bitops.h                  |    2 -
 arch/powerpc/include/asm/reg.h                     |    3 +-
 arch/powerpc/include/asm/systbl.h                  |    1 +
 arch/powerpc/include/asm/unistd.h                  |    2 +-
 arch/powerpc/include/uapi/asm/unistd.h             |    1 +
 arch/powerpc/kernel/cpu_setup_power.S              |    5 +-
 arch/powerpc/kernel/exceptions-64s.S               |    4 +-
 arch/powerpc/platforms/cell/spufs/inode.c          |    1 +
 arch/powerpc/platforms/pseries/hvcserver.c         |    5 +-
 arch/s390/Kconfig                                  |    2 +-
 arch/s390/hypfs/inode.c                            |    1 +
 arch/s390/include/asm/cpu_mf.h                     |    1 +
 arch/score/Kconfig                                 |    2 +-
 arch/tile/Kconfig                                  |    2 +-
 arch/tile/include/asm/compat.h                     |    3 +
 arch/tile/kernel/compat.c                          |   42 +-
 arch/um/drivers/chan.h                             |    2 +-
 arch/um/drivers/chan_kern.c                        |    4 +-
 arch/um/drivers/chan_user.c                        |   12 +-
 arch/um/drivers/chan_user.h                        |    6 +-
 arch/um/drivers/line.c                             |   42 +-
 arch/um/drivers/net_kern.c                         |    2 +
 arch/um/drivers/ssl.c                              |    1 -
 arch/um/drivers/stdio_console.c                    |    1 -
 arch/um/os-Linux/signal.c                          |    2 +-
 arch/um/os-Linux/start_up.c                        |    2 +
 arch/unicore32/Kconfig                             |    2 +-
 arch/x86/Kconfig                                   |    2 +-
 arch/x86/include/asm/bootparam_utils.h             |   20 +-
 arch/x86/kernel/cpu/perf_event_intel_ds.c          |   10 +
 arch/x86/kernel/setup.c                            |   10 +-
 arch/x86/kernel/smpboot.c                          |    3 +-
 arch/x86/mm/init.c                                 |    5 +-
 arch/x86/mm/pat.c                                  |    7 +
 arch/x86/power/cpu.c                               |    2 +
 arch/xtensa/Kconfig                                |    2 +-
 drivers/acpi/glue.c                                |   55 +-
 drivers/acpi/processor_core.c                      |    3 +-
 drivers/acpi/processor_driver.c                    |    2 +-
 drivers/acpi/processor_perflib.c                   |    4 +-
 drivers/acpi/sleep.c                               |   16 +-
 drivers/ata/libata-acpi.c                          |    7 +-
 drivers/base/power/main.c                          |    2 -
 drivers/base/power/power.h                         |    8 +-
 drivers/base/power/qos.c                           |  217 +--
 drivers/base/power/sysfs.c                         |    1 +
 drivers/base/regmap/regmap-irq.c                   |    1 +
 drivers/bcma/driver_pci_host.c                     |    2 +
 drivers/char/hw_random/core.c                      |   19 +-
 drivers/char/hw_random/virtio-rng.c                |   13 +-
 drivers/char/random.c                              |   12 +-
 drivers/clk/tegra/clk-tegra20.c                    |    1 -
 drivers/clk/tegra/clk-tegra30.c                    |    1 -
 drivers/connector/cn_proc.c                        |    8 +
 drivers/cpufreq/cpufreq_governor.h                 |    2 +-
 drivers/cpufreq/highbank-cpufreq.c                 |    8 +-
 drivers/cpufreq/intel_pstate.c                     |   42 +-
 drivers/firmware/dmi_scan.c                        |    5 +-
 drivers/firmware/efivars.c                         |  131 +-
 drivers/gpio/gpio-ich.c                            |    4 +-
 drivers/gpio/gpio-mvebu.c                          |    7 +
 drivers/gpio/gpiolib.c                             |  143 +-
 drivers/gpu/drm/i915/i915_drv.c                    |   25 +-
 drivers/gpu/drm/i915/i915_irq.c                    |   26 +-
 drivers/gpu/drm/i915/i915_reg.h                    |    4 +-
 drivers/gpu/drm/i915/intel_crt.c                   |    2 +-
 drivers/gpu/drm/i915/intel_ddi.c                   |    2 +-
 drivers/gpu/drm/i915/intel_display.c               |   37 +-
 drivers/gpu/drm/i915/intel_dp.c                    |    3 +-
 drivers/gpu/drm/i915/intel_pm.c                    |    2 +-
 drivers/gpu/drm/mgag200/mgag200_drv.h              |    1 -
 drivers/gpu/drm/mgag200/mgag200_i2c.c              |    1 +
 drivers/gpu/drm/mgag200/mgag200_mode.c             |   27 +
 drivers/gpu/drm/nouveau/core/engine/disp/nv50.c    |    4 +-
 drivers/gpu/drm/nouveau/core/engine/graph/nve0.c   |    2 +-
 drivers/gpu/drm/nouveau/core/subdev/bios/init.c    |    2 +-
 drivers/gpu/drm/nouveau/core/subdev/i2c/base.c     |    1 +
 drivers/gpu/drm/nouveau/nouveau_abi16.c            |    5 +
 drivers/gpu/drm/nouveau/nouveau_agp.c              |   12 +
 drivers/gpu/drm/nouveau/nouveau_bo.c               |    4 +-
 drivers/gpu/drm/nouveau/nv50_display.c             |  174 ++-
 drivers/gpu/drm/radeon/evergreen.c                 |    6 +
 drivers/gpu/drm/radeon/evergreen_cs.c              |    2 +-
 drivers/gpu/drm/radeon/ni.c                        |    6 +
 drivers/gpu/drm/radeon/r600.c                      |    6 +
 drivers/gpu/drm/radeon/radeon_combios.c            |    9 +
 drivers/gpu/drm/radeon/radeon_drv.c                |    3 +-
 drivers/gpu/drm/radeon/radeon_irq_kms.c            |   12 +
 drivers/gpu/drm/radeon/si.c                        |    6 +
 drivers/gpu/drm/tegra/Kconfig                      |    1 -
 drivers/hid/hid-logitech-dj.c                      |   22 +-
 drivers/hwmon/lineage-pem.c                        |    2 +
 drivers/hwmon/pmbus/ltc2978.c                      |   40 +-
 drivers/hwmon/pmbus/pmbus_core.c                   |   12 +-
 drivers/hwmon/sht15.c                              |    8 +-
 drivers/iio/common/st_sensors/st_sensors_core.c    |    9 +-
 drivers/iio/dac/ad5064.c                           |   64 +-
 drivers/iio/imu/inv_mpu6050/Kconfig                |    1 +
 drivers/infiniband/hw/ipath/ipath_fs.c             |    1 +
 drivers/infiniband/hw/mlx4/cm.c                    |    1 -
 drivers/infiniband/hw/qib/qib_fs.c                 |    1 +
 drivers/input/keyboard/tc3589x-keypad.c            |    8 +-
 drivers/input/mouse/alps.c                         |   85 +-
 drivers/input/mouse/alps.h                         |    1 +
 drivers/input/mouse/cypress_ps2.c                  |   19 +-
 drivers/input/tablet/wacom_wac.c                   |    4 +
 drivers/input/touchscreen/ads7846.c                |    7 +-
 drivers/input/touchscreen/atmel_mxt_ts.c           |   68 +-
 drivers/input/touchscreen/mms114.c                 |   34 +-
 drivers/iommu/dmar.c                               |    1 +
 drivers/irqchip/irq-gic.c                          |    2 +-
 drivers/isdn/hisax/st5481_usb.c                    |   12 +-
 drivers/isdn/i4l/isdn_tty.c                        |    4 +-
 drivers/mailbox/pl320-ipc.c                        |    3 +-
 drivers/md/Kconfig                                 |   11 -
 drivers/md/dm-raid.c                               |  123 +-
 drivers/md/md.c                                    |   19 +-
 drivers/md/raid0.c                                 |   13 +-
 drivers/md/raid1.c                                 |    8 +-
 drivers/md/raid10.c                                |   97 +-
 drivers/md/raid10.h                                |    5 +
 drivers/md/raid5.c                                 |   38 +-
 drivers/mfd/Kconfig                                |    1 +
 drivers/mfd/ab8500-gpadc.c                         |   17 +-
 drivers/mfd/omap-usb-host.c                        |    6 +-
 drivers/mfd/palmas.c                               |   36 +-
 drivers/mfd/tps65912-core.c                        |    1 +
 drivers/mfd/twl4030-audio.c                        |    2 +-
 drivers/mfd/twl4030-madc.c                         |    2 +-
 drivers/misc/ibmasm/ibmasmfs.c                     |    1 +
 drivers/mtd/mtdchar.c                              |    1 +
 drivers/net/bonding/bond_main.c                    |    7 +-
 drivers/net/ethernet/broadcom/bgmac.c              |    4 +
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c    |    2 +-
 .../net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c    |    6 +
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c   |   81 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.h   |    7 +-
 drivers/net/ethernet/broadcom/tg3.c                |   14 +-
 drivers/net/ethernet/emulex/benet/be.h             |    1 +
 drivers/net/ethernet/emulex/benet/be_cmds.c        |   36 +-
 drivers/net/ethernet/emulex/benet/be_hw.h          |    4 +-
 drivers/net/ethernet/emulex/benet/be_main.c        |   10 +
 drivers/net/ethernet/freescale/fec.c               |   85 +-
 drivers/net/ethernet/freescale/fec.h               |   18 +-
 drivers/net/ethernet/intel/e1000e/ethtool.c        |   13 +
 drivers/net/ethernet/intel/e1000e/ich8lan.c        |   71 +-
 drivers/net/ethernet/intel/e1000e/ich8lan.h        |    2 +
 drivers/net/ethernet/intel/e1000e/netdev.c         |   82 +-
 drivers/net/ethernet/intel/e1000e/regs.h           |    1 +
 drivers/net/ethernet/intel/igb/e1000_82575.c       |   11 +-
 drivers/net/ethernet/intel/igb/igb.h               |    2 +-
 drivers/net/ethernet/intel/igb/igb_hwmon.c         |   14 +
 drivers/net/ethernet/intel/igb/igb_main.c          |   76 +-
 drivers/net/ethernet/marvell/mv643xx_eth.c         |   55 +-
 drivers/net/ethernet/mellanox/mlx4/cq.c            |    2 +-
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c     |   86 +-
 drivers/net/ethernet/mellanox/mlx4/fw.c            |    8 +
 drivers/net/ethernet/mellanox/mlx4/main.c          |    2 +-
 drivers/net/ethernet/mellanox/mlx4/mlx4.h          |    2 +-
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h       |    1 -
 drivers/net/ethernet/mellanox/mlx4/mr.c            |   10 +-
 drivers/net/ethernet/mellanox/mlx4/pd.c            |    2 +-
 drivers/net/ethernet/mellanox/mlx4/port.c          |    8 +-
 drivers/net/ethernet/mellanox/mlx4/qp.c            |    8 +-
 .../net/ethernet/mellanox/mlx4/resource_tracker.c  |    3 +
 drivers/net/ethernet/mellanox/mlx4/srq.c           |    2 +-
 drivers/net/ethernet/realtek/r8169.c               |   27 +-
 drivers/net/ethernet/sfc/efx.c                     |   16 +-
 drivers/net/ethernet/sfc/efx.h                     |    4 +-
 drivers/net/ethernet/sfc/net_driver.h              |    4 +-
 drivers/net/ethernet/sfc/rx.c                      |   25 +-
 drivers/net/ethernet/ti/cpsw.c                     |    2 +-
 drivers/net/hippi/rrunner.c                        |    3 +
 drivers/net/macvlan.c                              |    1 +
 drivers/net/phy/micrel.c                           |    3 +-
 drivers/net/phy/phy_device.c                       |   10 +-
 drivers/net/team/team.c                            |    2 +
 drivers/net/tun.c                                  |    2 +
 drivers/net/usb/Kconfig                            |   18 +
 drivers/net/usb/Makefile                           |    1 +
 drivers/net/usb/asix_devices.c                     |   31 +
 drivers/net/usb/ax88179_178a.c                     | 1448 ++++++++++++++++++++
 drivers/net/usb/cdc_ncm.c                          |    8 +
 drivers/net/vmxnet3/vmxnet3_drv.c                  |    1 +
 drivers/net/vmxnet3/vmxnet3_ethtool.c              |    6 +
 drivers/net/vmxnet3/vmxnet3_int.h                  |    4 +-
 drivers/net/vxlan.c                                |   10 +
 drivers/net/wireless/ath/ath9k/common.h            |    2 +-
 drivers/net/wireless/ath/ath9k/htc.h               |    1 +
 drivers/net/wireless/ath/ath9k/htc_drv_txrx.c      |   18 +-
 drivers/net/wireless/ath/ath9k/hw.c                |    4 +-
 drivers/net/wireless/iwlwifi/dvm/sta.c             |    2 +-
 drivers/net/wireless/iwlwifi/iwl-devtrace.h        |   12 +-
 drivers/net/wireless/iwlwifi/iwl-drv.c             |    3 +-
 drivers/net/wireless/iwlwifi/iwl-modparams.h       |    2 +-
 drivers/net/wireless/iwlwifi/iwl-phy-db.c          |   16 -
 drivers/net/wireless/iwlwifi/iwl-trans.h           |   20 +-
 drivers/net/wireless/iwlwifi/mvm/d3.c              |  104 +-
 drivers/net/wireless/iwlwifi/mvm/fw-api.h          |   18 +-
 drivers/net/wireless/iwlwifi/mvm/fw.c              |  133 +-
 drivers/net/wireless/iwlwifi/mvm/mac80211.c        |   19 +-
 drivers/net/wireless/iwlwifi/mvm/mvm.h             |    7 +-
 drivers/net/wireless/iwlwifi/mvm/ops.c             |   18 +-
 drivers/net/wireless/iwlwifi/mvm/rx.c              |   37 +-
 drivers/net/wireless/iwlwifi/mvm/sta.c             |   10 +
 drivers/net/wireless/iwlwifi/mvm/tx.c              |    6 +-
 drivers/net/wireless/iwlwifi/pcie/internal.h       |   35 +-
 drivers/net/wireless/iwlwifi/pcie/rx.c             |   14 +-
 drivers/net/wireless/iwlwifi/pcie/tx.c             |  299 ++--
 drivers/net/wireless/libertas/if_sdio.c            |    6 +-
 drivers/net/wireless/mwifiex/pcie.c                |    2 +-
 drivers/net/wireless/rt2x00/rt2x00dev.c            |    8 +-
 drivers/oprofile/oprofilefs.c                      |    1 +
 drivers/pci/pci-acpi.c                             |    8 +-
 drivers/platform/x86/chromeos_laptop.c             |   41 +-
 drivers/pnp/pnpacpi/core.c                         |    8 +-
 drivers/regulator/core.c                           |   12 +-
 drivers/regulator/db8500-prcmu.c                   |    4 +-
 drivers/regulator/palmas-regulator.c               |    3 +-
 drivers/regulator/twl-regulator.c                  |    9 +-
 drivers/rtc/rtc-mv.c                               |   28 +-
 drivers/scsi/scsi_lib.c                            |    7 +-
 drivers/staging/ccg/f_fs.c                         |    1 +
 drivers/staging/comedi/drivers/dt9812.c            |   16 +-
 drivers/staging/comedi/drivers/usbdux.c            |   31 +-
 drivers/staging/comedi/drivers/usbduxfast.c        |   30 +-
 drivers/staging/comedi/drivers/usbduxsigma.c       |   27 +-
 drivers/staging/imx-drm/ipuv3-crtc.c               |   23 +-
 drivers/staging/tidspbridge/rmgr/drv.c             |   70 +-
 drivers/staging/vt6656/card.c                      |    2 +-
 drivers/staging/vt6656/main_usb.c                  |    4 -
 drivers/staging/zcache/ramster/tcp.c               |   25 +-
 drivers/tty/hvc/hvcs.c                             |    9 +-
 drivers/tty/serial/8250/8250.c                     |   52 +-
 drivers/tty/serial/8250/8250_pci.c                 |   21 +-
 drivers/tty/serial/8250/8250_pnp.c                 |   12 +-
 drivers/tty/serial/Kconfig                         |    4 +-
 drivers/tty/serial/bcm63xx_uart.c                  |    8 +-
 drivers/tty/serial/mpc52xx_uart.c                  |    2 +-
 drivers/tty/serial/of_serial.c                     |    6 +
 drivers/tty/serial/vt8500_serial.c                 |    9 +-
 drivers/tty/tty_buffer.c                           |    2 +-
 drivers/usb/Makefile                               |    2 +-
 drivers/usb/c67x00/c67x00-sched.c                  |    4 +-
 drivers/usb/chipidea/udc.c                         |    6 +-
 drivers/usb/class/cdc-wdm.c                        |   23 +-
 drivers/usb/core/usb-acpi.c                        |    9 +-
 drivers/usb/dwc3/core.c                            |    1 +
 drivers/usb/dwc3/dwc3-exynos.c                     |    2 -
 drivers/usb/dwc3/dwc3-omap.c                       |    8 +-
 drivers/usb/dwc3/dwc3-pci.c                        |    2 -
 drivers/usb/dwc3/ep0.c                             |    7 +-
 drivers/usb/dwc3/gadget.c                          |    3 -
 drivers/usb/gadget/Makefile                        |   12 +-
 drivers/usb/gadget/composite.c                     |    5 +-
 drivers/usb/gadget/f_fs.c                          |    1 +
 drivers/usb/gadget/f_uac1.c                        |    1 +
 drivers/usb/gadget/imx_udc.c                       |   20 +-
 drivers/usb/gadget/inode.c                         |    1 +
 drivers/usb/gadget/omap_udc.c                      |    3 +-
 drivers/usb/gadget/pxa25x_udc.c                    |   24 +-
 drivers/usb/gadget/pxa27x_udc.c                    |   18 +-
 drivers/usb/gadget/s3c2410_udc.c                   |   28 +-
 drivers/usb/gadget/u_uac1.c                        |    3 +
 drivers/usb/host/ehci-hcd.c                        |    6 +-
 drivers/usb/host/ehci-q.c                          |   36 +-
 drivers/usb/musb/Kconfig                           |    5 -
 drivers/usb/musb/musb_core.c                       |    6 -
 drivers/usb/musb/omap2430.c                        |   12 +-
 drivers/usb/otg/otg.c                              |   10 +-
 drivers/usb/phy/omap-control-usb.c                 |   24 +-
 drivers/usb/phy/omap-usb3.c                        |    8 +-
 drivers/usb/phy/samsung-usbphy.c                   |    8 +-
 drivers/usb/serial/cp210x.c                        |   20 +
 drivers/usb/serial/option.c                        |    5 +
 drivers/usb/serial/qcaux.c                         |    1 +
 drivers/usb/serial/qcserial.c                      |    7 +-
 drivers/usb/serial/quatech2.c                      |    7 +-
 drivers/usb/storage/initializers.c                 |   76 +-
 drivers/usb/storage/initializers.h                 |    4 +-
 drivers/usb/storage/unusual_devs.h                 |  337 ++++-
 drivers/video/omap/lcd_ams_delta.c                 |    1 +
 drivers/video/omap/lcd_osk.c                       |    3 +
 drivers/w1/masters/w1-gpio.c                       |    6 +-
 drivers/w1/w1.c                                    |    3 +-
 drivers/xen/xen-acpi-processor.c                   |    8 +-
 drivers/xen/xen-pciback/pciback_ops.c              |    3 +-
 drivers/xen/xen-stub.c                             |    1 -
 drivers/xen/xenfs/super.c                          |    1 +
 fs/9p/vfs_super.c                                  |    1 +
 fs/adfs/super.c                                    |    1 +
 fs/affs/super.c                                    |    1 +
 fs/afs/super.c                                     |    1 +
 fs/autofs4/init.c                                  |    1 +
 fs/befs/linuxvfs.c                                 |    1 +
 fs/bfs/inode.c                                     |    1 +
 fs/binfmt_misc.c                                   |    1 +
 fs/btrfs/delayed-inode.c                           |  151 +-
 fs/btrfs/delayed-inode.h                           |    2 +
 fs/btrfs/disk-io.c                                 |   16 +-
 fs/btrfs/extent-tree.c                             |    5 +-
 fs/btrfs/file.c                                    |    1 +
 fs/btrfs/inode.c                                   |    9 +-
 fs/btrfs/ioctl.c                                   |   18 +-
 fs/btrfs/locking.h                                 |    1 -
 fs/btrfs/qgroup.c                                  |   10 +-
 fs/btrfs/relocation.c                              |   74 +-
 fs/btrfs/super.c                                   |    1 +
 fs/btrfs/transaction.c                             |   76 +-
 fs/btrfs/tree-log.c                                |    5 +-
 fs/btrfs/volumes.c                                 |   20 +-
 fs/ceph/super.c                                    |    1 +
 fs/cifs/cifsfs.c                                   |    1 +
 fs/cifs/cifssmb.c                                  |    2 +-
 fs/cifs/connect.c                                  |   16 +-
 fs/cifs/inode.c                                    |   11 +-
 fs/cifs/smb2ops.c                                  |    1 +
 fs/coda/inode.c                                    |    1 +
 fs/compat.c                                        |   15 +-
 fs/configfs/mount.c                                |    1 +
 fs/cramfs/inode.c                                  |    1 +
 fs/debugfs/inode.c                                 |    1 +
 fs/ecryptfs/Kconfig                                |    8 +
 fs/ecryptfs/Makefile                               |    7 +-
 fs/ecryptfs/crypto.c                               |    9 +-
 fs/ecryptfs/dentry.c                               |    2 -
 fs/ecryptfs/ecryptfs_kernel.h                      |   40 +-
 fs/ecryptfs/file.c                                 |    2 -
 fs/ecryptfs/inode.c                                |    8 +-
 fs/ecryptfs/keystore.c                             |    9 +-
 fs/ecryptfs/main.c                                 |    1 +
 fs/ecryptfs/messaging.c                            |    5 +-
 fs/efs/super.c                                     |    1 +
 fs/exofs/super.c                                   |    1 +
 fs/ext2/ialloc.c                                   |    1 -
 fs/ext2/inode.c                                    |    2 +
 fs/ext2/super.c                                    |    1 +
 fs/ext3/super.c                                    |    5 +-
 fs/ext4/super.c                                    |    7 +-
 fs/f2fs/super.c                                    |    1 +
 fs/fat/namei_msdos.c                               |    1 +
 fs/fat/namei_vfat.c                                |    1 +
 fs/filesystems.c                                   |    2 +-
 fs/freevxfs/vxfs_super.c                           |    3 +-
 fs/fuse/control.c                                  |    1 +
 fs/fuse/inode.c                                    |    2 +
 fs/gfs2/ops_fstype.c                               |    4 +-
 fs/hfs/super.c                                     |    1 +
 fs/hfsplus/super.c                                 |    1 +
 fs/hostfs/hostfs_kern.c                            |   10 +-
 fs/hpfs/super.c                                    |    1 +
 fs/hppfs/hppfs.c                                   |    1 +
 fs/hugetlbfs/inode.c                               |    1 +
 fs/isofs/inode.c                                   |    4 +-
 fs/jffs2/super.c                                   |    1 +
 fs/jfs/super.c                                     |    1 +
 fs/logfs/super.c                                   |    1 +
 fs/minix/inode.c                                   |    1 +
 fs/namei.c                                         |    2 -
 fs/ncpfs/inode.c                                   |    1 +
 fs/nfs/super.c                                     |    4 +-
 fs/nfsd/cache.h                                    |    1 +
 fs/nfsd/netns.h                                    |    1 +
 fs/nfsd/nfs4callback.c                             |   33 +-
 fs/nfsd/nfs4proc.c                                 |   97 +-
 fs/nfsd/nfs4state.c                                |  783 ++++++-----
 fs/nfsd/nfs4xdr.c                                  |  111 +-
 fs/nfsd/nfscache.c                                 |  208 ++-
 fs/nfsd/nfsctl.c                                   |   14 +-
 fs/nfsd/state.h                                    |   27 +-
 fs/nfsd/vfs.c                                      |    9 +-
 fs/nfsd/xdr4.h                                     |    3 +-
 fs/nfsd/xdr4cb.h                                   |   23 +
 fs/nilfs2/super.c                                  |    1 +
 fs/ntfs/super.c                                    |    1 +
 fs/ocfs2/dlmfs/dlmfs.c                             |    1 +
 fs/ocfs2/super.c                                   |    1 +
 fs/omfs/inode.c                                    |    1 +
 fs/openpromfs/inode.c                              |    1 +
 fs/pipe.c                                          |    3 +
 fs/proc/namespaces.c                               |   12 +-
 fs/qnx4/inode.c                                    |    1 +
 fs/qnx6/inode.c                                    |    1 +
 fs/quota/dquot.c                                   |    5 +-
 fs/reiserfs/super.c                                |    5 +-
 fs/romfs/super.c                                   |    1 +
 fs/squashfs/super.c                                |    1 +
 fs/sysv/super.c                                    |    4 +-
 fs/ubifs/super.c                                   |    1 +
 fs/udf/super.c                                     |    1 +
 fs/ufs/super.c                                     |    1 +
 fs/xfs/xfs_super.c                                 |    1 +
 include/acpi/acpi_bus.h                            |    6 +-
 include/acpi/processor.h                           |    3 +
 include/asm-generic/atomic.h                       |    6 -
 include/asm-generic/cmpxchg.h                      |   10 +
 include/drm/drm_crtc.h                             |    6 +-
 include/linux/ecryptfs.h                           |   12 +-
 include/linux/fs.h                                 |    2 +
 include/linux/hardirq.h                            |    2 -
 include/linux/i2c/atmel_mxt_ts.h                   |    5 +
 include/linux/idr.h                                |   68 +-
 include/linux/iio/common/st_sensors.h              |    9 +-
 include/linux/list.h                               |    4 +-
 include/linux/mfd/palmas.h                         |    1 +
 include/linux/mfd/tps65912.h                       |    1 +
 include/linux/mfd/wm831x/auxadc.h                  |    2 +
 include/linux/mfd/wm831x/core.h                    |    2 +-
 include/linux/netfilter/ipset/ip_set_ahash.h       |    4 +-
 include/linux/perf_event.h                         |    6 +
 include/linux/regulator/driver.h                   |    2 +
 include/linux/res_counter.h                        |    1 +
 include/linux/smpboot.h                            |    4 +
 include/linux/sunrpc/clnt.h                        |    1 +
 include/linux/sunrpc/gss_api.h                     |    6 +
 include/linux/sunrpc/msg_prot.h                    |    3 +
 include/linux/sunrpc/xprt.h                        |    1 +
 include/linux/usb/composite.h                      |    3 +-
 include/net/tcp.h                                  |    4 +
 include/uapi/linux/acct.h                          |    6 +-
 include/uapi/linux/aio_abi.h                       |    4 +-
 include/uapi/linux/raid/md_p.h                     |    6 +-
 include/uapi/linux/serial_core.h                   |    5 +-
 init/Kconfig                                       |    4 -
 ipc/msg.c                                          |    6 +-
 ipc/msgutil.c                                      |    3 -
 kernel/fork.c                                      |    5 +-
 kernel/futex.c                                     |   46 +-
 kernel/signal.c                                    |    5 +-
 kernel/smpboot.c                                   |    4 +-
 kernel/softirq.c                                   |   21 +-
 kernel/stop_machine.c                              |    2 +-
 kernel/trace/Kconfig                               |   24 +-
 kernel/trace/trace.c                               |   27 +-
 kernel/user_namespace.c                            |    4 +
 kernel/workqueue.c                                 |    7 +-
 lib/idr.c                                          |   96 +-
 lib/xz/Kconfig                                     |    2 +-
 mm/Kconfig                                         |    8 +-
 mm/fremap.c                                        |    5 +-
 mm/ksm.c                                           |    2 +-
 mm/memcontrol.c                                    |    8 +-
 mm/memory_hotplug.c                                |    2 +-
 mm/mempolicy.c                                     |    4 +-
 mm/process_vm_access.c                             |    8 -
 net/9p/trans_virtio.c                              |    2 +-
 net/bridge/br_device.c                             |    2 +-
 net/bridge/br_input.c                              |    2 +-
 net/bridge/br_mdb.c                                |    4 +
 net/bridge/br_multicast.c                          |    3 +-
 net/bridge/br_private.h                            |    4 +-
 net/caif/caif_dev.c                                |    2 +-
 net/caif/caif_usb.c                                |    4 +-
 net/ceph/osdmap.c                                  |   42 +-
 net/core/dev.c                                     |    5 +-
 net/core/rtnetlink.c                               |    1 +
 net/dcb/dcbnl.c                                    |    8 +
 net/ieee802154/6lowpan.h                           |    2 +-
 net/ipv4/inet_connection_sock.c                    |    1 +
 net/ipv4/ip_input.c                                |    6 +-
 net/ipv4/ip_options.c                              |    2 +-
 net/ipv4/tcp_input.c                               |    6 +-
 net/ipv6/ip6_input.c                               |    9 +-
 net/ipv6/route.c                                   |    3 +-
 net/irda/ircomm/ircomm_tty.c                       |   29 +-
 net/irda/iriap.c                                   |    7 +-
 net/key/af_key.c                                   |    8 +-
 net/l2tp/l2tp_ppp.c                                |    1 +
 net/mac80211/cfg.c                                 |   11 +
 net/mac80211/iface.c                               |    8 +-
 net/mac80211/mlme.c                                |   28 +-
 net/mac80211/tx.c                                  |   80 +-
 net/netfilter/ipset/ip_set_core.c                  |    3 +-
 net/netfilter/nf_conntrack_helper.c                |   11 +-
 net/netfilter/nfnetlink.c                          |    7 +-
 net/netfilter/xt_AUDIT.c                           |    3 +
 net/netlabel/netlabel_unlabeled.c                  |   27 +-
 net/rds/message.c                                  |    8 +-
 net/rds/stats.c                                    |    1 +
 net/sched/sch_qfq.c                                |   66 +-
 net/sctp/endpointola.c                             |    2 +-
 net/sctp/socket.c                                  |    6 +-
 net/sctp/ssnmap.c                                  |    8 +-
 net/sctp/tsnmap.c                                  |   13 +-
 net/sctp/ulpqueue.c                                |   87 +-
 net/sunrpc/auth_gss/Makefile                       |    3 +-
 net/sunrpc/auth_gss/auth_gss.c                     |    2 +-
 net/sunrpc/auth_gss/gss_krb5_mech.c                |    7 +-
 net/sunrpc/auth_gss/gss_mech_switch.c              |    7 +-
 net/sunrpc/auth_gss/gss_rpc_upcall.c               |  358 +++++
 net/sunrpc/auth_gss/gss_rpc_upcall.h               |   48 +
 net/sunrpc/auth_gss/gss_rpc_xdr.c                  |  838 +++++++++++
 net/sunrpc/auth_gss/gss_rpc_xdr.h                  |  264 ++++
 net/sunrpc/auth_gss/svcauth_gss.c                  |  375 ++++-
 net/sunrpc/cache.c                                 |    4 +-
 net/sunrpc/clnt.c                                  |    3 +
 net/sunrpc/netns.h                                 |    6 +
 net/sunrpc/rpc_pipe.c                              |    5 +-
 net/sunrpc/xprt.c                                  |    2 +
 net/sunrpc/xprtsock.c                              |   18 +-
 net/wireless/core.c                                |    3 +-
 net/wireless/nl80211.c                             |  110 +-
 scripts/Makefile.headersinst                       |   11 +-
 security/keys/compat.c                             |    4 +-
 security/keys/process_keys.c                       |    4 +-
 sound/core/seq/oss/seq_oss_event.c                 |   14 +-
 sound/core/seq/seq_timer.c                         |    8 +-
 sound/core/vmaster.c                               |    5 +-
 sound/oss/sequencer.c                              |    6 +
 sound/pci/asihpi/asihpi.c                          |    3 +-
 sound/pci/hda/hda_codec.c                          |   35 +-
 sound/pci/hda/patch_ca0132.c                       |   36 +-
 sound/pci/hda/patch_cirrus.c                       |    4 +
 sound/pci/hda/patch_realtek.c                      |    2 +
 sound/pci/hda/patch_sigmatel.c                     |   29 +
 sound/pci/ice1712/ice1712.c                        |    2 +
 sound/soc/codecs/wm5102.c                          |   15 +-
 sound/soc/codecs/wm5110.c                          |   16 +-
 sound/soc/codecs/wm8350.c                          |    4 +-
 sound/soc/codecs/wm8960.c                          |    8 +-
 sound/soc/tegra/tegra20_i2s.h                      |    2 +-
 sound/soc/tegra/tegra30_i2s.h                      |    2 +-
 sound/usb/card.c                                   |   15 +
 tools/testing/selftests/efivarfs/efivarfs.sh       |   59 +
 tools/usb/ffs-test.c                               |    2 +-
 663 files changed, 9300 insertions(+), 3531 deletions(-)
 create mode 100644 Documentation/filesystems/nfs/rpc-server-gss.txt
 create mode 100644 drivers/net/usb/ax88179_178a.c
 create mode 100644 fs/nfsd/xdr4cb.h
 create mode 100644 net/sunrpc/auth_gss/gss_rpc_upcall.c
 create mode 100644 net/sunrpc/auth_gss/gss_rpc_upcall.h
 create mode 100644 net/sunrpc/auth_gss/gss_rpc_xdr.c
 create mode 100644 net/sunrpc/auth_gss/gss_rpc_xdr.h

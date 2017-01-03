Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from host.76.145.23.62.rev.coltfrance.com ([62.23.145.76]:38590 "EHLO
        proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934233AbdACOqv (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 3 Jan 2017 09:46:51 -0500
From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org,
        dri-devel@lists.freedesktop.org, netdev@vger.kernel.org,
        linux-media@vger.kernel.org, linux-mmc@vger.kernel.org,
        netfilter-devel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-raid@vger.kernel.org, linux-spi@vger.kernel.org,
        linux-mtd@lists.infradead.org, linux-rdma@vger.kernel.org,
        fcoe-devel@open-fcoe.org, alsa-devel@alsa-project.org,
        linux-fbdev@vger.kernel.org, xen-devel@lists.xenproject.org,
        arnd@arndb.de, davem@davemloft.net, airlied@linux.ie
Cc: nicolas.dichtel@6wind.com
Subject: [PATCH] uapi: use wildcards to list files
Date: Tue,  3 Jan 2017 15:35:44 +0100
Message-Id: <1483454144-10519-1-git-send-email-nicolas.dichtel@6wind.com>
In-Reply-To: <20161203.192346.1198940437155108508.davem@davemloft.net>
References: <20161203.192346.1198940437155108508.davem@davemloft.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Regularly, when a new header is created in include/uapi/, the developer
forgets to add it in the corresponding Kbuild file. This error is usually
detected after the release is out.

In fact, all headers under include/uapi/ should be exported, so let's
use wildcards.

After this patch, the following files, which were not exported, are now
exported:
drm/vgem_drm.h
drm/armada_drm.h
drm/omap_drm.h
drm/etnaviv_drm.h
rdma/qedr-abi.h
linux/bcache.h
linux/kfd_ioctl.h
linux/cryptouser.h
linux/kcm.h
linux/kcov.h
linux/seg6_iptunnel.h
linux/stm.h
linux/seg6.h
linux/auto_dev-ioctl.h
linux/userio.h
linux/pr.h
linux/wil6210_uapi.h
linux/nilfs2_ondisk.h
linux/hash_info.h
linux/seg6_genl.h
linux/seg6_hmac.h
linux/batman_adv.h
linux/nsfs.h
linux/qrtr.h
linux/btrfs_tree.h
linux/coresight-stm.h
linux/dma-buf.h
linux/module.h
linux/lightnvm.h
linux/nilfs2_api.h

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---

This patch is built against linus tree. I don't know if it should be
done against antoher tree.

Comments are welcomed,
Nicolas

 include/uapi/asm-generic/Kbuild            |  36 +--
 include/uapi/drm/Kbuild                    |  22 +-
 include/uapi/linux/Kbuild                  | 463 +----------------------------
 include/uapi/linux/android/Kbuild          |   2 +-
 include/uapi/linux/byteorder/Kbuild        |   3 +-
 include/uapi/linux/caif/Kbuild             |   3 +-
 include/uapi/linux/can/Kbuild              |   6 +-
 include/uapi/linux/dvb/Kbuild              |   9 +-
 include/uapi/linux/hdlc/Kbuild             |   2 +-
 include/uapi/linux/hsi/Kbuild              |   2 +-
 include/uapi/linux/iio/Kbuild              |   3 +-
 include/uapi/linux/isdn/Kbuild             |   2 +-
 include/uapi/linux/mmc/Kbuild              |   2 +-
 include/uapi/linux/netfilter/Kbuild        |  88 +-----
 include/uapi/linux/netfilter/ipset/Kbuild  |   5 +-
 include/uapi/linux/netfilter_arp/Kbuild    |   3 +-
 include/uapi/linux/netfilter_bridge/Kbuild |  18 +-
 include/uapi/linux/netfilter_ipv4/Kbuild   |  10 +-
 include/uapi/linux/netfilter_ipv6/Kbuild   |  13 +-
 include/uapi/linux/nfsd/Kbuild             |   6 +-
 include/uapi/linux/raid/Kbuild             |   3 +-
 include/uapi/linux/spi/Kbuild              |   2 +-
 include/uapi/linux/sunrpc/Kbuild           |   2 +-
 include/uapi/linux/tc_act/Kbuild           |  15 +-
 include/uapi/linux/tc_ematch/Kbuild        |   5 +-
 include/uapi/linux/usb/Kbuild              |  12 +-
 include/uapi/linux/wimax/Kbuild            |   2 +-
 include/uapi/misc/Kbuild                   |   2 +-
 include/uapi/mtd/Kbuild                    |   6 +-
 include/uapi/rdma/Kbuild                   |  17 +-
 include/uapi/rdma/hfi/Kbuild               |   2 +-
 include/uapi/scsi/Kbuild                   |   5 +-
 include/uapi/scsi/fc/Kbuild                |   5 +-
 include/uapi/sound/Kbuild                  |  16 +-
 include/uapi/video/Kbuild                  |   4 +-
 include/uapi/xen/Kbuild                    |   5 +-
 36 files changed, 47 insertions(+), 754 deletions(-)

diff --git a/include/uapi/asm-generic/Kbuild b/include/uapi/asm-generic/Kbuild
index b73de7bb7a62..8e52cdc3d941 100644
--- a/include/uapi/asm-generic/Kbuild
+++ b/include/uapi/asm-generic/Kbuild
@@ -1,36 +1,2 @@
 # UAPI Header export list
-header-y += auxvec.h
-header-y += bitsperlong.h
-header-y += errno-base.h
-header-y += errno.h
-header-y += fcntl.h
-header-y += int-l64.h
-header-y += int-ll64.h
-header-y += ioctl.h
-header-y += ioctls.h
-header-y += ipcbuf.h
-header-y += kvm_para.h
-header-y += mman-common.h
-header-y += mman.h
-header-y += msgbuf.h
-header-y += param.h
-header-y += poll.h
-header-y += posix_types.h
-header-y += resource.h
-header-y += sembuf.h
-header-y += setup.h
-header-y += shmbuf.h
-header-y += shmparam.h
-header-y += siginfo.h
-header-y += signal-defs.h
-header-y += signal.h
-header-y += socket.h
-header-y += sockios.h
-header-y += stat.h
-header-y += statfs.h
-header-y += swab.h
-header-y += termbits.h
-header-y += termios.h
-header-y += types.h
-header-y += ucontext.h
-header-y += unistd.h
+header-y += $(notdir $(wildcard $(srctree)/include/uapi/asm-generic/*.h))
diff --git a/include/uapi/drm/Kbuild b/include/uapi/drm/Kbuild
index 9355dd8eff3b..75f4cde6d9ba 100644
--- a/include/uapi/drm/Kbuild
+++ b/include/uapi/drm/Kbuild
@@ -1,22 +1,2 @@
 # UAPI Header export list
-header-y += drm.h
-header-y += drm_fourcc.h
-header-y += drm_mode.h
-header-y += drm_sarea.h
-header-y += amdgpu_drm.h
-header-y += exynos_drm.h
-header-y += i810_drm.h
-header-y += i915_drm.h
-header-y += mga_drm.h
-header-y += nouveau_drm.h
-header-y += qxl_drm.h
-header-y += r128_drm.h
-header-y += radeon_drm.h
-header-y += savage_drm.h
-header-y += sis_drm.h
-header-y += tegra_drm.h
-header-y += via_drm.h
-header-y += vmwgfx_drm.h
-header-y += msm_drm.h
-header-y += vc4_drm.h
-header-y += virtgpu_drm.h
+header-y += $(notdir $(wildcard $(srctree)/include/uapi/drm/*.h))
diff --git a/include/uapi/linux/Kbuild b/include/uapi/linux/Kbuild
index a8b93e685239..9d2d4ebc1e5c 100644
--- a/include/uapi/linux/Kbuild
+++ b/include/uapi/linux/Kbuild
@@ -25,458 +25,19 @@ header-y += wimax/
 
 genhdr-y += version.h
 
-ifneq ($(wildcard $(srctree)/arch/$(SRCARCH)/include/uapi/asm/a.out.h \
-		  $(srctree)/arch/$(SRCARCH)/include/asm/a.out.h),)
-header-y += a.out.h
-endif
-
-header-y += acct.h
-header-y += adb.h
-header-y += adfs_fs.h
-header-y += affs_hardblocks.h
-header-y += agpgart.h
-header-y += aio_abi.h
-header-y += am437x-vpfe.h
-header-y += apm_bios.h
-header-y += arcfb.h
-header-y += atalk.h
-header-y += atmapi.h
-header-y += atmarp.h
-header-y += atmbr2684.h
-header-y += atmclip.h
-header-y += atmdev.h
-header-y += atm_eni.h
-header-y += atm.h
-header-y += atm_he.h
-header-y += atm_idt77105.h
-header-y += atmioc.h
-header-y += atmlec.h
-header-y += atmmpc.h
-header-y += atm_nicstar.h
-header-y += atmppp.h
-header-y += atmsap.h
-header-y += atmsvc.h
-header-y += atm_tcp.h
-header-y += atm_zatm.h
-header-y += audit.h
-header-y += auto_fs4.h
-header-y += auto_fs.h
-header-y += auxvec.h
-header-y += ax25.h
-header-y += b1lli.h
-header-y += baycom.h
-header-y += bcm933xx_hcs.h
-header-y += bfs_fs.h
-header-y += binfmts.h
-header-y += blkpg.h
-header-y += blktrace_api.h
-header-y += blkzoned.h
-header-y += bpf_common.h
-header-y += bpf_perf_event.h
-header-y += bpf.h
-header-y += bpqether.h
-header-y += bsg.h
-header-y += bt-bmc.h
-header-y += btrfs.h
-header-y += can.h
-header-y += capability.h
-header-y += capi.h
-header-y += cciss_defs.h
-header-y += cciss_ioctl.h
-header-y += cdrom.h
-header-y += cec.h
-header-y += cec-funcs.h
-header-y += cgroupstats.h
-header-y += chio.h
-header-y += cm4000_cs.h
-header-y += cn_proc.h
-header-y += coda.h
-header-y += coda_psdev.h
-header-y += coff.h
-header-y += connector.h
-header-y += const.h
-header-y += cramfs_fs.h
-header-y += cuda.h
-header-y += cyclades.h
-header-y += cycx_cfm.h
-header-y += dcbnl.h
-header-y += dccp.h
-header-y += devlink.h
-header-y += dlmconstants.h
-header-y += dlm_device.h
-header-y += dlm.h
-header-y += dlm_netlink.h
-header-y += dlm_plock.h
-header-y += dm-ioctl.h
-header-y += dm-log-userspace.h
-header-y += dn.h
-header-y += dqblk_xfs.h
-header-y += edd.h
-header-y += efs_fs_sb.h
-header-y += elfcore.h
-header-y += elf-em.h
-header-y += elf-fdpic.h
-header-y += elf.h
-header-y += errno.h
-header-y += errqueue.h
-header-y += ethtool.h
-header-y += eventpoll.h
-header-y += fadvise.h
-header-y += falloc.h
-header-y += fanotify.h
-header-y += fb.h
-header-y += fcntl.h
-header-y += fd.h
-header-y += fdreg.h
-header-y += fib_rules.h
-header-y += fiemap.h
-header-y += filter.h
-header-y += firewire-cdev.h
-header-y += firewire-constants.h
-header-y += flat.h
-header-y += fou.h
-header-y += fs.h
-header-y += fsl_hypervisor.h
-header-y += fuse.h
-header-y += futex.h
-header-y += gameport.h
-header-y += genetlink.h
-header-y += gen_stats.h
-header-y += gfs2_ondisk.h
-header-y += gigaset_dev.h
-header-y += gpio.h
-header-y += gsmmux.h
-header-y += gtp.h
-header-y += hdlcdrv.h
-header-y += hdlc.h
-header-y += hdreg.h
-header-y += hiddev.h
-header-y += hid.h
-header-y += hidraw.h
-header-y += hpet.h
-header-y += hsr_netlink.h
-header-y += hyperv.h
-header-y += hysdn_if.h
-header-y += i2c-dev.h
-header-y += i2c.h
-header-y += i2o-dev.h
-header-y += i8k.h
-header-y += icmp.h
-header-y += icmpv6.h
-header-y += if_addr.h
-header-y += if_addrlabel.h
-header-y += if_alg.h
-header-y += if_arcnet.h
-header-y += if_arp.h
-header-y += if_bonding.h
-header-y += if_bridge.h
-header-y += if_cablemodem.h
-header-y += if_eql.h
-header-y += if_ether.h
-header-y += if_fc.h
-header-y += if_fddi.h
-header-y += if_frad.h
-header-y += if.h
-header-y += if_hippi.h
-header-y += if_infiniband.h
-header-y += if_link.h
-header-y += if_ltalk.h
-header-y += if_macsec.h
-header-y += if_packet.h
-header-y += if_phonet.h
-header-y += if_plip.h
-header-y += if_ppp.h
-header-y += if_pppol2tp.h
-header-y += if_pppox.h
-header-y += if_slip.h
-header-y += if_team.h
-header-y += if_tun.h
-header-y += if_tunnel.h
-header-y += if_vlan.h
-header-y += if_x25.h
-header-y += igmp.h
-header-y += ila.h
-header-y += in6.h
-header-y += inet_diag.h
-header-y += in.h
-header-y += inotify.h
-header-y += input.h
-header-y += input-event-codes.h
-header-y += in_route.h
-header-y += ioctl.h
-header-y += ip6_tunnel.h
-header-y += ipc.h
-header-y += ip.h
-header-y += ipmi.h
-header-y += ipmi_msgdefs.h
-header-y += ipsec.h
-header-y += ipv6.h
-header-y += ipv6_route.h
-header-y += ip_vs.h
-header-y += ipx.h
-header-y += irda.h
-header-y += irqnr.h
-header-y += isdn_divertif.h
-header-y += isdn.h
-header-y += isdnif.h
-header-y += isdn_ppp.h
-header-y += iso_fs.h
-header-y += ivtvfb.h
-header-y += ivtv.h
-header-y += ixjuser.h
-header-y += jffs2.h
-header-y += joystick.h
-header-y += kcmp.h
-header-y += kdev_t.h
-header-y += kd.h
-header-y += kernelcapi.h
-header-y += kernel.h
-header-y += kernel-page-flags.h
-header-y += kexec.h
-header-y += keyboard.h
-header-y += keyctl.h
+tmphdr-y := $(notdir $(wildcard $(srctree)/include/uapi/linux/*.h))
 
-ifneq ($(wildcard $(srctree)/arch/$(SRCARCH)/include/uapi/asm/kvm.h \
-		  $(srctree)/arch/$(SRCARCH)/include/asm/kvm.h),)
-header-y += kvm.h
+ifeq ($(wildcard $(srctree)/arch/$(SRCARCH)/include/uapi/asm/a.out.h \
+		 $(srctree)/arch/$(SRCARCH)/include/asm/a.out.h),)
+tmphdr-y = $(filter-out a.out.h $(tmphdr-y))
 endif
-
-
-ifneq ($(wildcard $(srctree)/arch/$(SRCARCH)/include/uapi/asm/kvm_para.h \
-		  $(srctree)/arch/$(SRCARCH)/include/asm/kvm_para.h),)
-header-y += kvm_para.h
+ifeq ($(wildcard $(srctree)/arch/$(SRCARCH)/include/uapi/asm/kvm.h \
+		 $(srctree)/arch/$(SRCARCH)/include/asm/kvm.h),)
+tmphdr-y = $(filter-out kvm.h $(tmphdr-y))
+endif
+ifeq ($(wildcard $(srctree)/arch/$(SRCARCH)/include/uapi/asm/kvm_para.h \
+		 $(srctree)/arch/$(SRCARCH)/include/asm/kvm_para.h),)
+tmphdr-y = $(filter-out kvm_para.h $(tmphdr-y))
 endif
 
-header-y += hw_breakpoint.h
-header-y += l2tp.h
-header-y += libc-compat.h
-header-y += lirc.h
-header-y += limits.h
-header-y += llc.h
-header-y += loop.h
-header-y += lp.h
-header-y += lwtunnel.h
-header-y += magic.h
-header-y += major.h
-header-y += map_to_7segment.h
-header-y += matroxfb.h
-header-y += mdio.h
-header-y += media.h
-header-y += media-bus-format.h
-header-y += mei.h
-header-y += membarrier.h
-header-y += memfd.h
-header-y += mempolicy.h
-header-y += meye.h
-header-y += mic_common.h
-header-y += mic_ioctl.h
-header-y += mii.h
-header-y += minix_fs.h
-header-y += mman.h
-header-y += mmtimer.h
-header-y += mpls.h
-header-y += mpls_iptunnel.h
-header-y += mqueue.h
-header-y += mroute6.h
-header-y += mroute.h
-header-y += msdos_fs.h
-header-y += msg.h
-header-y += mtio.h
-header-y += nbd.h
-header-y += ncp_fs.h
-header-y += ncp.h
-header-y += ncp_mount.h
-header-y += ncp_no.h
-header-y += ndctl.h
-header-y += neighbour.h
-header-y += netconf.h
-header-y += netdevice.h
-header-y += net_dropmon.h
-header-y += netfilter_arp.h
-header-y += netfilter_bridge.h
-header-y += netfilter_decnet.h
-header-y += netfilter.h
-header-y += netfilter_ipv4.h
-header-y += netfilter_ipv6.h
-header-y += net.h
-header-y += netlink_diag.h
-header-y += netlink.h
-header-y += netrom.h
-header-y += net_namespace.h
-header-y += net_tstamp.h
-header-y += nfc.h
-header-y += nfs2.h
-header-y += nfs3.h
-header-y += nfs4.h
-header-y += nfs4_mount.h
-header-y += nfsacl.h
-header-y += nfs_fs.h
-header-y += nfs.h
-header-y += nfs_idmap.h
-header-y += nfs_mount.h
-header-y += nl80211.h
-header-y += n_r3964.h
-header-y += nubus.h
-header-y += nvme_ioctl.h
-header-y += nvram.h
-header-y += omap3isp.h
-header-y += omapfb.h
-header-y += oom.h
-header-y += openvswitch.h
-header-y += packet_diag.h
-header-y += param.h
-header-y += parport.h
-header-y += patchkey.h
-header-y += pci.h
-header-y += pci_regs.h
-header-y += perf_event.h
-header-y += personality.h
-header-y += pfkeyv2.h
-header-y += pg.h
-header-y += phantom.h
-header-y += phonet.h
-header-y += pktcdvd.h
-header-y += pkt_cls.h
-header-y += pkt_sched.h
-header-y += pmu.h
-header-y += poll.h
-header-y += posix_acl.h
-header-y += posix_acl_xattr.h
-header-y += posix_types.h
-header-y += ppdev.h
-header-y += ppp-comp.h
-header-y += ppp_defs.h
-header-y += ppp-ioctl.h
-header-y += pps.h
-header-y += prctl.h
-header-y += psci.h
-header-y += ptp_clock.h
-header-y += ptrace.h
-header-y += qnx4_fs.h
-header-y += qnxtypes.h
-header-y += quota.h
-header-y += radeonfb.h
-header-y += random.h
-header-y += raw.h
-header-y += rds.h
-header-y += reboot.h
-header-y += reiserfs_fs.h
-header-y += reiserfs_xattr.h
-header-y += resource.h
-header-y += rfkill.h
-header-y += rio_cm_cdev.h
-header-y += rio_mport_cdev.h
-header-y += romfs_fs.h
-header-y += rose.h
-header-y += route.h
-header-y += rtc.h
-header-y += rtnetlink.h
-header-y += scc.h
-header-y += sched.h
-header-y += scif_ioctl.h
-header-y += screen_info.h
-header-y += sctp.h
-header-y += sdla.h
-header-y += seccomp.h
-header-y += securebits.h
-header-y += selinux_netlink.h
-header-y += sem.h
-header-y += serial_core.h
-header-y += serial.h
-header-y += serial_reg.h
-header-y += serio.h
-header-y += shm.h
-header-y += signalfd.h
-header-y += signal.h
-header-y += smiapp.h
-header-y += snmp.h
-header-y += sock_diag.h
-header-y += socket.h
-header-y += sockios.h
-header-y += sonet.h
-header-y += sonypi.h
-header-y += soundcard.h
-header-y += sound.h
-header-y += stat.h
-header-y += stddef.h
-header-y += string.h
-header-y += suspend_ioctls.h
-header-y += swab.h
-header-y += synclink.h
-header-y += sync_file.h
-header-y += sysctl.h
-header-y += sysinfo.h
-header-y += target_core_user.h
-header-y += taskstats.h
-header-y += tcp.h
-header-y += tcp_metrics.h
-header-y += telephony.h
-header-y += termios.h
-header-y += thermal.h
-header-y += time.h
-header-y += times.h
-header-y += timex.h
-header-y += tiocl.h
-header-y += tipc_config.h
-header-y += tipc_netlink.h
-header-y += tipc.h
-header-y += toshiba.h
-header-y += tty_flags.h
-header-y += tty.h
-header-y += types.h
-header-y += udf_fs_i.h
-header-y += udp.h
-header-y += uhid.h
-header-y += uinput.h
-header-y += uio.h
-header-y += uleds.h
-header-y += ultrasound.h
-header-y += un.h
-header-y += unistd.h
-header-y += unix_diag.h
-header-y += usbdevice_fs.h
-header-y += usbip.h
-header-y += utime.h
-header-y += utsname.h
-header-y += uuid.h
-header-y += uvcvideo.h
-header-y += v4l2-common.h
-header-y += v4l2-controls.h
-header-y += v4l2-dv-timings.h
-header-y += v4l2-mediabus.h
-header-y += v4l2-subdev.h
-header-y += veth.h
-header-y += vfio.h
-header-y += vhost.h
-header-y += videodev2.h
-header-y += virtio_9p.h
-header-y += virtio_balloon.h
-header-y += virtio_blk.h
-header-y += virtio_config.h
-header-y += virtio_console.h
-header-y += virtio_gpu.h
-header-y += virtio_ids.h
-header-y += virtio_input.h
-header-y += virtio_net.h
-header-y += virtio_pci.h
-header-y += virtio_ring.h
-header-y += virtio_rng.h
-header-y += virtio_scsi.h
-header-y += virtio_types.h
-header-y += virtio_vsock.h
-header-y += virtio_crypto.h
-header-y += vm_sockets.h
-header-y += vt.h
-header-y += vtpm_proxy.h
-header-y += wait.h
-header-y += wanrouter.h
-header-y += watchdog.h
-header-y += wimax.h
-header-y += wireless.h
-header-y += x25.h
-header-y += xattr.h
-header-y += xfrm.h
-header-y += xilinx-v4l2-controls.h
-header-y += zorro.h
-header-y += zorro_ids.h
-header-y += userfaultfd.h
+header-y += $(tmphdr-y)
diff --git a/include/uapi/linux/android/Kbuild b/include/uapi/linux/android/Kbuild
index ca011eec252a..37a629f4746a 100644
--- a/include/uapi/linux/android/Kbuild
+++ b/include/uapi/linux/android/Kbuild
@@ -1,2 +1,2 @@
 # UAPI Header export list
-header-y += binder.h
+header-y += $(notdir $(wildcard $(srctree)/include/uapi/linux/android/*.h))
diff --git a/include/uapi/linux/byteorder/Kbuild b/include/uapi/linux/byteorder/Kbuild
index 619225b9ff2e..d6585c79597c 100644
--- a/include/uapi/linux/byteorder/Kbuild
+++ b/include/uapi/linux/byteorder/Kbuild
@@ -1,3 +1,2 @@
 # UAPI Header export list
-header-y += big_endian.h
-header-y += little_endian.h
+header-y += $(notdir $(wildcard $(srctree)/include/uapi/linux/byteorder/*.h))
diff --git a/include/uapi/linux/caif/Kbuild b/include/uapi/linux/caif/Kbuild
index 43396612d3a3..0deed17a523c 100644
--- a/include/uapi/linux/caif/Kbuild
+++ b/include/uapi/linux/caif/Kbuild
@@ -1,3 +1,2 @@
 # UAPI Header export list
-header-y += caif_socket.h
-header-y += if_caif.h
+header-y += $(notdir $(wildcard $(srctree)/include/uapi/linux/caif/*.h))
diff --git a/include/uapi/linux/can/Kbuild b/include/uapi/linux/can/Kbuild
index 21c91bf25a29..0b7f01ea62d6 100644
--- a/include/uapi/linux/can/Kbuild
+++ b/include/uapi/linux/can/Kbuild
@@ -1,6 +1,2 @@
 # UAPI Header export list
-header-y += bcm.h
-header-y += error.h
-header-y += gw.h
-header-y += netlink.h
-header-y += raw.h
+header-y += $(notdir $(wildcard $(srctree)/include/uapi/linux/can/*.h))
diff --git a/include/uapi/linux/dvb/Kbuild b/include/uapi/linux/dvb/Kbuild
index d40942cfc627..6845c2b87161 100644
--- a/include/uapi/linux/dvb/Kbuild
+++ b/include/uapi/linux/dvb/Kbuild
@@ -1,9 +1,2 @@
 # UAPI Header export list
-header-y += audio.h
-header-y += ca.h
-header-y += dmx.h
-header-y += frontend.h
-header-y += net.h
-header-y += osd.h
-header-y += version.h
-header-y += video.h
+header-y += $(notdir $(wildcard $(srctree)/include/uapi/linux/dvb/*.h))
diff --git a/include/uapi/linux/hdlc/Kbuild b/include/uapi/linux/hdlc/Kbuild
index 8c1d2cb75e33..529c2c839277 100644
--- a/include/uapi/linux/hdlc/Kbuild
+++ b/include/uapi/linux/hdlc/Kbuild
@@ -1,2 +1,2 @@
 # UAPI Header export list
-header-y += ioctl.h
+header-y += $(notdir $(wildcard $(srctree)/include/uapi/linux/hdlc/*.h))
diff --git a/include/uapi/linux/hsi/Kbuild b/include/uapi/linux/hsi/Kbuild
index a16a00544258..8f59b8f5f8e5 100644
--- a/include/uapi/linux/hsi/Kbuild
+++ b/include/uapi/linux/hsi/Kbuild
@@ -1,2 +1,2 @@
 # UAPI Header export list
-header-y += hsi_char.h cs-protocol.h
+header-y += $(notdir $(wildcard $(srctree)/include/uapi/linux/hsi/*.h))
diff --git a/include/uapi/linux/iio/Kbuild b/include/uapi/linux/iio/Kbuild
index 86f76d84c44f..aa6f9887cc4e 100644
--- a/include/uapi/linux/iio/Kbuild
+++ b/include/uapi/linux/iio/Kbuild
@@ -1,3 +1,2 @@
 # UAPI Header export list
-header-y += events.h
-header-y += types.h
+header-y += $(notdir $(wildcard $(srctree)/include/uapi/linux/iio/*.h))
diff --git a/include/uapi/linux/isdn/Kbuild b/include/uapi/linux/isdn/Kbuild
index 89e52850bf29..1e842431b0a8 100644
--- a/include/uapi/linux/isdn/Kbuild
+++ b/include/uapi/linux/isdn/Kbuild
@@ -1,2 +1,2 @@
 # UAPI Header export list
-header-y += capicmd.h
+header-y += $(notdir $(wildcard $(srctree)/include/uapi/linux/isdn/*.h))
diff --git a/include/uapi/linux/mmc/Kbuild b/include/uapi/linux/mmc/Kbuild
index 8c1d2cb75e33..02d0c0605d1a 100644
--- a/include/uapi/linux/mmc/Kbuild
+++ b/include/uapi/linux/mmc/Kbuild
@@ -1,2 +1,2 @@
 # UAPI Header export list
-header-y += ioctl.h
+header-y += $(notdir $(wildcard $(srctree)/include/uapi/linux/mmc/*.h))
diff --git a/include/uapi/linux/netfilter/Kbuild b/include/uapi/linux/netfilter/Kbuild
index 03f194aeadc5..a27c332c489c 100644
--- a/include/uapi/linux/netfilter/Kbuild
+++ b/include/uapi/linux/netfilter/Kbuild
@@ -1,89 +1,3 @@
 # UAPI Header export list
 header-y += ipset/
-header-y += nf_conntrack_common.h
-header-y += nf_conntrack_ftp.h
-header-y += nf_conntrack_sctp.h
-header-y += nf_conntrack_tcp.h
-header-y += nf_conntrack_tuple_common.h
-header-y += nf_log.h
-header-y += nf_tables.h
-header-y += nf_tables_compat.h
-header-y += nf_nat.h
-header-y += nfnetlink.h
-header-y += nfnetlink_acct.h
-header-y += nfnetlink_compat.h
-header-y += nfnetlink_conntrack.h
-header-y += nfnetlink_cthelper.h
-header-y += nfnetlink_cttimeout.h
-header-y += nfnetlink_log.h
-header-y += nfnetlink_queue.h
-header-y += x_tables.h
-header-y += xt_AUDIT.h
-header-y += xt_CHECKSUM.h
-header-y += xt_CLASSIFY.h
-header-y += xt_CONNMARK.h
-header-y += xt_CONNSECMARK.h
-header-y += xt_CT.h
-header-y += xt_DSCP.h
-header-y += xt_HMARK.h
-header-y += xt_IDLETIMER.h
-header-y += xt_LED.h
-header-y += xt_LOG.h
-header-y += xt_MARK.h
-header-y += xt_NFLOG.h
-header-y += xt_NFQUEUE.h
-header-y += xt_RATEEST.h
-header-y += xt_SECMARK.h
-header-y += xt_SYNPROXY.h
-header-y += xt_TCPMSS.h
-header-y += xt_TCPOPTSTRIP.h
-header-y += xt_TEE.h
-header-y += xt_TPROXY.h
-header-y += xt_addrtype.h
-header-y += xt_bpf.h
-header-y += xt_cgroup.h
-header-y += xt_cluster.h
-header-y += xt_comment.h
-header-y += xt_connbytes.h
-header-y += xt_connlabel.h
-header-y += xt_connlimit.h
-header-y += xt_connmark.h
-header-y += xt_conntrack.h
-header-y += xt_cpu.h
-header-y += xt_dccp.h
-header-y += xt_devgroup.h
-header-y += xt_dscp.h
-header-y += xt_ecn.h
-header-y += xt_esp.h
-header-y += xt_hashlimit.h
-header-y += xt_helper.h
-header-y += xt_ipcomp.h
-header-y += xt_iprange.h
-header-y += xt_ipvs.h
-header-y += xt_l2tp.h
-header-y += xt_length.h
-header-y += xt_limit.h
-header-y += xt_mac.h
-header-y += xt_mark.h
-header-y += xt_multiport.h
-header-y += xt_nfacct.h
-header-y += xt_osf.h
-header-y += xt_owner.h
-header-y += xt_physdev.h
-header-y += xt_pkttype.h
-header-y += xt_policy.h
-header-y += xt_quota.h
-header-y += xt_rateest.h
-header-y += xt_realm.h
-header-y += xt_recent.h
-header-y += xt_rpfilter.h
-header-y += xt_sctp.h
-header-y += xt_set.h
-header-y += xt_socket.h
-header-y += xt_state.h
-header-y += xt_statistic.h
-header-y += xt_string.h
-header-y += xt_tcpmss.h
-header-y += xt_tcpudp.h
-header-y += xt_time.h
-header-y += xt_u32.h
+header-y += $(notdir $(wildcard $(srctree)/include/uapi/linux/netfilter/*.h))
diff --git a/include/uapi/linux/netfilter/ipset/Kbuild b/include/uapi/linux/netfilter/ipset/Kbuild
index d2680423d9ab..b6dc00483ac2 100644
--- a/include/uapi/linux/netfilter/ipset/Kbuild
+++ b/include/uapi/linux/netfilter/ipset/Kbuild
@@ -1,5 +1,2 @@
 # UAPI Header export list
-header-y += ip_set.h
-header-y += ip_set_bitmap.h
-header-y += ip_set_hash.h
-header-y += ip_set_list.h
+header-y += $(notdir $(wildcard $(srctree)/include/uapi/linux/netfilter/ipset/*.h))
diff --git a/include/uapi/linux/netfilter_arp/Kbuild b/include/uapi/linux/netfilter_arp/Kbuild
index 62d5637cc0ac..63b09feaf660 100644
--- a/include/uapi/linux/netfilter_arp/Kbuild
+++ b/include/uapi/linux/netfilter_arp/Kbuild
@@ -1,3 +1,2 @@
 # UAPI Header export list
-header-y += arp_tables.h
-header-y += arpt_mangle.h
+header-y += $(notdir $(wildcard $(srctree)/include/uapi/linux/netfilter_arp/*.h))
diff --git a/include/uapi/linux/netfilter_bridge/Kbuild b/include/uapi/linux/netfilter_bridge/Kbuild
index 0fbad8ef96de..6bbfc5a91965 100644
--- a/include/uapi/linux/netfilter_bridge/Kbuild
+++ b/include/uapi/linux/netfilter_bridge/Kbuild
@@ -1,18 +1,2 @@
 # UAPI Header export list
-header-y += ebt_802_3.h
-header-y += ebt_among.h
-header-y += ebt_arp.h
-header-y += ebt_arpreply.h
-header-y += ebt_ip.h
-header-y += ebt_ip6.h
-header-y += ebt_limit.h
-header-y += ebt_log.h
-header-y += ebt_mark_m.h
-header-y += ebt_mark_t.h
-header-y += ebt_nat.h
-header-y += ebt_nflog.h
-header-y += ebt_pkttype.h
-header-y += ebt_redirect.h
-header-y += ebt_stp.h
-header-y += ebt_vlan.h
-header-y += ebtables.h
+header-y += $(notdir $(wildcard $(srctree)/include/uapi/linux/netfilter_bridge/*.h))
diff --git a/include/uapi/linux/netfilter_ipv4/Kbuild b/include/uapi/linux/netfilter_ipv4/Kbuild
index ecb291df390e..273777606d02 100644
--- a/include/uapi/linux/netfilter_ipv4/Kbuild
+++ b/include/uapi/linux/netfilter_ipv4/Kbuild
@@ -1,10 +1,2 @@
 # UAPI Header export list
-header-y += ip_tables.h
-header-y += ipt_CLUSTERIP.h
-header-y += ipt_ECN.h
-header-y += ipt_LOG.h
-header-y += ipt_REJECT.h
-header-y += ipt_TTL.h
-header-y += ipt_ah.h
-header-y += ipt_ecn.h
-header-y += ipt_ttl.h
+header-y += $(notdir $(wildcard $(srctree)/include/uapi/linux/netfilter_ipv4/*.h))
diff --git a/include/uapi/linux/netfilter_ipv6/Kbuild b/include/uapi/linux/netfilter_ipv6/Kbuild
index 75a668ca2353..2d3507f5b0aa 100644
--- a/include/uapi/linux/netfilter_ipv6/Kbuild
+++ b/include/uapi/linux/netfilter_ipv6/Kbuild
@@ -1,13 +1,2 @@
 # UAPI Header export list
-header-y += ip6_tables.h
-header-y += ip6t_HL.h
-header-y += ip6t_LOG.h
-header-y += ip6t_NPT.h
-header-y += ip6t_REJECT.h
-header-y += ip6t_ah.h
-header-y += ip6t_frag.h
-header-y += ip6t_hl.h
-header-y += ip6t_ipv6header.h
-header-y += ip6t_mh.h
-header-y += ip6t_opts.h
-header-y += ip6t_rt.h
+header-y += $(notdir $(wildcard $(srctree)/include/uapi/linux/netfilter_ipv6/*.h))
diff --git a/include/uapi/linux/nfsd/Kbuild b/include/uapi/linux/nfsd/Kbuild
index c11bc404053c..b66c1120b54f 100644
--- a/include/uapi/linux/nfsd/Kbuild
+++ b/include/uapi/linux/nfsd/Kbuild
@@ -1,6 +1,2 @@
 # UAPI Header export list
-header-y += cld.h
-header-y += debug.h
-header-y += export.h
-header-y += nfsfh.h
-header-y += stats.h
+header-y += $(notdir $(wildcard $(srctree)/include/uapi/linux/nfsd/*.h))
diff --git a/include/uapi/linux/raid/Kbuild b/include/uapi/linux/raid/Kbuild
index e2c3d25405d7..409aa2ecd82f 100644
--- a/include/uapi/linux/raid/Kbuild
+++ b/include/uapi/linux/raid/Kbuild
@@ -1,3 +1,2 @@
 # UAPI Header export list
-header-y += md_p.h
-header-y += md_u.h
+header-y += $(notdir $(wildcard $(srctree)/include/uapi/linux/raid/*.h))
diff --git a/include/uapi/linux/spi/Kbuild b/include/uapi/linux/spi/Kbuild
index 0cc747eff165..8d269bd5e31a 100644
--- a/include/uapi/linux/spi/Kbuild
+++ b/include/uapi/linux/spi/Kbuild
@@ -1,2 +1,2 @@
 # UAPI Header export list
-header-y += spidev.h
+header-y += $(notdir $(wildcard $(srctree)/include/uapi/linux/spi/*.h))
diff --git a/include/uapi/linux/sunrpc/Kbuild b/include/uapi/linux/sunrpc/Kbuild
index 8e02e47c20fb..4a880e5aeba3 100644
--- a/include/uapi/linux/sunrpc/Kbuild
+++ b/include/uapi/linux/sunrpc/Kbuild
@@ -1,2 +1,2 @@
 # UAPI Header export list
-header-y += debug.h
+header-y += $(notdir $(wildcard $(srctree)/include/uapi/linux/sunrpc/*.h))
diff --git a/include/uapi/linux/tc_act/Kbuild b/include/uapi/linux/tc_act/Kbuild
index e3db7403296f..24f8b1d9a4ed 100644
--- a/include/uapi/linux/tc_act/Kbuild
+++ b/include/uapi/linux/tc_act/Kbuild
@@ -1,15 +1,2 @@
 # UAPI Header export list
-header-y += tc_csum.h
-header-y += tc_defact.h
-header-y += tc_gact.h
-header-y += tc_ipt.h
-header-y += tc_mirred.h
-header-y += tc_nat.h
-header-y += tc_pedit.h
-header-y += tc_skbedit.h
-header-y += tc_vlan.h
-header-y += tc_bpf.h
-header-y += tc_connmark.h
-header-y += tc_ife.h
-header-y += tc_tunnel_key.h
-header-y += tc_skbmod.h
+header-y += $(notdir $(wildcard $(srctree)/include/uapi/linux/tc_act/*.h))
diff --git a/include/uapi/linux/tc_ematch/Kbuild b/include/uapi/linux/tc_ematch/Kbuild
index 53fca3925535..909ef0d196b1 100644
--- a/include/uapi/linux/tc_ematch/Kbuild
+++ b/include/uapi/linux/tc_ematch/Kbuild
@@ -1,5 +1,2 @@
 # UAPI Header export list
-header-y += tc_em_cmp.h
-header-y += tc_em_meta.h
-header-y += tc_em_nbyte.h
-header-y += tc_em_text.h
+header-y += $(notdir $(wildcard $(srctree)/include/uapi/linux/tc_ematch/*.h))
diff --git a/include/uapi/linux/usb/Kbuild b/include/uapi/linux/usb/Kbuild
index 4cc4d6e7e523..4a5eb3f2b704 100644
--- a/include/uapi/linux/usb/Kbuild
+++ b/include/uapi/linux/usb/Kbuild
@@ -1,12 +1,2 @@
 # UAPI Header export list
-header-y += audio.h
-header-y += cdc.h
-header-y += cdc-wdm.h
-header-y += ch11.h
-header-y += ch9.h
-header-y += functionfs.h
-header-y += g_printer.h
-header-y += gadgetfs.h
-header-y += midi.h
-header-y += tmc.h
-header-y += video.h
+header-y += $(notdir $(wildcard $(srctree)/include/uapi/linux/usb/*.h))
diff --git a/include/uapi/linux/wimax/Kbuild b/include/uapi/linux/wimax/Kbuild
index 1c97be49971f..f9f41558ebbe 100644
--- a/include/uapi/linux/wimax/Kbuild
+++ b/include/uapi/linux/wimax/Kbuild
@@ -1,2 +1,2 @@
 # UAPI Header export list
-header-y += i2400m.h
+header-y += $(notdir $(wildcard $(srctree)/include/uapi/linux/wimax/*.h))
diff --git a/include/uapi/misc/Kbuild b/include/uapi/misc/Kbuild
index e96cae7d58c9..c4ad43dfbcfa 100644
--- a/include/uapi/misc/Kbuild
+++ b/include/uapi/misc/Kbuild
@@ -1,2 +1,2 @@
 # misc Header export list
-header-y += cxl.h
+header-y += $(notdir $(wildcard $(srctree)/include/uapi/misc/*.h))
diff --git a/include/uapi/mtd/Kbuild b/include/uapi/mtd/Kbuild
index 5a691e10cd0e..0fbbdecf0302 100644
--- a/include/uapi/mtd/Kbuild
+++ b/include/uapi/mtd/Kbuild
@@ -1,6 +1,2 @@
 # UAPI Header export list
-header-y += inftl-user.h
-header-y += mtd-abi.h
-header-y += mtd-user.h
-header-y += nftl-user.h
-header-y += ubi-user.h
+header-y += $(notdir $(wildcard $(srctree)/include/uapi/mtd/*.h))
diff --git a/include/uapi/rdma/Kbuild b/include/uapi/rdma/Kbuild
index 82bdf5626859..0c51ce6905fb 100644
--- a/include/uapi/rdma/Kbuild
+++ b/include/uapi/rdma/Kbuild
@@ -1,18 +1,3 @@
 # UAPI Header export list
-header-y += ib_user_cm.h
-header-y += ib_user_mad.h
-header-y += ib_user_sa.h
-header-y += ib_user_verbs.h
-header-y += rdma_netlink.h
-header-y += rdma_user_cm.h
 header-y += hfi/
-header-y += rdma_user_rxe.h
-header-y += cxgb3-abi.h
-header-y += cxgb4-abi.h
-header-y += mlx4-abi.h
-header-y += mlx5-abi.h
-header-y += mthca-abi.h
-header-y += nes-abi.h
-header-y += ocrdma-abi.h
-header-y += hns-abi.h
-header-y += vmw_pvrdma-abi.h
+header-y += $(notdir $(wildcard $(srctree)/include/uapi/rdma/*.h))
diff --git a/include/uapi/rdma/hfi/Kbuild b/include/uapi/rdma/hfi/Kbuild
index ef23c294fc71..4fef4d891000 100644
--- a/include/uapi/rdma/hfi/Kbuild
+++ b/include/uapi/rdma/hfi/Kbuild
@@ -1,2 +1,2 @@
 # UAPI Header export list
-header-y += hfi1_user.h
+header-y += $(notdir $(wildcard $(srctree)/include/uapi/rdma/hfi/*.h))
diff --git a/include/uapi/scsi/Kbuild b/include/uapi/scsi/Kbuild
index d791e0ad509d..f3f1df5e24dd 100644
--- a/include/uapi/scsi/Kbuild
+++ b/include/uapi/scsi/Kbuild
@@ -1,6 +1,3 @@
 # UAPI Header export list
 header-y += fc/
-header-y += scsi_bsg_fc.h
-header-y += scsi_netlink.h
-header-y += scsi_netlink_fc.h
-header-y += cxlflash_ioctl.h
+header-y += $(notdir $(wildcard $(srctree)/include/uapi/scsi/*.h))
diff --git a/include/uapi/scsi/fc/Kbuild b/include/uapi/scsi/fc/Kbuild
index 5ead9fac265c..1b84093983c5 100644
--- a/include/uapi/scsi/fc/Kbuild
+++ b/include/uapi/scsi/fc/Kbuild
@@ -1,5 +1,2 @@
 # UAPI Header export list
-header-y += fc_els.h
-header-y += fc_fs.h
-header-y += fc_gs.h
-header-y += fc_ns.h
+header-y += $(notdir $(wildcard $(srctree)/include/uapi/scsi/fc/*.h))
diff --git a/include/uapi/sound/Kbuild b/include/uapi/sound/Kbuild
index 9578d8bdbf31..d2eb3b2aedf3 100644
--- a/include/uapi/sound/Kbuild
+++ b/include/uapi/sound/Kbuild
@@ -1,16 +1,2 @@
 # UAPI Header export list
-header-y += asequencer.h
-header-y += asoc.h
-header-y += asound.h
-header-y += asound_fm.h
-header-y += compress_offload.h
-header-y += compress_params.h
-header-y += emu10k1.h
-header-y += firewire.h
-header-y += hdsp.h
-header-y += hdspm.h
-header-y += sb16_csp.h
-header-y += sfnt_info.h
-header-y += tlv.h
-header-y += usb_stream.h
-header-y += snd_sst_tokens.h
+header-y += $(notdir $(wildcard $(srctree)/include/uapi/sound/*.h))
diff --git a/include/uapi/video/Kbuild b/include/uapi/video/Kbuild
index ac7203bb32cc..cd6d03c1e7ff 100644
--- a/include/uapi/video/Kbuild
+++ b/include/uapi/video/Kbuild
@@ -1,4 +1,2 @@
 # UAPI Header export list
-header-y += edid.h
-header-y += sisfb.h
-header-y += uvesafb.h
+header-y += $(notdir $(wildcard $(srctree)/include/uapi/video/*.h))
diff --git a/include/uapi/xen/Kbuild b/include/uapi/xen/Kbuild
index 5c459628e8c7..32feafaaa784 100644
--- a/include/uapi/xen/Kbuild
+++ b/include/uapi/xen/Kbuild
@@ -1,5 +1,2 @@
 # UAPI Header export list
-header-y += evtchn.h
-header-y += gntalloc.h
-header-y += gntdev.h
-header-y += privcmd.h
+header-y += $(notdir $(wildcard $(srctree)/include/uapi/xen/*.h))
-- 
2.8.1


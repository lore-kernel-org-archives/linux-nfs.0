Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:58644 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752027Ab1C2BVr convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 28 Mar 2011 21:21:47 -0400
Received: by wwk4 with SMTP id 4so2380798wwk.1
        for <linux-nfs@vger.kernel.org>; Mon, 28 Mar 2011 18:21:45 -0700 (PDT)
In-Reply-To: <20110325161156.007b2a10@tlielax.poochiereds.net>
References: <20110325161156.007b2a10@tlielax.poochiereds.net>
Date: Mon, 28 Mar 2011 18:21:45 -0700
Message-ID: <AANLkTikq+y4hEaeyc=D5HRU2Jna4MZ41C+A3=0vF4JMZ@mail.gmail.com>
Subject: Re: BUG() in shrink_dcache_for_umount_subtree on nfs4 mount
From: Mark Moseley <moseleymark@gmail.com>
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
To: unlisted-recipients:; (no To-header on input)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, Mar 25, 2011 at 1:11 PM, Jeff Layton <jlayton@redhat.com> wrote:
> I got this today on my Fedora 15 alpha machine:
>
> [18959.724464] BUG: Dentry ffff8801a6fe8840{i=2,n=} still in use (1) [unmount of nfs4 0:2c]
> [18959.724507] ------------[ cut here ]------------
> [18959.724609] kernel BUG at fs/dcache.c:947!
> [18959.724691] invalid opcode: 0000 [#1] SMP
> [18959.724781] last sysfs file: /sys/devices/system/cpu/cpu3/topology/thread_siblings
> [18959.724926] CPU 3
> [18959.724967] Modules linked in: nfs lockd nfs_acl tun fuse ip6table_filter ip6_tables ebtable_nat ebtables sco bnep l2cap bluetooth rfkill it87 adt7475 hwmon_vid rpcsec_gss_krb5 auth_rpcgss des_generic sunrpc cachefiles fscache cpufreq_ondemand powernow_k8 freq_table mperf xfs exportfs snd_hda_codec_hdmi snd_hda_codec_realtek snd_hda_intel snd_usb_audio snd_hda_codec snd_hwdep virtio_net snd_usbmidi_lib kvm_amd snd_seq snd_rawmidi sp5100_tco i2c_piix4 raid1 snd_pcm snd_seq_device kvm snd_timer snd uvcvideo edac_core ppdev edac_mce_amd parport_pc parport snd_page_alloc videodev k10temp r8169 mii soundcore v4l2_compat_ioctl32 wmi uinput microcode ipv6 ata_generic pata_acpi pata_atiixp usb_storage radeon ttm drm_kms_helper drm i2c_algo_bit i2c_core [last unloaded: scsi_wait_scan]
> [18959.725006]
> [18959.725006] Pid: 17684, comm: umount.nfs4 Not tainted 2.6.38.1-6.fc15.x86_64 #1 BIOSTAR Group TA790GX 128M/TA790GX 128M
> [18959.725006] RIP: 0010:[<ffffffff8113289f>]  [<ffffffff8113289f>] shrink_dcache_for_umount_subtree+0x104/0x1c9
> [18959.725006] RSP: 0018:ffff8801ee94bd98  EFLAGS: 00010296
> [18959.725006] RAX: 0000000000000062 RBX: ffff8801a6fe8840 RCX: 000000000000affd
> [18959.725006] RDX: 0000000000000000 RSI: 0000000000000046 RDI: 0000000000000246
> [18959.725006] RBP: ffff8801ee94bdc8 R08: 0000000000000002 R09: 0000ffff00066c0a
> [18959.725006] R10: 0000ffff00066c0a R11: 0000000000000000 R12: ffff8801a6fe8840
> [18959.725006] R13: ffff8801974281c0 R14: ffff8801a6fcccb0 R15: 0000000000000000
> [18959.725006] FS:  00007ff67dd45720(0000) GS:ffff8800cfd80000(0000) knlGS:00000000f76f3870
> [18959.725006] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [18959.725006] CR2: 00007ff67dd78000 CR3: 00000001ff5fe000 CR4: 00000000000006e0
> [18959.725006] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> [18959.725006] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> [18959.725006] Process umount.nfs4 (pid: 17684, threadinfo ffff8801ee94a000, task ffff88021b674560)
> [18959.725006] Stack:
> [18959.725006]  ffff8801f9df4658 0000000000000000 ffff8801f9df4400 ffff8801a6fe8f00
> [18959.725006]  ffff8801ee94bf28 ffff8801a6fccc00 ffff8801ee94bde8 ffffffff81133215
> [18959.725006]  ffff8801f9df4400 ffffffffa0587900 ffff8801ee94be18 ffffffff81122e29
> [18959.725006] Call Trace:
> [18959.725006]  [<ffffffff81133215>] shrink_dcache_for_umount+0x4d/0x5f
> [18959.725006]  [<ffffffff81122e29>] generic_shutdown_super+0x23/0xde
> [18959.725006]  [<ffffffff81122f61>] kill_anon_super+0x13/0x4c
> [18959.725006]  [<ffffffffa056334a>] nfs4_kill_super+0x44/0x77 [nfs]
> [18959.725006]  [<ffffffff81123185>] deactivate_locked_super+0x26/0x4b
> [18959.725006]  [<ffffffff81123cc1>] deactivate_super+0x37/0x3b
> [18959.725006]  [<ffffffff811385dc>] mntput_no_expire+0xcc/0xd1
> [18959.725006]  [<ffffffff81138607>] mntput+0x26/0x28
> [18959.725006]  [<ffffffff81138a8e>] release_mounts+0x59/0x73
> [18959.725006]  [<ffffffff81138ff4>] sys_umount+0x28d/0x2da
> [18959.725006]  [<ffffffff81009bc2>] system_call_fastpath+0x16/0x1b
> [18959.725006] Code: 8b 40 28 4c 8b 08 48 8b 43 30 48 85 c0 74 07 48 8b 90 a8 00 00 00 48 89 34 24 48 c7 c7 ce 24 7b 81 48 89 de 31 c0 e8 1a 91 33 00 <0f> 0b 4c 8b 63 18 4c 39 e3 75 11 48 8d bb 90 00 00 00 45 31 e4
> [18959.725006] RIP  [<ffffffff8113289f>] shrink_dcache_for_umount_subtree+0x104/0x1c9
> [18959.725006]  RSP <ffff8801ee94bd98>
> [18959.725006] [drm] force priority to high
> [18959.725006] [drm] force priority to high
> [18959.747232] [drm] force priority to high
> [18959.758010] ---[ end trace 625763676adf8f53 ]---
>
> ...I'm pretty sure the umount was triggered by autofs on a filesystem
> that I wasn't using at the moment. Beyond that I don't think I did much
> special on the filesystem. I haven't gone to look at the package in
> detail, but I expect that this is a fairly stock 2.6.38.1 kernel.


I've got the same error in 2.6.38.2 (64-bit, Debian Lenny). It happens
when umount tries to unmount a NetApp GX mount with a *lot* of
submounts. The top-level mount is a regular (in fstab) NFSv3 mount
over UDP. All of the submounts are handled by the kernel itself (and
incidentally, what is the correct term for this sort of submount?),
i.e. only the toplevel mount appears in fstab and the submounts
automagically appear underneath when used. Sort of like automounting
but not.

For completeness sake, here's my backtrace:


[ 1468.950280] BUG: Dentry ffff880226133e40{i=b4670040,n=web192} still
in use (1) [unmount of nfs 0:19]
[ 1468.950306] ------------[ cut here ]------------
[ 1468.959538] kernel BUG at fs/dcache.c:947!
[ 1468.960023] invalid opcode: 0000 [#1] SMP
[ 1468.960023] last sysfs file:
/sys/devices/system/cpu/cpu7/cache/index2/shared_cpu_map
[ 1468.960023] CPU 0
[ 1468.960023] Modules linked in: ipt_addrtype raid0 md_mod ioatdma
dca power_meter loop joydev fan evdev psmouse dcdbas serio_raw
i5000_edac pcspkr edac_core i5k_amb shpchp pci_hotplug processor
button thermal_sys sg sr_mod cdrom ehci_hcd uhci_hcd sata_sil24 sd_mod
crc_t10dif [last unloaded: scsi_wait_scan]
[ 1468.960023]
[ 1468.960023] Pid: 9859, comm: umount.nfs Not tainted 2.6.38.2 #1
Dell Inc. PowerEdge 1950/0DT097
[ 1468.960023] RIP: 0010:[<ffffffff81154541>]  [<ffffffff81154541>]
shrink_dcache_for_umount_subtree+0x251/0x260
[ 1468.960023] RSP: 0018:ffff880198d47d58  EFLAGS: 00010292
[ 1468.960023] RAX: 000000000000006e RBX: ffff880226001a1c RCX: 000000000001ffff
[ 1468.960023] RDX: 0000000000000000 RSI: 0000000000000082 RDI: ffffffff81cf4830
[ 1468.960023] RBP: ffff880198d47d88 R08: 0000000000000006 R09: 0000000000000000
[ 1468.960023] R10: 0000000000000003 R11: 00000000ffffffff R12: ffff8802260019c0
[ 1468.960023] R13: ffff880226133e40 R14: ffff880226133ee0 R15: ffff880226001a1c
[ 1468.960023] FS:  00000304a71996e0(0000) GS:ffff8800cfc00000(0000)
knlGS:0000000000000000
[ 1468.960023] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[ 1468.960023] CR2: ffffffffff600400 CR3: 0000000001646000 CR4: 00000000000006f0
[ 1468.960023] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[ 1468.960023] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[ 1468.960023] Process umount.nfs (pid: 9859, threadinfo
ffff880198d46000, task ffff880227f91730)
[ 1468.960023] Stack:
[ 1468.960023]  ffff88022505ae58 ffff880226001900 ffff88022600195c
ffff88022505ac00
[ 1468.960023]  ffff88022505ac00 0000000000000100 ffff880198d47db8
ffffffff811545b2
[ 1468.960023]  0000000000000282 ffff88022505ac00 ffff880224715800
ffffffff816bcc20
[ 1468.960023] Call Trace:
[ 1468.960023]  [<ffffffff811545b2>] shrink_dcache_for_umount+0x62/0x80
[ 1468.960023]  [<ffffffff8113d35c>] generic_shutdown_super+0x2c/0x110
[ 1468.960023]  [<ffffffff8113d4d6>] kill_anon_super+0x16/0x60
[ 1468.960023]  [<ffffffff8123c485>] nfs_kill_super+0x25/0x40
[ 1468.960023]  [<ffffffff8113dc05>] deactivate_locked_super+0x55/0x70
[ 1468.960023]  [<ffffffff8113ebc9>] deactivate_super+0x79/0x80
[ 1468.960023]  [<ffffffff8115bb37>] mntput_no_expire+0x137/0x1b0
[ 1468.960023]  [<ffffffff8115bbcd>] mntput+0x1d/0x40
[ 1468.960023]  [<ffffffff8115bc61>] release_mounts+0x71/0x90
[ 1468.960023]  [<ffffffff8115c1c8>] sys_umount+0x308/0x3c0
[ 1468.960023]  [<ffffffff810030fb>] system_call_fastpath+0x16/0x1b
[ 1468.960023] Code: 8b 45 30 48 85 c0 74 07 48 8b 90 a8 00 00 00 48
8d 86 58 02 00 00 48 c7 c7 20 c7 88 81 48 89 04 24 4c 89 ee 31 c0 e8
0d 0c 4c 00 <0f> 0b eb fe 0f 0b eb fe 0f 1f 80 00 00 00 00 55 48 89 e5
41 55
[ 1468.960023] RIP  [<ffffffff81154541>]
shrink_dcache_for_umount_subtree+0x251/0x260
[ 1468.960023]  RSP <ffff880198d47d58>
[ 1469.500150] ---[ end trace 74f032acd854ca51 ]---

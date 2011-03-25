Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:63354 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751384Ab1CYUL7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Mar 2011 16:11:59 -0400
Date: Fri, 25 Mar 2011 16:11:56 -0400
From: Jeff Layton <jlayton@redhat.com>
To: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org
Subject: BUG() in shrink_dcache_for_umount_subtree on nfs4 mount
Message-ID: <20110325161156.007b2a10@tlielax.poochiereds.net>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

I got this today on my Fedora 15 alpha machine:

[18959.724464] BUG: Dentry ffff8801a6fe8840{i=2,n=} still in use (1) [unmount of nfs4 0:2c]
[18959.724507] ------------[ cut here ]------------
[18959.724609] kernel BUG at fs/dcache.c:947!
[18959.724691] invalid opcode: 0000 [#1] SMP 
[18959.724781] last sysfs file: /sys/devices/system/cpu/cpu3/topology/thread_siblings
[18959.724926] CPU 3 
[18959.724967] Modules linked in: nfs lockd nfs_acl tun fuse ip6table_filter ip6_tables ebtable_nat ebtables sco bnep l2cap bluetooth rfkill it87 adt7475 hwmon_vid rpcsec_gss_krb5 auth_rpcgss des_generic sunrpc cachefiles fscache cpufreq_ondemand powernow_k8 freq_table mperf xfs exportfs snd_hda_codec_hdmi snd_hda_codec_realtek snd_hda_intel snd_usb_audio snd_hda_codec snd_hwdep virtio_net snd_usbmidi_lib kvm_amd snd_seq snd_rawmidi sp5100_tco i2c_piix4 raid1 snd_pcm snd_seq_device kvm snd_timer snd uvcvideo edac_core ppdev edac_mce_amd parport_pc parport snd_page_alloc videodev k10temp r8169 mii soundcore v4l2_compat_ioctl32 wmi uinput microcode ipv6 ata_generic pata_acpi pata_atiixp usb_storage radeon ttm drm_kms_helper drm i2c_algo_bit i2c_core [last unloaded: scsi_wait_scan]
[18959.725006] 
[18959.725006] Pid: 17684, comm: umount.nfs4 Not tainted 2.6.38.1-6.fc15.x86_64 #1 BIOSTAR Group TA790GX 128M/TA790GX 128M
[18959.725006] RIP: 0010:[<ffffffff8113289f>]  [<ffffffff8113289f>] shrink_dcache_for_umount_subtree+0x104/0x1c9
[18959.725006] RSP: 0018:ffff8801ee94bd98  EFLAGS: 00010296
[18959.725006] RAX: 0000000000000062 RBX: ffff8801a6fe8840 RCX: 000000000000affd
[18959.725006] RDX: 0000000000000000 RSI: 0000000000000046 RDI: 0000000000000246
[18959.725006] RBP: ffff8801ee94bdc8 R08: 0000000000000002 R09: 0000ffff00066c0a
[18959.725006] R10: 0000ffff00066c0a R11: 0000000000000000 R12: ffff8801a6fe8840
[18959.725006] R13: ffff8801974281c0 R14: ffff8801a6fcccb0 R15: 0000000000000000
[18959.725006] FS:  00007ff67dd45720(0000) GS:ffff8800cfd80000(0000) knlGS:00000000f76f3870
[18959.725006] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[18959.725006] CR2: 00007ff67dd78000 CR3: 00000001ff5fe000 CR4: 00000000000006e0
[18959.725006] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[18959.725006] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[18959.725006] Process umount.nfs4 (pid: 17684, threadinfo ffff8801ee94a000, task ffff88021b674560)
[18959.725006] Stack:
[18959.725006]  ffff8801f9df4658 0000000000000000 ffff8801f9df4400 ffff8801a6fe8f00
[18959.725006]  ffff8801ee94bf28 ffff8801a6fccc00 ffff8801ee94bde8 ffffffff81133215
[18959.725006]  ffff8801f9df4400 ffffffffa0587900 ffff8801ee94be18 ffffffff81122e29
[18959.725006] Call Trace:
[18959.725006]  [<ffffffff81133215>] shrink_dcache_for_umount+0x4d/0x5f
[18959.725006]  [<ffffffff81122e29>] generic_shutdown_super+0x23/0xde
[18959.725006]  [<ffffffff81122f61>] kill_anon_super+0x13/0x4c
[18959.725006]  [<ffffffffa056334a>] nfs4_kill_super+0x44/0x77 [nfs]
[18959.725006]  [<ffffffff81123185>] deactivate_locked_super+0x26/0x4b
[18959.725006]  [<ffffffff81123cc1>] deactivate_super+0x37/0x3b
[18959.725006]  [<ffffffff811385dc>] mntput_no_expire+0xcc/0xd1
[18959.725006]  [<ffffffff81138607>] mntput+0x26/0x28
[18959.725006]  [<ffffffff81138a8e>] release_mounts+0x59/0x73
[18959.725006]  [<ffffffff81138ff4>] sys_umount+0x28d/0x2da
[18959.725006]  [<ffffffff81009bc2>] system_call_fastpath+0x16/0x1b
[18959.725006] Code: 8b 40 28 4c 8b 08 48 8b 43 30 48 85 c0 74 07 48 8b 90 a8 00 00 00 48 89 34 24 48 c7 c7 ce 24 7b 81 48 89 de 31 c0 e8 1a 91 33 00 <0f> 0b 4c 8b 63 18 4c 39 e3 75 11 48 8d bb 90 00 00 00 45 31 e4 
[18959.725006] RIP  [<ffffffff8113289f>] shrink_dcache_for_umount_subtree+0x104/0x1c9
[18959.725006]  RSP <ffff8801ee94bd98>
[18959.725006] [drm] force priority to high
[18959.725006] [drm] force priority to high
[18959.747232] [drm] force priority to high
[18959.758010] ---[ end trace 625763676adf8f53 ]---

...I'm pretty sure the umount was triggered by autofs on a filesystem
that I wasn't using at the moment. Beyond that I don't think I did much
special on the filesystem. I haven't gone to look at the package in
detail, but I expect that this is a fairly stock 2.6.38.1 kernel.

-- 
Jeff Layton <jlayton@redhat.com>

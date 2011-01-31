Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp-out-1.desy.de ([131.169.56.84]:60560 "EHLO
	smtp-out-1.desy.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754022Ab1AaLhk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 31 Jan 2011 06:37:40 -0500
Received: from smtp-map-1.desy.de (smtp-map-1.desy.de [131.169.56.66])
	by smtp-out-1.desy.de (DESY_OUT_1) with ESMTP id 90315195C
	for <linux-nfs@vger.kernel.org>; Mon, 31 Jan 2011 12:37:38 +0100 (MET)
Received: from adserv70.win.desy.de (adserv70.win.desy.de [131.169.97.56])
	by smtp-map-1.desy.de (DESY_MAP_1) with ESMTP id 8823513E8D
	for <linux-nfs@vger.kernel.org>; Mon, 31 Jan 2011 12:37:38 +0100 (MET)
Received: from smtp-intra-1.desy.de (lb-40-26.desy.de) by adserv70.win.desy.de
 (Clearswift SMTPRS 5.3.4) with ESMTP id <T9ae87cd3dd83a9613815a8@adserv70.win.desy.de> for <linux-nfs@vger.kernel.org>;
 Mon, 31 Jan 2011 12:37:38 +0100
Received: from [131.169.185.68] (anahit.desy.de [131.169.185.68])
	by smtp-intra-1.desy.de (DESY-INTRA-1) with ESMTP id 2E2DC3E901
	for <linux-nfs@vger.kernel.org>; Mon, 31 Jan 2011 12:37:38 +0100 (MET)
Message-ID: <4D469F31.8060909@desy.de>
Date: Mon, 31 Jan 2011 12:38:25 +0100
From: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
To: NFS list <linux-nfs@vger.kernel.org>
Subject: 2.6.38-rc2 + pnfs kernel crash
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

pnfs-all-latest 66e2713ceff5ab6aa26fe9dd41484e2ac7db8c70

[258924.345210] ------------[ cut here ]------------
[258924.345212] kernel BUG at fs/nfs/pnfs.c:262!
[258924.345215] invalid opcode: 0000 [#1] SMP
[258924.345219] last sysfs file:
/sys/devices/pci0000:00/0000:00:1f.2/host0/target0:0:0/0:0:0:0/block/sda/sda4/stat
[258924.345221] CPU 0
[258924.345223] Modules linked in: nfs_layout_nfsv41_files joydev st
ide_gd_mod ide_cd_mod snd_pcm_oss snd_mixer_oss snd_seq edd
rpcsec_gss_krb5 nfs lockd fscache nfs_acl auth_rpcgss sunrpc vboxnetadp
vboxnetflt vboxdrv cpufreq_conservative cpufreq_userspace
cpufreq_powersave acpi_cpufreq mperf loop dm_mod snd_hda_codec_idt
snd_usb_audio snd_usbmidi_lib snd_rawmidi snd_seq_device snd_hda_intel
snd_hda_codec snd_hwdep iTCO_wdt e1000e snd_pcm sg sr_mod cdrom
snd_timer snd snd_page_alloc iTCO_vendor_support pcspkr i2c_i801 button
microcode serio_raw ext4 jbd2 crc16 fan processor ide_pci_generic
ide_core ata_generic pata_marvell thermal thermal_sys
[258924.345279]
[258924.345282] Pid: 10209, comm: 131.169.40.35-m Tainted: G        W I
2.6.38-rc2-pnfs-2+ #34 DX38BT/pczW1007
[258924.345285] RIP: 0010:[<ffffffffa0461177>]  [<ffffffffa0461177>]
destroy_layout_hdr+0x57/0x60 [nfs]
[258924.345296] RSP: 0018:ffff880129893df0  EFLAGS: 00010216
[258924.345298] RAX: ffff8800c5df6388 RBX: ffff8800c5df6380 RCX:
000000000003ffff
[258924.345301] RDX: 0000000000001f1e RSI: 0000000000000046 RDI:
ffff8800c5df6380
[258924.345304] RBP: ffff880129893e00 R08: 000000000007cfe5 R09:
0000000000000000
[258924.345307] R10: 000000000000000a R11: 0000000000000001 R12:
ffff88012c744a90
[258924.345309] R13: ffff880129893e30 R14: 0000000000000000 R15:
ffff8800039208f0
[258924.345312] FS:  0000000000000000(0000) GS:ffff8800cea00000(0000)
knlGS:0000000000000000
[258924.345315] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[258924.345318] CR2: 00007f37b390c000 CR3: 000000012ce48000 CR4:
00000000000406f0
[258924.345321] DR0: 0000000000000000 DR1: 0000000000000000 DR2:
0000000000000000
[258924.345324] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7:
0000000000000400
[258924.345327] Process 131.169.40.35-m (pid: 10209, threadinfo
ffff880129892000, task ffff88012c8ca050)
[258924.345329] Stack:
[258924.345331]  ffff880129893e00 ffff8800c5df6380 ffff880129893e60
ffffffffa046299b
[258924.345336]  ffff880100000003 0000000000000000 ffffffffffffffff
ffff880003920800
[258924.345342]  ffff880129893e30 ffff880129893e30 ffffffffa0471820
ffff8800c5df6380
[258924.345348] Call Trace:
[258924.345357]  [<ffffffffa046299b>] pnfs_destroy_layout+0xab/0x100 [nfs]
[258924.345366]  [<ffffffffa0462a80>] pnfs_destroy_all_layouts+0x90/0xd0
[nfs]
[258924.345376]  [<ffffffffa045af3f>] nfs4_run_state_manager+0x2bf/0x580
[nfs]
[258924.345386]  [<ffffffffa045ac80>] ? nfs4_run_state_manager+0x0/0x580
[nfs]
[258924.345396]  [<ffffffffa045ac80>] ? nfs4_run_state_manager+0x0/0x580
[nfs]
[258924.345400]  [<ffffffff8105d016>] kthread+0x96/0xa0
[258924.345404]  [<ffffffff81003b54>] kernel_thread_helper+0x4/0x10
[258924.345408]  [<ffffffff8105cf80>] ? kthread+0x0/0xa0
[258924.345411]  [<ffffffff81003b50>] ? kernel_thread_helper+0x0/0x10
[258924.345413] Code: f0 00 00 00 00 e8 8a ff ff ff 48 83 c4 08 5b c9 c3
48 89 fa 48 c7 c6 40 94 46 a0 48 c7 c7 44 b9 46 a0 31 c0 e8 91 d5 f8 e0
eb be <0f> 0b 0f 1f 80 00 00 00 00 55 48 89 e5 53 48 89 fb 48 83 ec 08
[258924.345465] RIP  [<ffffffffa0461177>] destroy_layout_hdr+0x57/0x60 [nfs]
[258924.345475]  RSP <ffff880129893df0>
[258924.345478] ---[ end trace a7919e7f17c0a729 ]---


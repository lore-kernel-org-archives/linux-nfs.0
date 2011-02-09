Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from eazy.amigager.de ([213.239.192.238]:41319 "EHLO
	eazy.amigager.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755988Ab1BIWMy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 9 Feb 2011 17:12:54 -0500
Received: from mac.home (port-92-206-85-183.dynamic.qsc.de [92.206.85.183])
	by eazy.amigager.de (Postfix) with ESMTPA id 08A72F30005
	for <linux-nfs@vger.kernel.org>; Wed,  9 Feb 2011 23:04:25 +0100 (CET)
Date: Wed, 9 Feb 2011 23:04:27 +0100
From: Tino Keitel <tino.keitel@tikei.de>
To: linux-nfs@vger.kernel.org
Subject: 2.6.38-rc3: kernel BUG at fs/nfsd/nfs4state.c:3132!
Message-ID: <20110209220427.GA12140@mac.home>
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi,

I get the following error with kernel 2.6.38-rc3 during normal file access via
NFS v4. The underlying FS is ext4, if that matters.

At least one other user seems to have the same problem:
http://pastebin.com/QRq1TMkj

<0>------------[ cut here ]------------
kernel BUG at fs/nfsd/nfs4state.c:3132!
<0>invalid opcode: 0000 [#1] SMP 
<0>last sysfs file: /sys/devices/virtual/block/dm-8/uevent
CPU 0 
Modules linked in: ipv6 usblp btusb bluetooth loop arc4 ecb
snd_hda_codec_idt snd_hda_intel snd_hda_codec snd_pcm_oss ath5k
dvb_usb_vp7045 ath dvb_usb snd_pcm snd_timer mac80211
 snd_page_alloc evdev dvb_core sky2 rc_core ata_piix cfg80211

Pid: 2280, comm: nfsd Not tainted 2.6.38-rc3-00062-gb64606b #6
Mac-F4208EAA/Macmini2,1
RIP: 0010:[<ffffffff8119f973>]  [<ffffffff8119f973>]
nfs4_preprocess_stateid_op+0x3a3/0x490
RSP: 0018:ffff8800b399bd50  EFLAGS: 00010246
RAX: 0000000000000000 RBX: ffff8800b60a9000 RCX: ffffffff8175a010
RDX: ffff8800ab784e48 RSI: ffffffff8175a020 RDI: ffffffff8175a000
RBP: ffff8800a4ce5678 R08: 0000000000000000 R09: 0000000000000000
R10: ffff8800b3910180 R11: c600000000000000 R12: ffff8800b390f1c0
R13: ffff8800b390f1a0 R14: 0000000000000000 R15: ffff8800aba079a0
FS:  0000000000000000(0000) GS:ffff8800bde00000(0000)
knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 00007f2b8805d000 CR3: 00000000b6fe8000 CR4: 00000000000006b0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process nfsd (pid: 2280, threadinfo ffff8800b399a000, task
ffff8800b63a62d0)
<0>Stack:
 000000004d507f0d ffff8800b390f1a0 ffff8800b3910040 ffff8800b391c000
 0000000016000000 0000000000000000 ffff8800b3910040 ffffffff8118f549
 ffff8800b390f000 ffff8800b3910000 ffff8800b390f000 ffff8800b391c000
<0>Call Trace:
 [<ffffffff8118f549>] ? nfsd4_read+0x79/0xc0
 [<ffffffff81190096>] ? nfsd4_proc_compound+0x416/0x4d0
 [<ffffffff8117f5ad>] ? nfsd_dispatch+0xfd/0x240
 [<ffffffff8146f1f9>] ? svc_process_common+0x339/0x680
 [<ffffffff81035b70>] ? default_wake_function+0x0/0x20
 [<ffffffff8117ecc0>] ? nfsd+0x0/0x150
 [<ffffffff8146f80a>] ? svc_process+0x10a/0x160
 [<ffffffff8117ecc0>] ? nfsd+0x0/0x150
 [<ffffffff8117ed72>] ? nfsd+0xb2/0x150
 [<ffffffff81055ff6>] ? kthread+0x96/0xa0
 [<ffffffff810039b4>] ? kernel_thread_helper+0x4/0x10
 [<ffffffff81055f60>] ? kthread+0x0/0xa0
 [<ffffffff810039b0>] ? kernel_thread_helper+0x0/0x10
<0>Code: 27 29 41 3b 47 50 0f 87 9a fd ff ff 0f 83 e9 fe ff ff e9 76 ff
ff ff 48 8b 42 48 45 31 f6 49 89 04 24 48 85 c0 0f 85 7b fd ff ff <0f>
0b 49 8b 57 48 48 8b 42 40 48 85 c
0 0f 85 2a ff ff ff 48 8b 
RIP  [<ffffffff8119f973>] nfs4_preprocess_stateid_op+0x3a3/0x490
 RSP <ffff8800b399bd50>
---[ end trace 7ef2fa5b1b62014a ]---

Regards,
Tino

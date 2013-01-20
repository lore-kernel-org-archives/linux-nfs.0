Return-Path: linux-nfs-owner@vger.kernel.org
Received: from ironport2-out.teksavvy.com ([206.248.154.182]:32002 "EHLO
	ironport2-out.teksavvy.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752052Ab3ATWvO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 20 Jan 2013 17:51:14 -0500
Message-ID: <50FC74E0.20305@teksavvy.com>
Date: Sun, 20 Jan 2013 17:51:12 -0500
From: Mark Lord <kernel@teksavvy.com>
MIME-Version: 1.0
To: Stanislav Kinsbursky <skinsbursky@parallels.com>
CC: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org,
        Linux Kernel <linux-kernel@vger.kernel.org>
Subject: Re: BUG at net/sunrpc/svc_xprt.c:921 (another one)
References: <50F42F85.50907@teksavvy.com> <20130114203711.GA29982@fieldses.org> <50F4D800.5040703@teksavvy.com> <20130115205625.GH4940@fieldses.org> <50F63882.8000607@parallels.com> <50F72F03.5070806@teksavvy.com> <50F786AF.4070107@parallels.com> <20130117130335.GD6598@fieldses.org> <50F7FB7E.2020503@parallels.com> <50F88C14.7030903@teksavvy.com> <50F8DF7E.8080107@parallels.com>
In-Reply-To: <50F8DF7E.8080107@parallels.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Got it again, this time on a different system
running mostly the same software.

This time, I noticed when it happened:  on mounting another system's storage over NFS.
I was doing a "mount" command when suddenly this happened.  Linux-3.7.3.

[ 3342.841487] ------------[ cut here ]------------
[ 3342.841527] kernel BUG at net/sunrpc/svc_xprt.c:921!
[ 3342.841547] invalid opcode: 0000 [#1] PREEMPT SMP
[ 3342.841579] Modules linked in: nfsv3 nfsv4 sha1_generic ppp_mppe ppp_async crc_ccitt ppp_generic
slhc btusb hid_generic arc4 usbhid hid b43 coretemp kvm_intel kvm mac80211 cfg80211
snd_hda_codec_idt dell_wmi snd_hda_intel snd_hda_codec snd_hwdep snd_pcm_oss snd_mixer_oss snd_pcm
dell_laptop dcdbas snd_seq_dummy snd_seq_oss microcode snd_seq_midi psmouse snd_rawmidi
snd_seq_midi_event snd_seq nouveau ttm drm_kms_helper ssb drm bnep i2c_algo_bit snd_timer i2c_core
mxm_wmi snd_seq_device rfcomm snd bluetooth parport_pc soundcore snd_page_alloc ppdev video nfsd
auth_rpcgss nfs lockd binfmt_misc sunrpc lp parport firewire_ohci tg3 firewire_core crc_itu_t libphy
hwmon sdhci_pci sdhci
[ 3342.842104] CPU 1
[ 3342.842120] Pid: 4108, comm: nfsv4.0-svc Not tainted 3.7.3 #3 Dell Inc. Precision M6300
       /0JM680
[ 3342.842151] RIP: 0010:[<ffffffffa007ba6e>]  [<ffffffffa007ba6e>] svc_delete_xprt+0x23/0xf3 [sunrpc]
[ 3342.842206] RSP: 0018:ffff8801a680be38  EFLAGS: 00010286
[ 3342.842226] RAX: 00000000ffffffff RBX: ffff880215103000 RCX: dead000000200200
[ 3342.842247] RDX: dead000000100100 RSI: ffff880215103038 RDI: 0000000000000006
[ 3342.842270] RBP: ffff880215726900 R08: 0000000000000606 R09: ffff88021fd11280
[ 3342.842293] R10: 00000000004f9885 R11: ffff88021fd11280 R12: ffff880215726900
[ 3342.842315] R13: ffff880215103038 R14: 0000000000000000 R15: 0000000000000000
[ 3342.842337] FS:  0000000000000000(0000) GS:ffff88021fd00000(0000) knlGS:0000000000000000
[ 3342.842361] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[ 3342.842380] CR2: 0000000000b0d000 CR3: 00000001cf402000 CR4: 00000000000007e0
[ 3342.842402] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[ 3342.842425] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[ 3342.842448] Process nfsv4.0-svc (pid: 4108, threadinfo ffff8801a680a000, task ffff8802027cf080)
[ 3342.842476] Stack:
[ 3342.842488]  dead000000200200 ffff88020970a000 ffff880215103000 ffff880215726900
[ 3342.842527]  ffff880215726900 ffffffffa007c960 ffff8801a680bfd8 0000000000011280
[ 3342.842568]  ffff8801a680bfd8 ffff88020970a000 ffff88020970a000 ffff8801a680bf08
[ 3342.842608] Call Trace:
[ 3342.842644]  [<ffffffffa007c960>] ? svc_recv+0xcc/0x338 [sunrpc]
[ 3342.842678]  [<ffffffffa0488000>] ? nfs_callback_authenticate+0x20/0x20 [nfsv4]
[ 3342.842712]  [<ffffffffa048801d>] ? nfs4_callback_svc+0x1d/0x3c [nfsv4]
[ 3342.842739]  [<ffffffff8103dcf9>] ? kthread+0x81/0x89
[ 3342.842763]  [<ffffffff81040101>] ? posix_cpu_nsleep_restart+0x11/0x89
[ 3342.842787]  [<ffffffff8103dc78>] ? kthread_freezable_should_stop+0x31/0x31
[ 3342.842813]  [<ffffffff8130302c>] ? ret_from_fork+0x7c/0xb0
[ 3342.842835]  [<ffffffff8103dc78>] ? kthread_freezable_should_stop+0x31/0x31
[ 3342.842856] Code: c2 84 d2 74 02 eb a0 c3 41 55 4c 8d 6f 38 41 54 4c 89 ee 55 53 48 89 fb 51 48
8b 6f 40 bf 06 00 00 00 e8 62 fa ff ff 85 c0 74 02 <0f> 0b 48 8b 43 08 4c 8d 65 10 48 89 df ff 50 38
4c 89 e7 e8 2a
[ 3342.843192] RIP  [<ffffffffa007ba6e>] svc_delete_xprt+0x23/0xf3 [sunrpc]
[ 3342.843235]  RSP <ffff8801a680be38>
[ 3342.858471] ---[ end trace f0dbe9f9cd4029c3 ]---

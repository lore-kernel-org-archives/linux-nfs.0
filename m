From: "Nilssen, Rune" <rune.nilssen-FJFKJQU35qU@public.gmane.org>
Subject: BUG: soft lockup - CPU#0 stuck for 11s! [nfsd:5285]  then server hangs
Date: Tue, 26 Feb 2008 12:55:57 +0100
Message-ID: <20152332B494B94B87A4EA764C6B9F861D8D6A@fixoosr09.findexa.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
To: <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fixoosr11.gulesider.no ([80.239.38.54]:3704 "HELO
	fixoosr11.gulesider.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1750747AbYBZMNN convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 26 Feb 2008 07:13:13 -0500
Received: from fixoosr09.findexa.net ([172.27.48.161])
 by fixoosr11.gulesider.no (SMSSMTP 4.1.2.20) with SMTP id M2008022612555724346
 for <linux-nfs@vger.kernel.org>; Tue, 26 Feb 2008 12:55:57 +0100
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

Im having problems with an nfs server that keeps hanging for no apparent reason. This server shares webpages across several loadbalanced apache servers. Prior to hang I keep getting messages like this in dmesg:

Feb 23 08:45:21 nfs1 kernel: BUG: soft lockup - CPU#0 stuck for 11s! [nfsd:5285]
Feb 23 08:45:21 nfs1 kernel:
Feb 23 08:45:21 nfs1 kernel: Pid: 5285, comm:                 nfsd
Feb 23 08:45:21 nfs1 kernel: EIP: 0060:[<c014c364>] CPU: 0
Feb 23 08:45:21 nfs1 kernel: EIP is at put_page+0xa/0x9b
Feb 23 08:45:21 nfs1 kernel:  EFLAGS: 00000246    Not tainted  (2.6.23-gentoo-r8 #1)
Feb 23 08:45:21 nfs1 kernel: EAX: 80000008 EBX: c173c5e0 ECX: 00000000 EDX: 00000000
Feb 23 08:45:21 nfs1 kernel: ESI: 00000002 EDI: df0f4bd8 EBP: df0f4c7c DS: 007b ES: 007b FS: 00d8
Feb 23 08:45:21 nfs1 kernel: CR0: 8005003b CR2: b701afcc CR3: 00626000 CR4: 000006f0
Feb 23 08:45:21 nfs1 kernel: DR0: 00000000 DR1: 00000000 DR2: 00000000 DR3: 00000000
Feb 23 08:45:21 nfs1 kernel: DR6: ffff0ff0 DR7: 00000400
Feb 23 08:45:21 nfs1 kernel:  [<c017c424>] generic_file_splice_read+0x3c9/0x45d
Feb 23 08:45:21 nfs1 kernel:  [<c01f428a>] find_acceptable_alias+0x15/0xad
Feb 23 08:45:21 nfs1 kernel:  [<c01f6985>] nfsd_acceptable+0x0/0xb9
Feb 23 08:45:21 nfs1 kernel:  [<c01f6985>] nfsd_acceptable+0x0/0xb9
Feb 23 08:45:21 nfs1 kernel:  [<c01f43aa>] find_exported_dentry+0x88/0x171
Feb 23 08:45:21 nfs1 kernel:  [<c011e006>] enqueue_entity+0x1d2/0x1f3
Feb 23 08:45:21 nfs1 kernel:  [<c043cfc9>] cache_check+0x59/0x3bb
Feb 23 08:45:21 nfs1 kernel:  [<c011d8b8>] inc_nr_running+0x13/0x26
Feb 23 08:45:21 nfs1 kernel:  [<c01fa803>] exp_get_by_name+0x43/0x52
Feb 23 08:45:21 nfs1 kernel:  [<c043dd7d>] sunrpc_cache_lookup+0x3e/0xf4
Feb 23 08:45:21 nfs1 kernel:  [<c012f147>] set_current_groups+0x139/0x143
Feb 23 08:45:21 nfs1 kernel:  [<c01fc4c0>] nfsd_setuser+0x125/0x175
Feb 23 08:45:21 nfs1 kernel:  [<c017b48a>] do_splice_to+0x5d/0x64
Feb 23 08:45:21 nfs1 kernel:  [<c017b6d3>] splice_direct_to_actor+0xb5/0x143
Feb 23 08:45:21 nfs1 kernel:  [<c01f7f4d>] nfsd_direct_splice_actor+0x0/0xa
Feb 23 08:45:21 nfs1 kernel:  [<c01f7e57>] nfsd_vfs_read+0x1ed/0x2e3
Feb 23 08:45:21 nfs1 kernel:  [<c01f837c>] nfsd_read+0xbe/0xd3
Feb 23 08:45:21 nfs1 kernel:  [<c01fde98>] nfsd3_proc_read+0x116/0x15f
Feb 23 08:45:21 nfs1 kernel:  [<c01f46d0>] nfsd_dispatch+0xd3/0x1c5
Feb 23 08:45:21 nfs1 kernel:  [<c0436f2a>] svc_process+0x3c7/0x699
Feb 23 08:45:21 nfs1 kernel:  [<c0439c0a>] svc_recv+0x341/0x3b7
Feb 23 08:45:21 nfs1 kernel:  [<c01f4c48>] nfsd+0x17e/0x27e
Feb 23 08:45:21 nfs1 kernel:  [<c01f4aca>] nfsd+0x0/0x27e
Feb 23 08:45:21 nfs1 kernel:  [<c01059f7>] kernel_thread_helper+0x7/0x10
Feb 23 08:45:21 nfs1 kernel:  =======================


This was the last of a series of seemingly several hundred messages before the server hung and had to be reset. Could this be ralated to a bug in nfs or are any of you able to tell what this dump actually means and what I should investigate further?

Any help would be greatly apprechiated.

Best regards,
Rune Nilssen

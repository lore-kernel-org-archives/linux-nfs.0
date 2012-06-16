Return-Path: linux-nfs-owner@vger.kernel.org
Received: from catastrophix.ugh.no ([178.79.162.34]:55255 "EHLO
	catastrophix.ugh.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752718Ab2FPSne (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 16 Jun 2012 14:43:34 -0400
Message-ID: <4FDCD3C7.5080503@tomt.net>
Date: Sat, 16 Jun 2012 20:43:19 +0200
From: Andre Tomt <andre@tomt.net>
MIME-Version: 1.0
To: Linux-NFS <linux-nfs@vger.kernel.org>
CC: Fengguang Wu <fengguang.wu@intel.com>, David Howells <dhowells@redhat.com>,
        LKML <linux-kernel@vger.kernel.org>
Subject: Re: BUG in __key_instantiate_and_link(): unable to handle kernel
 paging request at 0000632e6472616f
References: <20120601034114.GA9248@localhost> <4FDBF056.7040404@tomt.net>
In-Reply-To: <4FDBF056.7040404@tomt.net>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 16. juni 2012 04:32, Andre Tomt wrote:
> FWIW; I am (still) seeing this exact same crash several times an hour on
> 3.4.3-rc1 on Ubuntu 12.04 client. Only that the same second it happens,
> all my three displays corrupts badly, becoming completely unreadable.
> Switching to console and back usually gets my desktop back on two of
> three displays, and sometimes it will need a full xserver restart.
> Obviously some memory corruption going on.
>
> One of the crashes also triggered a NX error:
> [20292.196332] kernel tried to execute NX-protected page - exploit
> attempt? (uid: 0)
>
> And after a while, things start locking up.
>
> It didn't really start happening until a few days ago though, I've been
> running 3.4 for since some -rc through all the stable releases. Perhaps
> server suddenly got a working idmapper or something? Its a debian
> unstable updated a couple times a month.
>
> Booting latest git master now, to see if any of the recent NFS fixes
> just pulled by Linus fixes anything (-rc2 had other showstopper nfs
> issues).

Just had it happen with 3.5-git as of a couple hours ago (last commit 
a2c2df8672f55195f101d9251117aa59e358d296):
Jun 16 19:01:49 slurv kernel: [50823.271618] general protection fault: 
0000 [#1] SMP
Jun 16 19:01:49 slurv kernel: [50823.271640] CPU 10
Jun 16 19:01:49 slurv kernel: [50823.271690]
Jun 16 19:01:49 slurv kernel: [50823.271698] Pid: 1678, comm: rpc.idmapd 
Not tainted 3.5.0-1-desktop #1 System manufacturer System Product 
Name/P6T DELUXE V2
Jun 16 19:01:49 slurv kernel: [50823.271738] RIP: 
0010:[<ffffffff81129872>]  [<ffffffff81129872>] 
__key_instantiate_and_link+0x52/0xcb
Jun 16 19:01:49 slurv kernel: [50823.271767] RSP: 0018:ffff88061941bd38 
  EFLAGS: 00010246
Jun 16 19:01:49 slurv kernel: [50823.271785] RAX: 6337346330366233 RBX: 
ffff880606fb97f0 RCX: 0000000000000000
Jun 16 19:01:49 slurv kernel: [50823.271807] RDX: 0000000000000006 RSI: 
ffff88061941be85 RDI: ffff880606fb97f0
Jun 16 19:01:49 slurv kernel: [50823.271829] RBP: ffff88061941bd88 R08: 
ffff8802bc9ed380 R09: ffff88061941bdb0
Jun 16 19:01:49 slurv kernel: [50823.271850] R10: 0000000000000000 R11: 
0000000000000000 R12: ffff88061aad63c0
Jun 16 19:01:49 slurv kernel: [50823.271872] R13: ffff8802bc9ed380 R14: 
0000000000000000 R15: ffff88061941bdb0
Jun 16 19:01:49 slurv kernel: [50823.271894] FS:  00007fd449a7d700(0000) 
GS:ffff88063fd40000(0000) knlGS:0000000000000000
Jun 16 19:01:49 slurv kernel: [50823.271919] CS:  0010 DS: 0000 ES: 0000 
CR0: 0000000080050033
Jun 16 19:01:49 slurv kernel: [50823.271937] CR2: 00007f8844002028 CR3: 
000000061be95000 CR4: 00000000000007e0
Jun 16 19:01:49 slurv kernel: [50823.271959] DR0: 0000000000000000 DR1: 
0000000000000000 DR2: 0000000000000000
Jun 16 19:01:49 slurv kernel: [50823.271980] DR3: 0000000000000000 DR6: 
00000000ffff0ff0 DR7: 0000000000000400
Jun 16 19:01:49 slurv kernel: [50823.272003] Process rpc.idmapd (pid: 
1678, threadinfo ffff88061941a000, task ffff88061b870000)
Jun 16 19:01:49 slurv kernel: [50823.272028] Stack:
Jun 16 19:01:49 slurv kernel: [50823.272036]  ffff88061941bd78 
0000000000000006 ffff88061941be85 fffffff01aad63e8
Jun 16 19:01:49 slurv kernel: [50823.272060]  ffff880606fb9840 
ffff880606fb97f0 ffff88061aad63c0 0000000000000006
Jun 16 19:01:49 slurv kernel: [50823.272083]  ffff88061941be85 
00007fffe09c4500 ffff88061941bdd8 ffffffff81129943
Jun 16 19:01:49 slurv kernel: [50823.272106] Call Trace:
Jun 16 19:01:49 slurv kernel: [50823.272116]  [<ffffffff81129943>] 
key_instantiate_and_link+0x58/0x80
Jun 16 19:01:49 slurv kernel: [50823.272145]  [<ffffffffa058a906>] 
idmap_pipe_downcall+0x154/0x1ad [nfs]
Jun 16 19:01:49 slurv kernel: [50823.272173]  [<ffffffffa04aeae2>] 
rpc_pipe_write+0x56/0x6f [sunrpc]
Jun 16 19:01:49 slurv kernel: [50823.272195]  [<ffffffff810c86ce>] 
vfs_write+0xad/0x13d
Jun 16 19:01:49 slurv kernel: [50823.272212]  [<ffffffff810c8949>] 
sys_write+0x45/0x6c
Jun 16 19:01:49 slurv kernel: [50823.272229]  [<ffffffff8130a462>] 
system_call_fastpath+0x16/0x1b
Jun 16 19:01:49 slurv kernel: [50823.272258] Code: 48 89 55 b8 48 89 75 
c0 e8 16 e4 1d 00 48 8b 43 78 c7 45 cc f0 ff ff ff 48 8b 55 b8 48 8b 75 
c0 a8 01 75 4f 48 8b 43 20 48 89 df <ff> 50 18 85 c0 89 45 cc 75 3e 48 
8b 43 48 f0 ff 40 44 f0 80 4b
Jun 16 19:01:49 slurv kernel: [50823.272317] RIP  [<ffffffff81129872>] 
__key_instantiate_and_link+0x52/0xcb
Jun 16 19:01:49 slurv kernel: [50823.272339]  RSP <ffff88061941bd38>
Jun 16 19:01:49 slurv kernel: [50823.279199] ---[ end trace 
25122b5e9d0b0c76 ]---

It did take a while this time.

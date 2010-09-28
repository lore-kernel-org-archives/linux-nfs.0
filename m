Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:47976 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755133Ab0I1RKg convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 28 Sep 2010 13:10:36 -0400
Subject: Re: BUG() at mm/filemap.c:550
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
In-Reply-To: <20100928152756.GH24465@fieldses.org>
References: <20100928152623.GG24465@fieldses.org>
	 <20100928152756.GH24465@fieldses.org>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 28 Sep 2010 13:10:32 -0400
Message-ID: <1285693832.9185.24.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, 2010-09-28 at 11:27 -0400, J. Bruce Fields wrote:
> I'm getting this on the latest trond/linux-next.
> 
> Looks like it's probably reproduceable just with basic connectathon
> tests over any nfs version.
> 
> --b.
> 
> ------------[ cut here ]------------
> kernel BUG at mm/filemap.c:550!
> invalid opcode: 0000 [#1] PREEMPT 
> last sysfs file: /sys/devices/virtio-pci/virtio2/net/eth0/broadcast
> CPU 0 
> Modules linked in: [last unloaded: scsi_wait_scan]
> 
> Pid: 4342, comm: rm Not tainted 2.6.36-rc5-00191-g250bc65 #454 /Bochs
> RIP: 0010:[<ffffffff810abd12>]  [<ffffffff810abd12>] unlock_page+0x32/0x40
> RSP: 0018:ffff88001e735d98  EFLAGS: 00010246
> RAX: ffff88001d52ea00 RBX: ffffea00005a1660 RCX: 0000000000000000
> RDX: 0000000000000002 RSI: ffff88001e01ef4a RDI: ffffea00005a1660
> RBP: ffff88001e735da8 R08: ffffffff82606d70 R09: 0000000000000000
> R10: 0000000000000246 R11: 000000000000015a R12: 0000000000000001
> R13: ffff88001d596d28 R14: ffff88001e735e58 R15: 0000000000000001
> FS:  00007f79de748700(0000) GS:ffffffff81e1c000(0000) knlGS:0000000000000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> CR2: 00007f79de726008 CR3: 000000001fbb1000 CR4: 00000000000006f0
> DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> Process rm (pid: 4342, threadinfo ffff88001e734000, task ffff88001e8fa050)
> Stack:
>  ffff88001e735db8 ffff88001e735e58 ffff88001e735dc8 ffffffff8121b42a
> <0> ffff88001e735e58 ffff880019bd4000 ffff88001e735e28 ffffffff8121bd41
> <0> ffff88001e735df8 0000000000000000 ffffffff810f4200 ffff88001e735f38
> Call Trace:
>  [<ffffffff8121b42a>] cache_page_release+0x1a/0x40
>  [<ffffffff8121bd41>] nfs_do_filldir+0xf1/0x130
>  [<ffffffff810f4200>] ? filldir+0x0/0xe0
>  [<ffffffff810f4200>] ? filldir+0x0/0xe0
>  [<ffffffff8121bfa5>] nfs_readdir+0x225/0x460
>  [<ffffffff812405d0>] ? nfs4_decode_dirent+0x0/0x100
>  [<ffffffff810f4200>] ? filldir+0x0/0xe0
>  [<ffffffff810f4480>] vfs_readdir+0xc0/0xe0
>  [<ffffffff810f4608>] sys_getdents+0x88/0xf0
>  [<ffffffff810024d8>] system_call_fastpath+0x16/0x1b
> Code: ec 08 0f 1f 44 00 00 f6 07 01 48 89 fb 74 1c 80 27 fe e8 a2 e7 ff ff 48 89 de 31 d2 48 89 c7 e8 65 da fa ff 48 83 c4 08 5b c9 c3 <0f> 0b eb fe 66 2e 0f 1f 84 00 00 00 00 00 55 48 89 e5 48 83 ec 
> RIP  [<ffffffff810abd12>] unlock_page+0x32/0x40
>  RSP <ffff88001e735d98>
> ---[ end trace 9808e83fed8c72ce ]---

Yes. That unlock_page() in cache_page_release() appears to be incorrect,
since the page is always unlocked after the call to read_cache_page().
I can't see that we really need to lock the page there. Nothing can
change the contents while we hold the dir->i_mutex.

I've therefore pushed out a revised version of that branch with the
unlock_page() removed.

Cheers
  Trond

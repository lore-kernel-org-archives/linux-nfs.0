From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH] nfs: clear_commit_release incorrectly handle truncated
 page
Date: Tue, 02 Feb 2010 12:00:03 -0500
Message-ID: <1265130003.3177.51.camel@localhost>
References: <87hbpzhqlp.fsf@openvz.org> <1265123045.3177.21.camel@localhost>
	 <87eil3pszw.fsf@openvz.org> <1265124999.3177.27.camel@localhost>
	 <87mxzrk4wk.fsf@openvz.org> <1265127435.3177.47.camel@localhost>
	 <87pr4nzisc.fsf@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	linux-nfs@vger.kernel.org
To: Dmitry Monakhov <dmonakhov@openvz.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:39451 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756670Ab0BBRAH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 2 Feb 2010 12:00:07 -0500
In-Reply-To: <87pr4nzisc.fsf@openvz.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2010-02-02 at 19:47 +0300, Dmitry Monakhov wrote: 
> Trond Myklebust <trond.myklebust@fys.uio.no> writes:
> > Hmm.... There is a known problem with a reference leak in
> > nfs_wb_page_cancel() (I've queued up a fix for 2.6.33 in the 'bugfixes'
> > branch of my git tree already). What happens when you apply the
> > following patch?
> The not helps, still get the same oops(log follows).
> Have you tried my testcase?
> 
>  BUG: unable to handle kernel NULL pointer dereference at 00000040
>  IP: [<f80d415f>] nfs_clear_request_commit+0x3f/0xb0 [nfs]
>  *pde = 00000000 
>  Oops: 0000 [#1] SMP DEBUG_PAGEALLOC
>  last sysfs file: /sys/devices/platform/thinkpad_acpi/leds/tpacpi::thinkvantage/uevent
>  Modules linked in: binfmt_misc quota_v2 quota_tree nfsd exportfs nfs lockd sunrpc iwl3945 thinkpad_acpi psmouse led_class serio_raw iwlcore nvram raid1 raid0 linear e1000e
>  
>  Pid: 1035, comm: nfsiod Not tainted 2.6.33-rc6 #60 2623DDU/2623DDU
>  EIP: 0060:[<f80d415f>] EFLAGS: 00010296 CPU: 0
>  EIP is at nfs_clear_request_commit+0x3f/0xb0 [nfs]
>  EAX: 00000000 EBX: c2561d80 ECX: c06d3700 EDX: 00000014
>  ESI: f69916c0 EDI: f80dab58 EBP: f6724ef4 ESP: f6724ee8
>   DS: 007b ES: 007b FS: 00d8 GS: 0000 SS: 0068
>  Process nfsiod (pid: 1035, ti=f6724000 task=f69dda90 task.ti=f6724000)
>  Stack:
>   c04df67d f69d7440 f69916c0 f6724f34 f80d4258 f6724f44 00001b0e 00000000
>  <0> ffff799c 00000400 f505f000 94c0042a f69917e0 f69917e8 00000000 f69916c0
>  <0> f69916c4 f69916c0 f80dab58 f6724f3c f8075703 f6724f58 f8075871 f6724f60
>  Call Trace:
>   [<c04df67d>] ? schedule+0x3ad/0xa30
>   [<f80d4258>] ? nfs_commit_release+0x88/0x1a0 [nfs]
>   [<f8075703>] ? rpc_release_calldata+0x13/0x20 [sunrpc]
>   [<f8075871>] ? rpc_free_task+0x41/0x70 [sunrpc]
>   [<c01acc4c>] ? probe_workqueue_execution+0x8c/0xd0
>   [<f8075940>] ? rpc_async_release+0x10/0x20 [sunrpc]
>   [<c015834d>] ? worker_thread+0x10d/0x210
>   [<f8075930>] ? rpc_async_release+0x0/0x20 [sunrpc]
>   [<c015bb10>] ? autoremove_wake_function+0x0/0x50
>   [<c0158240>] ? worker_thread+0x0/0x210
>   [<c015b724>] ? kthread+0x74/0x80
>   [<c015b6b0>] ? kthread+0x0/0x80
>   [<c0103546>] ? kernel_thread_helper+0x6/0x10
>  Code: f0 0f ba 70 28 01 19 d2 31 c0 85 d2 75 0e 8b 5d f8 8b 75 fc 89 ec 5d c3 8d 74 26 00 89 d8 ba 10 00 00 00 e8 74 0e 10 c8 8b 43 10 <8b> 70 40 9c 5b fa e8 26 67 0d c8 8d 46 30 b9 ff ff ff ff 0f bd 
>  EIP: [<f80d415f>] nfs_clear_request_commit+0x3f/0xb0 [nfs] SS:ESP 0068:f6724ee8
>  CR2: 0000000000000040
>  ---[ end trace 4bf8ee9d233ce744 ]---

Yep. Looking more carefully at your test case, I don't see how
truncate_inode_page() can be involved at all. You are extending the file
using lseek(), not truncate(). So something else must be at work here.

I'll see if I can reproduce it.

Trond


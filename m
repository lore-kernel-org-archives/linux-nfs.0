Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mout.gmx.net ([212.227.15.19]:58775 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756963AbaGRQW4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 18 Jul 2014 12:22:56 -0400
Message-ID: <53C949DC.5060008@gmx.de>
Date: Fri, 18 Jul 2014 18:22:52 +0200
From: =?UTF-8?B?VG9yYWxmIEbDtnJzdGVy?= <toralf.foerster@gmx.de>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>,
        Kinglong Mee <kinglongmee@gmail.com>
CC: Linux NFS mailing list <linux-nfs@vger.kernel.org>
Subject: Re: fuzz tested user mode linux crashed in NFS code path
References: <53C10EAA.2000802@gmx.de> <53C12A93.3040803@gmail.com> <20140716185724.GC2397@fieldses.org> <20140717202721.GG30442@fieldses.org>
In-Reply-To: <20140717202721.GG30442@fieldses.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 07/17/2014 10:27 PM, J. Bruce Fields wrote:
>> Toralf, is that crash reproduceable?  If so, does replacing the above
>> kmalloc by a kcalloc also fix it?

Yes.

I could reproduce it today, it tooks about 2 hours using these trinity paramters :

-C 2 -N 100000 -x mremap -x munmap -q -v /mnt/nfsv4


The backtrace of the core file :

Thread 1 (LWP 17085):
#0  0xb770baec in __kernel_vsyscall ()
#1  0x08484e85 in kill () at ../sysdeps/unix/syscall-template.S:81
#2  0x0807253d in uml_abort () at arch/um/os-Linux/util.c:93
#3  0x08072885 in os_dump_core () at arch/um/os-Linux/util.c:148
#4  0x0806241d in panic_exit (self=0x86c95c0 <panic_exit_notifier>, unused1=0, unused2=0x8700980 <buf.19753>) at arch/um/kernel/um_arch.c:240
#5  0x08099706 in notifier_call_chain (nl=0x0, val=2231598400, v=0x6, nr_to_call=-2, nr_calls=0x0) at kernel/notifier.c:93
#6  0x08099863 in __atomic_notifier_call_chain (nr_calls=<optimized out>, nr_to_call=<optimized out>, v=<optimized out>, val=<optimized out>, nh=<optimized out>) at kernel/notifier.c:183
#7  atomic_notifier_call_chain (nh=0x8700944 <panic_notifier_list>, val=0, v=0x8700980 <buf.19753>) at kernel/notifier.c:193
#8  0x084e0494 in panic (fmt=0x0) at kernel/panic.c:133
#9  0x080ffc70 in kfree (x=0x218) at mm/slub.c:3380
#10 0x0822c0db in nfsd4_encode_lock (resp=0x85576120, nfserr=0, lock=0x855752d0) at fs/nfsd/nfs4xdr.c:2910
#11 0x08233ad3 in nfsd4_encode_operation (resp=0x85576120, op=0x855752b0) at fs/nfsd/nfs4xdr.c:3889
#12 0x0822afff in nfsd4_proc_compound (rqstp=0x85571030, args=0x85037d40, resp=0x85576120) at fs/nfsd/nfs4proc.c:1386
#13 0x08219aea in nfsd_dispatch (rqstp=0x85571030, statp=0x7fcc8018) at fs/nfsd/nfssvc.c:686
#14 0x084686ff in svc_process_common (rqstp=0x85571030, argv=0x85037d40, resv=0x855711ac) at net/sunrpc/svc.c:1206
#15 0x08469bbb in svc_process (rqstp=0x85571030) at net/sunrpc/svc.c:1331
#16 0x08219472 in nfsd (vrqstp=0x85571030) at fs/nfsd/nfssvc.c:609
#17 0x08095806 in kthread (_create=0x84f86eb0) at kernel/kthread.c:207
#18 0x0805f64b in new_thread_handler () at arch/um/kernel/process.c:129
#19 0x00000000 in ?? ()

and the UML guest command line :

...
Kernel panic - not syncing: BUG!
CPU: 0 PID: 1397 Comm: nfsd Tainted: G    B         3.16.0-rc5-00152-g59ca9ee-dirty #76
Stack:
 0859f770 0859f770 00000003 086c8547 00000000 855752d0 0c6c9700 85037e1c
 084e3e42 00000000 85037df0 85037e44 084e0478 085ab1c4 08700980 0859c46a
 85037e50 00000000 00000000 855752d0 0c6c9700 85037e74 080ffc70 0859c46a
Call Trace:
 [<084e3e42>] dump_stack+0x26/0x28
 [<084e0478>] panic+0x7a/0x194
 [<080ffc70>] kfree+0x80/0x150
 [<0822ba5e>] ? nfsd4_encode_stateid+0x3e/0x60
 [<0822c0db>] nfsd4_encode_lock+0x4b/0x60
 [<08233ad3>] nfsd4_encode_operation+0xd3/0x1d0
 [<0822afff>] nfsd4_proc_compound+0x4bf/0x670
 [<0809b999>] ? groups_alloc+0x39/0xe0
 [<08219aea>] nfsd_dispatch+0xda/0x200
 [<084686ff>] svc_process_common+0x31f/0x610
 [<08469bbb>] svc_process+0x10b/0x140
 [<0809d270>] ? default_wake_function+0x0/0x20
 [<08219390>] ? nfsd+0x0/0x140
 [<08219472>] nfsd+0xe2/0x140
 [<08095806>] kthread+0xd6/0xe0
 [<0809c60d>] ? finish_task_switch.isra.56+0x1d/0x70
 [<0805f64b>] new_thread_handler+0x6b/0x90


I can now try with kzalloc, but due to the nature of this issue I think, that the absence of this crash - even after 2-3 hours - doesn't mean by 100%, that kzalloc fixed it, or ?


> 
> Sorry, that should be kzalloc.  We should probably fix that regardless.
> 
> But I still don't understand how you hit this case....
> 
> --b.


-- 
Toralf


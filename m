Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:37726 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759960AbaGPS50 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 16 Jul 2014 14:57:26 -0400
Date: Wed, 16 Jul 2014 14:57:24 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: Toralf =?utf-8?Q?F=C3=B6rster?= <toralf.foerster@gmx.de>,
        Linux NFS mailing list <linux-nfs@vger.kernel.org>
Subject: Re: fuzz tested user mode linux crashed in NFS code path
Message-ID: <20140716185724.GC2397@fieldses.org>
References: <53C10EAA.2000802@gmx.de>
 <53C12A93.3040803@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <53C12A93.3040803@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Jul 12, 2014 at 08:31:15PM +0800, Kinglong Mee wrote:
> I think it is caused by kfree an uninitialized address.
> Can you test with the patch listed in following url,
> I have send some days before ?
> 
> "[PATCH 1/4] NFSD: Fix memory leak in encoding denied lock"
> http://www.spinics.net/lists/linux-nfs/msg44719.html

I have this queued for 3.17, but if it causes a crash then it should go
to 3.16 now.

However, I'm confused: the only explicit initialization of lk_denied is
in the case vfs_lock_file() returns -EAGAIN.  Our usual tests (cthon,
pynfs) do lots of succesful locks, so should have hit this before.

OK, I see: this memory zeroed by a memset in svc_process_common():

	memset(rqstp->rq_argp, 0, procp->pc_argsize);

*But* in the case of the NFSv4 compound operation, we only have enough
space in rq_argp for 8 operations, anything more is allocated in
fs/nfsd/nfs4xdr.c:nfsd4_decode_compound:

	if (argp->opcnt > ARRAY_SIZE(argp->iops)) {
		argp->ops = kmalloc(argp->opcnt * sizeof(*argp->ops), GFP_KERNEL);
		...

So, perhaps we got a compound with more than 8 operations, with the LOCK
operation in the 9th or later position?

But the Linux NFS client doesn't do that, so I don't understand how
Toralf hit this.

Am I missing anything here?

Toralf, is that crash reproduceable?  If so, does replacing the above
kmalloc by a kcalloc also fix it?

(And thanks for your fuzz testing, it seems to catch interesting bugs.)

--b.


> 
> thanks,
> Kinglong Mee
> 
> On 7/12/2014 18:32, Toralf Förster wrote:
> > A fuzz-tested a x86 32 bit user user mode linux guest using guest kernel v3.16-rc4-142-g47ea8dd 
> > with trinity using NFSv4 victim files (both NFS server and NFS client run within the same UML).
> > 
> > The guest crashed :
> > 
> > Kernel panic - not syncing: BUG!
> > CPU: 0 PID: 1395 Comm: nfsd Tainted: G    B         3.16.0-rc4-00142-g47ea8dd-dirty #68
> > Stack:
> >  0859f770 0859f770 00000003 086c8547 00000000 858742a0 0cacd700 85447e1c
> >  084e3dd2 00000000 85447df0 85447e44 084e0408 085ab1c4 08700980 0859c46a
> >  85447e50 00000000 00000000 858742a0 0cacd700 85447e74 080ffc70 0859c46a
> > Call Trace:
> >  [<084e3dd2>] dump_stack+0x26/0x28
> >  [<084e0408>] panic+0x7a/0x194
> >  [<080ffc70>] kfree+0x80/0x150
> >  [<0822ba2e>] ? nfsd4_encode_stateid+0x3e/0x60
> >  [<0822c0ab>] nfsd4_encode_lock+0x4b/0x60
> >  [<08233aa3>] nfsd4_encode_operation+0xd3/0x1d0
> >  [<0822afcf>] nfsd4_proc_compound+0x4bf/0x670
> >  [<0809b999>] ? groups_alloc+0x39/0xe0
> >  [<08219aba>] nfsd_dispatch+0xda/0x200
> >  [<0846868f>] svc_process_common+0x31f/0x610
> >  [<08469b4b>] svc_process+0x10b/0x140
> >  [<0809d270>] ? default_wake_function+0x0/0x20
> >  [<08219360>] ? nfsd+0x0/0x140
> >  [<08219442>] nfsd+0xe2/0x140
> >  [<08095806>] kthread+0xd6/0xe0
> >  [<0809c60d>] ? finish_task_switch.isra.56+0x1d/0x70
> >  [<0805f64b>] new_thread_handler+0x6b/0x90
> > 
> > 
> > FWIW "dirty" cames from 1 patch from Richard Weinberger for arch/um/kernel/tlb.c and arch/um/os-Linux/skas/process.c
> > 
> > 
> > The back trace of the core file gives:
> > 
> > 
> > Thread 1 (LWP 12687):
> > #0  0xb7797aec in __kernel_vsyscall ()
> > #1  0x08484e15 in kill () at ../sysdeps/unix/syscall-template.S:81
> > #2  0x0807253d in uml_abort () at arch/um/os-Linux/util.c:93
> > #3  0x08072885 in os_dump_core () at arch/um/os-Linux/util.c:148
> > #4  0x0806241d in panic_exit (self=0x86c95c0 <panic_exit_notifier>, unused1=0, unused2=0x8700980 <buf.19753>) at arch/um/kernel/um_arch.c:240
> > #5  0x08099706 in notifier_call_chain (nl=0x0, val=2235858240, v=0x6, nr_to_call=-2, nr_calls=0x0) at kernel/notifier.c:93
> > #6  0x08099863 in __atomic_notifier_call_chain (nr_calls=<optimized out>, nr_to_call=<optimized out>, v=<optimized out>, val=<optimized out>, nh=<optimized out>) at kernel/notifier.c:183
> > #7  atomic_notifier_call_chain (nh=0x8700944 <panic_notifier_list>, val=0, v=0x8700980 <buf.19753>) at kernel/notifier.c:193
> > #8  0x084e0424 in panic (fmt=0x0) at kernel/panic.c:133
> > #9  0x080ffc70 in kfree (x=0x194) at mm/slub.c:3380
> > #10 0x0822c0ab in nfsd4_encode_lock (resp=0x85871030, nfserr=0, lock=0x858742a0) at fs/nfsd/nfs4xdr.c:2910
> > #11 0x08233aa3 in nfsd4_encode_operation (resp=0x85871030, op=0x85874280) at fs/nfsd/nfs4xdr.c:3889
> > #12 0x0822afcf in nfsd4_proc_compound (rqstp=0x858750f0, args=0x85447d40, resp=0x85871030) at fs/nfsd/nfs4proc.c:1386
> > #13 0x08219aba in nfsd_dispatch (rqstp=0x858750f0, statp=0x832c1018) at fs/nfsd/nfssvc.c:686
> > #14 0x0846868f in svc_process_common (rqstp=0x858750f0, argv=0x85447d40, resv=0x8587526c) at net/sunrpc/svc.c:1206
> > #15 0x08469b4b in svc_process (rqstp=0x858750f0) at net/sunrpc/svc.c:1331
> > #16 0x08219442 in nfsd (vrqstp=0x858750f0) at fs/nfsd/nfssvc.c:609
> > #17 0x08095806 in kthread (_create=0x85377eb0) at kernel/kthread.c:207
> > #18 0x0805f64b in new_thread_handler () at arch/um/kernel/process.c:129
> > #19 0x00000000 in ?? ()
> > 
> > 
> > 

From: Erez Zadok <ezk-EX0cT3Az47bauI2f2gSDlQ@public.gmane.org>
Subject: [NFS] lockdep warnings in nfs4 (v2.6.24-rc6-125-g5356f66)
Date: Mon, 24 Dec 2007 15:40:44 -0500
Message-ID: <200712242040.lBOKeiFA003845@agora.fsl.cs.sunysb.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:56073 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751828AbXL1ITn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 28 Dec 2007 03:19:43 -0500
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1J8ARS-0004WD-Im
	for linux-nfs@vger.kernel.org; Fri, 28 Dec 2007 19:19:42 +1100
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

My setup: ext2 partition, exported to localhost; nfs4 mounted on localhost;
unionfs mounted on top of nfs4 mount.  Issuing assorted regression tests via
the union.  Kernel compiled with lockdep.  Four of my tests (rmdir, readdir,
rename, and rename with whiteouts), trigger the same lockdep warning when
unmounting nfs4.  It doesn't happen when unionfs is mounted on top of
anything else, including nfs2 and nfs3.

I've not tried to reproduce it w/o unionfs, but the lockdep warning below
appears to be unrelated to unionfs.  If you'd like me to try and reproduce
it w/o unionfs, let me know.

Cheers,
Erez.

=======================================================
[ INFO: possible circular locking dependency detected ]
2.6.24-rc6-unionfs2 #80
-------------------------------------------------------
umount.nfs4/4017 is trying to acquire lock:
 (&(&clp->cl_renewd)->work){--..}, at: [<c0223e53>] __cancel_work_timer+0x83/0x17f

but task is already holding lock:
 (&clp->cl_sem){----}, at: [<f8879897>] nfs4_kill_renewd+0x17/0x29 [nfs]

which lock already depends on the new lock.


the existing dependency chain (in reverse order) is:

-> #1 (&clp->cl_sem){----}:
       [<c0230699>] __lock_acquire+0x9cc/0xb95
       [<c0230c39>] lock_acquire+0x5f/0x78
       [<c0397cb8>] down_read+0x3a/0x4c
       [<f88798e6>] nfs4_renew_state+0x1c/0x1b8 [nfs]
       [<c0223821>] run_workqueue+0xd9/0x1ac
       [<c0224220>] worker_thread+0x7a/0x86
       [<c0226b49>] kthread+0x3b/0x62
       [<c02033a3>] kernel_thread_helper+0x7/0x10
       [<ffffffff>] 0xffffffff

-> #0 (&(&clp->cl_renewd)->work){--..}:
       [<c0230589>] __lock_acquire+0x8bc/0xb95
       [<c0230c39>] lock_acquire+0x5f/0x78
       [<c0223e87>] __cancel_work_timer+0xb7/0x17f
       [<c0223f5a>] cancel_delayed_work_sync+0xb/0xd
       [<f887989e>] nfs4_kill_renewd+0x1e/0x29 [nfs]
       [<f885a8f6>] nfs_free_client+0x37/0x9e [nfs]
       [<f885ab20>] nfs_put_client+0x5d/0x62 [nfs]
       [<f885ab9a>] nfs_free_server+0x75/0xae [nfs]
       [<f8862672>] nfs4_kill_super+0x27/0x2b [nfs]
       [<c0258aab>] deactivate_super+0x3f/0x51
       [<c0269668>] mntput_no_expire+0x42/0x67
       [<c025d0e4>] path_release_on_umount+0x15/0x18
       [<c0269d30>] sys_umount+0x1a3/0x1cb
       [<c0269d71>] sys_oldumount+0x19/0x1b
       [<c02026ca>] sysenter_past_esp+0x5f/0xa5
       [<ffffffff>] 0xffffffff

other info that might help us debug this:

1 lock held by umount.nfs4/4017:
 #0:  (&clp->cl_sem){----}, at: [<f8879897>] nfs4_kill_renewd+0x17/0x29 [nfs]

stack backtrace:
Pid: 4017, comm: umount.nfs4 Not tainted 2.6.24-rc6-unionfs2 #80
 [<c020371f>] show_trace_log_lvl+0x1a/0x2f
 [<c02040a8>] show_trace+0x12/0x14
 [<c020497f>] dump_stack+0x6c/0x72
 [<c022eca5>] print_circular_bug_tail+0x5f/0x68
 [<c0230589>] __lock_acquire+0x8bc/0xb95
 [<c0230c39>] lock_acquire+0x5f/0x78
 [<c0223e87>] __cancel_work_timer+0xb7/0x17f
 [<c0223f5a>] cancel_delayed_work_sync+0xb/0xd
 [<f887989e>] nfs4_kill_renewd+0x1e/0x29 [nfs]
 [<f885a8f6>] nfs_free_client+0x37/0x9e [nfs]
 [<f885ab20>] nfs_put_client+0x5d/0x62 [nfs]
 [<f885ab9a>] nfs_free_server+0x75/0xae [nfs]
 [<f8862672>] nfs4_kill_super+0x27/0x2b [nfs]
 [<c0258aab>] deactivate_super+0x3f/0x51
 [<c0269668>] mntput_no_expire+0x42/0x67
 [<c025d0e4>] path_release_on_umount+0x15/0x18
 [<c0269d30>] sys_umount+0x1a3/0x1cb
 [<c0269d71>] sys_oldumount+0x19/0x1b
 [<c02026ca>] sysenter_past_esp+0x5f/0xa5
 =======================


-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs


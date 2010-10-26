Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:48299 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760325Ab0JZWMA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 26 Oct 2010 18:12:00 -0400
Date: Tue, 26 Oct 2010 18:11:56 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Arnd Bergmann <arnd@arndb.de>, Bryan Schumaker <bjschuma@netapp.com>,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: nfsd changes for 2.6.37
Message-ID: <20101026221156.GD1842@fieldses.org>
References: <20101026164549.GD19445@fieldses.org>
 <201010262218.36940.arnd@arndb.de>
 <4CC73BA6.1090407@netapp.com>
 <201010262255.40481.arnd@arndb.de>
 <AANLkTimPBqafDPxYpZjuym8+-yk4vKYTU15Js-Ux_e6Z@mail.gmail.com>
 <20101026212433.GB1842@fieldses.org>
 <AANLkTinOd9pDVRYDQ5+dqn8LPf4yoOW=j8NxyCfCQAB6@mail.gmail.com>
 <20101026214441.GC1842@fieldses.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20101026214441.GC1842@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, Oct 26, 2010 at 05:44:41PM -0400, J. Bruce Fields wrote:
> On Tue, Oct 26, 2010 at 02:37:26PM -0700, Linus Torvalds wrote:
> > On Tue, Oct 26, 2010 at 2:24 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> > >
> > > I did a couple connectathon runs just now with no obvious ill effects
> > > except for some sleep-within-spinlock warnings in the lease code.
> > 
> > Hmm. Those sleep-within-spinlock warnings are very likely serious
> > bugs.
> 
> Yeah, didn't mean to belittle them.
> 
> > Can you quote the whole warning with stack trace?
> 
> It's just obvious allocations in setlease:
> 
> BUG: sleeping function called from invalid context at mm/slab.c:3101
> in_atomic(): 1, irqs_disabled(): 0, pid: 4345, name: lease_tests
> 1 lock held by lease_tests/4345:
>  #0:  (file_lock_lock){+.+.+.}, at: [<ffffffff81128be5>] lock_flocks+0x15/0x20
> Pid: 4345, comm: lease_tests Not tainted 2.6.36-05858-gbd5e20b #1028
> Call Trace:
>  [<ffffffff8103141d>] __might_sleep+0x10d/0x140
>  [<ffffffff810e3ad3>] kmem_cache_alloc+0x1f3/0x230
>  [<ffffffff8112a4d2>] generic_setlease+0x112/0x2c0
>  [<ffffffff8112a6b5>] __vfs_setlease+0x35/0x40
>  [<ffffffff8112acfe>] fcntl_setlease+0xce/0x180
>  [<ffffffff810f7c2e>] sys_fcntl+0x2fe/0x630
>  [<ffffffff81961999>] ? trace_hardirqs_on_thunk+0x3a/0x3f
>  [<ffffffff81002658>] system_call_fastpath+0x16/0x1b
> 
> I'm testing a patch.

This works for me.

I'm not saying it's correct, but it does at least pass my dumb tests
without complaining.

--b.

diff --git a/fs/locks.c b/fs/locks.c
index 02b6e0e..db3afa0 100644
--- a/fs/locks.c
+++ b/fs/locks.c
@@ -1379,7 +1379,9 @@ int generic_setlease(struct file *filp, long arg, struct file_lock **flp)
 	if (error)
 		return error;
 
+	lock_flocks();
 	time_out_leases(inode);
+	unlock_flocks();
 
 	BUG_ON(!(*flp)->fl_lmops->fl_break);
 
@@ -1400,6 +1402,7 @@ int generic_setlease(struct file *filp, long arg, struct file_lock **flp)
 			goto out;
 	}
 
+	lock_flocks();
 	/*
 	 * At this point, we know that if there is an exclusive
 	 * lease on this file, then we hold it on this filp
@@ -1427,28 +1430,31 @@ int generic_setlease(struct file *filp, long arg, struct file_lock **flp)
 	error = -EAGAIN;
 	if ((arg == F_RDLCK && (wrlease_count > 0)) ||
 	    (arg == F_WRLCK && ((rdlease_count + wrlease_count) > 0)))
-		goto out;
+		goto out_unlock;
 
 	if (my_before != NULL) {
 		*flp = *my_before;
 		error = lease->fl_lmops->fl_change(my_before, arg);
-		goto out;
+		goto out_unlock;
 	}
 
 	error = 0;
 	if (arg == F_UNLCK)
-		goto out;
+		goto out_unlock;
 
 	error = -EINVAL;
 	if (!leases_enable)
-		goto out;
+		goto out_unlock;
 
 	locks_copy_lock(new_fl, lease);
 	locks_insert_lock(before, new_fl);
 
 	*flp = new_fl;
+	unlock_flocks();
 	return 0;
 
+out_unlock:
+	unlock_flocks();
 out:
 	if (new_fl != NULL)
 		locks_free_lock(new_fl);
@@ -1495,9 +1501,7 @@ int vfs_setlease(struct file *filp, long arg, struct file_lock **lease)
 {
 	int error;
 
-	lock_flocks();
 	error = __vfs_setlease(filp, arg, lease);
-	unlock_flocks();
 
 	return error;
 }
@@ -1524,8 +1528,6 @@ int fcntl_setlease(unsigned int fd, struct file *filp, long arg)
 	if (error)
 		return error;
 
-	lock_flocks();
-
 	error = __vfs_setlease(filp, arg, &flp);
 	if (error || arg == F_UNLCK)
 		goto out_unlock;
@@ -1541,7 +1543,6 @@ int fcntl_setlease(unsigned int fd, struct file *filp, long arg)
 
 	error = __f_setown(filp, task_pid(current), PIDTYPE_PID, 0);
 out_unlock:
-	unlock_flocks();
 	return error;
 }
 

From: Miklos Szeredi <miklos@szeredi.hu>
Subject: Re: nfs: infinite loop in fcntl(F_SETLKW)
Date: Mon, 14 Apr 2008 23:15:53 +0200
Message-ID: <E1JlW1p-0006vZ-NW@pomaz-ex.szeredi.hu>
References: <E1JjcgO-0004q2-VJ@pomaz-ex.szeredi.hu> <E1Jk2oI-0007UX-MS@pomaz-ex.szeredi.hu> <1207861339.8180.14.camel@heimdal.trondhjem.org> <1207861661.8180.18.camel@heimdal.trondhjem.org> <1207862436.8180.30.camel@heimdal.trondhjem.org> <20080410215410.GF22324@fieldses.org> <E1JkxZI-0003Bc-9C@pomaz-ex.szeredi.hu> <20080414171909.GE15950@fieldses.org>
Cc: miklos@szeredi.hu, trond.myklebust@fys.uio.no,
	eshel@almaden.ibm.com, neilb@suse.de, akpm@linux-foundation.org,
	linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-fsdevel@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-reply-to: <20080414171909.GE15950@fieldses.org> (bfields@fieldses.org)
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> On Sun, Apr 13, 2008 at 10:28:08AM +0200, Miklos Szeredi wrote:
> > > Apologies, that was indeed a behavioral change introduced in a commit
> > > that claimed just to be shuffling code around.
> > 
> > Another complaint about this series: using EINPROGRESS to signal
> > asynchronous locking looks really fishy.  How does the filesystem
> > know, that the caller wants to do async locking?
> 
> The caller sets a fl_grant callback.  But I guess the interesting
> question is how the caller knows that the filesystem is really going to
> return the results asynchronously:
> 
> > How do we make sure,
> > that the filesystem (like fuse or 9p, which "blindly" return the error
> > from the server) doesn't return EINPROGRESS even when it's _not_ doing
> > an asynchronous lock?
> 
> Right, there's no safeguard there--if fuse returns EINPROGRESS, then
> we'll wait for a grant callback that's not going to come.  It should
> time out, so that's not a total disaster, but still.
> 
> Anyway, I'm not sure what to do about that.
> 
> > 
> > I think it would have been much cleaner to have a completely separate
> > interface for async locking, instead of trying to cram that into
> > f_op->lock().
> 
> Maybe so.  ->lock() had quite a bit crammed into it even before this.

Oh yeah, but at least that was 1:1 with the fcntl interface.

> > Would that be possible to fix now?  Or at least make EINPROGRESS a
> > kernel-internal error value (>512), to make it that it has a special
> > meaning for the _kernel only_?
> 
> Perhaps so.
> 
> The behavior of lockd will still depend to some degree on the exact
> error returned from the filesystem--e.g. if you return -EAGAIN from
> ->lock() without later calling ->fl_grant() it will cause some
> unexpected delays.  (Though again clients will eventually give up and
> poll for the lock.)

OK, so the semantics of vfs_lock_file() are now:

1) if !FL_SLEEP, then return 0 if granted, -EAGAIN on contention
2) if FL_SLEEP and fl_grant == NULL, then return 0 if granted, block on
   contention
3) if FL_SLEEP and fl_grant != NULL, then return 0 if granted, on
   contention:
   a) either return -EINPROGRESS and call fl_grant when granted
   b) or return -EAGAIN  and call fl_notify when the lock needs retrying

As a first step, how about doing the following:

For 3) use LOCK_FILE_ASYNC as a return value.  AFAICS there's no
reason to distinguish between a) and b).  For 1) leave the -EAGAIN
error, since in that case no lock was queued.

Here's an untested patch.  Comments?

Miklos


---
 fs/gfs2/locking/dlm/plock.c |    2 +-
 fs/lockd/svclock.c          |   13 ++++---------
 fs/locks.c                  |   20 ++++++++++----------
 include/linux/fs.h          |   15 +++++++++++++++
 4 files changed, 30 insertions(+), 20 deletions(-)

Index: linux-2.6/fs/locks.c
===================================================================
--- linux-2.6.orig/fs/locks.c	2008-04-14 22:19:57.000000000 +0200
+++ linux-2.6/fs/locks.c	2008-04-14 22:52:06.000000000 +0200
@@ -784,8 +784,10 @@ find_conflict:
 		if (!flock_locks_conflict(request, fl))
 			continue;
 		error = -EAGAIN;
-		if (request->fl_flags & FL_SLEEP)
-			locks_insert_block(fl, request);
+		if (!(request->fl_flags & FL_SLEEP))
+			goto out;
+		error = FILE_LOCK_ASYNC;
+		locks_insert_block(fl, request);
 		goto out;
 	}
 	if (request->fl_flags & FL_ACCESS)
@@ -841,7 +843,7 @@ static int __posix_lock_file(struct inod
 			error = -EDEADLK;
 			if (posix_locks_deadlock(request, fl))
 				goto out;
-			error = -EAGAIN;
+			error = FILE_LOCK_ASYNC;
 			locks_insert_block(fl, request);
 			goto out;
   		}
@@ -1040,7 +1042,7 @@ int posix_lock_file_wait(struct file *fi
 	might_sleep ();
 	for (;;) {
 		error = posix_lock_file(filp, fl, NULL);
-		if ((error != -EAGAIN) || !(fl->fl_flags & FL_SLEEP))
+		if (error != FILE_LOCK_ASYNC)
 			break;
 		error = wait_event_interruptible(fl->fl_wait, !fl->fl_next);
 		if (!error)
@@ -1112,9 +1114,7 @@ int locks_mandatory_area(int read_write,
 
 	for (;;) {
 		error = __posix_lock_file(inode, &fl, NULL);
-		if (error != -EAGAIN)
-			break;
-		if (!(fl.fl_flags & FL_SLEEP))
+		if (error != FILE_LOCK_ASYNC)
 			break;
 		error = wait_event_interruptible(fl.fl_wait, !fl.fl_next);
 		if (!error) {
@@ -1534,7 +1534,7 @@ int flock_lock_file_wait(struct file *fi
 	might_sleep();
 	for (;;) {
 		error = flock_lock_file(filp, fl);
-		if ((error != -EAGAIN) || !(fl->fl_flags & FL_SLEEP))
+		if (error != FILE_LOCK_ASYNC)
 			break;
 		error = wait_event_interruptible(fl->fl_wait, !fl->fl_next);
 		if (!error)
@@ -1806,7 +1806,7 @@ again:
 	else {
 		for (;;) {
 			error = posix_lock_file(filp, file_lock, NULL);
-			if (error != -EAGAIN || cmd == F_SETLK)
+			if (error != FILE_LOCK_ASYNC)
 				break;
 			error = wait_event_interruptible(file_lock->fl_wait,
 					!file_lock->fl_next);
@@ -1934,7 +1934,7 @@ again:
 	else {
 		for (;;) {
 			error = posix_lock_file(filp, file_lock, NULL);
-			if (error != -EAGAIN || cmd == F_SETLK64)
+			if (error != FILE_LOCK_ASYNC)
 				break;
 			error = wait_event_interruptible(file_lock->fl_wait,
 					!file_lock->fl_next);
Index: linux-2.6/fs/gfs2/locking/dlm/plock.c
===================================================================
--- linux-2.6.orig/fs/gfs2/locking/dlm/plock.c	2008-04-09 16:44:15.000000000 +0200
+++ linux-2.6/fs/gfs2/locking/dlm/plock.c	2008-04-14 22:54:05.000000000 +0200
@@ -108,7 +108,7 @@ int gdlm_plock(void *lockspace, struct l
 	if (xop->callback == NULL)
 		wait_event(recv_wq, (op->done != 0));
 	else
-		return -EINPROGRESS;
+		return FILE_LOCK_ASYNC;
 
 	spin_lock(&ops_lock);
 	if (!list_empty(&op->list)) {
Index: linux-2.6/fs/lockd/svclock.c
===================================================================
--- linux-2.6.orig/fs/lockd/svclock.c	2008-04-09 16:44:18.000000000 +0200
+++ linux-2.6/fs/lockd/svclock.c	2008-04-14 22:55:20.000000000 +0200
@@ -423,8 +423,8 @@ nlmsvc_lock(struct svc_rqst *rqstp, stru
 			goto out;
 		case -EAGAIN:
 			ret = nlm_lck_denied;
-			break;
-		case -EINPROGRESS:
+			goto out;
+		case FILE_LOCK_ASYNC:
 			if (wait)
 				break;
 			/* Filesystem lock operation is in progress
@@ -439,10 +439,6 @@ nlmsvc_lock(struct svc_rqst *rqstp, stru
 			goto out;
 	}
 
-	ret = nlm_lck_denied;
-	if (!wait)
-		goto out;
-
 	ret = nlm_lck_blocked;
 
 	/* Append to list of blocked */
@@ -520,7 +516,7 @@ nlmsvc_testlock(struct svc_rqst *rqstp, 
 	}
 
 	error = vfs_test_lock(file->f_file, &lock->fl);
-	if (error == -EINPROGRESS) {
+	if (error == FILE_LOCK_ASYNC) {
 		ret = nlmsvc_defer_lock_rqst(rqstp, block);
 		goto out;
 	}
@@ -744,8 +740,7 @@ nlmsvc_grant_blocked(struct nlm_block *b
 	switch (error) {
 	case 0:
 		break;
-	case -EAGAIN:
-	case -EINPROGRESS:
+	case FILE_LOCK_ASYNC:
 		dprintk("lockd: lock still blocked error %d\n", error);
 		nlmsvc_insert_block(block, NLM_NEVER);
 		nlmsvc_release_block(block);
Index: linux-2.6/include/linux/fs.h
===================================================================
--- linux-2.6.orig/include/linux/fs.h	2008-04-09 16:44:54.000000000 +0200
+++ linux-2.6/include/linux/fs.h	2008-04-14 23:03:03.000000000 +0200
@@ -837,6 +837,21 @@ extern spinlock_t files_lock;
 #define FL_SLEEP	128	/* A blocking lock */
 
 /*
+ * FILE_LOCK_ASYNC:
+ *
+ *   Special return value from posix_lock_file() and vfs_lock_file()
+ *   for asynchronous locking.
+ *
+ *   For posix_lock_file() it means, that the lock has been queued on
+ *   the block list.
+ *
+ *   For vfs_lock_file() it means, that the filesystem will call back
+ *   either fl_notify() or fl_granted() when the lock needs to be
+ *   retried or if it has been granted.
+ */
+#define FILE_LOCK_ASYNC 1
+
+/*
  * The POSIX file lock owner is determined by
  * the "struct files_struct" in the thread group
  * (or NULL for no owner - BSD locks).

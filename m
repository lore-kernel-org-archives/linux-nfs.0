From: Sridhar Samudrala <sri@us.ibm.com>
Subject: [PATCH] NFS file locking for clustered filesystems
Date: Tue, 5 Oct 2004 14:09:01 -0700 (PDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.61.0410051353330.2242@localhost-009047018098.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CEwYx-0003RN-3U
	for nfs@lists.sourceforge.net; Tue, 05 Oct 2004 14:09:35 -0700
Received: from e5.ny.us.ibm.com ([32.97.182.105])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.41)
	id 1CEwYl-0005lq-5v
	for nfs@lists.sourceforge.net; Tue, 05 Oct 2004 14:09:35 -0700
To: trond.myklebust@fys.uio.no, andros@citi.umich.edu
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Trond, Andy,

This is a cleaned up version of the patch i posted couple of weeks back 
that adds support to propagate NFS lockd locks to the underlying filesystem.
The patch is against 2.6.9-rc3-CITI_NFS4_ALL-1 tree.

This patch introduces asynchronous lock request mechanism so that the 
underlying filesystem lock operation can be called without blocking lockd.

Optional extensions to filesystem lock call: f_op->lock()
---------------------------------------------------------
- Any cluster filesystem that would like the locks propagated should
   support these optional extensions. 
- The calls to the filesystem will return immediately with 0 or an
   appropriate error if they can perform the operation without involving
   any network IO.
- If the filesystem has to do any network io to perform the operation, it
   should return -EINPROGRESS, start the operation in background and return
   the result asynchronously using a callback once the operation is completed.
- The following new callback is added to struct lock_manager_operations
    int (*fl_vfs_callback)(struct file_lock *fl, struct file_lock *conf_lock,
                           int result);

Changes to lock manager:
------------------------
- Replace posix_lock_file() and posix_test_lock() calls in lockd with new
   routines vfs_lock_file() and vfs_test_lock() that make calls to the
   underlying filesystem.
- For a blocking call(F_SETLKW), if the filesystem returns EINPROGRESS, the
   lock manager will return NLM_LCK_BLOCKED to the client and adds the
   deferred request to the nlm_blocked list. Once the filesystem completes the
   asynchronous operation, it invokes fl_vfs_callback() with the appropriate
   result.  Based on the result, the callback will update the deferred request,
   moves it to the head of nlm_blocked and wakes up lockd.
   nlmsvc_retry_blocked() will find the deferred block  and send a GRANTED_MSG
   to the client with NLM_LCK_GRANTED/NLM_LCK_DENIED when the request is
   retried.
- For a non-blocking call(F_SETLK, F_GETLK), if the fileystem returns
   EINPROGRESS, the lock manager defers the lock request for 7secs and adds it
   to the nlm_blocked list.  If the callback is not invoked before the deferred
   duration, NLM_LCK_DENIED is sent to the client when it is revisited. If the
   callback is invoked before the deferred duration, it updates the blocked
   request, moves it to the head of nlm_blocked and wakes up lockd.
   nlmsvc_retry_blocked() will find the deferred block and revists the
   request causing NLM_LCK_GRANTED/NLM_LCK_DENIED to be sent to the client
   based on the result.

Thanks
Sridhar
-------------------------------------------------------------------------------
diff -Nru a/fs/lockd/svc.c b/fs/lockd/svc.c
--- a/fs/lockd/svc.c	2004-10-05 12:12:06 -07:00
+++ b/fs/lockd/svc.c	2004-10-05 12:12:06 -07:00
@@ -312,6 +312,45 @@
  	up(&nlmsvc_sema);
  }

+/* Dispatch routine for lockd */
+int
+nlmsvc_dispatch(struct svc_rqst *rqstp, u32 *statp)
+{
+	struct svc_procedure    *procp;
+	kxdrproc_t              xdr;
+	struct kvec *           argv = &rqstp->rq_arg.head[0];
+	struct kvec *           resv = &rqstp->rq_res.head[0];
+
+	dprintk("lockd: nlmsvc_dispatch vers %d proc %d\n",
+		rqstp->rq_vers, rqstp->rq_proc);
+
+	procp = rqstp->rq_procinfo;
+
+	/* Decode arguments */
+	xdr = procp->pc_decode;
+	if (xdr && !xdr(rqstp, argv->iov_base, rqstp->rq_argp)) {
+		dprintk("lockd: failed to decode arguments!\n");
+		*statp = rpc_garbage_args;
+		return 1;
+	}
+
+	/* Now call the procedure handler, and encode status. */
+	*statp = procp->pc_func(rqstp, rqstp->rq_argp, rqstp->rq_resp);
+	if (((struct nlm_res  *)(rqstp->rq_resp))->status == EINPROGRESS) {
+		dprintk("lockd: Deferring request!\n");
+		return 0;
+	}
+
+	/* Encode reply */
+	if (*statp == rpc_success && (xdr = procp->pc_encode) &&
+	    !xdr(rqstp, resv->iov_base+resv->iov_len, rqstp->rq_resp)) {
+		dprintk("lockd: failed to encode reply\n");
+		*statp = rpc_system_err;
+	}
+
+	return 1;
+}
+
  /*
   * Sysctl parameters (same as module parameters, different interface).
   */
@@ -472,12 +511,14 @@
  		.vs_vers	= 1,
  		.vs_nproc	= 17,
  		.vs_proc	= nlmsvc_procedures,
+		.vs_dispatch	= nlmsvc_dispatch,
  		.vs_xdrsize	= NLMSVC_XDRSIZE,
  };
  static struct svc_version	nlmsvc_version3 = {
  		.vs_vers	= 3,
  		.vs_nproc	= 24,
  		.vs_proc	= nlmsvc_procedures,
+		.vs_dispatch	= nlmsvc_dispatch,
  		.vs_xdrsize	= NLMSVC_XDRSIZE,
  };
  #ifdef CONFIG_LOCKD_V4
@@ -485,6 +526,7 @@
  		.vs_vers	= 4,
  		.vs_nproc	= 24,
  		.vs_proc	= nlmsvc_procedures4,
+		.vs_dispatch	= nlmsvc_dispatch,
  		.vs_xdrsize	= NLMSVC_XDRSIZE,
  };
  #endif
diff -Nru a/fs/lockd/svc4proc.c b/fs/lockd/svc4proc.c
--- a/fs/lockd/svc4proc.c	2004-10-05 12:12:06 -07:00
+++ b/fs/lockd/svc4proc.c	2004-10-05 12:12:06 -07:00
@@ -102,7 +102,8 @@
  		return rpc_success;

  	/* Now check for conflicting locks */
-	resp->status = nlmsvc_testlock(file, &argp->lock, &resp->lock);
+	resp->status = nlmsvc_testlock(rqstp, file, &argp->lock, &resp->lock,
+				       &resp->cookie);

  	dprintk("lockd: TEST4          status %d\n", ntohl(resp->status));
  	nlm_release_host(host);
diff -Nru a/fs/lockd/svclock.c b/fs/lockd/svclock.c
--- a/fs/lockd/svclock.c	2004-10-05 12:12:06 -07:00
+++ b/fs/lockd/svclock.c	2004-10-05 12:12:06 -07:00
@@ -241,7 +241,7 @@
  		posix_unblock_lock(file->f_file, fl);
  	if (unlock) {
  		fl->fl_type = F_UNLCK;
-		posix_lock_file(file->f_file, fl);
+		vfs_lock_file(file->f_file, fl, 0);
  		block->b_granted = 0;
  	}

@@ -264,6 +264,8 @@
  	if (block->b_host)
  		nlm_release_host(block->b_host);
  	nlmclnt_freegrantargs(&block->b_call);
+	if (block->b_fl)
+		kfree(block->b_fl);
  	kfree(block);
  }

@@ -291,16 +293,43 @@
  }

  /*
+ * Defer a lock request. Retry after 7secs.
+ */
+static u32
+nlmsvc_defer_lock_rqst(struct svc_rqst *rqstp, struct nlm_block *block)
+{
+	u32 status = nlm_lck_denied_nolocks;
+
+	block->b_flags |= B_DEFERRED;
+	block->b_done = 1;
+
+	nlmsvc_insert_block(block, 7 * HZ);
+
+	block->b_cache_req = &rqstp->rq_chandle;
+	if (rqstp->rq_chandle.defer) {
+		block->b_deferred_req =
+			 rqstp->rq_chandle.defer(block->b_cache_req);
+		if (block->b_deferred_req != NULL)
+			status = EINPROGRESS;
+	}
+	dprintk("lockd: nlmsvc_defer_lock_rqst block %p flags %ld status %d\n",
+		block, block->b_flags, status);
+
+	return status;
+}
+
+/*
   * Attempt to establish a lock, and if it can't be granted, block it
   * if required.
   */
  u32
  nlmsvc_lock(struct svc_rqst *rqstp, struct nlm_file *file,
-			struct nlm_lock *lock, int wait, struct nlm_cookie *cookie)
+	    struct nlm_lock *lock, int wait, struct nlm_cookie *cookie)
  {
  	struct file_lock	*conflock;
  	struct nlm_block	*block;
  	int			error;
+	u32			status;

  	dprintk("lockd: nlmsvc_lock(%s/%ld, ty=%d, pi=%d, %Ld-%Ld, bl=%d)\n",
  				file->f_file->f_dentry->d_inode->i_sb->s_id,
@@ -320,14 +349,55 @@
  	/* Lock file against concurrent access */
  	down(&file->f_sema);

+	if (block && (block->b_flags & B_DEFERRED)) {
+		dprintk("lockd: nlmsvc_lock deferred block %p flags %ld\n",
+			block, block->b_flags);
+		if (block->b_flags & B_GOT_LOCK) {
+			nlmsvc_delete_block(block, 0);
+			status = nlm_granted;
+		} else {
+			if (block->b_flags & B_TOO_LATE) {
+				nlmsvc_delete_block(block, 1);
+				status = nlm_lck_denied;
+			} else {
+				if (block->b_flags & B_WAIT)
+					status = nlm_lck_blocked;
+				else
+					status = EINPROGRESS;
+			}
+		}
+		up(&file->f_sema);
+		return status;
+	}
+
  	if (!(conflock = posix_test_lock(file->f_file, &lock->fl))) {
-		error = posix_lock_file(file->f_file, &lock->fl);
+		error = vfs_lock_file(file->f_file, &lock->fl, wait);
+		dprintk("lockd: vfs_lock_file error %d block %p wait %d\n",
+			-error, block, wait);
+
+		if ((block == NULL) && (error == -EINPROGRESS)) {
+			if (!(block = nlmsvc_create_block(rqstp, file, lock,
+							  cookie))) {
+				up(&file->f_sema);
+				return nlm_lck_denied_nolocks;
+			}
+			if (wait) {
+				block->b_flags |= B_DEFERRED;
+				block->b_flags |= B_WAIT;
+				block->b_done = 1;
+				nlmsvc_insert_block(block, NLM_NEVER);
+				status = nlm_lck_blocked;
+			} else {
+				status = nlmsvc_defer_lock_rqst(rqstp, block);
+			}
+			up(&file->f_sema);
+			return status;
+		}

-		if (block)
+		if (block && !(block->b_flags & B_DEFERRED))
  			nlmsvc_delete_block(block, 0);
  		up(&file->f_sema);

-		dprintk("lockd: posix_lock_file returned %d\n", -error);
  		switch(-error) {
  		case 0:
  			return nlm_granted;
@@ -380,10 +450,13 @@
   * Test for presence of a conflicting lock.
   */
  u32
-nlmsvc_testlock(struct nlm_file *file, struct nlm_lock *lock,
-				       struct nlm_lock *conflock)
+nlmsvc_testlock(struct svc_rqst *rqstp, struct nlm_file *file,
+		struct nlm_lock *lock, struct nlm_lock *conflock,
+		struct nlm_cookie *cookie)
  {
-	struct file_lock	*fl;
+	struct file_lock	*fl = NULL;
+	struct nlm_block 	*block;
+	int			error;

  	dprintk("lockd: nlmsvc_testlock(%s/%ld, ty=%d, %Ld-%Ld)\n",
  				file->f_file->f_dentry->d_inode->i_sb->s_id,
@@ -392,17 +465,55 @@
  				(long long)lock->fl.fl_start,
  				(long long)lock->fl.fl_end);

-	if ((fl = posix_test_lock(file->f_file, &lock->fl)) != NULL) {
-		dprintk("lockd: conflicting lock(ty=%d, %Ld-%Ld)\n",
-				fl->fl_type, (long long)fl->fl_start,
-				(long long)fl->fl_end);
-		conflock->caller = "somehost";	/* FIXME */
-		conflock->oh.len = 0;		/* don't return OH info */
-		conflock->fl = *fl;
-		return nlm_lck_denied;
+	lock->fl.fl_flags |= FL_LOCKD;
+
+	/* Get existing block (in case client is busy-waiting) */
+	block = nlmsvc_lookup_block(file, lock, 0);
+
+	if (block && (block->b_flags & B_DEFERRED)) {
+		fl = block->b_fl;
+		dprintk("lockd: nlmsvc_testlock deferred block %p flags %ld "
+			"fl %p\n", block, block->b_flags, fl);
+		if (block->b_flags & B_GOT_LOCK) {
+			nlmsvc_delete_block(block, 0);
+			if (fl != NULL)
+				goto conf_lock;
+			else {
+				nlmsvc_delete_block(block, 0);
+				return nlm_granted;
+			}
+		} else {
+			if (block->b_flags & B_TOO_LATE) {
+				nlmsvc_delete_block(block, 0);
+				return nlm_lck_denied;
+			} else {
+				return EINPROGRESS;
+			}
+		}
+	}
+
+	error = vfs_test_lock(file->f_file, &lock->fl, &fl);
+	if (fl)
+		goto conf_lock;
+
+	if (error == -EINPROGRESS && block == NULL) {
+		if (!(block = nlmsvc_create_block(rqstp, file, lock, cookie)))
+			return nlm_granted;
+		block->b_flags |= B_TEST;
+		return nlmsvc_defer_lock_rqst(rqstp, block);
  	}

  	return nlm_granted;
+
+conf_lock:
+	dprintk("lockd: conflicting lock(ty=%d, %Ld-%Ld)\n",
+		fl->fl_type, (long long)fl->fl_start, (long long)fl->fl_end);
+	conflock->caller = "somehost";	/* FIXME */
+	conflock->oh.len = 0;		/* don't return OH info */
+	conflock->fl = *fl;
+	if (block)
+		nlmsvc_delete_block(block, 0);
+	return nlm_lck_denied;
  }

  /*
@@ -428,7 +539,8 @@
  	nlmsvc_cancel_blocked(file, lock);

  	lock->fl.fl_type = F_UNLCK;
-	error = posix_lock_file(file->f_file, &lock->fl);
+	lock->fl.fl_flags |= FL_LOCKD;
+	error = vfs_lock_file(file->f_file, &lock->fl, 0);

  	return (error < 0)? nlm_lck_denied_nolocks : nlm_granted;
  }
@@ -483,6 +595,83 @@
  	printk(KERN_WARNING "lockd: notification for unknown block!\n");
  }

+/*
+ * Helper routine that updates a deferred block in response to the callback
+ * from VFS based on the returned conflock and result.
+ */
+static int
+nlmsvc_update_deferred_block(struct nlm_block *block, struct file_lock *conf,
+			     int result)
+{
+	int rc = 0;
+
+	if (block->b_flags & B_TOO_LATE)
+		return 1; 
+
+	if (block->b_flags & B_TEST) {
+		if (result == EBUSY && conf && conf->fl_type != F_UNLCK) {
+			block->b_fl = (struct file_lock *)
+					kmalloc(sizeof(*block), GFP_KERNEL);
+			if (block->b_fl) {
+				memcpy(block->b_fl, conf,
+				       sizeof(struct file_lock));
+				block->b_flags |= B_GOT_LOCK;
+			}
+		}
+	} else {
+		if (result == 0) {
+			rc = posix_lock_file(block->b_file->f_file,
+					     &block->b_call.a_args.lock.fl);
+			if (rc == 0) {
+				block->b_flags |= B_GOT_LOCK;
+				block->b_granted = 1;
+			}
+		}
+	}
+
+	nlmsvc_insert_block(block, 0);
+	svc_wake_up(block->b_daemon);
+
+	return rc;
+}
+
+/*
+ * This is a callback from the filesystem for VFS file lock requests.
+ * It will be used if fl_vfs_callback is defined and the filesystem can not
+ * respond to the request immediately.
+ * For GETLK request it will copy the reply to the nlm_block.
+ * For SETLK or SETLKW request it will get the local posix lock.
+ * In all cases it will move the block to the head of nlm_blocked q where
+ * nlmsvc_retry_blocked() can send back a reply for SETLKW or revisit the
+ * deferred rpc for GETLK and SETLK.
+ */
+static int
+nlmsvc_vfs_lock_callback(struct file_lock *fl, struct file_lock *conf,
+			 int result)
+{
+	struct nlm_block        **bp, *block;
+	int rc = 0;
+
+	dprintk("lockd: nlmsvc_vfs_lock_callback for lock %p conf %p result "
+		"%d\n", fl, conf, result);
+
+	lock_kernel();
+	for (bp = &nlm_blocked; (block = *bp) != 0; bp = &block->b_next) {
+		if (nlm_compare_locks(&block->b_call.a_args.lock.fl, fl)) {
+			if (block->b_flags & B_DEFERRED) {
+				rc = nlmsvc_update_deferred_block(block, conf,
+								  result);
+				break;
+			}
+		}
+	}
+	unlock_kernel();
+
+	dprintk("lockd: nlmsvc_vfs_lock_callback done block %p flags %ld\n",
+		block, block ? block->b_flags : 0);
+	return rc;
+}
+
  static int nlmsvc_same_owner(struct file_lock *fl1, struct file_lock *fl2)
  {
  	return fl1->fl_owner == fl2->fl_owner && fl1->fl_pid == fl2->fl_pid;
@@ -491,6 +680,7 @@
  struct lock_manager_operations nlmsvc_lock_operations = {
  	.fl_compare_owner = nlmsvc_same_owner,
  	.fl_notify = nlmsvc_notify_blocked,
+	.fl_vfs_callback = nlmsvc_vfs_lock_callback,
  };

  /*
@@ -542,7 +732,7 @@
  	 * following yields an error, this is most probably due to low
  	 * memory. Retry the lock in a few seconds.
  	 */
-	if ((error = posix_lock_file(file->f_file, &lock->fl)) < 0) {
+	if ((error = vfs_lock_file(file->f_file, &lock->fl, 0)) < 0) {
  		printk(KERN_WARNING "lockd: unexpected error %d in %s!\n",
  				-error, __FUNCTION__);
  		nlmsvc_insert_block(block, 10 * HZ);
@@ -654,6 +844,28 @@
  	nlm_release_file(file);
  }

+/* Helper function to handle retry of a deferred block.
+ * If it is a blocking lock, call grant_blocked to send a GRANTED_MSG.
+ * For a non-blocking lock, revisit the RPC request.
+ */
+static void
+nlmsvc_retry_deferred_block(struct nlm_block *block)
+{
+	if (!(block->b_flags & B_GOT_LOCK) && !(block->b_flags & B_WAIT))
+		block->b_flags |= B_TOO_LATE;
+
+	if (block->b_flags & B_WAIT) {
+		if (block->b_granted)
+			nlmsvc_grant_blocked(block);
+		nlmsvc_delete_block(block, 0);
+	} else {
+		nlmsvc_insert_block(block, NLM_NEVER);
+		dprintk("lockd: nlmsvc_retry_deferred_block revisit block %p "
+			"flags %ld\n", block, block->b_flags);
+		block->b_deferred_req->revisit(block->b_deferred_req, 0);
+	}
+}
+
  /*
   * Retry all blocked locks that have been notified. This is where lockd
   * picks up locks that can be granted, or grant notifications that must
@@ -674,9 +886,12 @@
  			break;
  		dprintk("nlmsvc_retry_blocked(%p, when=%ld, done=%d)\n",
  			block, block->b_when, block->b_done);
-		if (block->b_done)
-			nlmsvc_delete_block(block, 0);
-		else
+		if (block->b_done) {
+			if (block->b_flags & B_DEFERRED)
+				nlmsvc_retry_deferred_block(block);
+			else
+				nlmsvc_delete_block(block, 0);
+		} else
  			nlmsvc_grant_blocked(block);
  	}

diff -Nru a/fs/lockd/svcproc.c b/fs/lockd/svcproc.c
--- a/fs/lockd/svcproc.c	2004-10-05 12:12:06 -07:00
+++ b/fs/lockd/svcproc.c	2004-10-05 12:12:06 -07:00
@@ -129,7 +129,10 @@
  		return rpc_success;

  	/* Now check for conflicting locks */
-	resp->status = cast_status(nlmsvc_testlock(file, &argp->lock, &resp->lock));
+	resp->status = nlmsvc_testlock(rqstp, file, &argp->lock, &resp->lock,
+				       &resp->cookie);
+	if (resp->status != EINPROGRESS)
+		resp->status = cast_status(resp->status);

  	dprintk("lockd: TEST          status %d vers %d\n",
  		ntohl(resp->status), rqstp->rq_vers);
@@ -172,8 +175,10 @@
  #endif

  	/* Now try to lock the file */
-	resp->status = cast_status(nlmsvc_lock(rqstp, file, &argp->lock,
-					       argp->block, &argp->cookie));
+	resp->status = nlmsvc_lock(rqstp, file, &argp->lock, argp->block,
+				   &argp->cookie);
+	if (resp->status != EINPROGRESS)
+		resp->status = cast_status(resp->status);

  	dprintk("lockd: LOCK          status %d\n", ntohl(resp->status));
  	nlm_release_host(host);
diff -Nru a/fs/lockd/svcsubs.c b/fs/lockd/svcsubs.c
--- a/fs/lockd/svcsubs.c	2004-10-05 12:12:06 -07:00
+++ b/fs/lockd/svcsubs.c	2004-10-05 12:12:06 -07:00
@@ -176,7 +176,7 @@
  			lock.fl_type  = F_UNLCK;
  			lock.fl_start = 0;
  			lock.fl_end   = OFFSET_MAX;
-			if (posix_lock_file(file->f_file, &lock) < 0) {
+			if (vfs_lock_file(file->f_file, &lock, 0) < 0) {
  				printk("lockd: unlock failure in %s:%d\n",
  						__FILE__, __LINE__);
  				return 1;
diff -Nru a/fs/locks.c b/fs/locks.c
--- a/fs/locks.c	2004-10-05 12:12:06 -07:00
+++ b/fs/locks.c	2004-10-05 12:12:06 -07:00
@@ -482,6 +482,8 @@
  {
  	lock_kernel();
  	__locks_delete_block(waiter);
+	if (waiter->fl_flags & FL_FREE)
+		kfree(waiter);
  	unlock_kernel();
  }

@@ -594,6 +596,22 @@
  	return (locks_conflict(caller_fl, sys_fl));
  }

+/* Determine if lock sys_fl and lock caller_fl are same. */
+int posix_locks_same(struct file_lock *caller_fl, struct file_lock *sys_fl)
+{
+	/* POSIX locks owned by the same process do not conflict with
+	 * each other.
+	 */
+	if (IS_POSIX(sys_fl) &&
+	    posix_same_owner(caller_fl, sys_fl) &&
+	    caller_fl->fl_type == sys_fl->fl_type &&
+	    caller_fl->fl_start <= sys_fl->fl_start &&
+	    caller_fl->fl_end >= sys_fl->fl_end)
+		return 1;
+	else
+		return 0;
+}
+
  /* Determine if lock sys_fl blocks lock caller_fl. FLOCK specific
   * checking before calling the locks_conflict().
   */
@@ -656,6 +674,52 @@

  EXPORT_SYMBOL(posix_test_lock);

+/*
+ * Make a call to the underlying filesystem lock operation to test for the 
+ * lock even if there is no conflict with the local posix locks.
+ */
+int
+vfs_test_lock(struct file *filp, struct file_lock *fl, struct file_lock **conf)
+{
+	struct file_lock *cfl;
+	int result = 0;
+	int samelock = 0;
+
+	lock_kernel();
+	for (cfl = filp->f_dentry->d_inode->i_flock; cfl; cfl = cfl->fl_next) {
+		if (!IS_POSIX(cfl))
+			continue; 
+		if (posix_locks_same(cfl, fl))
+			samelock = 1;
+		if (posix_locks_conflict(cfl, fl))
+			break;
+	}
+	unlock_kernel();
+
+	if (cfl || samelock)
+		goto out;
+ 
+	if (filp->f_op && filp->f_op->lock) {
+		struct file_lock fl1;
+
+		memcpy(&fl1, fl, sizeof(struct file_lock));
+		result = filp->f_op->lock(filp, F_GETLK, &fl1);
+		if (result == 0 && fl1.fl_type != F_UNLCK) {
+			cfl = (struct file_lock *)
+				kmalloc(sizeof(struct file_lock), GFP_KERNEL);
+			if (cfl) {
+				memcpy(cfl, &fl1, sizeof(struct file_lock));
+				cfl->fl_flags |= FL_FREE;
+			}
+		}
+	}
+out:
+	*conf = cfl;
+
+	return result;
+}
+EXPORT_SYMBOL(vfs_test_lock);
+
  /* This function tests for deadlock condition before putting a process to
   * sleep. The detection scheme is no longer recursive. Recursive was neat,
   * but dangerous - we risked stack corruption if the lock data was bad, or
@@ -973,6 +1037,35 @@
  }
  EXPORT_SYMBOL(posix_lock_file_wait);

+/*
+ * Make a call to the underlying filesystem lock operation if supported as 
+ * well as local posix call.
+ */
+int vfs_lock_file(struct file *filp, struct file_lock *fl, int wait)
+{
+	int rc = 0;
+	int cmd = F_SETLK;
+
+	if (fl->fl_type != F_UNLCK) {
+		/* Check if the underlying filesystem will allow us to lock */
+		if (filp->f_op && filp->f_op->lock) {
+			if (wait)
+				cmd = F_SETLKW;
+			rc = filp->f_op->lock(filp, cmd, fl);
+		}
+		if (rc == 0)
+			rc = __posix_lock_file(filp->f_dentry->d_inode, fl);
+	} else {
+		rc = __posix_lock_file(filp->f_dentry->d_inode, fl);
+
+		/* Check if the underlying filesystem will allow us to unlock */
+		if (!rc && filp->f_op && filp->f_op->lock)
+			rc = filp->f_op->lock(filp, cmd, fl);
+	}
+	return rc;
+}
+EXPORT_SYMBOL(vfs_lock_file);
+
  /**
   * locks_mandatory_locked - Check for an active lock
   * @inode: the file to check
@@ -1914,12 +2007,20 @@
   *	@blocker: the lock which is blocking
   *	@waiter: the lock which conflicts and has to wait
   *
- * lockd needs to block waiting for locks.
+ * This routine is for the use of lockd alone. It allows lockd to wait
+ * for locks by putting the lock in the list of blocking locks without
+ * actually going to sleep itself.
   */
-void
+int
  posix_block_lock(struct file_lock *blocker, struct file_lock *waiter)
  {
-	locks_insert_block(blocker, waiter);
+	int error;
+
+	error = posix_locks_deadlock(waiter, blocker);
+	if (!error)
+		locks_insert_block(blocker, waiter);
+
+	return error;
  }

  EXPORT_SYMBOL(posix_block_lock);
@@ -1945,7 +2046,7 @@
  	} else {
  		unlock_kernel();
  		waiter->fl_type = F_UNLCK;
-		posix_lock_file(filp, waiter);
+		vfs_lock_file(filp, waiter, 0);
  	}
  }

diff -Nru a/include/linux/fs.h b/include/linux/fs.h
--- a/include/linux/fs.h	2004-10-05 12:12:06 -07:00
+++ b/include/linux/fs.h	2004-10-05 12:12:06 -07:00
@@ -613,6 +613,7 @@
  #define FL_LOCKD	16	/* lock held by rpc.lockd */
  #define FL_LEASE	32	/* lease held on this file */
  #define FL_SLEEP	128	/* A blocking lock */
+#define FL_FREE		256	/* file lock should be freed */

  /*
   * The POSIX file lock owner is determined by
@@ -636,6 +637,7 @@
  	void (*fl_copy_lock)(struct file_lock *, struct file_lock *);
  	void (*fl_release_private)(struct file_lock *);
  	void (*fl_break)(struct file_lock *);	/* break_lease callback */
+	int (*fl_vfs_callback)(struct file_lock *, struct file_lock *, int result);
  };

  /* that will die - we need it for nfs_lock_info */
@@ -695,7 +697,7 @@
  extern struct file_lock *posix_test_lock(struct file *, struct file_lock *);
  extern int posix_lock_file(struct file *, struct file_lock *);
  extern int posix_lock_file_wait(struct file *, struct file_lock *);
-extern void posix_block_lock(struct file_lock *, struct file_lock *);
+extern int posix_block_lock(struct file_lock *, struct file_lock *);
  extern void posix_unblock_lock(struct file *, struct file_lock *);
  extern int posix_locks_deadlock(struct file_lock *, struct file_lock *);
  extern int flock_lock_file_wait(struct file *filp, struct file_lock *fl);
@@ -706,6 +708,8 @@
  extern int lock_may_read(struct inode *, loff_t start, unsigned long count);
  extern int lock_may_write(struct inode *, loff_t start, unsigned long count);
  extern void steal_locks(fl_owner_t from);
+extern int vfs_lock_file(struct file *, struct file_lock *, int);
+extern int vfs_test_lock(struct file *, struct file_lock *, struct file_lock **);

  struct fasync_struct {
  	int	magic;
diff -Nru a/include/linux/lockd/lockd.h b/include/linux/lockd/lockd.h
--- a/include/linux/lockd/lockd.h	2004-10-05 12:12:06 -07:00
+++ b/include/linux/lockd/lockd.h	2004-10-05 12:12:06 -07:00
@@ -119,6 +119,15 @@
  	unsigned char		b_incall;	/* doing callback */
  	unsigned char		b_done;		/* callback complete */
  	struct nlm_file *	b_file;		/* file in question */
+	struct cache_req *      b_cache_req;    /* deferred request handling */
+	struct file_lock *      b_fl;           /* set for GETLK */
+	struct cache_deferred_req * b_deferred_req;
+	unsigned long           b_flags;        /* block flags */
+#define B_DEFERRED             1  /* Deferred lock */
+#define B_GOT_LOCK             2  /* Got deferred lock */
+#define B_TOO_LATE             4  /* Too late for deferred lock */
+#define B_WAIT                 16 /* Deferred Blocking lock */
+#define B_TEST                 32 /* Deferred Test lock */
  };

  /*
@@ -174,8 +183,9 @@
  u32		  nlmsvc_lock(struct svc_rqst *, struct nlm_file *,
  					struct nlm_lock *, int, struct nlm_cookie *);
  u32		  nlmsvc_unlock(struct nlm_file *, struct nlm_lock *);
-u32		  nlmsvc_testlock(struct nlm_file *, struct nlm_lock *,
-					struct nlm_lock *);
+u32		  nlmsvc_testlock(struct svc_rqst *, struct nlm_file *,
+				  struct nlm_lock *, struct nlm_lock *,
+				  struct nlm_cookie *);
  u32		  nlmsvc_cancel_blocked(struct nlm_file *, struct nlm_lock *);
  unsigned long	  nlmsvc_retry_blocked(void);
  int		  nlmsvc_traverse_blocks(struct nlm_host *, struct nlm_file *,


-------------------------------------------------------
This SF.net email is sponsored by: IT Product Guide on ITManagersJournal
Use IT products in your business? Tell us what you think of them. Give us
Your Opinions, Get Free ThinkGeek Gift Certificates! Click to find out more
http://productguide.itmanagersjournal.com/guidepromo.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

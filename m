From: Marc Eshel <eshel@almaden.ibm.com>
Subject: [patch] updated locking for cluster filesystem
Date: Wed, 5 Jan 2005 10:30:51 -0800
Message-ID: <OFF0F350CC.407F8F16-ON88256F80.005F8C6A-88256F80.0065B3AD@us.ibm.com>
References: <OFECF97ADD.AD77F838-ON88256F6C.0062E165-88256F6C.0067B807@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: nfs@lists.sourceforge.net, Manoj Naik <manoj@almaden.ibm.com>,
	"William A.(Andy) Adamson" <andros@citi.umich.edu>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CmFyh-0006VQ-50
	for nfs@lists.sourceforge.net; Wed, 05 Jan 2005 10:33:51 -0800
Received: from e2.ny.us.ibm.com ([32.97.182.142])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1CmFyc-0006Ej-HQ
	for nfs@lists.sourceforge.net; Wed, 05 Jan 2005 10:33:51 -0800
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e2.ny.us.ibm.com (8.12.10/8.12.10) with ESMTP id j05IXc9W007041
	for <nfs@lists.sourceforge.net>; Wed, 5 Jan 2005 13:33:38 -0500
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay04.pok.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j05IXcoD165076
	for <nfs@lists.sourceforge.net>; Wed, 5 Jan 2005 13:33:38 -0500
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11/8.12.11) with ESMTP id j05IXbgM009376
	for <nfs@lists.sourceforge.net>; Wed, 5 Jan 2005 13:33:37 -0500
In-Reply-To: <OFECF97ADD.AD77F838-ON88256F6C.0062E165-88256F6C.0067B807@us.ibm.com>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Sender: nfs-admin@lists.sourceforge.net
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

Hi Trond,

Here is an updated patch for Linux 2.6.10 which I believe addresses the
issues you had with the old one. In general the approach now is to have
complete separation between the local (POSIX) locking and the filesystem
locking. Only one of the two is called and there is no local state for
filesystem locks. The filesystem is responsible for keeping lock state and
cleaning up locks when necessary.

vfs_test_and_lock_file() is now really atomic for the POSIX case, to make
the filesystem locking atomic it will need a change in the interface so for
now there are two calls (test and lock).

Filesystems that want to support NLM locking will have to change to use the
new callback routine (fl_vfs_callback) for both blocking and non-blocking
locks. Since the filesystem needs to distinguish between the blocking and
the non-blocking calls, we are using FL_SLEEP to indicate blocking call. We
did not use SETLKW since it might cause filesystem that are not updated for
the new callback interface to block lockd. This the only point that we are
not completely comfortable with, let me know what you think.

Regards, Marc.


--- /nas/linux-2.6.10-uncompiled/fs/locks.c     2005-01-04
11:09:04.000000000 -0800
+++ /nas/linux-2.6.10-locks/fs/locks.c    2005-01-05 09:07:27.696101464
-0800
@@ -153,7 +153,7 @@ static struct file_lock *locks_alloc_loc
 }

 /* Free a lock which is not in use. */
-static inline void locks_free_lock(struct file_lock *fl)
+inline void locks_free_lock(struct file_lock *fl)
 {
  if (fl == NULL) {
   BUG();
@@ -183,6 +183,8 @@ static inline void locks_free_lock(struc
  kmem_cache_free(filelock_cache, fl);
 }

+EXPORT_SYMBOL(locks_free_lock);
+
 void locks_init_lock(struct file_lock *fl)
 {
  INIT_LIST_HEAD(&fl->fl_link);
@@ -656,7 +658,43 @@ posix_test_lock(struct file *filp, struc
  return (cfl);
 }

+int
+vfs_test_lock(struct file *filp, struct file_lock *fl, struct file_lock
**conf)
+{
+     struct file_lock *cfl;
+     int result = 0;
+
+     if (filp->f_op && filp->f_op->lock) {
+           cfl = locks_alloc_lock();
+           if (cfl == NULL)
+                 return -ENOLCK;
+           locks_copy_lock(cfl, fl);
+           result = filp->f_op->lock(filp, F_GETLK, cfl);
+           if (!result && cfl->fl_type == F_UNLCK) {
+                 locks_free_lock(cfl);
+                 cfl = NULL;
+           }
+     }
+     else {
+           lock_kernel();
+           for (cfl = filp->f_dentry->d_inode->i_flock; cfl; cfl =
cfl->fl_next) {
+                 if (!IS_POSIX(cfl))
+                       continue;
+                 if (posix_locks_conflict(cfl, fl))
+                       break;
+           }
+           unlock_kernel();
+        }
+     if (cfl) {
+           *conf = cfl;
+           return -EAGAIN;
+        }
+     *conf = NULL;
+     return result;
+}
+
 EXPORT_SYMBOL(posix_test_lock);
+EXPORT_SYMBOL(vfs_test_lock);

 /* This function tests for deadlock condition before putting a process to
  * sleep. The detection scheme is no longer recursive. Recursive was neat,
@@ -755,8 +793,10 @@ out:
 }

 EXPORT_SYMBOL(posix_lock_file);
+EXPORT_SYMBOL(vfs_lock_file);

-static int __posix_lock_file(struct inode *inode, struct file_lock
*request)
+static int __posix_lock_file(struct inode *inode, struct file_lock
*request,
+                                     struct file_lock **conflock)
 {
  struct file_lock *fl;
  struct file_lock *new_fl, *new_fl2;
@@ -781,13 +821,18 @@ static int __posix_lock_file(struct inod
    if (!posix_locks_conflict(request, fl))
     continue;
    error = -EAGAIN;
-                 if (!(request->fl_flags & FL_SLEEP))
+                 if (!(request->fl_flags & FL_SLEEP)) {
+                       if (conflock)
+                             *conflock = fl;
     goto out;
+                 }
    error = -EDEADLK;
    if (posix_locks_deadlock(request, fl))
     goto out;
    error = -EAGAIN;
    locks_insert_block(fl, request);
+                 if (conflock)
+                       *conflock = fl;
    goto out;
     }
    }
@@ -944,8 +989,65 @@ static int __posix_lock_file(struct inod
  */
 int posix_lock_file(struct file *filp, struct file_lock *fl)
 {
-     return __posix_lock_file(filp->f_dentry->d_inode, fl);
+     return __posix_lock_file(filp->f_dentry->d_inode, fl, NULL);
+}
+
+/**
+ * vfs_lock_file - Apply a POSIX-style lock to a file but call the
underlying
+ *   filesystem if it provides an interface
+ * @filp: The file to apply the lock to
+ * @fl: The lock to be applied
+ *
+ */
+int vfs_lock_file(struct file *filp, struct file_lock *fl)
+{
+     int error = 0;
+
+     if (filp->f_op && filp->f_op->lock) {
+           error = filp->f_op->lock(filp, F_SETLK, fl);
+     }
+     else
+           error = __posix_lock_file(filp->f_dentry->d_inode, fl, NULL);
+
+     return error;
+}
+
+/*
+ * vfs_test_and_lock_file - Test for an existing lock and acquire it if
available.
+ * @filp: The file to apply the lock to
+ * @fl: The lock to be applied
+ * @conf: The conflicting lock, if no conflict fl_type set to F_UNLCK
+ * Return: 0 if granted, -EAGAIN otherwise
+ *
+ * Only non-blocking locks are handled
+ */
+int vfs_test_and_lock_file(struct file *filp, struct file_lock *fl, struct
file_lock **conf)
+{
+     int error = 0;
+     int count = 0;          /* To avoid live deadlock. */
+     int maxtries = 1000;
+
+     if (filp->f_op && filp->f_op->lock) {
+try_again:
+           count++;
+           if (count > maxtries) {
+                 printk(KERN_ERR "vfs_test_and_lock_file: EDEADLK filp %p
fl %p\n",
+                       filp, fl);
+                 return -EDEADLK;
+           }
+           error = filp->f_op->lock(filp, F_SETLK, fl);
+           if (error == -EAGAIN) {
+                 error = vfs_test_lock(filp, fl, conf);
+                 if (!error && *conf == NULL)
+                       goto try_again;
+           }
+     }
+     else
+           error = __posix_lock_file(filp->f_dentry->d_inode, fl, conf);
+
+     return error;
 }
+EXPORT_SYMBOL(vfs_test_and_lock_file);

 /**
  * posix_lock_file_wait - Apply a POSIX-style lock to a file
@@ -961,7 +1063,7 @@ int posix_lock_file_wait(struct file *fi
  int error;
  might_sleep ();
  for (;;) {
-           error = __posix_lock_file(filp->f_dentry->d_inode, fl);
+           error = __posix_lock_file(filp->f_dentry->d_inode, fl, NULL);
   if ((error != -EAGAIN) || !(fl->fl_flags & FL_SLEEP))
    break;
   error = wait_event_interruptible(fl->fl_wait, !fl->fl_next);
@@ -1033,7 +1135,7 @@ int locks_mandatory_area(int read_write,
  fl.fl_end = offset + count - 1;

  for (;;) {
-           error = __posix_lock_file(inode, &fl);
+           error = __posix_lock_file(inode, &fl, NULL);
   if (error != -EAGAIN)
    break;
   if (!(fl.fl_flags & FL_SLEEP))
@@ -1661,7 +1763,7 @@ int fcntl_setlk(struct file *filp, unsig
  }

  for (;;) {
-           error = __posix_lock_file(inode, file_lock);
+           error = __posix_lock_file(inode, file_lock, NULL);
   if ((error != -EAGAIN) || (cmd == F_SETLK))
    break;
   error = wait_event_interruptible(file_lock->fl_wait,
@@ -1792,7 +1894,7 @@ int fcntl_setlk64(struct file *filp, uns
  }

  for (;;) {
-           error = __posix_lock_file(inode, file_lock);
+           error = __posix_lock_file(inode, file_lock, NULL);
   if ((error != -EAGAIN) || (cmd == F_SETLK64))
    break;
   error = wait_event_interruptible(file_lock->fl_wait,
@@ -1838,11 +1940,6 @@ void locks_remove_posix(struct file *fil
  lock.fl_ops = NULL;
  lock.fl_lmops = NULL;

-     if (filp->f_op && filp->f_op->lock != NULL) {
-           filp->f_op->lock(filp, F_SETLK, &lock);
-           goto out;
-     }
-
  /* Can't use posix_lock_file here; we need to remove it no matter
   * which pid we have.
   */
@@ -1856,7 +1953,7 @@ void locks_remove_posix(struct file *fil
   before = &fl->fl_next;
  }
  unlock_kernel();
-out:
+
  if (lock.fl_ops && lock.fl_ops->fl_release_private)
   lock.fl_ops->fl_release_private(&lock);
 }
--- /nas/linux-2.6.10-uncompiled/fs/lockd/svc.c 2005-01-04
11:09:04.000000000 -0800
+++ /nas/linux-2.6.10-locks/fs/lockd/svc.c      2005-01-04
14:14:02.000000000 -0800
@@ -317,6 +317,44 @@ out:
 }
 EXPORT_SYMBOL(lockd_down);

+int
+nlmsvc_dispatch(struct svc_rqst *rqstp, u32 *statp)
+{
+     struct svc_procedure    *procp;
+     kxdrproc_t        xdr;
+     struct kvec *           argv = &rqstp->rq_arg.head[0];
+     struct kvec *           resv = &rqstp->rq_res.head[0];
+
+     dprintk("lockd: nlmsvc_dispatch vers %d proc %d\n",
+                       rqstp->rq_vers, rqstp->rq_proc);
+
+     procp = rqstp->rq_procinfo;
+     statp = resv->iov_base +resv->iov_len;
+
+     /* Decode arguments */
+     xdr = procp->pc_decode;
+
+     if (xdr && !xdr(rqstp, argv->iov_base, rqstp->rq_argp)) {
+           dprintk("lockd: failed to decode arguments!\n");
+           *statp = rpc_garbage_args;
+           return 1;
+     }
+     /* Now call the procedure handler, and encode status. */
+     *statp = procp->pc_func(rqstp, rqstp->rq_argp, rqstp->rq_resp);
+     if (((struct nlm_res  *)(rqstp->rq_resp))->status ==
nlm_lck_deferred) {
+           dprintk("lockd: Deferring request!\n");
+           return 0;
+     }
+     /* Encode reply */
+     if (*statp == rpc_success && (xdr = procp->pc_encode)
+         && !xdr(rqstp, resv->iov_base+resv->iov_len, rqstp->rq_resp)) {
+                 dprintk("lockd: failed to encode reply\n");
+                 /* serv->sv_stats->rpcsystemerr++; */
+                 *statp = rpc_system_err;
+     }
+     return 1;
+}
+
 /*
  * Sysctl parameters (same as module parameters, different interface).
  */
@@ -481,12 +519,14 @@ static struct svc_version nlmsvc_version
   .vs_vers = 1,
   .vs_nproc      = 17,
   .vs_proc = nlmsvc_procedures,
+     .vs_dispatch      = nlmsvc_dispatch,
   .vs_xdrsize    = NLMSVC_XDRSIZE,
 };
 static struct svc_version    nlmsvc_version3 = {
   .vs_vers = 3,
   .vs_nproc      = 24,
   .vs_proc = nlmsvc_procedures,
+     .vs_dispatch      = nlmsvc_dispatch,
   .vs_xdrsize    = NLMSVC_XDRSIZE,
 };
 #ifdef CONFIG_LOCKD_V4
@@ -494,6 +534,7 @@ static struct svc_version   nlmsvc_version
   .vs_vers = 4,
   .vs_nproc      = 24,
   .vs_proc = nlmsvc_procedures4,
+     .vs_dispatch      = nlmsvc_dispatch,
   .vs_xdrsize    = NLMSVC_XDRSIZE,
 };
 #endif
--- /nas/linux-2.6.10-uncompiled/fs/lockd/svc4proc.c  2004-12-24
13:34:31.000000000 -0800
+++ /nas/linux-2.6.10-locks/fs/lockd/svc4proc.c 2005-01-04
14:14:02.000000000 -0800
@@ -102,7 +102,7 @@ nlm4svc_proc_test(struct svc_rqst *rqstp
   return rpc_success;

  /* Now check for conflicting locks */
-     resp->status = nlmsvc_testlock(file, &argp->lock, &resp->lock);
+     resp->status = nlmsvc_testlock(rqstp, file, &argp->lock, &resp->lock,
&resp->cookie);

  dprintk("lockd: TEST4          status %d\n", ntohl(resp->status));
  nlm_release_host(host);
--- /nas/linux-2.6.10-uncompiled/fs/lockd/svcproc.c   2004-12-24
13:35:01.000000000 -0800
+++ /nas/linux-2.6.10-locks/fs/lockd/svcproc.c  2005-01-04
14:14:02.000000000 -0800
@@ -37,6 +37,7 @@ cast_to_nlm(u32 status, u32 vers)
   case nlm_lck_denied_nolocks:
   case nlm_lck_blocked:
   case nlm_lck_denied_grace_period:
+     case nlm_lck_deferred:
    break;
   case nlm4_deadlock:
    status = nlm_lck_denied;
@@ -129,7 +130,7 @@ nlmsvc_proc_test(struct svc_rqst *rqstp,
   return rpc_success;

  /* Now check for conflicting locks */
-     resp->status = cast_status(nlmsvc_testlock(file, &argp->lock,
&resp->lock));
+     resp->status = cast_status(nlmsvc_testlock(rqstp, file, &argp->lock,
&resp->lock, &resp->cookie));

  dprintk("lockd: TEST          status %d vers %d\n",
   ntohl(resp->status), rqstp->rq_vers);
--- /nas/linux-2.6.10-uncompiled/fs/lockd/svclock.c   2004-12-24
13:34:29.000000000 -0800
+++ /nas/linux-2.6.10-locks/fs/lockd/svclock.c  2005-01-04
15:23:01.000000000 -0800
@@ -264,6 +264,8 @@ nlmsvc_delete_block(struct nlm_block *bl
  if (block->b_host)
   nlm_release_host(block->b_host);
  nlmclnt_freegrantargs(&block->b_call);
+     if (block->b_fl)
+           kfree(block->b_fl);
  kfree(block);
 }

@@ -291,6 +293,33 @@ nlmsvc_traverse_blocks(struct nlm_host *
 }

 /*
+ * Deferred lock request handling for non-blocking lock
+ */
+
+static u32
+nlmsvc_defer_lock_rqst(struct svc_rqst *rqstp, struct nlm_block *block)
+{
+     u32 status = nlm_lck_denied_nolocks;
+
+     block->b_flags |= B_DEFERRED;
+     block->b_done = 1;
+
+     nlmsvc_insert_block(block, NLM_TIMEOUT);
+
+     block->b_cache_req = &rqstp->rq_chandle;
+        if (rqstp->rq_chandle.defer) {
+           block->b_deferred_req =
+                 rqstp->rq_chandle.defer(block->b_cache_req);
+           if (block->b_deferred_req != NULL)
+                 status = nlm_lck_deferred;
+     }
+     dprintk("lockd: nlmsvc_defer_lock_rqst block %p flags %ld status
%d\n",
+           block, block->b_flags, status);
+
+     return status;
+}
+
+/*
  * Attempt to establish a lock, and if it can't be granted, block it
  * if required.
  */
@@ -298,9 +327,10 @@ u32
 nlmsvc_lock(struct svc_rqst *rqstp, struct nlm_file *file,
    struct nlm_lock *lock, int wait, struct nlm_cookie *cookie)
 {
-     struct file_lock  *conflock;
+     struct file_lock  *conflock = NULL;
  struct nlm_block      *block;
  int             error;
+     u32               status;

  dprintk("lockd: nlmsvc_lock(%s/%ld, ty=%d, pi=%d, %Ld-%Ld, bl=%d)\n",
     file->f_file->f_dentry->d_inode->i_sb->s_id,
@@ -320,32 +350,91 @@ again:
  /* Lock file against concurrent access */
  down(&file->f_sema);

-     if (!(conflock = posix_test_lock(file->f_file, &lock->fl))) {
-           error = posix_lock_file(file->f_file, &lock->fl);
+     if (block && (block->b_flags & B_DEFERRED)) {
+           dprintk("lockd: nlmsvc_lock deferred block %p flags %ld\n",
+                 block, block->b_flags);
+           if (block->b_flags & B_GOT_LOCK) {
+                 nlmsvc_delete_block(block, 0);
+                 status = nlm_granted;
+           } else {
+                 if (block->b_flags & B_TOO_LATE) {
+                       nlmsvc_delete_block(block, 1);
+                       status = nlm_lck_denied;
+                 } else {
+                       if (block->b_flags & B_WAIT)
+                             status = nlm_lck_blocked;
+                       else
+                             status = nlm_lck_deferred;
+                 }
+           }
+           up(&file->f_sema);
+           return status;
+     }
+
+     if (wait && file->f_file->f_op && file->f_file->f_op->lock) {
+           /* Since we cannot make blocking calls to the filesystem from
lockd,
+              we use FL_SLEEP to indicate a blocking call to distinguish
+              it from a non-blocking call */
+           lock->fl.fl_flags |= FL_SLEEP;
+           error = vfs_lock_file(file->f_file, &lock->fl);
+     }
+     else
+           error = vfs_test_and_lock_file(file->f_file, &lock->fl,
&conflock);
+
+     dprintk("lockd: posix_lock_file returned %d\n", -error);
+
+     if (error == -EINPROGRESS) {
+           /* Filesystem lock operation is in progress
+              Add it to the queue waiting for callback */
+           if (block)
+                 BUG();
+           if (!(block = nlmsvc_create_block(rqstp, file, lock,
+                                     cookie))) {
+                 up(&file->f_sema);
+                 return nlm_lck_denied_nolocks;
+           }
+           if (wait) {
+                 block->b_flags |= (B_DEFERRED | B_WAIT);
+                 block->b_done = 1;
+                 nlmsvc_insert_block(block, NLM_NEVER);
+                 status = nlm_lck_blocked;
+           } else {
+                 status = nlmsvc_defer_lock_rqst(rqstp, block);
+           }
+           up(&file->f_sema);
+           return status;
+     }

-           if (block)
+     if (error != -EAGAIN) {
+           if (block && !(block->b_flags & B_DEFERRED))
    nlmsvc_delete_block(block, 0);
+
   up(&file->f_sema);

-     dprintk("lockd: posix_lock_file returned %d\n", -error);
   switch(-error) {
   case 0:
    return nlm_granted;
   case EDEADLK:
    return nlm_deadlock;
-           case EAGAIN:
-                 return nlm_lck_denied;
   default:             /* includes ENOLCK */
    return nlm_lck_denied_nolocks;
   }
  }
-
+
+     /* If the conflicting lock was returned from the filesystem, the
notification
+        will occur on the callback and we don't need to block on it. Also
we may
+        not block on it because the lock might not exist locally for
distributed
+        filesystems */
+     if (conflock && file->f_file->f_op && file->f_file->f_op->lock) {
+           locks_free_lock(conflock);
+           conflock = NULL;
+     }
  if (!wait) {
   up(&file->f_sema);
   return nlm_lck_denied;
  }

-     if (posix_locks_deadlock(&lock->fl, conflock)) {
+     if (conflock && posix_locks_deadlock(&lock->fl, conflock)) {
   up(&file->f_sema);
   return nlm_deadlock;
  }
@@ -368,8 +457,9 @@ again:
  if (list_empty(&block->b_call.a_args.lock.fl.fl_block)) {
   /* Now add block to block list of the conflicting lock
      if we haven't done so. */
-           dprintk("lockd: blocking on this lock.\n");
-           posix_block_lock(conflock, &block->b_call.a_args.lock.fl);
+           dprintk("lockd: blocking on conflock %p\n", conflock);
+           if (conflock)
+                 posix_block_lock(conflock,
&block->b_call.a_args.lock.fl);
  }

  up(&file->f_sema);
@@ -380,10 +470,13 @@ again:
  * Test for presence of a conflicting lock.
  */
 u32
-nlmsvc_testlock(struct nlm_file *file, struct nlm_lock *lock,
-                              struct nlm_lock *conflock)
+nlmsvc_testlock(struct svc_rqst *rqstp, struct nlm_file *file,
+           struct nlm_lock *lock, struct nlm_lock *conflock,
+           struct nlm_cookie *cookie)
 {
-     struct file_lock  *fl;
+     struct file_lock  *conf = NULL;
+     struct nlm_block  *block;
+     u32   error;

  dprintk("lockd: nlmsvc_testlock(%s/%ld, ty=%d, %Ld-%Ld)\n",
     file->f_file->f_dentry->d_inode->i_sb->s_id,
@@ -392,17 +485,58 @@ nlmsvc_testlock(struct nlm_file *file, s
     (long long)lock->fl.fl_start,
     (long long)lock->fl.fl_end);

-     if ((fl = posix_test_lock(file->f_file, &lock->fl)) != NULL) {
-           dprintk("lockd: conflicting lock(ty=%d, %Ld-%Ld)\n",
-                       fl->fl_type, (long long)fl->fl_start,
-                       (long long)fl->fl_end);
-           conflock->caller = "somehost";      /* FIXME */
-           conflock->oh.len = 0;         /* don't return OH info */
-           conflock->fl = *fl;
-           return nlm_lck_denied;
+     lock->fl.fl_flags |= FL_LOCKD;
+
+     /* Get existing block (in case client is busy-waiting) */
+     block = nlmsvc_lookup_block(file, lock, 0);
+
+     if (block && (block->b_flags & B_DEFERRED)) {
+           dprintk("lockd: nlmsvc_testlock deferred block %p flags %ld "
+                 "fl %p\n", block, block->b_flags, block->b_fl);
+           if (block->b_flags & B_GOT_LOCK) {
+                 if (block->b_fl != NULL) {
+                       conflock->fl = *block->b_fl;
+                       goto conf_lock;
+                 }
+                 else {
+                       nlmsvc_delete_block(block, 0);
+                       return nlm_granted;
+                 }
+           } else {
+                 if (block->b_flags & B_TOO_LATE) {
+                       nlmsvc_delete_block(block, 0);
+                       return nlm_lck_denied;
+                 } else {
+                       return EINPROGRESS;
+                 }
+           }
+     }
+
+     error = vfs_test_lock(file->f_file, &lock->fl, &conf);
+     if (conf) {
+           conflock->fl = *conf;
+           if (file->f_file->f_op && file->f_file->f_op->lock)
+                 locks_free_lock(conf);  /* A filesystem lock */
+           goto conf_lock;
+        }
+     if (error == -EINPROGRESS && block == NULL) {
+           if (!(block = nlmsvc_create_block(rqstp, file, lock, cookie)))
+                 return nlm_granted;
+           block->b_flags |= B_TEST;
+           return nlmsvc_defer_lock_rqst(rqstp, block);
  }

  return nlm_granted;
+
+conf_lock:
+     dprintk("lockd: conflicting lock(ty=%d, %Ld-%Ld)\n",
+           conflock->fl.fl_type, (long long)conflock->fl.fl_start,
+           (long long)conflock->fl.fl_end);
+     conflock->caller = "somehost";      /* FIXME */
+     conflock->oh.len = 0;         /* don't return OH info */
+     if (block)
+           nlmsvc_delete_block(block, 0);
+     return nlm_lck_denied;
 }

 /*
@@ -428,7 +562,8 @@ nlmsvc_unlock(struct nlm_file *file, str
  nlmsvc_cancel_blocked(file, lock);

  lock->fl.fl_type = F_UNLCK;
-     error = posix_lock_file(file->f_file, &lock->fl);
+     lock->fl.fl_flags |= FL_LOCKD;
+     error = vfs_lock_file(file->f_file, &lock->fl);

  return (error < 0)? nlm_lck_denied_nolocks : nlm_granted;
 }
@@ -483,6 +618,73 @@ nlmsvc_notify_blocked(struct file_lock *
  printk(KERN_WARNING "lockd: notification for unknown block!\n");
 }

+/*
+ * Helper routine that updates a deferred block in response to the
callback
+ * from VFS based on the returned conflock and result.
+ */
+static void
+nlmsvc_update_deferred_block(struct nlm_block *block, struct file_lock
*conf,
+                      int result)
+{
+     if (block->b_flags & B_TEST) {
+           if (result == EBUSY && conf && conf->fl_type != F_UNLCK) {
+                 block->b_fl = (struct file_lock *)
+                             kmalloc(sizeof(*block), GFP_KERNEL);
+                 if (block->b_fl) {
+                       locks_copy_lock(block->b_fl, conf);
+                       block->b_flags |= B_GOT_LOCK;
+                 }
+           }
+     } else {
+           if (result == 0) {
+                 block->b_flags |= B_GOT_LOCK;
+                 block->b_granted = 1;
+           }
+     }
+     nlmsvc_insert_block(block, 0);
+     svc_wake_up(block->b_daemon);
+     return;
+}
+
+/*
+ * This is a callback from the filesystem for VFS file lock requests.
+ * It will be used if fl_vfs_callback is defined and the filesystem can
not
+ * respond to the request immediately.
+ * For GETLK request it will copy the reply to the nlm_block.
+ * For SETLK or SETLKW request it will get the local posix lock.
+ * In all cases it will move the block to the head of nlm_blocked q where
+ * nlmsvc_retry_blocked() can send back a reply for SETLKW or revisit the
+ * deferred rpc for GETLK and SETLK.
+ */
+static int
+nlmsvc_vfs_lock_callback(struct file_lock *fl, struct file_lock *conf,
+                  int result)
+{
+     struct nlm_block        **bp, *block;
+     int rc = 0;
+
+     dprintk("lockd: nlmsvc_vfs_lock_callback for lock %p conf %p result "
+           "%d\n", fl, conf, result);
+
+     lock_kernel();
+     for (bp = &nlm_blocked; (block = *bp) != 0; bp = &block->b_next) {
+           if (nlm_compare_locks(&block->b_call.a_args.lock.fl, fl)) {
+                 if (block->b_flags & B_DEFERRED) {
+                       if (block->b_flags & B_TOO_LATE) {
+                                   rc = 1;
+                             break;
+                       }
+                       nlmsvc_update_deferred_block(block, conf, result);
+                 }
+           }
+     }
+     unlock_kernel();
+
+     dprintk("lockd: nlmsvc_vfs_lock_callback done block %p flags %ld\n",
+           block, block ? block->b_flags : 0);
+     return rc;
+}
+
 static int nlmsvc_same_owner(struct file_lock *fl1, struct file_lock *fl2)
 {
  return fl1->fl_owner == fl2->fl_owner && fl1->fl_pid == fl2->fl_pid;
@@ -491,6 +693,7 @@ static int nlmsvc_same_owner(struct file
 struct lock_manager_operations nlmsvc_lock_operations = {
  .fl_compare_owner = nlmsvc_same_owner,
  .fl_notify = nlmsvc_notify_blocked,
+     .fl_vfs_callback = nlmsvc_vfs_lock_callback,
 };

 /*
@@ -509,7 +712,7 @@ nlmsvc_grant_blocked(struct nlm_block *b
 {
  struct nlm_file       *file = block->b_file;
  struct nlm_lock       *lock = &block->b_call.a_args.lock;
-     struct file_lock  *conflock;
+     struct file_lock  *conflock = NULL;
  int             error;

  dprintk("lockd: grant blocked lock %p\n", block);
@@ -529,20 +732,23 @@ nlmsvc_grant_blocked(struct nlm_block *b
  }

  /* Try the lock operation again */
-     if ((conflock = posix_test_lock(file->f_file, &lock->fl)) != NULL) {
+     error = vfs_test_and_lock_file(file->f_file, &lock->fl, &conflock);
+     if (conflock) {
   /* Bummer, we blocked again */
   dprintk("lockd: lock still blocked\n");
   nlmsvc_insert_block(block, NLM_NEVER);
-           posix_block_lock(conflock, &lock->fl);
+           /* Free filesystem conflicting lock, can not block on it, the
+                 filesystem lock might not exist locally.  */
+           if (file->f_file->f_op && file->f_file->f_op->lock) {
+                 locks_free_lock(conflock);
+                 conflock = NULL;
+           }
+           else
+                 posix_block_lock(conflock, &lock->fl);
   up(&file->f_sema);
   return;
  }
-
-     /* Alright, no conflicting lock. Now lock it for real. If the
-      * following yields an error, this is most probably due to low
-      * memory. Retry the lock in a few seconds.
-      */
-     if ((error = posix_lock_file(file->f_file, &lock->fl)) < 0) {
+     if (error) {
   printk(KERN_WARNING "lockd: unexpected error %d in %s!\n",
     -error, __FUNCTION__);
   nlmsvc_insert_block(block, 10 * HZ);
@@ -654,6 +860,28 @@ nlmsvc_grant_reply(struct svc_rqst *rqst
  nlm_release_file(file);
 }

+/* Helper function to handle retry of a deferred block.
+ * If it is a blocking lock, call grant_blocked to send a GRANTED_MSG.
+ * For a non-blocking lock, revisit the RPC request.
+ */
+static void
+nlmsvc_retry_deferred_block(struct nlm_block *block)
+{
+     if (!(block->b_flags & B_GOT_LOCK) && !(block->b_flags & B_WAIT))
+           block->b_flags |= B_TOO_LATE;
+
+     if (block->b_flags & B_WAIT) {
+           if (block->b_granted)
+                 nlmsvc_grant_blocked(block);
+           nlmsvc_delete_block(block, 0);
+     } else {
+           nlmsvc_insert_block(block, NLM_NEVER);
+           dprintk("lockd: nlmsvc_retry_deferred_block revisit block %p "
+                 "flags %ld\n", block, block->b_flags);
+           block->b_deferred_req->revisit(block->b_deferred_req, 0);
+     }
+}
+
 /*
  * Retry all blocked locks that have been notified. This is where lockd
  * picks up locks that can be granted, or grant notifications that must
@@ -674,8 +902,12 @@ nlmsvc_retry_blocked(void)
    break;
   dprintk("nlmsvc_retry_blocked(%p, when=%ld, done=%d)\n",
    block, block->b_when, block->b_done);
-           if (block->b_done)
-                 nlmsvc_delete_block(block, 0);
+           if (block->b_done) {
+                 if (block->b_flags & B_DEFERRED)
+                       nlmsvc_retry_deferred_block(block);
+                 else
+                       nlmsvc_delete_block(block, 0);
+           }
   else
    nlmsvc_grant_blocked(block);
  }
--- /nas/linux-2.6.10-uncompiled/fs/lockd/svcsubs.c   2004-12-24
13:35:01.000000000 -0800
+++ /nas/linux-2.6.10-locks/fs/lockd/svcsubs.c  2005-01-04
14:14:02.000000000 -0800
@@ -176,7 +176,7 @@ again:
    lock.fl_type  = F_UNLCK;
    lock.fl_start = 0;
    lock.fl_end   = OFFSET_MAX;
-                 if (posix_lock_file(file->f_file, &lock) < 0) {
+                 if (vfs_lock_file(file->f_file, &lock) < 0) {
     printk("lockd: unlock failure in %s:%d\n",
       __FILE__, __LINE__);
     return 1;
--- /nas/linux-2.6.10-uncompiled/fs/nfsd/nfs4state.c  2005-01-04
11:42:39.000000000 -0800
+++ /nas/linux-2.6.10-locks/fs/nfsd/nfs4state.c 2005-01-04
15:44:24.000000000 -0800
@@ -2672,7 +2672,7 @@ nfsd4_lock(struct svc_rqst *rqstp, struc
  struct nfs4_stateid *lock_stp;
  struct file *filp;
  struct file_lock file_lock;
-     struct file_lock *conflock;
+     struct file_lock *conflock = NULL;
  int status = 0;
  unsigned int strhashval;

@@ -2797,8 +2797,7 @@ nfsd4_lock(struct svc_rqst *rqstp, struc
  * Try to lock the file in the VFS.
  * Note: locks.c uses the BKL to protect the inode's lock list.
  */
-
-     status = posix_lock_file(filp, &file_lock);
+     status = vfs_test_and_lock_file(filp, &file_lock, &conflock);
  if (file_lock.fl_ops && file_lock.fl_ops->fl_release_private)
   file_lock.fl_ops->fl_release_private(&file_lock);
  dprintk("NFSD: nfsd4_lock: posix_lock_file status %d\n",status);
@@ -2819,16 +2818,15 @@ nfsd4_lock(struct svc_rqst *rqstp, struc

conflicting_lock:
dprintk("NFSD: nfsd4_lock: conflicting lock found!\n");
-     status = nfserr_denied;
-     /* XXX There is a race here. Future patch needed to provide
-      * an atomic posix_lock_and_test_file
-      */
-     if (!(conflock = posix_test_lock(filp, &file_lock))) {
+     if (status != -EAGAIN) {
status = nfserr_serverfault;
goto out;
}
+     status = nfserr_denied;
nfs4_set_lock_denied(conflock, &lock->lk_denied);
-
+     if (filp->f_op && filp->f_op->lock) /* A filesystem lock */
+           locks_free_lock(conflock);
+
out_destroy_new_stateid:
if (lock->lk_is_new) {
dprintk("NFSD: nfsd4_lock: destroy new stateid!\n");
@@ -2857,7 +2855,7 @@ nfsd4_lockt(struct svc_rqst *rqstp, stru
struct inode *inode;
struct file file;
struct file_lock file_lock;
-     struct file_lock *conflicting_lock;
+     struct file_lock *conflicting_lock = NULL;
unsigned int strhashval;
int status;

@@ -2927,11 +2925,12 @@ nfsd4_lockt(struct svc_rqst *rqstp, stru
memset(&file, 0, sizeof (struct file));
file.f_dentry = current_fh->fh_dentry;

-     status = nfs_ok;
-     conflicting_lock = posix_test_lock(&file, &file_lock);
+     status = vfs_test_lock(&file, &file_lock, &conflicting_lock);
if (conflicting_lock) {
status = nfserr_denied;
nfs4_set_lock_denied(conflicting_lock, &lockt->lt_denied);
+           if (file.f_op && file.f_op->lock) /* A filesystem lock */
+                 locks_free_lock(conflicting_lock);
}
out:
nfs4_unlock_state();
@@ -2981,7 +2980,7 @@ nfsd4_locku(struct svc_rqst *rqstp, stru
/*
*  Try to unlock the file in the VFS.
*/
-     status = posix_lock_file(filp, &file_lock);
+     status = vfs_lock_file(filp, &file_lock);
if (file_lock.fl_ops && file_lock.fl_ops->fl_release_private)
file_lock.fl_ops->fl_release_private(&file_lock);
if (status) {
--- /nas/linux-2.6.10-uncompiled/include/linux/fs.h   2005-01-04
11:09:04.000000000 -0800
+++ /nas/linux-2.6.10-locks/include/linux/fs.h  2005-01-04
14:14:02.000000000 -0800
@@ -647,6 +647,7 @@ struct lock_manager_operations {
void (*fl_copy_lock)(struct file_lock *, struct file_lock *);
void (*fl_release_private)(struct file_lock *);
void (*fl_break)(struct file_lock *);
+     int (*fl_vfs_callback)(struct file_lock *, struct file_lock *, int
result);
};

/* that will die - we need it for nfs_lock_info */
@@ -706,6 +707,10 @@ extern void locks_remove_flock(struct fi
extern struct file_lock *posix_test_lock(struct file *, struct file_lock
*);
extern int posix_lock_file(struct file *, struct file_lock *);
extern int posix_lock_file_wait(struct file *, struct file_lock *);
+extern int vfs_lock_file(struct file *, struct file_lock *);
+extern int vfs_test_lock(struct file *, struct file_lock *, struct
file_lock **);
+extern int vfs_test_and_lock_file(struct file *, struct file_lock *,
struct file_lock **);
+extern void locks_free_lock(struct file_lock *fl);
extern void posix_block_lock(struct file_lock *, struct file_lock *);
extern void posix_unblock_lock(struct file *, struct file_lock *);
extern int posix_locks_deadlock(struct file_lock *, struct file_lock *);
--- /nas/linux-2.6.10-uncompiled/include/linux/lockd/lockd.h
2004-12-24 13:34:01.000000000 -0800
+++ /nas/linux-2.6.10-locks/include/linux/lockd/lockd.h     2005-01-04
15:06:17.000000000 -0800
@@ -106,6 +106,8 @@ struct nlm_file {
* couldn't be granted because of a conflicting lock).
*/
#define NLM_NEVER       (~(unsigned long) 0)
+#define NLM_TIMEOUT          (~(unsigned long) 7 * HZ) /* timeout on
non-blocking call
+                                              to filesystem */
struct nlm_block {
struct nlm_block *      b_next;           /* linked list (all blocks) */
struct nlm_block *      b_fnext;    /* linked list (per file) */
@@ -119,6 +121,15 @@ struct nlm_block {
unsigned char           b_incall;   /* doing callback */
unsigned char           b_done;           /* callback complete */
struct nlm_file * b_file;           /* file in question */
+     struct cache_req *      b_cache_req;      /* deferred request
handling */
+     struct file_lock *      b_fl;       /* set for GETLK */
+     struct cache_deferred_req * b_deferred_req;
+     unsigned long           b_flags;        /* block flags */
+#define B_DEFERRED           1  /* None blocking lock */
+#define B_GOT_LOCK           2  /* Got non-blocking lock */
+#define B_TOO_LATE           4  /* Too late for non-blocking lock */
+#define B_WAIT               16 /* Blocking lock */
+#define B_TEST               32 /* Test lock */
};

/*
@@ -174,8 +185,8 @@ int         nlmsvc_async_call(struct nlm_rqst
 u32          nlmsvc_lock(struct svc_rqst *, struct nlm_file *,
      struct nlm_lock *, int, struct nlm_cookie *);
u32           nlmsvc_unlock(struct nlm_file *, struct nlm_lock *);
-u32          nlmsvc_testlock(struct nlm_file *, struct nlm_lock *,
-                             struct nlm_lock *);
+u32          nlmsvc_testlock(struct svc_rqst *, struct nlm_file *,
+                 struct nlm_lock *, struct nlm_lock *, struct nlm_cookie
*);
u32           nlmsvc_cancel_blocked(struct nlm_file *, struct nlm_lock *);
unsigned long       nlmsvc_retry_blocked(void);
int           nlmsvc_traverse_blocks(struct nlm_host *, struct nlm_file *,
--- /nas/linux-2.6.10-uncompiled/include/linux/lockd/nlm.h  2004-12-24
13:34:30.000000000 -0800
+++ /nas/linux-2.6.10-locks/include/linux/lockd/nlm.h 2005-01-04
14:14:02.000000000 -0800
@@ -29,6 +29,7 @@ enum {
NLM_FBIG                = 8,
NLM_FAILED              = 9,
#endif
+     NLM_LCK_DEFERRED        = 10,
};

#define NLM_PROGRAM           100021
--- /nas/linux-2.6.10-uncompiled/include/linux/lockd/xdr.h  2004-12-24
13:33:48.000000000 -0800
+++ /nas/linux-2.6.10-locks/include/linux/lockd/xdr.h 2005-01-04
14:14:02.000000000 -0800
@@ -21,6 +21,7 @@
#define     nlm_lck_denied_nolocks
__constant_htonl(NLM_LCK_DENIED_NOLOCKS)
#define     nlm_lck_blocked         __constant_htonl(NLM_LCK_BLOCKED)
#define     nlm_lck_denied_grace_period
__constant_htonl(NLM_LCK_DENIED_GRACE_PERIOD)
+#define    nlm_lck_deferred  __constant_htonl(NLM_LCK_DEFERRED)

/* Lock info passed via NLM */
struct nlm_lock {




-------------------------------------------------------
The SF.Net email is sponsored by: Beat the post-holiday blues
Get a FREE limited edition SourceForge.net t-shirt from ThinkGeek.
It's fun and FREE -- well, almost....http://www.thinkgeek.com/sfshirt
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

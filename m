Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:55762 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757891Ab0BDTMM convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 4 Feb 2010 14:12:12 -0500
Subject: [GIT PULL] Please pull NFS client bugfixes
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 04 Feb 2010 14:10:59 -0500
Message-ID: <1265310659.3317.28.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi Linus,

Please pull from the "bugfixes" branch of the repository at

   git pull git://git.linux-nfs.org/projects/trondmy/nfs-2.6.git bugfixes

This will update the following files through the appended changesets.

  Cheers,
    Trond

----
 fs/nfs/file.c      |    2 +
 fs/nfs/inode.c     |    4 ++-
 fs/nfs/nfs4_fs.h   |    2 +
 fs/nfs/nfs4proc.c  |   78 ++++++++++++++++++++++++++++++++++++++-------------
 fs/nfs/nfs4state.c |    2 +-
 fs/nfs/pagelist.c  |   17 ++++++-----
 fs/nfs/super.c     |   15 +++++++++-
 fs/nfs/sysctl.c    |    2 +
 fs/nfs/write.c     |    3 +-
 9 files changed, 93 insertions(+), 32 deletions(-)

commit 9b4b351346b41d923d69adec865814fdaac4dba9
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Wed Feb 3 08:27:35 2010 -0500

    NFS: Don't clobber the attribute type in nfs_update_inode()
    
    If the NFS_ATTR_FATTR_TYPE field isn't set in fattr->valid, then we should
    not set the S_IFMT part of inode->i_mode.
    
    Reported-by: Al Viro <viro@zeniv.linux.org.uk>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 387c149b54b4321cbc790dadbd4f8eedb5a90468
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Wed Feb 3 08:27:35 2010 -0500

    NFS: Fix a umount race
    
    Ensure that we unregister the bdi before kill_anon_super() calls
    ida_remove() on our device name.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
    Cc: stable@kernel.org

commit 9f557cd8073104b39528794d44e129331ded649f
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Wed Feb 3 08:27:22 2010 -0500

    NFS: Fix an Oops when truncating a file
    
    The VM/VFS does not allow mapping->a_ops->invalidatepage() to fail.
    Unfortunately, nfs_wb_page_cancel() may fail if a fatal signal occurs.
    Since the NFS code assumes that the page stays mapped for as long as the
    writeback is active, we can end up Oopsing (among other things).
    
    The only safe fix here is to convert nfs_wait_on_request(), so as to make
    it uninterruptible (as is already the case with wait_on_page_writeback()).
    
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
    Cc: stable@kernel.org

commit a2c0b9e291208f65221a0ad8a0c80a377707d480
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Tue Jan 26 15:42:47 2010 -0500

    NFS: Ensure that we handle NFS4ERR_STALE_STATEID correctly
    
    Even if the server is crazy, we should be able to mark the stateid as being
    bad, to ensure it gets recovered.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
    Reviewed-by: Chuck Lever <chuck.lever@oracle.com>

commit 03391693a95900875b0973569d2d73ff3aa8972e
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Tue Jan 26 15:42:38 2010 -0500

    NFSv4.1: Don't call nfs4_schedule_state_recovery() unnecessarily
    
    Currently, nfs4_handle_exception() will call it twice if called with an
    error of -NFS4ERR_STALE_CLIENTID, -NFS4ERR_STALE_STATEID or
    -NFS4ERR_EXPIRED.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
    Reviewed-by: Chuck Lever <chuck.lever@oracle.com>

commit 8e469ebd6dc32cbaf620e134d79f740bf0ebab79
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Tue Jan 26 15:42:30 2010 -0500

    NFSv4: Don't allow posix locking against servers that don't support it
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
    Cc: stable@kernel.org
    Reviewed-by: Chuck Lever <chuck.lever@oracle.com>

commit 2bee72a6aa1e6d0a4f5da56217f0d0bbbdd0d9a3
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Tue Jan 26 15:42:21 2010 -0500

    NFSv4: Ensure that the NFSv4 locking can recover from stateid errors
    
    In most cases, we just want to mark the lock_stateid sequence id as being
    uninitialised.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
    Cc: stable@kernel.org
    Reviewed-by: Chuck Lever <chuck.lever@oracle.com>

commit b0706ca415b188ed58788420de4d5c9972b2afb2
Author: David Howells <dhowells@redhat.com>
Date:   Tue Jan 26 15:42:11 2010 -0500

    NFS: Avoid warnings when CONFIG_NFS_V4=n
    
    Avoid the following warnings when CONFIG_NFS_V4=n:
    
    	fs/nfs/sysctl.c:19: warning: unused variable `nfs_set_port_max'
    	fs/nfs/sysctl.c:18: warning: unused variable `nfs_set_port_min'
    
    by making those variables contingent on NFSv4 being configured.
    
    Signed-off-by: David Howells <dhowells@redhat.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
    Reviewed-by: Chuck Lever <chuck.lever@oracle.com>

commit 0aa05887af728b058af91197f0ae9b3ae63dd74a
Author: H Hartley Sweeten <hartleys@visionengravers.com>
Date:   Tue Jan 26 15:42:03 2010 -0500

    NFS: Make nfs_commitdata_release static
    
    The symbol nfs_commitdata_release is only used locally
    in this file. Make it static to prevent the following sparse warning:
    
    warning: symbol 'nfs_commitdata_release' was not declared. Should it be static?
    
    Signed-off-by: H Hartley Sweeten <hsweeten@visionengravers.com>
    Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
    Reviewed-by: Chuck Lever <chuck.lever@oracle.com>

commit 82be934a59ff891cac598727e5a862ba2b9d1fac
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Tue Jan 26 15:41:53 2010 -0500

    NFS: Try to commit unstable writes in nfs_release_page()
    
    If someone calls nfs_release_page(), we presumably already know that the
    page is clean, however it may be holding an unstable write.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
    Cc: stable@kernel.org
    Reviewed-by: Chuck Lever <chuck.lever@oracle.com>

commit c9edda7140ec6a22accf7f2f86da362dfbfd41fc
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Tue Jan 26 15:41:34 2010 -0500

    NFS: Fix a reference leak in nfs_wb_cancel_page()
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
    Cc: stable@kernel.org
    Reviewed-by: Chuck Lever <chuck.lever@oracle.com>

diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index 6b89132..63f2071 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -486,6 +486,8 @@ static int nfs_release_page(struct page *page, gfp_t gfp)
 {
 	dfprintk(PAGECACHE, "NFS: release_page(%p)\n", page);
 
+	if (gfp & __GFP_WAIT)
+		nfs_wb_page(page->mapping->host, page);
 	/* If PagePrivate() is set, then the page is not freeable */
 	if (PagePrivate(page))
 		return 0;
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index faa0918..f141bde 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -1261,8 +1261,10 @@ static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr)
 
 	if (fattr->valid & NFS_ATTR_FATTR_MODE) {
 		if ((inode->i_mode & S_IALLUGO) != (fattr->mode & S_IALLUGO)) {
+			umode_t newmode = inode->i_mode & S_IFMT;
+			newmode |= fattr->mode & S_IALLUGO;
+			inode->i_mode = newmode;
 			invalid |= NFS_INO_INVALID_ATTR|NFS_INO_INVALID_ACCESS|NFS_INO_INVALID_ACL;
-			inode->i_mode = fattr->mode;
 		}
 	} else if (server->caps & NFS_CAP_MODE)
 		invalid |= save_cache_validity & (NFS_INO_INVALID_ATTR
diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 865265b..0c6fda3 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -146,6 +146,7 @@ enum {
 	NFS_O_RDWR_STATE,		/* OPEN stateid has read/write state */
 	NFS_STATE_RECLAIM_REBOOT,	/* OPEN stateid server rebooted */
 	NFS_STATE_RECLAIM_NOGRACE,	/* OPEN stateid needs to recover state */
+	NFS_STATE_POSIX_LOCKS,		/* Posix locks are supported */
 };
 
 struct nfs4_state {
@@ -277,6 +278,7 @@ extern void nfs4_state_set_mode_locked(struct nfs4_state *, fmode_t);
 extern void nfs4_schedule_state_recovery(struct nfs_client *);
 extern void nfs4_schedule_state_manager(struct nfs_client *);
 extern int nfs4_state_mark_reclaim_nograce(struct nfs_client *clp, struct nfs4_state *state);
+extern int nfs4_state_mark_reclaim_reboot(struct nfs_client *clp, struct nfs4_state *state);
 extern void nfs41_handle_sequence_flag_errors(struct nfs_client *clp, u32 flags);
 extern void nfs4_put_lock_state(struct nfs4_lock_state *lsp);
 extern int nfs4_set_lock_state(struct nfs4_state *state, struct file_lock *fl);
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 198d51d..375f0fa 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -249,19 +249,15 @@ static int nfs4_handle_exception(const struct nfs_server *server, int errorcode,
 			if (state == NULL)
 				break;
 			nfs4_state_mark_reclaim_nograce(clp, state);
-		case -NFS4ERR_STALE_CLIENTID:
+			goto do_state_recovery;
 		case -NFS4ERR_STALE_STATEID:
-		case -NFS4ERR_EXPIRED:
-			nfs4_schedule_state_recovery(clp);
-			ret = nfs4_wait_clnt_recover(clp);
-			if (ret == 0)
-				exception->retry = 1;
-#if !defined(CONFIG_NFS_V4_1)
-			break;
-#else /* !defined(CONFIG_NFS_V4_1) */
-			if (!nfs4_has_session(server->nfs_client))
+			if (state == NULL)
 				break;
-			/* FALLTHROUGH */
+			nfs4_state_mark_reclaim_reboot(clp, state);
+		case -NFS4ERR_STALE_CLIENTID:
+		case -NFS4ERR_EXPIRED:
+			goto do_state_recovery;
+#if defined(CONFIG_NFS_V4_1)
 		case -NFS4ERR_BADSESSION:
 		case -NFS4ERR_BADSLOT:
 		case -NFS4ERR_BAD_HIGH_SLOT:
@@ -274,7 +270,7 @@ static int nfs4_handle_exception(const struct nfs_server *server, int errorcode,
 			nfs4_schedule_state_recovery(clp);
 			exception->retry = 1;
 			break;
-#endif /* !defined(CONFIG_NFS_V4_1) */
+#endif /* defined(CONFIG_NFS_V4_1) */
 		case -NFS4ERR_FILE_OPEN:
 			if (exception->timeout > HZ) {
 				/* We have retried a decent amount, time to
@@ -293,6 +289,12 @@ static int nfs4_handle_exception(const struct nfs_server *server, int errorcode,
 	}
 	/* We failed to handle the error */
 	return nfs4_map_errors(ret);
+do_state_recovery:
+	nfs4_schedule_state_recovery(clp);
+	ret = nfs4_wait_clnt_recover(clp);
+	if (ret == 0)
+		exception->retry = 1;
+	return ret;
 }
 

@@ -1658,6 +1660,8 @@ static int _nfs4_do_open(struct inode *dir, struct path *path, fmode_t fmode, in
 	status = PTR_ERR(state);
 	if (IS_ERR(state))
 		goto err_opendata_put;
+	if ((opendata->o_res.rflags & NFS4_OPEN_RESULT_LOCKTYPE_POSIX) != 0)
+		set_bit(NFS_STATE_POSIX_LOCKS, &state->flags);
 	nfs4_opendata_put(opendata);
 	nfs4_put_state_owner(sp);
 	*res = state;
@@ -3422,15 +3426,14 @@ _nfs4_async_handle_error(struct rpc_task *task, const struct nfs_server *server,
 			if (state == NULL)
 				break;
 			nfs4_state_mark_reclaim_nograce(clp, state);
-		case -NFS4ERR_STALE_CLIENTID:
+			goto do_state_recovery;
 		case -NFS4ERR_STALE_STATEID:
+			if (state == NULL)
+				break;
+			nfs4_state_mark_reclaim_reboot(clp, state);
+		case -NFS4ERR_STALE_CLIENTID:
 		case -NFS4ERR_EXPIRED:
-			rpc_sleep_on(&clp->cl_rpcwaitq, task, NULL);
-			nfs4_schedule_state_recovery(clp);
-			if (test_bit(NFS4CLNT_MANAGER_RUNNING, &clp->cl_state) == 0)
-				rpc_wake_up_queued_task(&clp->cl_rpcwaitq, task);
-			task->tk_status = 0;
-			return -EAGAIN;
+			goto do_state_recovery;
 #if defined(CONFIG_NFS_V4_1)
 		case -NFS4ERR_BADSESSION:
 		case -NFS4ERR_BADSLOT:
@@ -3458,6 +3461,13 @@ _nfs4_async_handle_error(struct rpc_task *task, const struct nfs_server *server,
 	}
 	task->tk_status = nfs4_map_errors(task->tk_status);
 	return 0;
+do_state_recovery:
+	rpc_sleep_on(&clp->cl_rpcwaitq, task, NULL);
+	nfs4_schedule_state_recovery(clp);
+	if (test_bit(NFS4CLNT_MANAGER_RUNNING, &clp->cl_state) == 0)
+		rpc_wake_up_queued_task(&clp->cl_rpcwaitq, task);
+	task->tk_status = 0;
+	return -EAGAIN;
 }
 
 static int
@@ -4088,6 +4098,28 @@ static const struct rpc_call_ops nfs4_recover_lock_ops = {
 	.rpc_release = nfs4_lock_release,
 };
 
+static void nfs4_handle_setlk_error(struct nfs_server *server, struct nfs4_lock_state *lsp, int new_lock_owner, int error)
+{
+	struct nfs_client *clp = server->nfs_client;
+	struct nfs4_state *state = lsp->ls_state;
+
+	switch (error) {
+	case -NFS4ERR_ADMIN_REVOKED:
+	case -NFS4ERR_BAD_STATEID:
+	case -NFS4ERR_EXPIRED:
+		if (new_lock_owner != 0 ||
+		   (lsp->ls_flags & NFS_LOCK_INITIALIZED) != 0)
+			nfs4_state_mark_reclaim_nograce(clp, state);
+		lsp->ls_seqid.flags &= ~NFS_SEQID_CONFIRMED;
+		break;
+	case -NFS4ERR_STALE_STATEID:
+		if (new_lock_owner != 0 ||
+		    (lsp->ls_flags & NFS_LOCK_INITIALIZED) != 0)
+			nfs4_state_mark_reclaim_reboot(clp, state);
+		lsp->ls_seqid.flags &= ~NFS_SEQID_CONFIRMED;
+	};
+}
+
 static int _nfs4_do_setlk(struct nfs4_state *state, int cmd, struct file_lock *fl, int recovery_type)
 {
 	struct nfs4_lockdata *data;
@@ -4126,6 +4158,9 @@ static int _nfs4_do_setlk(struct nfs4_state *state, int cmd, struct file_lock *f
 	ret = nfs4_wait_for_completion_rpc_task(task);
 	if (ret == 0) {
 		ret = data->rpc_status;
+		if (ret)
+			nfs4_handle_setlk_error(data->server, data->lsp,
+					data->arg.new_lock_owner, ret);
 	} else
 		data->cancelled = 1;
 	rpc_put_task(task);
@@ -4181,8 +4216,11 @@ static int _nfs4_proc_setlk(struct nfs4_state *state, int cmd, struct file_lock
 {
 	struct nfs_inode *nfsi = NFS_I(state->inode);
 	unsigned char fl_flags = request->fl_flags;
-	int status;
+	int status = -ENOLCK;
 
+	if ((fl_flags & FL_POSIX) &&
+			!test_bit(NFS_STATE_POSIX_LOCKS, &state->flags))
+		goto out;
 	/* Is this a delegated open? */
 	status = nfs4_set_lock_state(state, request);
 	if (status != 0)
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 6d263ed..c1e2733 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -901,7 +901,7 @@ void nfs4_schedule_state_recovery(struct nfs_client *clp)
 	nfs4_schedule_state_manager(clp);
 }
 
-static int nfs4_state_mark_reclaim_reboot(struct nfs_client *clp, struct nfs4_state *state)
+int nfs4_state_mark_reclaim_reboot(struct nfs_client *clp, struct nfs4_state *state)
 {
 
 	set_bit(NFS_STATE_RECLAIM_REBOOT, &state->flags);
diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index e297593..a12c45b 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -176,6 +176,12 @@ void nfs_release_request(struct nfs_page *req)
 	kref_put(&req->wb_kref, nfs_free_request);
 }
 
+static int nfs_wait_bit_uninterruptible(void *word)
+{
+	io_schedule();
+	return 0;
+}
+
 /**
  * nfs_wait_on_request - Wait for a request to complete.
  * @req: request to wait upon.
@@ -186,14 +192,9 @@ void nfs_release_request(struct nfs_page *req)
 int
 nfs_wait_on_request(struct nfs_page *req)
 {
-	int ret = 0;
-
-	if (!test_bit(PG_BUSY, &req->wb_flags))
-		goto out;
-	ret = out_of_line_wait_on_bit(&req->wb_flags, PG_BUSY,
-			nfs_wait_bit_killable, TASK_KILLABLE);
-out:
-	return ret;
+	return wait_on_bit(&req->wb_flags, PG_BUSY,
+			nfs_wait_bit_uninterruptible,
+			TASK_UNINTERRUPTIBLE);
 }
 
 /**
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index ce907ef..f1afee4 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -243,6 +243,7 @@ static int  nfs_show_stats(struct seq_file *, struct vfsmount *);
 static int nfs_get_sb(struct file_system_type *, int, const char *, void *, struct vfsmount *);
 static int nfs_xdev_get_sb(struct file_system_type *fs_type,
 		int flags, const char *dev_name, void *raw_data, struct vfsmount *mnt);
+static void nfs_put_super(struct super_block *);
 static void nfs_kill_super(struct super_block *);
 static int nfs_remount(struct super_block *sb, int *flags, char *raw_data);
 
@@ -266,6 +267,7 @@ static const struct super_operations nfs_sops = {
 	.alloc_inode	= nfs_alloc_inode,
 	.destroy_inode	= nfs_destroy_inode,
 	.write_inode	= nfs_write_inode,
+	.put_super	= nfs_put_super,
 	.statfs		= nfs_statfs,
 	.clear_inode	= nfs_clear_inode,
 	.umount_begin	= nfs_umount_begin,
@@ -335,6 +337,7 @@ static const struct super_operations nfs4_sops = {
 	.alloc_inode	= nfs_alloc_inode,
 	.destroy_inode	= nfs_destroy_inode,
 	.write_inode	= nfs_write_inode,
+	.put_super	= nfs_put_super,
 	.statfs		= nfs_statfs,
 	.clear_inode	= nfs4_clear_inode,
 	.umount_begin	= nfs_umount_begin,
@@ -2258,6 +2261,17 @@ error_splat_super:
 }
 
 /*
+ * Ensure that we unregister the bdi before kill_anon_super
+ * releases the device name
+ */
+static void nfs_put_super(struct super_block *s)
+{
+	struct nfs_server *server = NFS_SB(s);
+
+	bdi_unregister(&server->backing_dev_info);
+}
+
+/*
  * Destroy an NFS2/3 superblock
  */
 static void nfs_kill_super(struct super_block *s)
@@ -2265,7 +2279,6 @@ static void nfs_kill_super(struct super_block *s)
 	struct nfs_server *server = NFS_SB(s);
 
 	kill_anon_super(s);
-	bdi_unregister(&server->backing_dev_info);
 	nfs_fscache_release_super_cookie(s);
 	nfs_free_server(server);
 }
diff --git a/fs/nfs/sysctl.c b/fs/nfs/sysctl.c
index 70e1fbb..ad4d2e7 100644
--- a/fs/nfs/sysctl.c
+++ b/fs/nfs/sysctl.c
@@ -15,8 +15,10 @@
 
 #include "callback.h"
 
+#ifdef CONFIG_NFS_V4
 static const int nfs_set_port_min = 0;
 static const int nfs_set_port_max = 65535;
+#endif
 static struct ctl_table_header *nfs_callback_sysctl_table;
 
 static ctl_table nfs_cb_sysctls[] = {
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index d171696..7b54b8b 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1233,7 +1233,7 @@ int nfs_writeback_done(struct rpc_task *task, struct nfs_write_data *data)
 

 #if defined(CONFIG_NFS_V3) || defined(CONFIG_NFS_V4)
-void nfs_commitdata_release(void *data)
+static void nfs_commitdata_release(void *data)
 {
 	struct nfs_write_data *wdata = data;
 
@@ -1541,6 +1541,7 @@ int nfs_wb_page_cancel(struct inode *inode, struct page *page)
 			break;
 		}
 		ret = nfs_wait_on_request(req);
+		nfs_release_request(req);
 		if (ret < 0)
 			goto out;
 	}


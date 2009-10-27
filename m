From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [GIT] Please pull NFS client bugfixes...
Date: Tue, 27 Oct 2009 17:35:00 -0400
Message-ID: <1256679301.3234.1.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932461AbZJ0VfP@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Linus,

Please pull from the "bugfixes" branch of the repository at

   git pull git://git.linux-nfs.org/projects/trondmy/nfs-2.6.git bugfixes

This will update the following files through the appended changesets.

  Cheers,
    Trond

----
 fs/nfs/dir.c      |    2 ++
 fs/nfs/direct.c   |    1 +
 fs/nfs/nfs4proc.c |   15 ++++++++-------
 fs/nfs/nfs4xdr.c  |    1 -
 4 files changed, 11 insertions(+), 8 deletions(-)

commit 9a3936aac133037f65124fcb2d676a6c201a90a4
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Mon Oct 26 08:09:46 2009 -0400

    NFSv4: The link() operation should return any delegation on the file
    
    Otherwise, we have to wait for the server to recall it.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 141aeb9f26f9f12f1584c128ce8697cdffb046e7
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Mon Oct 26 08:09:46 2009 -0400

    NFSv4: Fix two unbalanced put_rpccred() issues.
    
    Commits 29fba38b (nfs41: lease renewal) and fc01cea9 (nfs41: sequence
    operation) introduce a couple of put_rpccred() calls on credentials for
    which there is no corresponding get_rpccred().
    
    See http://bugzilla.kernel.org/show_bug.cgi?id=14249
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 52567b03ca38b6e556ced450d64dba8d66e23b0e
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Fri Oct 23 14:46:42 2009 -0400

    NFSv4: Fix a bug when the server returns NFS4ERR_RESOURCE
    
    RFC 3530 states that when we recieve the error NFS4ERR_RESOURCE, we are not
    supposed to bump the sequence number on OPEN, LOCK, LOCKU, CLOSE, etc
    operations. The problem is that we map that error into EREMOTEIO in the XDR
    layer, and so the NFSv4 middle-layer routines like seqid_mutating_err(),
    and nfs_increment_seqid() don't recognise it.
    
    The fix is to defer the mapping until after the middle layers have
    processed the error.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit a8b40bc7e635831b61c43acc71a86d3a68b2dff0
Author: Terry Loftin <terry.loftin@hp.com>
Date:   Thu Oct 22 21:36:01 2009 -0400

    nfs: Panic when commit fails
    
    Actually pass the NFS_FILE_SYNC option to the server to avoid a
    Panic in nfs_direct_write_complete() when a commit fails.
    
    At the end of an nfs write, if the nfs commit fails, all the writes
    will be rescheduled.  They are supposed to be rescheduled as NFS_FILE_SYNC
    writes, but the rpc_task structure is not completely intialized and so
    the option is not passed.  When the rescheduled writes complete, the
    return indicates that they are NFS_UNSTABLE and we try to do another
    commit.  This leads to a Panic because the commit data structure pointer
    was set to null in the initial (failed) commit attempt.
    
    Signed-off-by: Terry Loftin <terry.loftin@hp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 32062c3..7cb2985 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -1536,6 +1536,8 @@ nfs_link(struct dentry *old_dentry, struct inode *dir, struct dentry *dentry)
 		old_dentry->d_parent->d_name.name, old_dentry->d_name.name,
 		dentry->d_parent->d_name.name, dentry->d_name.name);
 
+	nfs_inode_return_delegation(inode);
+
 	d_drop(dentry);
 	error = NFS_PROTO(dir)->link(inode, dir, &dentry->d_name);
 	if (error == 0) {
diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index 6c32100..e1d415e 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -457,6 +457,7 @@ static void nfs_direct_write_reschedule(struct nfs_direct_req *dreq)
 	};
 	struct rpc_task_setup task_setup_data = {
 		.rpc_client = NFS_CLIENT(inode),
+		.rpc_message = &msg,
 		.callback_ops = &nfs_write_direct_ops,
 		.workqueue = nfsiod_workqueue,
 		.flags = RPC_TASK_ASYNC,
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index ed7c269..ff37454 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -72,12 +72,17 @@ static int _nfs4_proc_getattr(struct nfs_server *server, struct nfs_fh *fhandle,
 /* Prevent leaks of NFSv4 errors into userland */
 static int nfs4_map_errors(int err)
 {
-	if (err < -1000) {
+	if (err >= -1000)
+		return err;
+	switch (err) {
+	case -NFS4ERR_RESOURCE:
+		return -EREMOTEIO;
+	default:
 		dprintk("%s could not handle NFSv4 error %d\n",
 				__func__, -err);
-		return -EIO;
+		break;
 	}
-	return err;
+	return -EIO;
 }
 
 /*
@@ -3060,9 +3065,6 @@ static void nfs4_renew_done(struct rpc_task *task, void *data)
 	if (time_before(clp->cl_last_renewal,timestamp))
 		clp->cl_last_renewal = timestamp;
 	spin_unlock(&clp->cl_lock);
-	dprintk("%s calling put_rpccred on rpc_cred %p\n", __func__,
-				task->tk_msg.rpc_cred);
-	put_rpccred(task->tk_msg.rpc_cred);
 }
 
 static const struct rpc_call_ops nfs4_renew_ops = {
@@ -4877,7 +4879,6 @@ void nfs41_sequence_call_done(struct rpc_task *task, void *data)
 	nfs41_sequence_free_slot(clp, task->tk_msg.rpc_resp);
 	dprintk("%s rpc_cred %p\n", __func__, task->tk_msg.rpc_cred);
 
-	put_rpccred(task->tk_msg.rpc_cred);
 	kfree(task->tk_msg.rpc_argp);
 	kfree(task->tk_msg.rpc_resp);
 
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 83ad47c..20b4e30 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -5681,7 +5681,6 @@ static struct {
 	{ NFS4ERR_SERVERFAULT,	-ESERVERFAULT	},
 	{ NFS4ERR_BADTYPE,	-EBADTYPE	},
 	{ NFS4ERR_LOCKED,	-EAGAIN		},
-	{ NFS4ERR_RESOURCE,	-EREMOTEIO	},
 	{ NFS4ERR_SYMLINK,	-ELOOP		},
 	{ NFS4ERR_OP_ILLEGAL,	-EOPNOTSUPP	},
 	{ NFS4ERR_DEADLOCK,	-EDEADLK	},

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

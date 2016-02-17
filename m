Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:56272 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1423553AbcBQOsd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 17 Feb 2016 09:48:33 -0500
From: Christoph Hellwig <hch@lst.de>
To: trond.myklebust@primarydata.com, Anna.Schumaker@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] nfs4: fix stateid handling for the NFS v4.2 operations
Date: Wed, 17 Feb 2016 15:48:28 +0100
Message-Id: <1455720508-16713-1-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The newly added NFS v4.2 operations (ALLOCATE, DEALLOCATE, SEEK and CLONE)
use a helper called nfs42_set_rw_stateid to select a stateid that is sent
to the server.  But they don't set the inode and state fields in the
nfs4_exception structure, and this don't partake in the stateid recovery
protocol.  Because of this they will simply return errors insted of trying
to recover a stateid when the server return a BAD_STATEID error.

Additionally CLONE has the problem that it operates on two files and thus
two stateids, and thus needs to call the exception handler twice to
recover stateids.

While we're at it stop grabbing an addititional reference to the open
context in all these operations - having the file open guarantees that
the open context won't go away.

All this can be produces with the generic/168 and generic/170 tests in
xfstests which stress the CLONE stateid handling.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/nfs/nfs42proc.c | 119 ++++++++++++++++++++++++++++++++++-------------------
 1 file changed, 76 insertions(+), 43 deletions(-)

diff --git a/fs/nfs/nfs42proc.c b/fs/nfs/nfs42proc.c
index bd25dc7..7cb43b9 100644
--- a/fs/nfs/nfs42proc.c
+++ b/fs/nfs/nfs42proc.c
@@ -16,29 +16,8 @@
 
 #define NFSDBG_FACILITY NFSDBG_PROC
 
-static int nfs42_set_rw_stateid(nfs4_stateid *dst, struct file *file,
-				fmode_t fmode)
-{
-	struct nfs_open_context *open;
-	struct nfs_lock_context *lock;
-	int ret;
-
-	open = get_nfs_open_context(nfs_file_open_context(file));
-	lock = nfs_get_lock_context(open);
-	if (IS_ERR(lock)) {
-		put_nfs_open_context(open);
-		return PTR_ERR(lock);
-	}
-
-	ret = nfs4_set_rw_stateid(dst, open, lock, fmode);
-
-	nfs_put_lock_context(lock);
-	put_nfs_open_context(open);
-	return ret;
-}
-
 static int _nfs42_proc_fallocate(struct rpc_message *msg, struct file *filep,
-				 loff_t offset, loff_t len)
+		struct nfs_lock_context *lock, loff_t offset, loff_t len)
 {
 	struct inode *inode = file_inode(filep);
 	struct nfs_server *server = NFS_SERVER(inode);
@@ -56,7 +35,8 @@ static int _nfs42_proc_fallocate(struct rpc_message *msg, struct file *filep,
 	msg->rpc_argp = &args;
 	msg->rpc_resp = &res;
 
-	status = nfs42_set_rw_stateid(&args.falloc_stateid, filep, FMODE_WRITE);
+	status = nfs4_set_rw_stateid(&args.falloc_stateid, lock->open_context,
+			lock, FMODE_WRITE);
 	if (status)
 		return status;
 
@@ -78,15 +58,26 @@ static int nfs42_proc_fallocate(struct rpc_message *msg, struct file *filep,
 {
 	struct nfs_server *server = NFS_SERVER(file_inode(filep));
 	struct nfs4_exception exception = { };
+	struct nfs_lock_context *lock;
 	int err;
 
+	lock = nfs_get_lock_context(nfs_file_open_context(filep));
+	if (IS_ERR(lock))
+		return PTR_ERR(lock);
+
+	exception.inode = file_inode(filep);
+	exception.state = lock->open_context->state;
+
 	do {
-		err = _nfs42_proc_fallocate(msg, filep, offset, len);
-		if (err == -ENOTSUPP)
-			return -EOPNOTSUPP;
+		err = _nfs42_proc_fallocate(msg, filep, lock, offset, len);
+		if (err == -ENOTSUPP) {
+			err = -EOPNOTSUPP;
+			break;
+		}
 		err = nfs4_handle_exception(server, err, &exception);
 	} while (exception.retry);
 
+	nfs_put_lock_context(lock);
 	return err;
 }
 
@@ -135,7 +126,8 @@ int nfs42_proc_deallocate(struct file *filep, loff_t offset, loff_t len)
 	return err;
 }
 
-static loff_t _nfs42_proc_llseek(struct file *filep, loff_t offset, int whence)
+static loff_t _nfs42_proc_llseek(struct file *filep,
+		struct nfs_lock_context *lock, loff_t offset, int whence)
 {
 	struct inode *inode = file_inode(filep);
 	struct nfs42_seek_args args = {
@@ -156,7 +148,8 @@ static loff_t _nfs42_proc_llseek(struct file *filep, loff_t offset, int whence)
 	if (!nfs_server_capable(inode, NFS_CAP_SEEK))
 		return -ENOTSUPP;
 
-	status = nfs42_set_rw_stateid(&args.sa_stateid, filep, FMODE_READ);
+	status = nfs4_set_rw_stateid(&args.sa_stateid, lock->open_context,
+			lock, FMODE_READ);
 	if (status)
 		return status;
 
@@ -175,17 +168,28 @@ loff_t nfs42_proc_llseek(struct file *filep, loff_t offset, int whence)
 {
 	struct nfs_server *server = NFS_SERVER(file_inode(filep));
 	struct nfs4_exception exception = { };
+	struct nfs_lock_context *lock;
 	loff_t err;
 
+	lock = nfs_get_lock_context(nfs_file_open_context(filep));
+	if (IS_ERR(lock))
+		return PTR_ERR(lock);
+
+	exception.inode = file_inode(filep);
+	exception.state = lock->open_context->state;
+
 	do {
-		err = _nfs42_proc_llseek(filep, offset, whence);
+		err = _nfs42_proc_llseek(filep, lock, offset, whence);
 		if (err >= 0)
 			break;
-		if (err == -ENOTSUPP)
-			return -EOPNOTSUPP;
+		if (err == -ENOTSUPP) {
+			err = -EOPNOTSUPP;
+			break;
+		}
 		err = nfs4_handle_exception(server, err, &exception);
 	} while (exception.retry);
 
+	nfs_put_lock_context(lock);
 	return err;
 }
 
@@ -298,8 +302,9 @@ int nfs42_proc_layoutstats_generic(struct nfs_server *server,
 }
 
 static int _nfs42_proc_clone(struct rpc_message *msg, struct file *src_f,
-			     struct file *dst_f, loff_t src_offset,
-			     loff_t dst_offset, loff_t count)
+		struct file *dst_f, struct nfs_lock_context *src_lock,
+		struct nfs_lock_context *dst_lock, loff_t src_offset,
+		loff_t dst_offset, loff_t count)
 {
 	struct inode *src_inode = file_inode(src_f);
 	struct inode *dst_inode = file_inode(dst_f);
@@ -320,11 +325,13 @@ static int _nfs42_proc_clone(struct rpc_message *msg, struct file *src_f,
 	msg->rpc_argp = &args;
 	msg->rpc_resp = &res;
 
-	status = nfs42_set_rw_stateid(&args.src_stateid, src_f, FMODE_READ);
+	status = nfs4_set_rw_stateid(&args.src_stateid, src_lock->open_context,
+			src_lock, FMODE_READ);
 	if (status)
 		return status;
 
-	status = nfs42_set_rw_stateid(&args.dst_stateid, dst_f, FMODE_WRITE);
+	status = nfs4_set_rw_stateid(&args.dst_stateid, dst_lock->open_context,
+			dst_lock, FMODE_WRITE);
 	if (status)
 		return status;
 
@@ -349,22 +356,48 @@ int nfs42_proc_clone(struct file *src_f, struct file *dst_f,
 	};
 	struct inode *inode = file_inode(src_f);
 	struct nfs_server *server = NFS_SERVER(file_inode(src_f));
-	struct nfs4_exception exception = { };
-	int err;
+	struct nfs_lock_context *src_lock;
+	struct nfs_lock_context *dst_lock;
+	struct nfs4_exception src_exception = { };
+	struct nfs4_exception dst_exception = { };
+	int err, err2;
 
 	if (!nfs_server_capable(inode, NFS_CAP_CLONE))
 		return -EOPNOTSUPP;
 
+	src_lock = nfs_get_lock_context(nfs_file_open_context(src_f));
+	if (IS_ERR(src_lock))
+		return PTR_ERR(src_lock);
+
+	src_exception.inode = file_inode(src_f);
+	src_exception.state = src_lock->open_context->state;
+
+	dst_lock = nfs_get_lock_context(nfs_file_open_context(dst_f));
+	if (IS_ERR(dst_lock)) {
+		err = PTR_ERR(dst_lock);
+		goto out_put_src_lock;
+	}
+		
+	dst_exception.inode = file_inode(dst_f);
+	dst_exception.state = dst_lock->open_context->state;
+
 	do {
-		err = _nfs42_proc_clone(&msg, src_f, dst_f, src_offset,
-					dst_offset, count);
+		err = _nfs42_proc_clone(&msg, src_f, dst_f, src_lock, dst_lock,
+					src_offset, dst_offset, count);
 		if (err == -ENOTSUPP || err == -EOPNOTSUPP) {
 			NFS_SERVER(inode)->caps &= ~NFS_CAP_CLONE;
-			return -EOPNOTSUPP;
+			err = -EOPNOTSUPP;
+			break;
 		}
-		err = nfs4_handle_exception(server, err, &exception);
-	} while (exception.retry);
 
-	return err;
+		err2 = nfs4_handle_exception(server, err, &src_exception);
+		err = nfs4_handle_exception(server, err, &dst_exception);
+		if (!err)
+			err = err2;
+	} while (src_exception.retry || dst_exception.retry);
 
+	nfs_put_lock_context(dst_lock);
+out_put_src_lock:
+	nfs_put_lock_context(src_lock);
+	return err;
 }
-- 
2.1.4


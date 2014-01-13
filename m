Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f175.google.com ([209.85.213.175]:39006 "EHLO
	mail-ig0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751316AbaAMSp4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Jan 2014 13:45:56 -0500
Received: by mail-ig0-f175.google.com with SMTP id uq10so3536560igb.2
        for <linux-nfs@vger.kernel.org>; Mon, 13 Jan 2014 10:45:54 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: shaobingqing <shaobingqing@bwstor.com.cn>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: [PATCH 1/2] NFSv4.1: Don't trust attributes if a pNFS LAYOUTCOMMIT is outstanding
Date: Mon, 13 Jan 2014 13:45:50 -0500
Message-Id: <1389638751-16173-1-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <395EC1ED-E67E-4666-B170-5C5F00264496@primarydata.com>
References: <395EC1ED-E67E-4666-B170-5C5F00264496@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If a LAYOUTCOMMIT is outstanding, then chances are that the metadata
server may still be returning incorrect values for the change attribute,
ctime, mtime and/or size.
Just ignore those attributes for now, and wait for the LAYOUTCOMMIT
rpc call to finish.

Reported-by: shaobingqing <shaobingqing@bwstor.com.cn>
Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/inode.c    | 19 +++++++++++++++++--
 fs/nfs/nfs4proc.c |  5 ++---
 fs/nfs/pnfs.h     | 16 ++++++++++++++++
 3 files changed, 35 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 5feec233895d..c63e15224466 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -1283,12 +1283,28 @@ static int nfs_inode_attrs_need_update(const struct inode *inode, const struct n
 		((long)nfsi->attr_gencount - (long)nfs_read_attr_generation_counter() > 0);
 }
 
+/*
+ * Don't trust the change_attribute, mtime, ctime or size if
+ * a pnfs LAYOUTCOMMIT is outstanding
+ */
+static void nfs_inode_attrs_handle_layoutcommit(struct inode *inode,
+		struct nfs_fattr *fattr)
+{
+	if (pnfs_layoutcommit_outstanding(inode))
+		fattr->valid &= ~(NFS_ATTR_FATTR_CHANGE |
+				NFS_ATTR_FATTR_MTIME |
+				NFS_ATTR_FATTR_CTIME |
+				NFS_ATTR_FATTR_SIZE);
+}
+
 static int nfs_refresh_inode_locked(struct inode *inode, struct nfs_fattr *fattr)
 {
 	int ret;
 
 	trace_nfs_refresh_inode_enter(inode);
 
+	nfs_inode_attrs_handle_layoutcommit(inode, fattr);
+
 	if (nfs_inode_attrs_need_update(inode, fattr))
 		ret = nfs_update_inode(inode, fattr);
 	else
@@ -1518,8 +1534,7 @@ static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr)
 		if (new_isize != cur_isize) {
 			/* Do we perhaps have any outstanding writes, or has
 			 * the file grown beyond our last write? */
-			if ((nfsi->npages == 0 && !test_bit(NFS_INO_LAYOUTCOMMIT, &nfsi->flags)) ||
-			     new_isize > cur_isize) {
+			if ((nfsi->npages == 0) || new_isize > cur_isize) {
 				i_size_write(inode, new_isize);
 				invalid |= NFS_INO_INVALID_ATTR|NFS_INO_INVALID_DATA;
 			}
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 15052b81df42..f4908eb40a21 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -7780,10 +7780,7 @@ nfs4_layoutcommit_done(struct rpc_task *task, void *calldata)
 	case -NFS4ERR_BADLAYOUT:     /* no layout */
 	case -NFS4ERR_GRACE:	    /* loca_recalim always false */
 		task->tk_status = 0;
-		break;
 	case 0:
-		nfs_post_op_update_inode_force_wcc(data->args.inode,
-						   data->res.fattr);
 		break;
 	default:
 		if (nfs4_async_handle_error(task, server, NULL) == -EAGAIN) {
@@ -7798,6 +7795,8 @@ static void nfs4_layoutcommit_release(void *calldata)
 	struct nfs4_layoutcommit_data *data = calldata;
 
 	pnfs_cleanup_layoutcommit(data);
+	nfs_post_op_update_inode_force_wcc(data->args.inode,
+					   data->res.fattr);
 	put_rpccred(data->cred);
 	kfree(data);
 }
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index a4f41810a7f4..023793909778 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -359,6 +359,15 @@ pnfs_ld_layoutret_on_setattr(struct inode *inode)
 		PNFS_LAYOUTRET_ON_SETATTR;
 }
 
+static inline bool
+pnfs_layoutcommit_outstanding(struct inode *inode)
+{
+	struct nfs_inode *nfsi = NFS_I(inode);
+
+	return test_bit(NFS_INO_LAYOUTCOMMIT, &nfsi->flags) != 0 ||
+		test_bit(NFS_INO_LAYOUTCOMMITTING, &nfsi->flags) != 0;
+}
+
 static inline int pnfs_return_layout(struct inode *ino)
 {
 	struct nfs_inode *nfsi = NFS_I(ino);
@@ -515,6 +524,13 @@ pnfs_use_threshold(struct nfs4_threshold **dst, struct nfs4_threshold *src,
 	return false;
 }
 
+static inline bool
+pnfs_layoutcommit_outstanding(struct inode *inode)
+{
+	return false;
+}
+
+
 static inline struct nfs4_threshold *pnfs_mdsthreshold_alloc(void)
 {
 	return NULL;
-- 
1.8.4.2


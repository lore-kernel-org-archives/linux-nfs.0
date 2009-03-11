From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 11/30] NFSv4: Simplify some cache consistency post-op
 GETATTRs
Date: Wed, 11 Mar 2009 14:41:07 -0400
Message-ID: <20090311184107.5578.94265.stgit@heimdal.trondhjem.org>
References: <20090311184105.5578.22131.stgit@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:23111 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754670AbZCKSoQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 11 Mar 2009 14:44:16 -0400
Received: from sacrsexc1-prd.hq.netapp.com (sacrsexc1-prd.hq.netapp.com [10.99.115.27])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id n2BIi3rI021754
	for <linux-nfs@vger.kernel.org>; Wed, 11 Mar 2009 11:44:14 -0700 (PDT)
In-Reply-To: <20090311184105.5578.22131.stgit-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Certain asynchronous operations such as write() do not expect
(or care) that other metadata such as the file owner, mode, acls, ...
change. All they want to do is update and/or check the change attribute,
ctime, and mtime.
By skipping the file owner and group update, we also avoid having to do a
potential idmapper upcall for these asynchronous RPC calls.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/nfs4proc.c         |   13 ++++++++-----
 include/linux/nfs_fs_sb.h |    5 +++++
 2 files changed, 13 insertions(+), 5 deletions(-)


diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index aa433d0..101f5f4 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1439,7 +1439,7 @@ int nfs4_do_close(struct path *path, struct nfs4_state *state, int wait)
 	if (calldata->arg.seqid == NULL)
 		goto out_free_calldata;
 	calldata->arg.fmode = 0;
-	calldata->arg.bitmask = server->attr_bitmask;
+	calldata->arg.bitmask = server->cache_consistency_bitmask;
 	calldata->res.fattr = &calldata->fattr;
 	calldata->res.seqid = calldata->arg.seqid;
 	calldata->res.server = server;
@@ -1600,6 +1600,9 @@ static int _nfs4_server_capabilities(struct nfs_server *server, struct nfs_fh *f
 			server->caps |= NFS_CAP_HARDLINKS;
 		if (res.has_symlinks != 0)
 			server->caps |= NFS_CAP_SYMLINKS;
+		memcpy(server->cache_consistency_bitmask, res.attr_bitmask, sizeof(server->cache_consistency_bitmask));
+		server->cache_consistency_bitmask[0] &= FATTR4_WORD0_CHANGE|FATTR4_WORD0_SIZE;
+		server->cache_consistency_bitmask[1] &= FATTR4_WORD1_TIME_METADATA|FATTR4_WORD1_TIME_MODIFY;
 		server->acl_bitmask = res.acl_bitmask;
 	}
 	return status;
@@ -2079,7 +2082,7 @@ static void nfs4_proc_unlink_setup(struct rpc_message *msg, struct inode *dir)
 	struct nfs_removeargs *args = msg->rpc_argp;
 	struct nfs_removeres *res = msg->rpc_resp;
 
-	args->bitmask = server->attr_bitmask;
+	args->bitmask = server->cache_consistency_bitmask;
 	res->server = server;
 	msg->rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_REMOVE];
 }
@@ -2323,7 +2326,7 @@ static int _nfs4_proc_readdir(struct dentry *dentry, struct rpc_cred *cred,
 		.pages = &page,
 		.pgbase = 0,
 		.count = count,
-		.bitmask = NFS_SERVER(dentry->d_inode)->attr_bitmask,
+		.bitmask = NFS_SERVER(dentry->d_inode)->cache_consistency_bitmask,
 	};
 	struct nfs4_readdir_res res;
 	struct rpc_message msg = {
@@ -2552,7 +2555,7 @@ static void nfs4_proc_write_setup(struct nfs_write_data *data, struct rpc_messag
 {
 	struct nfs_server *server = NFS_SERVER(data->inode);
 
-	data->args.bitmask = server->attr_bitmask;
+	data->args.bitmask = server->cache_consistency_bitmask;
 	data->res.server = server;
 	data->timestamp   = jiffies;
 
@@ -2575,7 +2578,7 @@ static void nfs4_proc_commit_setup(struct nfs_write_data *data, struct rpc_messa
 {
 	struct nfs_server *server = NFS_SERVER(data->inode);
 	
-	data->args.bitmask = server->attr_bitmask;
+	data->args.bitmask = server->cache_consistency_bitmask;
 	data->res.server = server;
 	msg->rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_COMMIT];
 }
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index 9bb81ae..29b1e40 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -106,6 +106,11 @@ struct nfs_server {
 	u32			attr_bitmask[2];/* V4 bitmask representing the set
 						   of attributes supported on this
 						   filesystem */
+	u32			cache_consistency_bitmask[2];
+						/* V4 bitmask representing the subset
+						   of change attribute, size, ctime
+						   and mtime attributes supported by
+						   the server */
 	u32			acl_bitmask;	/* V4 bitmask representing the ACEs
 						   that are supported on this
 						   filesystem */


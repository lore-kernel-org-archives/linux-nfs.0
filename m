Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:34471 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751924AbbHYPfW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 25 Aug 2015 11:35:22 -0400
Received: by pabzx8 with SMTP id zx8so36950909pab.1
        for <linux-nfs@vger.kernel.org>; Tue, 25 Aug 2015 08:35:22 -0700 (PDT)
From: Peng Tao <tao.peng@primarydata.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Christoph Hellwig <hch@infradead.org>, Zach Brown <zab@zabbo.net>,
        Darren Hart <dvhart@linux.intel.com>, bfields@fieldses.org,
        Jeff Layton <jeff.layton@primarydata.com>,
        Peng Tao <tao.peng@primarydata.com>
Subject: [PATCH RFC 06/11] nfs42: add CLONE proc functions
Date: Tue, 25 Aug 2015 23:33:44 +0800
Message-Id: <1440516829-116041-7-git-send-email-tao.peng@primarydata.com>
In-Reply-To: <1440516829-116041-1-git-send-email-tao.peng@primarydata.com>
References: <1440516829-116041-1-git-send-email-tao.peng@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Peng Tao <tao.peng@primarydata.com>
---
 fs/nfs/nfs42.h            |  1 +
 fs/nfs/nfs42proc.c        | 71 +++++++++++++++++++++++++++++++++++++++++++++++
 fs/nfs/nfs4proc.c         |  3 +-
 include/linux/nfs_fs_sb.h |  1 +
 4 files changed, 75 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/nfs42.h b/fs/nfs/nfs42.h
index 814c125..b587ccd 100644
--- a/fs/nfs/nfs42.h
+++ b/fs/nfs/nfs42.h
@@ -17,5 +17,6 @@ int nfs42_proc_deallocate(struct file *, loff_t, loff_t);
 loff_t nfs42_proc_llseek(struct file *, loff_t, int);
 int nfs42_proc_layoutstats_generic(struct nfs_server *,
 				   struct nfs42_layoutstat_data *);
+int nfs42_proc_clone(struct file *, struct file *, loff_t, loff_t, loff_t);
 
 #endif /* __LINUX_FS_NFS_NFS4_2_H */
diff --git a/fs/nfs/nfs42proc.c b/fs/nfs/nfs42proc.c
index d731bbf..baa3141 100644
--- a/fs/nfs/nfs42proc.c
+++ b/fs/nfs/nfs42proc.c
@@ -269,3 +269,74 @@ int nfs42_proc_layoutstats_generic(struct nfs_server *server,
 		return PTR_ERR(task);
 	return 0;
 }
+
+static int _nfs42_proc_clone(struct rpc_message *msg, struct file *src_f,
+			     struct file *dst_f, loff_t src_offset,
+			     loff_t dst_offset, loff_t count)
+{
+	struct inode *src_inode = file_inode(src_f);
+	struct inode *dst_inode = file_inode(dst_f);
+	struct nfs_server *server = NFS_SERVER(dst_inode);
+	struct nfs42_clone_args args = {
+		.src_fh = NFS_FH(src_inode),
+		.dst_fh = NFS_FH(dst_inode),
+		.src_offset = src_offset,
+		.dst_offset = dst_offset,
+		.dst_bitmask = server->cache_consistency_bitmask,
+	};
+	struct nfs42_clone_res res = {
+		.server	= server,
+	};
+	int status;
+
+	msg->rpc_argp = &args;
+	msg->rpc_resp = &res;
+
+	status = nfs42_set_rw_stateid(&args.src_stateid, src_f, FMODE_READ);
+	if (status)
+		return status;
+
+	status = nfs42_set_rw_stateid(&args.dst_stateid, dst_f, FMODE_WRITE);
+	if (status)
+		return status;
+
+	res.dst_fattr = nfs_alloc_fattr();
+	if (!res.dst_fattr)
+		return -ENOMEM;
+
+	status = nfs4_call_sync(server->client, server, msg,
+				&args.seq_args, &res.seq_res, 0);
+	if (status == 0)
+		status = nfs_post_op_update_inode(dst_inode, res.dst_fattr);
+
+	kfree(res.dst_fattr);
+	return status;
+}
+
+int nfs42_proc_clone(struct file *src_f, struct file *dst_f,
+		     loff_t src_offset, loff_t dst_offset, loff_t count)
+{
+	struct rpc_message msg = {
+		.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_CLONE],
+	};
+	struct inode *inode = file_inode(src_f);
+	struct nfs_server *server = NFS_SERVER(file_inode(src_f));
+	struct nfs4_exception exception = { };
+	int err;
+
+	if (!nfs_server_capable(inode, NFS_CAP_CLONE))
+		return -EOPNOTSUPP;
+
+	do {
+		err = _nfs42_proc_clone(&msg, src_f, dst_f, src_offset,
+					dst_offset, count);
+		if (err == -ENOTSUPP || err == -EOPNOTSUPP) {
+			NFS_SERVER(inode)->caps &= ~NFS_CAP_CLONE;
+			return -EOPNOTSUPP;
+		}
+		err = nfs4_handle_exception(server, err, &exception);
+	} while (exception.retry);
+
+	return err;
+
+}
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 6e988fd..fb51b75 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -8659,7 +8659,8 @@ static const struct nfs4_minor_version_ops nfs_v4_2_minor_ops = {
 		| NFS_CAP_ALLOCATE
 		| NFS_CAP_DEALLOCATE
 		| NFS_CAP_SEEK
-		| NFS_CAP_LAYOUTSTATS,
+		| NFS_CAP_LAYOUTSTATS
+		| NFS_CAP_CLONE,
 	.init_client = nfs41_init_client,
 	.shutdown_client = nfs41_shutdown_client,
 	.match_stateid = nfs41_match_stateid,
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index 20bc8e5..2fb163a 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -238,5 +238,6 @@ struct nfs_server {
 #define NFS_CAP_ALLOCATE	(1U << 20)
 #define NFS_CAP_DEALLOCATE	(1U << 21)
 #define NFS_CAP_LAYOUTSTATS	(1U << 22)
+#define NFS_CAP_CLONE		(1U << 23)
 
 #endif
-- 
1.8.3.1


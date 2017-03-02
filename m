Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx141.netapp.com ([216.240.21.12]:30745 "EHLO mx141.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752270AbdCBQN2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 2 Mar 2017 11:13:28 -0500
From: Olga Kornievskaia <kolga@netapp.com>
To: <Trond.Myklebust@primarydata.com>
CC: <linux-nfs@vger.kernel.org>
Subject: [RFC v1 09/19] NFS OFFLOAD_STATUS op
Date: Thu, 2 Mar 2017 11:01:13 -0500
Message-ID: <20170302160123.30375-10-kolga@netapp.com>
In-Reply-To: <20170302160123.30375-1-kolga@netapp.com>
References: <20170302160123.30375-1-kolga@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
---
 fs/nfs/nfs42.h     |  2 ++
 fs/nfs/nfs42proc.c | 42 ++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 44 insertions(+)

diff --git a/fs/nfs/nfs42.h b/fs/nfs/nfs42.h
index 820fd63..47ffbb0 100644
--- a/fs/nfs/nfs42.h
+++ b/fs/nfs/nfs42.h
@@ -23,6 +23,8 @@ int nfs42_proc_layoutstats_generic(struct nfs_server *,
 int nfs42_proc_clone(struct file *, struct file *, loff_t, loff_t, loff_t);
 int nfs42_proc_copy_notify(struct file *, struct file *,
 			   struct nfs42_copy_notify_res *);
+int nfs42_proc_offload_status(struct file *, nfs4_stateid *,
+			      struct nfs42_offload_status_res *);
 #endif /* CONFIG_NFS_V4_2 */
 
 #endif /* __LINUX_FS_NFS_NFS4_2_H */
diff --git a/fs/nfs/nfs42proc.c b/fs/nfs/nfs42proc.c
index ade2938..d6de5ff 100644
--- a/fs/nfs/nfs42proc.c
+++ b/fs/nfs/nfs42proc.c
@@ -363,6 +363,48 @@ int nfs42_proc_copy_notify(struct file *src, struct file *dst,
 	return status;
 }
 
+int _nfs42_proc_offload_status(struct file *dst, nfs4_stateid *stateid,
+				struct nfs42_offload_status_res *res)
+{
+	struct nfs42_offload_status_args args;
+	struct nfs_server *dst_server = NFS_SERVER(file_inode(dst));
+	struct rpc_message msg = {
+		.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_OFFLOAD_STATUS],
+		.rpc_resp = res,
+	};
+	int status;
+
+	args.osa_src_fh = NFS_FH(file_inode(dst));
+	memcpy(&args.osa_stateid, stateid, sizeof(args.osa_stateid));
+	msg.rpc_argp = &args;
+	status = nfs4_call_sync(dst_server->client, dst_server, &msg,
+				&args.osa_seq_args, &res->osr_seq_res, 0);
+	if (status == -ENOTSUPP)
+		dst_server->caps &= ~NFS_CAP_OFFLOAD_STATUS;
+
+	return status;
+}
+
+int nfs42_proc_offload_status(struct file *dst, nfs4_stateid *stateid,
+				struct nfs42_offload_status_res *res)
+{
+	struct nfs_server *dst_server = NFS_SERVER(file_inode(dst));
+	struct nfs4_exception exception = { };
+	int status;
+
+	if (!(dst_server->caps & NFS_CAP_OFFLOAD_STATUS))
+		return -EOPNOTSUPP;
+
+	do {
+		status = _nfs42_proc_offload_status(dst, stateid, res);
+		if (status == -ENOTSUPP)
+			return -EOPNOTSUPP;
+		status = nfs4_handle_exception(dst_server, status, &exception);
+	} while (exception.retry);
+
+	return status;
+}
+
 static loff_t _nfs42_proc_llseek(struct file *filep,
 		struct nfs_lock_context *lock, loff_t offset, int whence)
 {
-- 
1.8.3.1


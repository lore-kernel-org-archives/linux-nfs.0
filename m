Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:48989 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754132Ab0HMVc3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 13 Aug 2010 17:32:29 -0400
From: andros@netapp.com
To: bhalevy@panasas.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH 29/50] pnfs_submit: add data server session to nfs4_setup_sequence
Date: Fri, 13 Aug 2010 17:31:41 -0400
Message-Id: <1281735122-1496-30-git-send-email-andros@netapp.com>
In-Reply-To: <1281735122-1496-29-git-send-email-andros@netapp.com>
References: <1281735122-1496-1-git-send-email-andros@netapp.com>
 <1281735122-1496-2-git-send-email-andros@netapp.com>
 <1281735122-1496-3-git-send-email-andros@netapp.com>
 <1281735122-1496-4-git-send-email-andros@netapp.com>
 <1281735122-1496-5-git-send-email-andros@netapp.com>
 <1281735122-1496-6-git-send-email-andros@netapp.com>
 <1281735122-1496-7-git-send-email-andros@netapp.com>
 <1281735122-1496-8-git-send-email-andros@netapp.com>
 <1281735122-1496-9-git-send-email-andros@netapp.com>
 <1281735122-1496-10-git-send-email-andros@netapp.com>
 <1281735122-1496-11-git-send-email-andros@netapp.com>
 <1281735122-1496-12-git-send-email-andros@netapp.com>
 <1281735122-1496-13-git-send-email-andros@netapp.com>
 <1281735122-1496-14-git-send-email-andros@netapp.com>
 <1281735122-1496-15-git-send-email-andros@netapp.com>
 <1281735122-1496-16-git-send-email-andros@netapp.com>
 <1281735122-1496-17-git-send-email-andros@netapp.com>
 <1281735122-1496-18-git-send-email-andros@netapp.com>
 <1281735122-1496-19-git-send-email-andros@netapp.com>
 <1281735122-1496-20-git-send-email-andros@netapp.com>
 <1281735122-1496-21-git-send-email-andros@netapp.com>
 <1281735122-1496-22-git-send-email-andros@netapp.com>
 <1281735122-1496-23-git-send-email-andros@netapp.com>
 <1281735122-1496-24-git-send-email-andros@netapp.com>
 <1281735122-1496-25-git-send-email-andros@netapp.com>
 <1281735122-1496-26-git-send-email-andros@netapp.com>
 <1281735122-1496-27-git-send-email-andros@netapp.com>
 <1281735122-1496-28-git-send-email-andros@netapp.com>
 <1281735122-1496-29-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: The pNFS Team <linux-nfs@vger.kernel.org>

Note: original patch of same name...

Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off_by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4_fs.h  |    3 +++
 fs/nfs/nfs4proc.c |   21 ++++++++++++---------
 fs/nfs/read.c     |    2 +-
 fs/nfs/unlink.c   |    2 +-
 fs/nfs/write.c    |    2 +-
 5 files changed, 18 insertions(+), 12 deletions(-)

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 311e15c..ef70bef 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -256,10 +256,12 @@ static inline struct nfs4_session *nfs4_get_session(const struct nfs_server *ser
 }
 
 extern int nfs4_setup_sequence(const struct nfs_server *server,
+		struct nfs4_session *ds_session,
 		struct nfs4_sequence_args *args, struct nfs4_sequence_res *res,
 		int cache_reply, struct rpc_task *task);
 extern void nfs4_destroy_session(struct nfs4_session *session);
 extern struct nfs4_session *nfs4_alloc_session(struct nfs_client *clp);
+extern int nfs4_proc_exchange_id(struct nfs_client *, struct rpc_cred *);
 extern int nfs4_proc_create_session(struct nfs_client *);
 extern int nfs4_proc_destroy_session(struct nfs4_session *);
 extern int nfs4_init_session(struct nfs_server *server);
@@ -272,6 +274,7 @@ static inline struct nfs4_session *nfs4_get_session(const struct nfs_server *ser
 }
 
 static inline int nfs4_setup_sequence(const struct nfs_server *server,
+		struct nfs4_session *ds_session,
 		struct nfs4_sequence_args *args, struct nfs4_sequence_res *res,
 		int cache_reply, struct rpc_task *task)
 {
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 2f00a67..e8b1620 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -570,6 +570,7 @@ static int nfs41_setup_sequence(struct nfs4_session *session,
 }
 
 int nfs4_setup_sequence(const struct nfs_server *server,
+		struct nfs4_session *ds_session,
 			struct nfs4_sequence_args *args,
 			struct nfs4_sequence_res *res,
 			int cache_reply,
@@ -578,6 +579,8 @@ int nfs4_setup_sequence(const struct nfs_server *server,
 	struct nfs4_session *session = nfs4_get_session(server);
 	int ret = 0;
 
+	if (ds_session)
+		session = ds_session;
 	if (session == NULL) {
 		args->sa_session = NULL;
 		res->sr_session = NULL;
@@ -607,7 +610,7 @@ static void nfs41_call_sync_prepare(struct rpc_task *task, void *calldata)
 
 	dprintk("--> %s data->seq_server %p\n", __func__, data->seq_server);
 
-	if (nfs4_setup_sequence(data->seq_server, data->seq_args,
+	if (nfs4_setup_sequence(data->seq_server, NULL, data->seq_args,
 				data->seq_res, data->cache_reply, task))
 		return;
 	rpc_call_start(task);
@@ -1396,7 +1399,7 @@ static void nfs4_open_prepare(struct rpc_task *task, void *calldata)
 		nfs_copy_fh(&data->o_res.fh, data->o_arg.fh);
 	}
 	data->timestamp = jiffies;
-	if (nfs4_setup_sequence(data->o_arg.server,
+	if (nfs4_setup_sequence(data->o_arg.server, NULL,
 				&data->o_arg.seq_args,
 				&data->o_res.seq_res, 1, task))
 		return;
@@ -1938,7 +1941,7 @@ static void nfs4_close_prepare(struct rpc_task *task, void *data)
 
 	nfs_fattr_init(calldata->res.fattr);
 	calldata->timestamp = jiffies;
-	if (nfs4_setup_sequence(NFS_SERVER(calldata->inode),
+	if (nfs4_setup_sequence(NFS_SERVER(calldata->inode), NULL,
 				&calldata->arg.seq_args, &calldata->res.seq_res,
 				1, task))
 		return;
@@ -3705,7 +3708,7 @@ static void nfs4_delegreturn_prepare(struct rpc_task *task, void *data)
 
 	d_data = (struct nfs4_delegreturndata *)data;
 
-	if (nfs4_setup_sequence(d_data->res.server,
+	if (nfs4_setup_sequence(d_data->res.server, NULL,
 				&d_data->args.seq_args,
 				&d_data->res.seq_res, 1, task))
 		return;
@@ -3961,7 +3964,7 @@ static void nfs4_locku_prepare(struct rpc_task *task, void *data)
 		return;
 	}
 	calldata->timestamp = jiffies;
-	if (nfs4_setup_sequence(calldata->server,
+	if (nfs4_setup_sequence(calldata->server, NULL,
 				&calldata->arg.seq_args,
 				&calldata->res.seq_res, 1, task))
 		return;
@@ -4116,7 +4119,7 @@ static void nfs4_lock_prepare(struct rpc_task *task, void *calldata)
 	} else
 		data->arg.new_lock_owner = 0;
 	data->timestamp = jiffies;
-	if (nfs4_setup_sequence(data->server,
+	if (nfs4_setup_sequence(data->server, NULL,
 				&data->arg.seq_args,
 				&data->res.seq_res, 1, task))
 		return;
@@ -5374,7 +5377,7 @@ nfs4_pnfs_layoutget_prepare(struct rpc_task *task, void *calldata)
 	struct nfs_server *server = NFS_SERVER(ino);
 
 	dprintk("--> %s\n", __func__);
-	if (nfs4_setup_sequence(server, &lgp->args.seq_args,
+	if (nfs4_setup_sequence(server, NULL, &lgp->args.seq_args,
 				&lgp->res.seq_res, 0, task))
 		return;
 	rpc_call_start(task);
@@ -5486,7 +5489,7 @@ static void pnfs_layoutcommit_prepare(struct rpc_task *task, void *data)
 		(struct pnfs_layoutcommit_data *)data;
 	struct nfs_server *server = NFS_SERVER(ldata->args.inode);
 
-	if (nfs4_setup_sequence(server, &ldata->args.seq_args,
+	if (nfs4_setup_sequence(server, NULL, &ldata->args.seq_args,
 				&ldata->res.seq_res, 1, task))
 		return;
 	rpc_call_start(task);
@@ -5595,7 +5598,7 @@ nfs4_pnfs_layoutreturn_prepare(struct rpc_task *task, void *calldata)
 	struct nfs_server *server = NFS_SERVER(ino);
 
 	dprintk("--> %s\n", __func__);
-	if (nfs4_setup_sequence(server, &lrp->args.seq_args,
+	if (nfs4_setup_sequence(server, NULL, &lrp->args.seq_args,
 				&lrp->res.seq_res, 0, task))
 		return;
 	rpc_call_start(task);
diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index 87adc27..8f3a894 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -411,7 +411,7 @@ void nfs_read_prepare(struct rpc_task *task, void *calldata)
 {
 	struct nfs_read_data *data = calldata;
 
-	if (nfs4_setup_sequence(NFS_SERVER(data->inode),
+	if (nfs4_setup_sequence(NFS_SERVER(data->inode), NULL,
 				&data->args.seq_args, &data->res.seq_res,
 				0, task))
 		return;
diff --git a/fs/nfs/unlink.c b/fs/nfs/unlink.c
index 2f84ada..51ae53b 100644
--- a/fs/nfs/unlink.c
+++ b/fs/nfs/unlink.c
@@ -110,7 +110,7 @@ void nfs_unlink_prepare(struct rpc_task *task, void *calldata)
 	struct nfs_unlinkdata *data = calldata;
 	struct nfs_server *server = NFS_SERVER(data->dir);
 
-	if (nfs4_setup_sequence(server, &data->args.seq_args,
+	if (nfs4_setup_sequence(server, NULL, &data->args.seq_args,
 				&data->res.seq_res, 1, task))
 		return;
 	rpc_call_start(task);
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 4d37229..5937247 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1052,7 +1052,7 @@ void nfs_write_prepare(struct rpc_task *task, void *calldata)
 {
 	struct nfs_write_data *data = calldata;
 
-	if (nfs4_setup_sequence(NFS_SERVER(data->inode),
+	if (nfs4_setup_sequence(NFS_SERVER(data->inode), NULL,
 				&data->args.seq_args,
 				&data->res.seq_res, 1, task))
 		return;
-- 
1.6.2.5


Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:13672 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752267Ab1BDVeO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 4 Feb 2011 16:34:14 -0500
From: andros@netapp.com
To: bhalevy@panasas.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@citi.umich.edu>,
        Dean Hildebrand <dhildeb@us.ibm.com>,
        Marc Eshel <eshel@almaden.ibm.com>, Mike Sager <sager@netapp.com>,
        Oleg Drokin <green@linuxhacker.ru>,
        Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>,
        Andy Adamson <andros@netapp.com>, Fred Isaman <iisaman@netapp.com>
Subject: [PATCH 02/40] pnfs_submit: add data server session to nfs4_setup_sequence
Date: Fri,  4 Feb 2011 16:33:24 -0500
Message-Id: <1296855242-2592-3-git-send-email-andros@netapp.com>
In-Reply-To: <1296855242-2592-2-git-send-email-andros@netapp.com>
References: <1296855242-2592-1-git-send-email-andros@netapp.com>
 <1296855242-2592-2-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: The pNFS Team <linux-nfs@vger.kernel.org>

Note: original patch of same name...

Signed-off-by: Andy Adamson <andros@citi.umich.edu>
Signed-off-by: Dean Hildebrand <dhildeb@us.ibm.com>
Signed-off-by: Marc Eshel <eshel@almaden.ibm.com>
Signed-off-by: Mike Sager <sager@netapp.com>
Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
Signed-off-by: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off_by: Benny Halevy <bhalevy@panasas.com>
Signed-off-by: Fred Isaman <iisaman@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4_fs.h  |    3 +++
 fs/nfs/nfs4proc.c |   17 ++++++++++-------
 fs/nfs/read.c     |    2 +-
 fs/nfs/unlink.c   |    4 ++--
 fs/nfs/write.c    |    2 +-
 5 files changed, 17 insertions(+), 11 deletions(-)

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 7a74740..28fda51 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -250,10 +250,12 @@ static inline struct nfs4_session *nfs4_get_session(const struct nfs_server *ser
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
@@ -266,6 +268,7 @@ static inline struct nfs4_session *nfs4_get_session(const struct nfs_server *ser
 }
 
 static inline int nfs4_setup_sequence(const struct nfs_server *server,
+		struct nfs4_session *ds_session,
 		struct nfs4_sequence_args *args, struct nfs4_sequence_res *res,
 		int cache_reply, struct rpc_task *task)
 {
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 78936a8..9d0d636 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -573,6 +573,7 @@ static int nfs41_setup_sequence(struct nfs4_session *session,
 }
 
 int nfs4_setup_sequence(const struct nfs_server *server,
+		struct nfs4_session *ds_session,
 			struct nfs4_sequence_args *args,
 			struct nfs4_sequence_res *res,
 			int cache_reply,
@@ -581,6 +582,8 @@ int nfs4_setup_sequence(const struct nfs_server *server,
 	struct nfs4_session *session = nfs4_get_session(server);
 	int ret = 0;
 
+	if (ds_session)
+		session = ds_session;
 	if (session == NULL) {
 		args->sa_session = NULL;
 		res->sr_session = NULL;
@@ -611,7 +614,7 @@ static void nfs41_call_sync_prepare(struct rpc_task *task, void *calldata)
 
 	dprintk("--> %s data->seq_server %p\n", __func__, data->seq_server);
 
-	if (nfs4_setup_sequence(data->seq_server, data->seq_args,
+	if (nfs4_setup_sequence(data->seq_server, NULL, data->seq_args,
 				data->seq_res, data->cache_reply, task))
 		return;
 	rpc_call_start(task);
@@ -1399,7 +1402,7 @@ static void nfs4_open_prepare(struct rpc_task *task, void *calldata)
 		nfs_copy_fh(&data->o_res.fh, data->o_arg.fh);
 	}
 	data->timestamp = jiffies;
-	if (nfs4_setup_sequence(data->o_arg.server,
+	if (nfs4_setup_sequence(data->o_arg.server, NULL,
 				&data->o_arg.seq_args,
 				&data->o_res.seq_res, 1, task))
 		return;
@@ -1950,7 +1953,7 @@ static void nfs4_close_prepare(struct rpc_task *task, void *data)
 
 	nfs_fattr_init(calldata->res.fattr);
 	calldata->timestamp = jiffies;
-	if (nfs4_setup_sequence(NFS_SERVER(calldata->inode),
+	if (nfs4_setup_sequence(NFS_SERVER(calldata->inode), NULL,
 				&calldata->arg.seq_args, &calldata->res.seq_res,
 				1, task))
 		return;
@@ -3652,7 +3655,7 @@ static void nfs4_delegreturn_prepare(struct rpc_task *task, void *data)
 
 	d_data = (struct nfs4_delegreturndata *)data;
 
-	if (nfs4_setup_sequence(d_data->res.server,
+	if (nfs4_setup_sequence(d_data->res.server, NULL,
 				&d_data->args.seq_args,
 				&d_data->res.seq_res, 1, task))
 		return;
@@ -3904,7 +3907,7 @@ static void nfs4_locku_prepare(struct rpc_task *task, void *data)
 		return;
 	}
 	calldata->timestamp = jiffies;
-	if (nfs4_setup_sequence(calldata->server,
+	if (nfs4_setup_sequence(calldata->server, NULL,
 				&calldata->arg.seq_args,
 				&calldata->res.seq_res, 1, task))
 		return;
@@ -4059,7 +4062,7 @@ static void nfs4_lock_prepare(struct rpc_task *task, void *calldata)
 	} else
 		data->arg.new_lock_owner = 0;
 	data->timestamp = jiffies;
-	if (nfs4_setup_sequence(data->server,
+	if (nfs4_setup_sequence(data->server, NULL,
 				&data->arg.seq_args,
 				&data->res.seq_res, 1, task))
 		return;
@@ -5328,7 +5331,7 @@ nfs4_layoutget_prepare(struct rpc_task *task, void *calldata)
 	 * However, that is not so catastrophic, and there seems
 	 * to be no way to prevent it completely.
 	 */
-	if (nfs4_setup_sequence(server, &lgp->args.seq_args,
+	if (nfs4_setup_sequence(server, NULL, &lgp->args.seq_args,
 				&lgp->res.seq_res, 0, task))
 		return;
 	if (pnfs_choose_layoutget_stateid(&lgp->args.stateid,
diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index aedcaa7..6c224e8 100644
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
index e313a51..82dc70b 100644
--- a/fs/nfs/unlink.c
+++ b/fs/nfs/unlink.c
@@ -113,7 +113,7 @@ void nfs_unlink_prepare(struct rpc_task *task, void *calldata)
 	struct nfs_unlinkdata *data = calldata;
 	struct nfs_server *server = NFS_SERVER(data->dir);
 
-	if (nfs4_setup_sequence(server, &data->args.seq_args,
+	if (nfs4_setup_sequence(server, NULL, &data->args.seq_args,
 				&data->res.seq_res, 1, task))
 		return;
 	rpc_call_start(task);
@@ -388,7 +388,7 @@ static void nfs_rename_prepare(struct rpc_task *task, void *calldata)
 	struct nfs_renamedata *data = calldata;
 	struct nfs_server *server = NFS_SERVER(data->old_dir);
 
-	if (nfs4_setup_sequence(server, &data->args.seq_args,
+	if (nfs4_setup_sequence(server, NULL, &data->args.seq_args,
 				&data->res.seq_res, 1, task))
 		return;
 	rpc_call_start(task);
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index c8278f4..7a2905d 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1048,7 +1048,7 @@ void nfs_write_prepare(struct rpc_task *task, void *calldata)
 {
 	struct nfs_write_data *data = calldata;
 
-	if (nfs4_setup_sequence(NFS_SERVER(data->inode),
+	if (nfs4_setup_sequence(NFS_SERVER(data->inode), NULL,
 				&data->args.seq_args,
 				&data->res.seq_res, 1, task))
 		return;
-- 
1.6.6


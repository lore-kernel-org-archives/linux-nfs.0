From: andros@netapp.com
Subject: [PATCH 1/2] pnfs: fix-multiple-free-slot-calls
Date: Thu, 22 Oct 2009 09:15:42 -0400
Message-ID: <1256217343-6991-2-git-send-email-andros@netapp.com>
References: <1256217343-6991-1-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: pnfs@linux-nfs.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:32075 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755906AbZJVNPz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 22 Oct 2009 09:15:55 -0400
In-Reply-To: <1256217343-6991-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Use _nfs4_async_handle_error and pass in either the MDS or DS client

Reported-by: Trond Myklebust <trond.myklebust@netapp.com>

nfs41_sequence_free_slot is called multiple times on SEQUENCE operation errors.

Fix this by moving the call to nfs41_sequence_free_slot from the error path of
nfs41_sequence_done to nfs4_async_handle_error for the SEQUENCE operation
error cases.

Signed-off-by: Andy Adamson <andros@netapp.com>
.
---
 fs/nfs/nfs4proc.c |   12 +++++++++---
 1 files changed, 9 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index c6abb45..72314c2 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -70,6 +70,9 @@ static int _nfs4_proc_open(struct nfs4_opendata *data);
 static int nfs4_do_fsinfo(struct nfs_server *, struct nfs_fh *, struct nfs_fsinfo *);
 static int nfs4_async_handle_error(struct rpc_task *, const struct nfs_server *,
 			 struct nfs4_state *, struct nfs4_sequence_res *);
+static int _nfs4_async_handle_error(struct rpc_task *,
+			const struct nfs_server *, struct nfs_client *,
+			struct nfs4_state *, struct nfs4_sequence_res *);
 static int _nfs4_proc_lookup(struct inode *dir, const struct qstr *name, struct nfs_fh *fhandle, struct nfs_fattr *fattr);
 static int _nfs4_proc_getattr(struct nfs_server *server, struct nfs_fh *fhandle, struct nfs_fattr *fattr);
 
@@ -3045,7 +3048,8 @@ static int pnfs4_read_done(struct rpc_task *task, struct nfs_read_data *data)
 
 	/* FIXME: pass data->args.context->state to nfs4_async_handle_error
 	   like in nfs4_read_done? */
-	if (nfs4_async_handle_error(task, mds_svr, NULL) == -EAGAIN) {
+	if (_nfs4_async_handle_error(task, NULL, client, NULL,
+					&data->res.seq_res) == -EAGAIN) {
 		nfs4_restart_rpc(task, client);
 		dprintk("<-- %s status= %d\n", __func__, -EAGAIN);
 		return -EAGAIN;
@@ -3085,7 +3089,8 @@ static int pnfs4_write_done(struct rpc_task *task, struct nfs_write_data *data)
 	*/
 	/* FIXME: pass data->args.context->state to nfs4_async_handle_error
 	   like in nfs4_write_done? */
-	if (nfs4_async_handle_error(task, mds_svr, NULL) == -EAGAIN) {
+	if (_nfs4_async_handle_error(task, NULL, client, NULL,
+					&data->res.seq_res) == -EAGAIN) {
 		nfs4_restart_rpc(task, client);
 		dprintk("<-- %s status= %d\n", __func__, -EAGAIN);
 		return -EAGAIN;
@@ -3133,7 +3138,8 @@ static int pnfs4_commit_done(struct rpc_task *task, struct nfs_write_data *data)
 
 	nfs41_sequence_done(client, &data->res.seq_res, task->tk_status);
 
-	if (nfs4_async_handle_error(task, mds_svr, NULL) == -EAGAIN) {
+	if (_nfs4_async_handle_error(task, NULL, client, NULL,
+					&data->res.seq_res) == -EAGAIN) {
 		nfs4_restart_rpc(task, client);
 		return -EAGAIN;
 	}
-- 
1.6.2.5


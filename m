Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f178.google.com ([209.85.223.178]:65352 "EHLO
	mail-ie0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932177AbaBAU4u (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 1 Feb 2014 15:56:50 -0500
Received: by mail-ie0-f178.google.com with SMTP id x13so5182460ief.23
        for <linux-nfs@vger.kernel.org>; Sat, 01 Feb 2014 12:56:50 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Cc: Chuck Lever <chuck.lever@oracle.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: [PATCH 1/2] NFSv4: Fix memory corruption in nfs4_proc_open_confirm
Date: Sat,  1 Feb 2014 15:56:47 -0500
Message-Id: <1391288208-23750-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

nfs41_wake_and_assign_slot() relies on the task->tk_msg.rpc_argp and
task->tk_msg.rpc_resp always pointing to the session sequence arguments.

nfs4_proc_open_confirm tries to pull a fast one by reusing the open
sequence structure, thus causing corruption of the NFSv4 slot table.

Cc: stable@vger.kernel.org # 3.12+
Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4proc.c       | 8 ++++----
 include/linux/nfs_xdr.h | 2 ++
 2 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 42da6af77587..2da6a698b8f7 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1620,15 +1620,15 @@ static void nfs4_open_confirm_prepare(struct rpc_task *task, void *calldata)
 {
 	struct nfs4_opendata *data = calldata;
 
-	nfs40_setup_sequence(data->o_arg.server, &data->o_arg.seq_args,
-				&data->o_res.seq_res, task);
+	nfs40_setup_sequence(data->o_arg.server, &data->c_arg.seq_args,
+				&data->c_res.seq_res, task);
 }
 
 static void nfs4_open_confirm_done(struct rpc_task *task, void *calldata)
 {
 	struct nfs4_opendata *data = calldata;
 
-	nfs40_sequence_done(task, &data->o_res.seq_res);
+	nfs40_sequence_done(task, &data->c_res.seq_res);
 
 	data->rpc_status = task->tk_status;
 	if (data->rpc_status == 0) {
@@ -1686,7 +1686,7 @@ static int _nfs4_proc_open_confirm(struct nfs4_opendata *data)
 	};
 	int status;
 
-	nfs4_init_sequence(&data->o_arg.seq_args, &data->o_res.seq_res, 1);
+	nfs4_init_sequence(&data->c_arg.seq_args, &data->c_res.seq_res, 1);
 	kref_get(&data->kref);
 	data->rpc_done = 0;
 	data->rpc_status = 0;
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 3ccfcecf8999..b2fb167b2e6d 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -379,12 +379,14 @@ struct nfs_openres {
  * Arguments to the open_confirm call.
  */
 struct nfs_open_confirmargs {
+	struct nfs4_sequence_args	seq_args;
 	const struct nfs_fh *	fh;
 	nfs4_stateid *		stateid;
 	struct nfs_seqid *	seqid;
 };
 
 struct nfs_open_confirmres {
+	struct nfs4_sequence_res	seq_res;
 	nfs4_stateid            stateid;
 	struct nfs_seqid *	seqid;
 };
-- 
1.8.5.3


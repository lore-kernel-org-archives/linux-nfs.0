Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:36205 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753641AbeE3SGU (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 30 May 2018 14:06:20 -0400
Received: by mail-io0-f193.google.com with SMTP id d73-v6so22696710iog.3
        for <linux-nfs@vger.kernel.org>; Wed, 30 May 2018 11:06:19 -0700 (PDT)
Received: from leira.trondhjem.org.localdomain (c-68-49-162-121.hsd1.mi.comcast.net. [68.49.162.121])
        by smtp.gmail.com with ESMTPSA id i201-v6sm8589368ite.33.2018.05.30.11.06.18
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 30 May 2018 11:06:18 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 03/19] NFS4: move ctx into nfs4_run_open_task
Date: Wed, 30 May 2018 14:05:37 -0400
Message-Id: <20180530180553.38769-4-trond.myklebust@hammerspace.com>
In-Reply-To: <20180530180553.38769-3-trond.myklebust@hammerspace.com>
References: <20180530180553.38769-1-trond.myklebust@hammerspace.com>
 <20180530180553.38769-2-trond.myklebust@hammerspace.com>
 <20180530180553.38769-3-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Fred Isaman <fred.isaman@gmail.com>

Preparing to add conditional LAYOUTGET to OPEN rpc, the LAYOUTGET
will need the ctx info.

Signed-off-by: Fred Isaman <fred.isaman@gmail.com>
Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/nfs4proc.c | 19 +++++++++++--------
 1 file changed, 11 insertions(+), 8 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 6287fb6dee50..830569a8d00a 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -86,7 +86,6 @@
 	| ATTR_MTIME_SET)
 
 struct nfs4_opendata;
-static int _nfs4_proc_open(struct nfs4_opendata *data);
 static int _nfs4_recover_proc_open(struct nfs4_opendata *data);
 static int nfs4_do_fsinfo(struct nfs_server *, struct nfs_fh *, struct nfs_fsinfo *);
 static void nfs_fixup_referral_attributes(struct nfs_fattr *fattr);
@@ -2328,7 +2327,8 @@ static const struct rpc_call_ops nfs4_open_ops = {
 	.rpc_release = nfs4_open_release,
 };
 
-static int nfs4_run_open_task(struct nfs4_opendata *data, int isrecover)
+static int nfs4_run_open_task(struct nfs4_opendata *data,
+			      struct nfs_open_context *ctx)
 {
 	struct inode *dir = d_inode(data->dir);
 	struct nfs_server *server = NFS_SERVER(dir);
@@ -2351,14 +2351,16 @@ static int nfs4_run_open_task(struct nfs4_opendata *data, int isrecover)
 	};
 	int status;
 
-	nfs4_init_sequence(&o_arg->seq_args, &o_res->seq_res, 1, isrecover);
 	kref_get(&data->kref);
 	data->rpc_done = false;
 	data->rpc_status = 0;
 	data->cancelled = false;
 	data->is_recover = false;
-	if (isrecover)
+	if (!ctx) {
+		nfs4_init_sequence(&o_arg->seq_args, &o_res->seq_res, 1, 1);
 		data->is_recover = true;
+	} else
+		nfs4_init_sequence(&o_arg->seq_args, &o_res->seq_res, 1, 0);
 	task = rpc_run_task(&task_setup_data);
 	if (IS_ERR(task))
 		return PTR_ERR(task);
@@ -2379,7 +2381,7 @@ static int _nfs4_recover_proc_open(struct nfs4_opendata *data)
 	struct nfs_openres *o_res = &data->o_res;
 	int status;
 
-	status = nfs4_run_open_task(data, 1);
+	status = nfs4_run_open_task(data, NULL);
 	if (status != 0 || !data->rpc_done)
 		return status;
 
@@ -2440,7 +2442,8 @@ static int nfs4_opendata_access(struct rpc_cred *cred,
 /*
  * Note: On error, nfs4_proc_open will free the struct nfs4_opendata
  */
-static int _nfs4_proc_open(struct nfs4_opendata *data)
+static int _nfs4_proc_open(struct nfs4_opendata *data,
+			   struct nfs_open_context *ctx)
 {
 	struct inode *dir = d_inode(data->dir);
 	struct nfs_server *server = NFS_SERVER(dir);
@@ -2448,7 +2451,7 @@ static int _nfs4_proc_open(struct nfs4_opendata *data)
 	struct nfs_openres *o_res = &data->o_res;
 	int status;
 
-	status = nfs4_run_open_task(data, 0);
+	status = nfs4_run_open_task(data, ctx);
 	if (!data->rpc_done)
 		return status;
 	if (status != 0) {
@@ -2799,7 +2802,7 @@ static int _nfs4_open_and_get_state(struct nfs4_opendata *opendata,
 
 	seq = raw_seqcount_begin(&sp->so_reclaim_seqcount);
 
-	ret = _nfs4_proc_open(opendata);
+	ret = _nfs4_proc_open(opendata, ctx);
 	if (ret != 0)
 		goto out;
 
-- 
2.17.0


Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gh0-f172.google.com ([209.85.160.172]:56497 "EHLO
	mail-gh0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S968171Ab3HIQtt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 9 Aug 2013 12:49:49 -0400
Received: by mail-gh0-f172.google.com with SMTP id r18so1299890ghr.3
        for <linux-nfs@vger.kernel.org>; Fri, 09 Aug 2013 09:49:49 -0700 (PDT)
Received: from seurat.1015granger.net ([2604:8800:100:81fc:20c:29ff:fe44:ec31])
        by mx.google.com with ESMTPSA id l67sm20675747yhc.26.2013.08.09.09.49.48
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Fri, 09 Aug 2013 09:49:48 -0700 (PDT)
Subject: [PATCH v2 14/33] NFS: Add nfs4_sequence calls for OPEN_CONFIRM
To: linux-nfs@vger.kernel.org
From: Chuck Lever <chuck.lever@oracle.com>
Date: Fri, 09 Aug 2013 12:49:47 -0400
Message-ID: <20130809164947.5362.51597.stgit@seurat.1015granger.net>
In-Reply-To: <20130809161957.5362.90865.stgit@seurat.1015granger.net>
References: <20130809161957.5362.90865.stgit@seurat.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Ensure OPEN_CONFIRM is not emitted while the transport is plugged.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/nfs/nfs4proc.c |   12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 9104467..5640dc0 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1591,10 +1591,20 @@ int nfs4_open_delegation_recall(struct nfs_open_context *ctx, struct nfs4_state
 	return nfs4_handle_delegation_recall_error(server, state, stateid, err);
 }
 
+static void nfs4_open_confirm_prepare(struct rpc_task *task, void *calldata)
+{
+	struct nfs4_opendata *data = calldata;
+
+	nfs40_setup_sequence(data->o_arg.server, &data->o_arg.seq_args,
+				&data->o_res.seq_res, task);
+}
+
 static void nfs4_open_confirm_done(struct rpc_task *task, void *calldata)
 {
 	struct nfs4_opendata *data = calldata;
 
+	nfs40_sequence_done(task, &data->o_res.seq_res);
+
 	data->rpc_status = task->tk_status;
 	if (data->rpc_status == 0) {
 		nfs4_stateid_copy(&data->o_res.stateid, &data->c_res.stateid);
@@ -1623,6 +1633,7 @@ out_free:
 }
 
 static const struct rpc_call_ops nfs4_open_confirm_ops = {
+	.rpc_call_prepare = nfs4_open_confirm_prepare,
 	.rpc_call_done = nfs4_open_confirm_done,
 	.rpc_release = nfs4_open_confirm_release,
 };
@@ -1650,6 +1661,7 @@ static int _nfs4_proc_open_confirm(struct nfs4_opendata *data)
 	};
 	int status;
 
+	nfs4_init_sequence(&data->o_arg.seq_args, &data->o_res.seq_res, 1);
 	kref_get(&data->kref);
 	data->rpc_done = 0;
 	data->rpc_status = 0;


Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gh0-f174.google.com ([209.85.160.174]:36840 "EHLO
	mail-gh0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S968171Ab3HIQtk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 9 Aug 2013 12:49:40 -0400
Received: by mail-gh0-f174.google.com with SMTP id r17so1278197ghr.33
        for <linux-nfs@vger.kernel.org>; Fri, 09 Aug 2013 09:49:40 -0700 (PDT)
Received: from seurat.1015granger.net ([2604:8800:100:81fc:20c:29ff:fe44:ec31])
        by mx.google.com with ESMTPSA id g39sm20680040yhb.13.2013.08.09.09.49.39
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Fri, 09 Aug 2013 09:49:39 -0700 (PDT)
Subject: [PATCH v2 13/33] NFS: Add nfs4_sequence calls for RELEASE_LOCKOWNER
To: linux-nfs@vger.kernel.org
From: Chuck Lever <chuck.lever@oracle.com>
Date: Fri, 09 Aug 2013 12:49:38 -0400
Message-ID: <20130809164938.5362.95295.stgit@seurat.1015granger.net>
In-Reply-To: <20130809161957.5362.90865.stgit@seurat.1015granger.net>
References: <20130809161957.5362.90865.stgit@seurat.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Ensure RELEASE_LOCKOWNER is not emitted while the transport is
plugged.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/nfs/nfs4proc.c |   20 ++++++++++++++++++++
 1 file changed, 20 insertions(+)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index b915c7d..9104467 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5662,8 +5662,23 @@ struct nfs_release_lockowner_data {
 	struct nfs4_lock_state *lsp;
 	struct nfs_server *server;
 	struct nfs_release_lockowner_args args;
+	struct nfs4_sequence_args seq_args;
+	struct nfs4_sequence_res seq_res;
 };
 
+static void nfs4_release_lockowner_prepare(struct rpc_task *task, void *calldata)
+{
+	struct nfs_release_lockowner_data *data = calldata;
+	nfs40_setup_sequence(data->server,
+				&data->seq_args, &data->seq_res, task);
+}
+
+static void nfs4_release_lockowner_done(struct rpc_task *task, void *calldata)
+{
+	struct nfs_release_lockowner_data *data = calldata;
+	nfs40_sequence_done(task, &data->seq_res);
+}
+
 static void nfs4_release_lockowner_release(void *calldata)
 {
 	struct nfs_release_lockowner_data *data = calldata;
@@ -5672,6 +5687,8 @@ static void nfs4_release_lockowner_release(void *calldata)
 }
 
 static const struct rpc_call_ops nfs4_release_lockowner_ops = {
+	.rpc_call_prepare = nfs4_release_lockowner_prepare,
+	.rpc_call_done = nfs4_release_lockowner_done,
 	.rpc_release = nfs4_release_lockowner_release,
 };
 
@@ -5684,14 +5701,17 @@ static int nfs4_release_lockowner(struct nfs_server *server, struct nfs4_lock_st
 
 	if (server->nfs_client->cl_mvops->minor_version != 0)
 		return -EINVAL;
+
 	data = kmalloc(sizeof(*data), GFP_NOFS);
 	if (!data)
 		return -ENOMEM;
+	nfs4_init_sequence(&data->seq_args, &data->seq_res, 0);
 	data->lsp = lsp;
 	data->server = server;
 	data->args.lock_owner.clientid = server->nfs_client->cl_clientid;
 	data->args.lock_owner.id = lsp->ls_seqid.owner_id;
 	data->args.lock_owner.s_dev = server->s_dev;
+
 	msg.rpc_argp = &data->args;
 	rpc_call_async(server->client, &msg, 0, &nfs4_release_lockowner_ops, data);
 	return 0;


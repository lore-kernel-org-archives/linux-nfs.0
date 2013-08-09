Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gh0-f178.google.com ([209.85.160.178]:57145 "EHLO
	mail-gh0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S968172Ab3HIQsD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 9 Aug 2013 12:48:03 -0400
Received: by mail-gh0-f178.google.com with SMTP id g15so1284453ghb.9
        for <linux-nfs@vger.kernel.org>; Fri, 09 Aug 2013 09:48:02 -0700 (PDT)
Received: from seurat.1015granger.net ([2604:8800:100:81fc:20c:29ff:fe44:ec31])
        by mx.google.com with ESMTPSA id i70sm12877897yhd.4.2013.08.09.09.48.01
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Fri, 09 Aug 2013 09:48:01 -0700 (PDT)
Subject: [PATCH v2 02/33] NFS: Rename nfs41_call_sync_data as a common data
 structure
To: linux-nfs@vger.kernel.org
From: Chuck Lever <chuck.lever@oracle.com>
Date: Fri, 09 Aug 2013 12:48:00 -0400
Message-ID: <20130809164800.5362.62683.stgit@seurat.1015granger.net>
In-Reply-To: <20130809161957.5362.90865.stgit@seurat.1015granger.net>
References: <20130809161957.5362.90865.stgit@seurat.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: rename nfs41_call_sync_data for use as a data structure
common to all NFSv4 minor versions.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/nfs/nfs4proc.c |   18 +++++++++---------
 1 file changed, 9 insertions(+), 9 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index f7a8f53..63e2279 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -447,6 +447,12 @@ static void renew_lease(const struct nfs_server *server, unsigned long timestamp
 	do_renew_lease(server->nfs_client, timestamp);
 }
 
+struct nfs4_call_sync_data {
+	const struct nfs_server *seq_server;
+	struct nfs4_sequence_args *seq_args;
+	struct nfs4_sequence_res *seq_res;
+};
+
 #if defined(CONFIG_NFS_V4_1)
 
 static void nfs41_sequence_free_slot(struct nfs4_sequence_res *res)
@@ -696,15 +702,9 @@ out:
 	return ret;
 }
 
-struct nfs41_call_sync_data {
-	const struct nfs_server *seq_server;
-	struct nfs4_sequence_args *seq_args;
-	struct nfs4_sequence_res *seq_res;
-};
-
 static void nfs41_call_sync_prepare(struct rpc_task *task, void *calldata)
 {
-	struct nfs41_call_sync_data *data = calldata;
+	struct nfs4_call_sync_data *data = calldata;
 	struct nfs4_session *session = nfs4_get_session(data->seq_server);
 
 	dprintk("--> %s data->seq_server %p\n", __func__, data->seq_server);
@@ -714,7 +714,7 @@ static void nfs41_call_sync_prepare(struct rpc_task *task, void *calldata)
 
 static void nfs41_call_sync_done(struct rpc_task *task, void *calldata)
 {
-	struct nfs41_call_sync_data *data = calldata;
+	struct nfs4_call_sync_data *data = calldata;
 
 	nfs41_sequence_done(task, data->seq_res);
 }
@@ -732,7 +732,7 @@ static int nfs4_call_sync_sequence(struct rpc_clnt *clnt,
 {
 	int ret;
 	struct rpc_task *task;
-	struct nfs41_call_sync_data data = {
+	struct nfs4_call_sync_data data = {
 		.seq_server = server,
 		.seq_args = args,
 		.seq_res = res,


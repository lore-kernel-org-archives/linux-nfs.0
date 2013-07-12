Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ye0-f180.google.com ([209.85.213.180]:41291 "EHLO
	mail-ye0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964992Ab3GLQcN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 12 Jul 2013 12:32:13 -0400
Received: by mail-ye0-f180.google.com with SMTP id r11so3212001yen.11
        for <linux-nfs@vger.kernel.org>; Fri, 12 Jul 2013 09:32:12 -0700 (PDT)
Received: from seurat.1015granger.net ([2604:8800:100:81fc:20c:29ff:fe93:815b])
        by mx.google.com with ESMTPSA id i4sm31727849yhg.16.2013.07.12.09.32.11
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 12 Jul 2013 09:32:11 -0700 (PDT)
Subject: [PATCH v1 05/19] NFS: Rename nfs41_call_sync_data as a common data
 structure
To: linux-nfs@vger.kernel.org
From: Chuck Lever <chuck.lever@oracle.com>
Date: Fri, 12 Jul 2013 12:32:10 -0400
Message-ID: <20130712163210.1444.28032.stgit@seurat.1015granger.net>
In-Reply-To: <20130712155303.1444.62697.stgit@seurat.1015granger.net>
References: <20130712155303.1444.62697.stgit@seurat.1015granger.net>
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
index e52d2b3..d7b2c85 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -391,6 +391,12 @@ static void renew_lease(const struct nfs_server *server, unsigned long timestamp
 	do_renew_lease(server->nfs_client, timestamp);
 }
 
+struct nfs4_call_sync_data {
+	const struct nfs_server *seq_server;
+	struct nfs4_sequence_args *seq_args;
+	struct nfs4_sequence_res *seq_res;
+};
+
 #if defined(CONFIG_NFS_V4_1)
 
 static int nfs4_run_rpc_task(struct rpc_clnt *clnt,
@@ -657,15 +663,9 @@ out:
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
@@ -675,7 +675,7 @@ static void nfs41_call_sync_prepare(struct rpc_task *task, void *calldata)
 
 static void nfs41_call_sync_done(struct rpc_task *task, void *calldata)
 {
-	struct nfs41_call_sync_data *data = calldata;
+	struct nfs4_call_sync_data *data = calldata;
 
 	nfs41_sequence_done(task, data->seq_res);
 }
@@ -691,7 +691,7 @@ static int nfs4_call_sync_sequence(struct rpc_clnt *clnt,
 				   struct nfs4_sequence_args *args,
 				   struct nfs4_sequence_res *res)
 {
-	struct nfs41_call_sync_data data = {
+	struct nfs4_call_sync_data data = {
 		.seq_server = server,
 		.seq_args = args,
 		.seq_res = res,


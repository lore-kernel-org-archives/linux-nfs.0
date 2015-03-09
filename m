Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qc0-f175.google.com ([209.85.216.175]:36624 "EHLO
	mail-qc0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751490AbbCIUFK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 9 Mar 2015 16:05:10 -0400
Received: by qcxm20 with SMTP id m20so5233923qcx.3
        for <linux-nfs@vger.kernel.org>; Mon, 09 Mar 2015 13:05:09 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 3/4] NFSv4.1: Allow getdeviceinfo to return notification info back to caller
Date: Mon,  9 Mar 2015 16:05:02 -0400
Message-Id: <1425931503-37261-4-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1425931503-37261-3-git-send-email-trond.myklebust@primarydata.com>
References: <1425931503-37261-1-git-send-email-trond.myklebust@primarydata.com>
 <1425931503-37261-2-git-send-email-trond.myklebust@primarydata.com>
 <1425931503-37261-3-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We are only allowed to cache deviceinfo if the server supports notifications
and actually promises to call us back when changes occur. Right now, we
request those notifications, but then we don't check the server's reply.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4proc.c       |  5 +++++
 fs/nfs/nfs4xdr.c        | 14 +++++---------
 include/linux/nfs_xdr.h |  2 ++
 3 files changed, 12 insertions(+), 9 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 627f37c44456..ba8b2b5e98a1 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -7944,6 +7944,8 @@ _nfs4_proc_getdeviceinfo(struct nfs_server *server,
 {
 	struct nfs4_getdeviceinfo_args args = {
 		.pdev = pdev,
+		.notify_types = NOTIFY_DEVICEID4_CHANGE |
+			NOTIFY_DEVICEID4_DELETE,
 	};
 	struct nfs4_getdeviceinfo_res res = {
 		.pdev = pdev,
@@ -7958,6 +7960,9 @@ _nfs4_proc_getdeviceinfo(struct nfs_server *server,
 
 	dprintk("--> %s\n", __func__);
 	status = nfs4_call_sync(server->client, server, &msg, &args.seq_args, &res.seq_res, 0);
+	if (res.notification & ~args.notify_types)
+		dprintk("%s: unsupported notification\n", __func__);
+
 	dprintk("<-- %s status=%d\n", __func__, status);
 
 	return status;
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 5c399ec41079..6b28a605c697 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -1920,7 +1920,7 @@ encode_getdeviceinfo(struct xdr_stream *xdr,
 
 	p = reserve_space(xdr, 4 + 4);
 	*p++ = cpu_to_be32(1);			/* bitmap length */
-	*p++ = cpu_to_be32(NOTIFY_DEVICEID4_CHANGE | NOTIFY_DEVICEID4_DELETE);
+	*p++ = cpu_to_be32(args->notify_types);
 }
 
 static void
@@ -5753,8 +5753,9 @@ out_overflow:
 
 #if defined(CONFIG_NFS_V4_1)
 static int decode_getdeviceinfo(struct xdr_stream *xdr,
-				struct pnfs_device *pdev)
+				struct nfs4_getdeviceinfo_res *res)
 {
+	struct pnfs_device *pdev = res->pdev;
 	__be32 *p;
 	uint32_t len, type;
 	int status;
@@ -5802,12 +5803,7 @@ static int decode_getdeviceinfo(struct xdr_stream *xdr,
 		if (unlikely(!p))
 			goto out_overflow;
 
-		if (be32_to_cpup(p++) &
-		    ~(NOTIFY_DEVICEID4_CHANGE | NOTIFY_DEVICEID4_DELETE)) {
-			dprintk("%s: unsupported notification\n",
-				__func__);
-		}
-
+		res->notification = be32_to_cpup(p++);
 		for (i = 1; i < len; i++) {
 			if (be32_to_cpup(p++)) {
 				dprintk("%s: unsupported notification\n",
@@ -7061,7 +7057,7 @@ static int nfs4_xdr_dec_getdeviceinfo(struct rpc_rqst *rqstp,
 	status = decode_sequence(xdr, &res->seq_res, rqstp);
 	if (status != 0)
 		goto out;
-	status = decode_getdeviceinfo(xdr, res->pdev);
+	status = decode_getdeviceinfo(xdr, res);
 out:
 	return status;
 }
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 4cb3eaa89cf7..3d88908fd140 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -255,11 +255,13 @@ struct nfs4_layoutget {
 struct nfs4_getdeviceinfo_args {
 	struct nfs4_sequence_args seq_args;
 	struct pnfs_device *pdev;
+	__u32 notify_types;
 };
 
 struct nfs4_getdeviceinfo_res {
 	struct nfs4_sequence_res seq_res;
 	struct pnfs_device *pdev;
+	__u32 notification;
 };
 
 struct nfs4_layoutcommit_args {
-- 
2.1.0


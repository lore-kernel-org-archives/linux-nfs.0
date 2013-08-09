Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gh0-f179.google.com ([209.85.160.179]:59847 "EHLO
	mail-gh0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S968171Ab3HIQtc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 9 Aug 2013 12:49:32 -0400
Received: by mail-gh0-f179.google.com with SMTP id f16so1291746ghb.38
        for <linux-nfs@vger.kernel.org>; Fri, 09 Aug 2013 09:49:31 -0700 (PDT)
Received: from seurat.1015granger.net ([2604:8800:100:81fc:20c:29ff:fe44:ec31])
        by mx.google.com with ESMTPSA id s65sm20680045yhs.14.2013.08.09.09.49.30
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Fri, 09 Aug 2013 09:49:30 -0700 (PDT)
Subject: [PATCH v2 12/33] NFS: Enable nfs4_setup_sequence() for DELEGRETURN
To: linux-nfs@vger.kernel.org
From: Chuck Lever <chuck.lever@oracle.com>
Date: Fri, 09 Aug 2013 12:49:29 -0400
Message-ID: <20130809164929.5362.2502.stgit@seurat.1015granger.net>
In-Reply-To: <20130809161957.5362.90865.stgit@seurat.1015granger.net>
References: <20130809161957.5362.90865.stgit@seurat.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When CONFIG_NFS_V4_1 is disabled, the calls to nfs4_setup_sequence()
and nfs4_sequence_done() are compiled out for the DELEGRETURN
operation.  To allow NFSv4.0 transport blocking to work for
DELEGRETURN, these call sites have to be present all the time.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/nfs/nfs4proc.c |    4 ----
 1 file changed, 4 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 51f4272..b915c7d 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -4862,7 +4862,6 @@ static void nfs4_delegreturn_release(void *calldata)
 	kfree(calldata);
 }
 
-#if defined(CONFIG_NFS_V4_1)
 static void nfs4_delegreturn_prepare(struct rpc_task *task, void *data)
 {
 	struct nfs4_delegreturndata *d_data;
@@ -4874,12 +4873,9 @@ static void nfs4_delegreturn_prepare(struct rpc_task *task, void *data)
 			&d_data->res.seq_res,
 			task);
 }
-#endif /* CONFIG_NFS_V4_1 */
 
 static const struct rpc_call_ops nfs4_delegreturn_ops = {
-#if defined(CONFIG_NFS_V4_1)
 	.rpc_call_prepare = nfs4_delegreturn_prepare,
-#endif /* CONFIG_NFS_V4_1 */
 	.rpc_call_done = nfs4_delegreturn_done,
 	.rpc_release = nfs4_delegreturn_release,
 };


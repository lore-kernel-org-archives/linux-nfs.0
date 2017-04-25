Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:33738 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1953563AbdDYUfn (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 25 Apr 2017 16:35:43 -0400
Received: by mail-it0-f67.google.com with SMTP id z67so23068507itb.0
        for <linux-nfs@vger.kernel.org>; Tue, 25 Apr 2017 13:35:43 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] NFSv3: nfs3_nlm_alloc_call should be declared static
Date: Tue, 25 Apr 2017 16:35:40 -0400
Message-Id: <20170425203540.37199-1-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Fix compiler warnings.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs3proc.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/nfs3proc.c b/fs/nfs/nfs3proc.c
index ce06ae0a25cf..0c07b567118d 100644
--- a/fs/nfs/nfs3proc.c
+++ b/fs/nfs/nfs3proc.c
@@ -865,7 +865,7 @@ static void nfs3_proc_commit_setup(struct nfs_commit_data *data, struct rpc_mess
 	msg->rpc_proc = &nfs3_procedures[NFS3PROC_COMMIT];
 }
 
-void nfs3_nlm_alloc_call(void *data)
+static void nfs3_nlm_alloc_call(void *data)
 {
 	struct nfs_lock_context *l_ctx = data;
 	if (l_ctx && test_bit(NFS_CONTEXT_UNLOCK, &l_ctx->open_context->flags)) {
@@ -874,7 +874,7 @@ void nfs3_nlm_alloc_call(void *data)
 	}
 }
 
-bool nfs3_nlm_unlock_prepare(struct rpc_task *task, void *data)
+static bool nfs3_nlm_unlock_prepare(struct rpc_task *task, void *data)
 {
 	struct nfs_lock_context *l_ctx = data;
 	if (l_ctx && test_bit(NFS_CONTEXT_UNLOCK, &l_ctx->open_context->flags))
@@ -883,7 +883,7 @@ bool nfs3_nlm_unlock_prepare(struct rpc_task *task, void *data)
 
 }
 
-void nfs3_nlm_release_call(void *data)
+static void nfs3_nlm_release_call(void *data)
 {
 	struct nfs_lock_context *l_ctx = data;
 	struct nfs_open_context *ctx;
-- 
2.9.3


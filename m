Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qg0-f66.google.com ([209.85.192.66]:34235 "EHLO
	mail-qg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751119AbcEPVnQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 16 May 2016 17:43:16 -0400
Received: by mail-qg0-f66.google.com with SMTP id e35so14889237qge.1
        for <linux-nfs@vger.kernel.org>; Mon, 16 May 2016 14:43:15 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Anna Schumaker <anna.schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 1/4] SUNRPC: Ensure get_rpccred() and put_rpccred() can take NULL arguments
Date: Mon, 16 May 2016 17:42:42 -0400
Message-Id: <1463434965-44877-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 include/linux/sunrpc/auth.h | 3 ++-
 net/sunrpc/auth.c           | 5 +++--
 2 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/include/linux/sunrpc/auth.h b/include/linux/sunrpc/auth.h
index 6a241a277249..c99fe999d0a8 100644
--- a/include/linux/sunrpc/auth.h
+++ b/include/linux/sunrpc/auth.h
@@ -201,7 +201,8 @@ char *			rpcauth_stringify_acceptor(struct rpc_cred *);
 static inline
 struct rpc_cred *	get_rpccred(struct rpc_cred *cred)
 {
-	atomic_inc(&cred->cr_count);
+	if (cred != NULL)
+		atomic_inc(&cred->cr_count);
 	return cred;
 }
 
diff --git a/net/sunrpc/auth.c b/net/sunrpc/auth.c
index 02f53674dc39..c2cf04bf609f 100644
--- a/net/sunrpc/auth.c
+++ b/net/sunrpc/auth.c
@@ -703,8 +703,7 @@ rpcauth_bindcred(struct rpc_task *task, struct rpc_cred *cred, int flags)
 		new = rpcauth_bind_new_cred(task, lookupflags);
 	if (IS_ERR(new))
 		return PTR_ERR(new);
-	if (req->rq_cred != NULL)
-		put_rpccred(req->rq_cred);
+	put_rpccred(req->rq_cred);
 	req->rq_cred = new;
 	return 0;
 }
@@ -712,6 +711,8 @@ rpcauth_bindcred(struct rpc_task *task, struct rpc_cred *cred, int flags)
 void
 put_rpccred(struct rpc_cred *cred)
 {
+	if (cred == NULL)
+		return;
 	/* Fast path for unhashed credentials */
 	if (test_bit(RPCAUTH_CRED_HASHED, &cred->cr_flags) == 0) {
 		if (atomic_dec_and_test(&cred->cr_count))
-- 
2.5.5


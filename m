Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx142.netapp.com ([216.240.21.19]:6612 "EHLO mx142.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1760474AbcLWQGr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 23 Dec 2016 11:06:47 -0500
From: <andros@netapp.com>
To: <anna.schumaker@netapp.com>
CC: <bfieldses.org@netapp.com>, <linux-nfs@vger.kernel.org>,
        Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 3 10/16] SUNRPC: AUTH_GSS add RPC_GSS_PROC_CREATE case for wrap and unwrap
Date: Fri, 23 Dec 2016 11:04:22 -0500
Message-ID: <1482509068-24516-11-git-send-email-andros@netapp.com>
In-Reply-To: <1482509068-24516-1-git-send-email-andros@netapp.com>
References: <1482509068-24516-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 net/sunrpc/auth_gss/auth_gss.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index 8445ff4..2b284e1 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -2325,7 +2325,8 @@ static void gss_wrap_req_encode(kxdreproc_t encode, struct rpc_rqst *rqstp,
 	int             status = -EIO;
 
 	dprintk("RPC: %5u %s\n", task->tk_pid, __func__);
-	if (ctx->gc_proc != RPC_GSS_PROC_DATA) {
+	if (!(ctx->gc_proc == RPC_GSS_PROC_DATA  ||
+	      ctx->gc_proc == RPC_GSS_PROC_CREATE)) {
 		/* The spec seems a little ambiguous here, but I think that not
 		 * wrapping context destruction requests makes the most sense.
 		 */
@@ -2444,7 +2445,8 @@ static void gss_wrap_req_encode(kxdreproc_t encode, struct rpc_rqst *rqstp,
 	int		savedlen = head->iov_len;
 	int             status = -EIO;
 
-	if (ctx->gc_proc != RPC_GSS_PROC_DATA)
+	if (!(ctx->gc_proc == RPC_GSS_PROC_DATA  ||
+	      ctx->gc_proc == RPC_GSS_PROC_CREATE))
 		goto out_decode;
 	switch (gss_cred->gc_service) {
 	case RPC_GSS_SVC_NONE:
-- 
1.8.3.1


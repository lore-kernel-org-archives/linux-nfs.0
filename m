Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx143.netapp.com ([216.240.21.24]:5726 "EHLO mx143.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751454AbdBXWUM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 24 Feb 2017 17:20:12 -0500
From: <andros@netapp.com>
To: <bfields@fieldses.org>
CC: <trond.myklebust@primarydata.com>, <schumaker.anna@gmail.com>,
        <linux-nfs@vger.kernel.org>, Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 5 12/17] SUNRPC: AUTH_GSS add RPC_GSS_PROC_CREATE case for wrap and unwrap
Date: Fri, 24 Feb 2017 17:19:48 -0500
Message-ID: <20170224221953.5502-13-andros@netapp.com>
In-Reply-To: <20170224221953.5502-1-andros@netapp.com>
References: <20170224221953.5502-1-andros@netapp.com>
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
index 5daab12..73e3204 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -2380,7 +2380,8 @@ gss_wrap_req(struct rpc_task *task,
 	int             status = -EIO;
 
 	dprintk("RPC: %5u %s\n", task->tk_pid, __func__);
-	if (ctx->gc_proc != RPC_GSS_PROC_DATA) {
+	if (!(ctx->gc_proc == RPC_GSS_PROC_DATA  ||
+	      ctx->gc_proc == RPC_GSS_PROC_CREATE)) {
 		/* The spec seems a little ambiguous here, but I think that not
 		 * wrapping context destruction requests makes the most sense.
 		 */
@@ -2499,7 +2500,8 @@ gss_unwrap_resp(struct rpc_task *task,
 	int		savedlen = head->iov_len;
 	int             status = -EIO;
 
-	if (ctx->gc_proc != RPC_GSS_PROC_DATA)
+	if (!(ctx->gc_proc == RPC_GSS_PROC_DATA  ||
+	      ctx->gc_proc == RPC_GSS_PROC_CREATE))
 		goto out_decode;
 	switch (gss_cred->gc_service) {
 	case RPC_GSS_SVC_NONE:
-- 
2.9.3


Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx141.netapp.com ([216.240.21.12]:7681 "EHLO mx141.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755948AbcLWQGb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 23 Dec 2016 11:06:31 -0500
From: <andros@netapp.com>
To: <anna.schumaker@netapp.com>
CC: <bfieldses.org@netapp.com>, <linux-nfs@vger.kernel.org>,
        Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 3 05/16] SUNRPC AUTH_GSS get RPCSEC_GSS version from gssd downcall
Date: Fri, 23 Dec 2016 11:04:17 -0500
Message-ID: <1482509068-24516-6-git-send-email-andros@netapp.com>
In-Reply-To: <1482509068-24516-1-git-send-email-andros@netapp.com>
References: <1482509068-24516-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 net/sunrpc/auth_gss/auth_gss.c | 16 ++++++++++++----
 1 file changed, 12 insertions(+), 4 deletions(-)

diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index 96135da..9288cc2 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -213,6 +213,7 @@ struct gss_auth {
 	unsigned int seclen;
 	unsigned int timeout;
 	unsigned long now = jiffies;
+	unsigned int gss_v;
 	u32 window_size;
 	int ret;
 
@@ -226,6 +227,13 @@ struct gss_auth {
 	if (timeout == 0)
 		timeout = GSSD_MIN_TIMEOUT;
 	ctx->gc_expiry = now + ((unsigned long)timeout * HZ);
+
+	/* RPCSEC_GSS version used to obtain context */
+	p = simple_get_bytes(p, end, &gss_v, sizeof(gss_v));
+	if (IS_ERR(p))
+		goto err;
+	ctx->gc_v = gss_v;
+
 	/* Sequence number window. Determines the maximum number of
 	 * simultaneous requests
 	 */
@@ -1511,10 +1519,10 @@ static void gss_pipe_free(struct gss_pipe *p)
 	req->rq_seqno = ctx->gc_seq++;
 	spin_unlock(&ctx->gc_seq_lock);
 
-	*p++ = htonl((u32) RPC_GSS_VERSION);
-	*p++ = htonl((u32) ctx->gc_proc);
-	*p++ = htonl((u32) req->rq_seqno);
-	*p++ = htonl((u32) gss_cred->gc_service);
+	*p++ = htonl((u32)ctx->gc_v);
+	*p++ = htonl((u32)ctx->gc_proc);
+	*p++ = htonl((u32)req->rq_seqno);
+	*p++ = htonl((u32)gss_cred->gc_service);
 	p = xdr_encode_netobj(p, &ctx->gc_wire_ctx);
 	*cred_len = htonl((p - (cred_len + 1)) << 2);
 
-- 
1.8.3.1


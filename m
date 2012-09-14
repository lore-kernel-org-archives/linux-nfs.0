Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:60918 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755359Ab2INVLf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 14 Sep 2012 17:11:35 -0400
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 2 2/5] SUNRPC set gss gc_expiry to full lifetime
Date: Fri, 14 Sep 2012 17:11:46 -0400
Message-Id: <1347657109-2180-3-git-send-email-andros@netapp.com>
In-Reply-To: <1347657109-2180-1-git-send-email-andros@netapp.com>
References: <1347657109-2180-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Only use the default GSSD_MIN_TIMEOUT if the gss downcall timeout is zero.
Store the full lifetime in gc_expiry (not 3/4 of the lifetime) as subsequent
patches will use the gc_expiry to determine buffered WRITE behavior in the
face of expired or soon to be expired gss credentials.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 net/sunrpc/auth_gss/auth_gss.c |   15 +++++++++++----
 1 files changed, 11 insertions(+), 4 deletions(-)

diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index 34c5220..c59f5ed 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -192,17 +192,21 @@ gss_fill_context(const void *p, const void *end, struct gss_cl_ctx *ctx, struct
 	const void *q;
 	unsigned int seclen;
 	unsigned int timeout;
+	unsigned long now = jiffies;
 	u32 window_size;
 	int ret;
 
-	/* First unsigned int gives the lifetime (in seconds) of the cred */
+	/* First unsigned int gives the remaining lifetime in seconds of the
+	 * credential - e.g. the remaining TGT lifetime for Kerberos or
+	 * the -t value passed to GSSD. */
 	p = simple_get_bytes(p, end, &timeout, sizeof(timeout));
 	if (IS_ERR(p))
 		goto err;
 	if (timeout == 0)
 		timeout = GSSD_MIN_TIMEOUT;
-	ctx->gc_expiry = jiffies + (unsigned long)timeout * HZ * 3 / 4;
-	/* Sequence number window. Determines the maximum number of simultaneous requests */
+	ctx->gc_expiry = now + ((unsigned long)timeout * HZ);
+	/* Sequence number window. Determines the maximum number of
+	 * simultaneous requests */
 	p = simple_get_bytes(p, end, &window_size, sizeof(window_size));
 	if (IS_ERR(p))
 		goto err;
@@ -237,9 +241,12 @@ gss_fill_context(const void *p, const void *end, struct gss_cl_ctx *ctx, struct
 		p = ERR_PTR(ret);
 		goto err;
 	}
+	dprintk("RPC:       %s Success. gc_expiry %lu now %lu timeout %u\n",
+		__func__, ctx->gc_expiry, now, timeout);
 	return q;
 err:
-	dprintk("RPC:       gss_fill_context returning %ld\n", -PTR_ERR(p));
+	dprintk("RPC:       %s returns %ld gc_expiry %lu now %lu timeout %u\n",
+		__func__, -PTR_ERR(p), ctx->gc_expiry, now, timeout);
 	return p;
 }
 
-- 
1.7.7.6


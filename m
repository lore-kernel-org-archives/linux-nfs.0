Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx141.netapp.com ([216.240.21.12]:5887 "EHLO mx141.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752691AbcLHSTX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 8 Dec 2016 13:19:23 -0500
From: <andros@netapp.com>
To: <bfields@fieldses.org>
CC: <linux-nfs@vger.kernel.org>, Andy Adamson <andros@netapp.com>
Subject: [PATCH 1/2] SVCAUTH update the rsc cache on RPC_GSS_PROC_DESTROY
Date: Thu, 8 Dec 2016 13:17:26 -0500
Message-ID: <1481221046-4999-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

The current code sets the expiry_time on the local copy of the rsc
cache entry - but not on the actual cache entry.
Note that currently, the rsc cache entries are not cleaned up even
when nfsd is stopped.

Update the cache with the new expiry_time of now so that cache_clean will
clean up (free) the context to be destroyed.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 net/sunrpc/auth_gss/svcauth_gss.c | 36 ++++++++++++++++++++++++++++++++++--
 1 file changed, 34 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/auth_gss/svcauth_gss.c b/net/sunrpc/auth_gss/svcauth_gss.c
index 45662d7..1e720ae 100644
--- a/net/sunrpc/auth_gss/svcauth_gss.c
+++ b/net/sunrpc/auth_gss/svcauth_gss.c
@@ -1393,6 +1393,38 @@ static void destroy_use_gss_proxy_proc_entry(struct net *net) {}
 
 #endif /* CONFIG_PROC_FS */
 
+/**
+ * rscp has been looked up in svcauth_gss_accept. Should have a
+ * refcount = 1.
+ */
+static int gss_svc_rsc_destroy(struct sunrpc_net *sn,
+			       struct rsc *rscp)
+{
+	struct rsc new;
+	int ret = -ENOMEM;
+
+	memset(&new, 0, sizeof(struct rsc));
+	if (dup_netobj(&new.handle, &rscp->handle))
+		goto out;
+	new.h.expiry_time = get_seconds();
+	set_bit(CACHE_NEGATIVE, &new.h.flags);
+
+	/**
+	 * Balance the cache_put at the end of svcauth_gss_accept.This
+	 * will leave the refcount = 1 so that the cache_clean cache_put
+	 * will call rsc_put.
+	 */
+	cache_get(&rscp->h);
+
+	rscp = rsc_update(sn->rsc_cache, &new, rscp);
+	if (!rscp)
+		goto out;
+	ret = 0;
+out:
+	rsc_free(&new);
+	return ret;
+}
+
 /*
  * Accept an rpcsec packet.
  * If context establishment, punt to user space
@@ -1489,8 +1521,8 @@ static void destroy_use_gss_proxy_proc_entry(struct net *net) {}
 	case RPC_GSS_PROC_DESTROY:
 		if (gss_write_verf(rqstp, rsci->mechctx, gc->gc_seq))
 			goto auth_err;
-		rsci->h.expiry_time = get_seconds();
-		set_bit(CACHE_NEGATIVE, &rsci->h.flags);
+		if (gss_svc_rsc_destroy(sn, rsci))
+			goto drop;
 		if (resv->iov_len + 4 > PAGE_SIZE)
 			goto drop;
 		svc_putnl(resv, RPC_SUCCESS);
-- 
1.8.3.1


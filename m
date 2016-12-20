Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx142.netapp.com ([216.240.21.19]:21171 "EHLO mx142.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752117AbcLTACQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 19 Dec 2016 19:02:16 -0500
From: <andros@netapp.com>
To: <bfields@fieldses.org>
CC: <neilb@suse.de>, <linux-nfs@vger.kernel.org>,
        Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 3] SVCAUTH update the rsc cache on RPC_GSS_PROC_DESTROY
Date: Mon, 19 Dec 2016 19:00:30 -0500
Message-ID: <1482192030-19219-2-git-send-email-andros@netapp.com>
In-Reply-To: <1482192030-19219-1-git-send-email-andros@netapp.com>
References: <1482192030-19219-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

The rsc cache code operates in a read_lock/write_lock environment.
Changes to a cache entry should use the provided rsc_update
routine which takes the write_lock.

The current code sets the expiry_time and the CACHE_NEGATIVE flag
without taking the write_lock as it does not call rsc_update.
Without this patch, while cache_clean sees the entries to be
removed, it does not remove the rsc_entries. This is because
rsc_update sets other fields in the entry to properly trigger
cache_clean.

Cache_clean takes the write_lock to remove expired or invalid
entries from the cache_list and calls cache_put on the entry.

Looking at sunrpc_cache_update, what we want is to invalidate the
cache entry, so that it is direclty replaced which means that
update_rsc is called. We pass in a new zero'ed rsc cache entry
to rsc_update with an expiry_time set to 0 along with the
invalidatedcache entry to be destroyed.

The cache_put at the end of svcauth_gss_accept processing drops
the reference count to 1 which allows the cache_put called by
cache_clean to result in a call to rsc_put and rsc_free
to reap the entry after it has been removed from the cache_list
under the write_lock.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 net/sunrpc/auth_gss/svcauth_gss.c | 18 +++++++++++++++---
 1 file changed, 15 insertions(+), 3 deletions(-)

diff --git a/net/sunrpc/auth_gss/svcauth_gss.c b/net/sunrpc/auth_gss/svcauth_gss.c
index 45662d7..b8093da 100644
--- a/net/sunrpc/auth_gss/svcauth_gss.c
+++ b/net/sunrpc/auth_gss/svcauth_gss.c
@@ -1409,7 +1409,9 @@ static void destroy_use_gss_proxy_proc_entry(struct net *net) {}
 	u32		crlen;
 	struct gss_svc_data *svcdata = rqstp->rq_auth_data;
 	struct rpc_gss_wire_cred *gc;
-	struct rsc	*rsci = NULL;
+	struct rsc	*rsci = NULL, new = {
+		.mechctx = 0,
+	};
 	__be32		*rpcstart;
 	__be32		*reject_stat = resv->iov_base + resv->iov_len;
 	int		ret;
@@ -1489,10 +1491,20 @@ static void destroy_use_gss_proxy_proc_entry(struct net *net) {}
 	case RPC_GSS_PROC_DESTROY:
 		if (gss_write_verf(rqstp, rsci->mechctx, gc->gc_seq))
 			goto auth_err;
-		rsci->h.expiry_time = get_seconds();
-		set_bit(CACHE_NEGATIVE, &rsci->h.flags);
+
+		/** Invalidate the cache entry so sunrpc_update_cache
+		 * direclty updates rsci. new->h.expiry_time is zero,
+		 * so rsci->h.expiry_time will be set to zero and 
+		 * cache_clean will properly remove rsci.
+		 */
+		clear_bit(CACHE_VALID, &rsci->h.flags);
+		rsci = rsc_update(sn->rsc_cache, &new, rsci);
+		if (!rsci)
+			goto drop;
+
 		if (resv->iov_len + 4 > PAGE_SIZE)
 			goto drop;
+
 		svc_putnl(resv, RPC_SUCCESS);
 		goto complete;
 	case RPC_GSS_PROC_DATA:
-- 
1.8.3.1


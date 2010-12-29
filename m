Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:54691 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752440Ab0L2Ury (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 29 Dec 2010 15:47:54 -0500
Date: Wed, 29 Dec 2010 15:47:52 -0500
To: linux-nfs@vger.kernel.org
Cc: Neil Brown <neilb@suse.de>
Subject: [PATCH] svcrpc: modifying positive sunrpc cache entries is racy
Message-ID: <20101229204752.GC12218@fieldses.org>
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

From: J. Bruce Fields <bfields@redhat.com>

Once a sunrpc cache entry is non-NEGATIVE, we should be replacing it
(and allowing any concurrent users to destroy it on last put) instead of
trying to update it in place.

Otherwise someone referencing the ip_map we're modifying here could try
to use the m_client just as we're putting the last reference.

The bug should only be seen by users of the legacy nfsd interfaces.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 net/sunrpc/svcauth_unix.c |   18 ++++++++++++++++--
 1 files changed, 16 insertions(+), 2 deletions(-)

Intended to apply for 2.6.38 if this looks right....

--b.

diff --git a/net/sunrpc/svcauth_unix.c b/net/sunrpc/svcauth_unix.c
index a04ac91..70586ad 100644
--- a/net/sunrpc/svcauth_unix.c
+++ b/net/sunrpc/svcauth_unix.c
@@ -386,6 +386,21 @@ int auth_unix_forget_old(struct auth_domain *dom)
 }
 EXPORT_SYMBOL_GPL(auth_unix_forget_old);
 
+static void auth_unix_invalidate_ip_map(struct cache_detail *cd, struct ip_map *ipm)
+{
+	struct cache_head *ch;
+	struct ip_map ip;
+
+	ip.m_client = ipm->m_client;
+	ip.h.flags = CACHE_NEGATIVE;
+	ip.h.expiry_time = ipm->h.expiry_time;
+	ch = sunrpc_cache_update(cd, &ip.h, &ipm->h,
+				 hash_str(ipm->m_class, IP_HASHBITS) ^
+				 hash_ip6(ipm->m_addr));
+	if (ch)
+		cache_put(ch, cd);
+}
+
 struct auth_domain *auth_unix_lookup(struct net *net, struct in6_addr *addr)
 {
 	struct ip_map *ipm;
@@ -401,8 +416,7 @@ struct auth_domain *auth_unix_lookup(struct net *net, struct in6_addr *addr)
 		return NULL;
 
 	if ((ipm->m_client->addr_changes - ipm->m_add_change) >0) {
-		if (test_and_set_bit(CACHE_NEGATIVE, &ipm->h.flags) == 0)
-			auth_domain_put(&ipm->m_client->h);
+		auth_unix_invalidate_ip_map(sn->ip_map_cache, ipm);
 		rv = NULL;
 	} else {
 		rv = &ipm->m_client->h;
-- 
1.7.3.4


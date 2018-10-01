Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it1-f175.google.com ([209.85.166.175]:33194 "EHLO
        mail-it1-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1729439AbeJAVUc (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 1 Oct 2018 17:20:32 -0400
Received: by mail-it1-f175.google.com with SMTP id h6-v6so6420234ith.0
        for <linux-nfs@vger.kernel.org>; Mon, 01 Oct 2018 07:42:23 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: "J . Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 04/15] SUNRPC: Make server side AUTH_UNIX use lockless lookups
Date: Mon,  1 Oct 2018 10:41:46 -0400
Message-Id: <20181001144157.3515-5-trond.myklebust@hammerspace.com>
In-Reply-To: <20181001144157.3515-4-trond.myklebust@hammerspace.com>
References: <20181001144157.3515-1-trond.myklebust@hammerspace.com>
 <20181001144157.3515-2-trond.myklebust@hammerspace.com>
 <20181001144157.3515-3-trond.myklebust@hammerspace.com>
 <20181001144157.3515-4-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Convert structs ip_map and unix_gid to use RCU protected lookups.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 net/sunrpc/svcauth_unix.c | 14 ++++++++------
 1 file changed, 8 insertions(+), 6 deletions(-)

diff --git a/net/sunrpc/svcauth_unix.c b/net/sunrpc/svcauth_unix.c
index 84cf39021a03..fb9041b92f72 100644
--- a/net/sunrpc/svcauth_unix.c
+++ b/net/sunrpc/svcauth_unix.c
@@ -97,6 +97,7 @@ struct ip_map {
 	char			m_class[8]; /* e.g. "nfsd" */
 	struct in6_addr		m_addr;
 	struct unix_domain	*m_client;
+	struct rcu_head		m_rcu;
 };
 
 static void ip_map_put(struct kref *kref)
@@ -107,7 +108,7 @@ static void ip_map_put(struct kref *kref)
 	if (test_bit(CACHE_VALID, &item->flags) &&
 	    !test_bit(CACHE_NEGATIVE, &item->flags))
 		auth_domain_put(&im->m_client->h);
-	kfree(im);
+	kfree_rcu(im, m_rcu);
 }
 
 static inline int hash_ip6(const struct in6_addr *ip)
@@ -286,9 +287,9 @@ static struct ip_map *__ip_map_lookup(struct cache_detail *cd, char *class,
 
 	strcpy(ip.m_class, class);
 	ip.m_addr = *addr;
-	ch = sunrpc_cache_lookup(cd, &ip.h,
-				 hash_str(class, IP_HASHBITS) ^
-				 hash_ip6(addr));
+	ch = sunrpc_cache_lookup_rcu(cd, &ip.h,
+				     hash_str(class, IP_HASHBITS) ^
+				     hash_ip6(addr));
 
 	if (ch)
 		return container_of(ch, struct ip_map, h);
@@ -418,6 +419,7 @@ struct unix_gid {
 	struct cache_head	h;
 	kuid_t			uid;
 	struct group_info	*gi;
+	struct rcu_head		rcu;
 };
 
 static int unix_gid_hash(kuid_t uid)
@@ -432,7 +434,7 @@ static void unix_gid_put(struct kref *kref)
 	if (test_bit(CACHE_VALID, &item->flags) &&
 	    !test_bit(CACHE_NEGATIVE, &item->flags))
 		put_group_info(ug->gi);
-	kfree(ug);
+	kfree_rcu(ug, rcu);
 }
 
 static int unix_gid_match(struct cache_head *corig, struct cache_head *cnew)
@@ -625,7 +627,7 @@ static struct unix_gid *unix_gid_lookup(struct cache_detail *cd, kuid_t uid)
 	struct cache_head *ch;
 
 	ug.uid = uid;
-	ch = sunrpc_cache_lookup(cd, &ug.h, unix_gid_hash(uid));
+	ch = sunrpc_cache_lookup_rcu(cd, &ug.h, unix_gid_hash(uid));
 	if (ch)
 		return container_of(ch, struct unix_gid, h);
 	else
-- 
2.17.1

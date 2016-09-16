Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43736 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S965550AbcIPUL1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 16 Sep 2016 16:11:27 -0400
Received: from int-mx10.intmail.prod.int.phx2.redhat.com (int-mx10.intmail.prod.int.phx2.redhat.com [10.5.11.23])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 595761B18
        for <linux-nfs@vger.kernel.org>; Fri, 16 Sep 2016 20:11:25 +0000 (UTC)
Received: from hut.sorensonfamily.com.redhat.com (ovpn-116-43.rdu2.redhat.com [10.10.116.43])
        by int-mx10.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id u8GKBOSG002839
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO)
        for <linux-nfs@vger.kernel.org>; Fri, 16 Sep 2016 16:11:24 -0400
From: Frank Sorenson <sorenson@redhat.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] sunrpc: include gid in the rpc_cred_cache hash
Date: Fri, 16 Sep 2016 15:12:15 -0500
Message-Id: <1474056735-4008-1-git-send-email-sorenson@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The current rpc_cred_cache hashtable uses only the uid in the hash
computation.  rpc_creds created with the same uid but different
gids will all go on the same hash chain.

In certain usage patterns, such as the following, this can lead to
extremely long hash chains for these uids, while the rest of the
hashtable remains nearly empty. This causes very high cpu usage
in rpcauth_lookup_credcache, and slow performance for that uid.

    for (i = 0 ; i < 100000 ; i++) {
        setregid(-1, i);
        stat(path, &st);
    }

Add the gid to the hash algorithm to distribute the rpc_creds
throughout the cache to avoid long individual hash chains.

Signed-off-by: Frank Sorenson <sorenson@redhat.com>

diff --git a/net/sunrpc/auth.c b/net/sunrpc/auth.c
index a7e42f9..2260e58 100644
--- a/net/sunrpc/auth.c
+++ b/net/sunrpc/auth.c
@@ -538,6 +538,14 @@ rpcauth_cache_enforce_limit(void)
 	rpcauth_cache_do_shrink(nr_to_scan);
 }
 
+static unsigned int
+rpcauth_hash_acred(struct auth_cred *acred, unsigned int hashbits)
+{
+	return hash_64(from_kgid(&init_user_ns, acred->gid) |
+		(from_kuid(&init_user_ns, acred->uid) << (sizeof(gid_t) * 8)),
+		hashbits);
+}
+
 /*
  * Look up a process' credentials in the authentication cache
  */
@@ -551,7 +559,7 @@ rpcauth_lookup_credcache(struct rpc_auth *auth, struct auth_cred * acred,
 			*entry, *new;
 	unsigned int nr;
 
-	nr = hash_long(from_kuid(&init_user_ns, acred->uid), cache->hashbits);
+	nr = rpcauth_hash_acred(acred, cache->hashbits);
 
 	rcu_read_lock();
 	hlist_for_each_entry_rcu(entry, &cache->hashtable[nr], cr_hash) {

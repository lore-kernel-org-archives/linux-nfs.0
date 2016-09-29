Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58716 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755089AbcI2Pny (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 29 Sep 2016 11:43:54 -0400
Received: from int-mx10.intmail.prod.int.phx2.redhat.com (int-mx10.intmail.prod.int.phx2.redhat.com [10.5.11.23])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 7DCE531B338
        for <linux-nfs@vger.kernel.org>; Thu, 29 Sep 2016 15:43:54 +0000 (UTC)
Received: from hut.sorensonfamily.com.redhat.com (ovpn-116-43.rdu2.redhat.com [10.10.116.43])
        by int-mx10.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id u8TFhoxG007382
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO)
        for <linux-nfs@vger.kernel.org>; Thu, 29 Sep 2016 11:43:54 -0400
From: Frank Sorenson <sorenson@redhat.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 5/5] sunrpc: replace generic auth_cred hash with auth-specific function
Date: Thu, 29 Sep 2016 10:44:41 -0500
Message-Id: <1475163881-12438-6-git-send-email-sorenson@redhat.com>
In-Reply-To: <1475163881-12438-1-git-send-email-sorenson@redhat.com>
References: <1475163881-12438-1-git-send-email-sorenson@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Replace the generic code to hash the auth_cred with the call to
the auth-specific hash function in the rpc_authops struct.

Signed-off-by: Frank Sorenson <sorenson@redhat.com>
---
 net/sunrpc/auth.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sunrpc/auth.c b/net/sunrpc/auth.c
index a7e42f9..2bff63a 100644
--- a/net/sunrpc/auth.c
+++ b/net/sunrpc/auth.c
@@ -551,7 +551,7 @@ rpcauth_lookup_credcache(struct rpc_auth *auth, struct auth_cred * acred,
 			*entry, *new;
 	unsigned int nr;
 
-	nr = hash_long(from_kuid(&init_user_ns, acred->uid), cache->hashbits);
+	nr = auth->au_ops->hash_cred(acred, cache->hashbits);
 
 	rcu_read_lock();
 	hlist_for_each_entry_rcu(entry, &cache->hashtable[nr], cr_hash) {
-- 
2.5.5


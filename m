Return-Path: <SRS0=j1eS=ND=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0CA97C46475
	for <linux-nfs@archiver.kernel.org>; Tue, 23 Oct 2018 16:35:16 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id AA5E220652
	for <linux-nfs@archiver.kernel.org>; Tue, 23 Oct 2018 16:35:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="N7MWQyBw"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AA5E220652
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727612AbeJXA7V (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 23 Oct 2018 20:59:21 -0400
Received: from mail-it1-f195.google.com ([209.85.166.195]:56101 "EHLO
        mail-it1-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727402AbeJXA7V (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 23 Oct 2018 20:59:21 -0400
Received: by mail-it1-f195.google.com with SMTP id c23-v6so2630010itd.5
        for <linux-nfs@vger.kernel.org>; Tue, 23 Oct 2018 09:35:13 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=YU3gbjUyPDvjsXqDm9aNeApsNYewl+FJT20atCmnH5M=;
        b=N7MWQyBwubfxX2m0WXYyr+TAfVnDm2tsxHPMOvGSICgvh6mVd16K/NCcxmZCX/Re8g
         6D7adE38JBO5O8Fvbwg3b+K+o3xBTNWwK6Fdcrggpurh6vXSqbHWs9jR9n5PcDaxSHt8
         FJxaE7UiQNaXcN6oxfDdh25Uuy3G+ri8BFhPerJ4hkKGNUSGwSBggWuA3MqspP5r8oWD
         Tl+vboFmNG2Yspz/BqzfK5IEg/6AmP8tmbcsBO6bUrdz478VspFd3NcUKQjcr72PBshU
         QfdinXlgxt0pMcfgnBBBbZlZ0IVg/QfcweR0WoxHctMScsQuDuDXcYj7j8kthQXsB0Ad
         cikg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=YU3gbjUyPDvjsXqDm9aNeApsNYewl+FJT20atCmnH5M=;
        b=hBDg8xCSnh5a/4iG9IAIho4h7AFMPa9CX8IiKRK+cukumEfb8nu0UbqNt3J04ExdFn
         F53mHc4YIFr4sFZjdOT1t/Lmwp/Mdui/YhdheB2XzPWb0OZNTJhwgWkMCbRU5udy0Dr3
         LKF+cN9wH0s5mOM6mVT2sDH6DN0tKSscISoBtFuXjvG9ChSmPGKXJvIQVrA6/f4HV7I1
         ZUNg7WO63/PQLJGVxDgap0PJwW7mrK4xhCMR8vuff/oehRjWUy0YtGtNTSz3vtypMOXI
         TO2iex54jpsSzmtx1YhJjFZ5jwixiL1gBy1Zy9dJdmab8aC1g7C6VzjDYUAgF/O3L3Kn
         7EDQ==
X-Gm-Message-State: ABuFfojnJjEl7gb6pCprN8NRYrnZ+/pg+YkcZT2K77rv8ULf3EGGNCqq
        DQGLkDHnjWP/utua0WLyT8AIdo0=
X-Google-Smtp-Source: ACcGV62DsM6yNX2Bva4sObUZuJZW2nqR6JvcDHHXdPG7gt8v80Ga2gdqqdQLQ+kLZ97EeUv3uFq8AQ==
X-Received: by 2002:a02:5f5a:: with SMTP id r87-v6mr38720411jab.22.1540312512909;
        Tue, 23 Oct 2018 09:35:12 -0700 (PDT)
Received: from localhost.localdomain (c-68-40-195-73.hsd1.mi.comcast.net. [68.40.195.73])
        by smtp.gmail.com with ESMTPSA id w20-v6sm573065ioa.82.2018.10.23.09.35.11
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 23 Oct 2018 09:35:12 -0700 (PDT)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     linux-nfs@vger.kernel.org
Subject: [PATCH 1/4] SUNRPC: Clean up the AUTH cache code
Date:   Tue, 23 Oct 2018 12:34:01 -0400
Message-Id: <20181023163404.27777-1-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.17.2
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 net/sunrpc/auth.c      | 147 ++++++++++++++++++++++++-----------------
 net/sunrpc/auth_null.c |   2 +-
 2 files changed, 87 insertions(+), 62 deletions(-)

diff --git a/net/sunrpc/auth.c b/net/sunrpc/auth.c
index 32985aa515be..c1576b110974 100644
--- a/net/sunrpc/auth.c
+++ b/net/sunrpc/auth.c
@@ -291,25 +291,30 @@ rpcauth_release(struct rpc_auth *auth)
 
 static DEFINE_SPINLOCK(rpc_credcache_lock);
 
-static void
+/*
+ * On success, the caller is responsible for freeing the reference
+ * held by the hashtable
+ */
+static bool
 rpcauth_unhash_cred_locked(struct rpc_cred *cred)
 {
+	if (!test_and_clear_bit(RPCAUTH_CRED_HASHED, &cred->cr_flags))
+		return false;
 	hlist_del_rcu(&cred->cr_hash);
-	smp_mb__before_atomic();
-	clear_bit(RPCAUTH_CRED_HASHED, &cred->cr_flags);
+	return true;
 }
 
-static int
+static bool
 rpcauth_unhash_cred(struct rpc_cred *cred)
 {
 	spinlock_t *cache_lock;
-	int ret;
+	bool ret;
 
+	if (!test_bit(RPCAUTH_CRED_HASHED, &cred->cr_flags))
+		return false;
 	cache_lock = &cred->cr_auth->au_credcache->lock;
 	spin_lock(cache_lock);
-	ret = atomic_read(&cred->cr_count) == 0;
-	if (ret)
-		rpcauth_unhash_cred_locked(cred);
+	ret = rpcauth_unhash_cred_locked(cred);
 	spin_unlock(cache_lock);
 	return ret;
 }
@@ -388,6 +393,44 @@ void rpcauth_destroy_credlist(struct list_head *head)
 	}
 }
 
+static void
+rpcauth_lru_add_locked(struct rpc_cred *cred)
+{
+	if (!list_empty(&cred->cr_lru))
+		return;
+	number_cred_unused++;
+	list_add_tail(&cred->cr_lru, &cred_unused);
+}
+
+static void
+rpcauth_lru_add(struct rpc_cred *cred)
+{
+	if (!list_empty(&cred->cr_lru))
+		return;
+	spin_lock(&rpc_credcache_lock);
+	rpcauth_lru_add_locked(cred);
+	spin_unlock(&rpc_credcache_lock);
+}
+
+static void
+rpcauth_lru_remove_locked(struct rpc_cred *cred)
+{
+	if (list_empty(&cred->cr_lru))
+		return;
+	number_cred_unused--;
+	list_del_init(&cred->cr_lru);
+}
+
+static void
+rpcauth_lru_remove(struct rpc_cred *cred)
+{
+	if (list_empty(&cred->cr_lru))
+		return;
+	spin_lock(&rpc_credcache_lock);
+	rpcauth_lru_remove_locked(cred);
+	spin_unlock(&rpc_credcache_lock);
+}
+
 /*
  * Clear the RPC credential cache, and delete those credentials
  * that are not referenced.
@@ -407,13 +450,10 @@ rpcauth_clear_credcache(struct rpc_cred_cache *cache)
 		head = &cache->hashtable[i];
 		while (!hlist_empty(head)) {
 			cred = hlist_entry(head->first, struct rpc_cred, cr_hash);
-			get_rpccred(cred);
-			if (!list_empty(&cred->cr_lru)) {
-				list_del(&cred->cr_lru);
-				number_cred_unused--;
-			}
-			list_add_tail(&cred->cr_lru, &free);
 			rpcauth_unhash_cred_locked(cred);
+			/* Note: We now hold a reference to cred */
+			rpcauth_lru_remove_locked(cred);
+			list_add_tail(&cred->cr_lru, &free);
 		}
 	}
 	spin_unlock(&cache->lock);
@@ -447,7 +487,6 @@ EXPORT_SYMBOL_GPL(rpcauth_destroy_credcache);
 static long
 rpcauth_prune_expired(struct list_head *free, int nr_to_scan)
 {
-	spinlock_t *cache_lock;
 	struct rpc_cred *cred, *next;
 	unsigned long expired = jiffies - RPC_AUTH_EXPIRY_MORATORIUM;
 	long freed = 0;
@@ -456,32 +495,24 @@ rpcauth_prune_expired(struct list_head *free, int nr_to_scan)
 
 		if (nr_to_scan-- == 0)
 			break;
+		if (atomic_read(&cred->cr_count) > 1) {
+			rpcauth_lru_remove_locked(cred);
+			continue;
+		}
 		/*
 		 * Enforce a 60 second garbage collection moratorium
 		 * Note that the cred_unused list must be time-ordered.
 		 */
-		if (time_in_range(cred->cr_expire, expired, jiffies) &&
-		    test_bit(RPCAUTH_CRED_HASHED, &cred->cr_flags) != 0) {
-			freed = SHRINK_STOP;
-			break;
-		}
-
-		list_del_init(&cred->cr_lru);
-		number_cred_unused--;
-		freed++;
-		if (atomic_read(&cred->cr_count) != 0)
+		if (!time_in_range(cred->cr_expire, expired, jiffies))
+			continue;
+		if (!rpcauth_unhash_cred(cred))
 			continue;
 
-		cache_lock = &cred->cr_auth->au_credcache->lock;
-		spin_lock(cache_lock);
-		if (atomic_read(&cred->cr_count) == 0) {
-			get_rpccred(cred);
-			list_add_tail(&cred->cr_lru, free);
-			rpcauth_unhash_cred_locked(cred);
-		}
-		spin_unlock(cache_lock);
+		rpcauth_lru_remove_locked(cred);
+		freed++;
+		list_add_tail(&cred->cr_lru, free);
 	}
-	return freed;
+	return freed ? freed : SHRINK_STOP;
 }
 
 static unsigned long
@@ -595,6 +626,7 @@ rpcauth_lookup_credcache(struct rpc_auth *auth, struct auth_cred * acred,
 	if (cred == NULL) {
 		cred = new;
 		set_bit(RPCAUTH_CRED_HASHED, &cred->cr_flags);
+		atomic_inc(&cred->cr_count);
 		hlist_add_head_rcu(&cred->cr_hash, &cache->hashtable[nr]);
 	} else
 		list_add_tail(&new->cr_lru, &free);
@@ -709,36 +741,29 @@ put_rpccred(struct rpc_cred *cred)
 {
 	if (cred == NULL)
 		return;
-	/* Fast path for unhashed credentials */
-	if (test_bit(RPCAUTH_CRED_HASHED, &cred->cr_flags) == 0) {
+	rcu_read_lock();
+	if (atomic_dec_and_test(&cred->cr_count))
+		goto destroy;
+	if (atomic_read(&cred->cr_count) != 1 ||
+	    !test_bit(RPCAUTH_CRED_HASHED, &cred->cr_flags))
+		goto out;
+	if (test_bit(RPCAUTH_CRED_UPTODATE, &cred->cr_flags) != 0) {
+		cred->cr_expire = jiffies;
+		rpcauth_lru_add(cred);
+		/* Race breaker */
+		if (unlikely(!test_bit(RPCAUTH_CRED_HASHED, &cred->cr_flags)))
+			rpcauth_lru_remove(cred);
+	} else if (rpcauth_unhash_cred(cred)) {
+		rpcauth_lru_remove(cred);
 		if (atomic_dec_and_test(&cred->cr_count))
-			cred->cr_ops->crdestroy(cred);
-		return;
-	}
-
-	if (!atomic_dec_and_lock(&cred->cr_count, &rpc_credcache_lock))
-		return;
-	if (!list_empty(&cred->cr_lru)) {
-		number_cred_unused--;
-		list_del_init(&cred->cr_lru);
-	}
-	if (test_bit(RPCAUTH_CRED_HASHED, &cred->cr_flags) != 0) {
-		if (test_bit(RPCAUTH_CRED_UPTODATE, &cred->cr_flags) != 0) {
-			cred->cr_expire = jiffies;
-			list_add_tail(&cred->cr_lru, &cred_unused);
-			number_cred_unused++;
-			goto out_nodestroy;
-		}
-		if (!rpcauth_unhash_cred(cred)) {
-			/* We were hashed and someone looked us up... */
-			goto out_nodestroy;
-		}
+			goto destroy;
 	}
-	spin_unlock(&rpc_credcache_lock);
-	cred->cr_ops->crdestroy(cred);
+out:
+	rcu_read_unlock();
 	return;
-out_nodestroy:
-	spin_unlock(&rpc_credcache_lock);
+destroy:
+	rcu_read_unlock();
+	cred->cr_ops->crdestroy(cred);
 }
 EXPORT_SYMBOL_GPL(put_rpccred);
 
diff --git a/net/sunrpc/auth_null.c b/net/sunrpc/auth_null.c
index 4b48228ee8c7..a7c00b4959f3 100644
--- a/net/sunrpc/auth_null.c
+++ b/net/sunrpc/auth_null.c
@@ -138,6 +138,6 @@ struct rpc_cred null_cred = {
 	.cr_lru		= LIST_HEAD_INIT(null_cred.cr_lru),
 	.cr_auth	= &null_auth,
 	.cr_ops		= &null_credops,
-	.cr_count	= ATOMIC_INIT(1),
+	.cr_count	= ATOMIC_INIT(2),
 	.cr_flags	= 1UL << RPCAUTH_CRED_UPTODATE,
 };
-- 
2.17.2


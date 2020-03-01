Return-Path: <SRS0=zwoO=4S=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,UNWANTED_LANGUAGE_BODY,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4D476C3F2D4
	for <linux-nfs@archiver.kernel.org>; Sun,  1 Mar 2020 23:25:23 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 2405124699
	for <linux-nfs@archiver.kernel.org>; Sun,  1 Mar 2020 23:25:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="vZfAfthe"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726627AbgCAXZW (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sun, 1 Mar 2020 18:25:22 -0500
Received: from mail-yw1-f68.google.com ([209.85.161.68]:38997 "EHLO
        mail-yw1-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726673AbgCAXZW (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 1 Mar 2020 18:25:22 -0500
Received: by mail-yw1-f68.google.com with SMTP id x184so9482034ywd.6
        for <linux-nfs@vger.kernel.org>; Sun, 01 Mar 2020 15:25:20 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=MWEyLw6EQcAivJXsLlZHcdf1lKHYi989/KDUlTy90nY=;
        b=vZfAftheEIXvNSdnKIAErv4k0Yl+Wx0I72g/Oknhfk1AUHGxdLY1D65sIdyly40zYC
         qDo+oFwkKgqpmgmST1Q6wBkqMd15JBKOEbFBCXaBGoyNtnBExl0YizpXrvIMod+YCWhA
         O6N/eVUhT/pYcZ+GLgOyFTEvZJXfVVn9Fe9a1eoKFY+81IkhY0MsGQoeFeA7a2QOXY8F
         ab5Fu2faFQx6xAEf5kLtWt/LmQDNAlns/DGQXEWzwyh1HFYVva+yD3/ASMIXVZ550hKl
         daAC3ghJi3jYEdTLORXeiuBwn9n4+GVDeUU+PesmysAoHQNqLkswGwP93fN6RrKpfZRT
         xSuw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=MWEyLw6EQcAivJXsLlZHcdf1lKHYi989/KDUlTy90nY=;
        b=Y01GMO3ElMZa3WuQ0cP7FmnsjkFtEa0xXsdCnoh6kvv6WUJa6LAvGbZXrwRdpdWIsV
         ZR1lBjsBNSaBMawofP/SLaAq95cWzAnuVfNv1Dwf2FU0IX7Xvsdqz139vBeAXU9q1Bmq
         nKCkctHTnSOnvlLql01qg1SmNFw5QO2PPveBnLFljR+PwhnoGS1Tu6b0t7rib8B9F0yl
         6mQc/7s2QMTAMK7egl93cOpn04GCcryqozb2YWYND3/dTR20f7sxrwZ+yJ0KqxJWZYIr
         I7fpTLbVDdwiNgGNXfxkBHbITpOerq+04inqgsjqNNOHy12slL3kF1VQmS5VK/dZnPqU
         Fbww==
X-Gm-Message-State: ANhLgQ26KiH4Oto8+w8iH75aznoQZ87UkzaVB/Im0oupg7prqt0seIZU
        C6w+1JSERbvpeWsjdBNavkrJRcdPvw==
X-Google-Smtp-Source: ADFU+vuvLVuZ2QwBr1SZwXr8GAWg0c27CJRIDro2QQnPH/M7voIgDlp17vR7i0p84iEJXik0mZVC2Q==
X-Received: by 2002:a05:6902:693:: with SMTP id i19mr389340ybt.297.1583105119633;
        Sun, 01 Mar 2020 15:25:19 -0800 (PST)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id u4sm7167301ywu.26.2020.03.01.15.25.18
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Sun, 01 Mar 2020 15:25:19 -0800 (PST)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     "J. Bruce Fields" <bfields@redhat.com>
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH 6/8] SUNRPC/cache: Allow garbage collection of invalid cache entries
Date:   Sun,  1 Mar 2020 18:21:43 -0500
Message-Id: <20200301232145.1465430-7-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.24.1
In-Reply-To: <20200301232145.1465430-6-trond.myklebust@hammerspace.com>
References: <20200301232145.1465430-1-trond.myklebust@hammerspace.com>
 <20200301232145.1465430-2-trond.myklebust@hammerspace.com>
 <20200301232145.1465430-3-trond.myklebust@hammerspace.com>
 <20200301232145.1465430-4-trond.myklebust@hammerspace.com>
 <20200301232145.1465430-5-trond.myklebust@hammerspace.com>
 <20200301232145.1465430-6-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

If the cache entry never gets initialised, we want the garbage
collector to be able to evict it. Otherwise if the upcall daemon
fails to initialise the entry, we end up never expiring it.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 include/linux/sunrpc/cache.h |  3 ---
 net/sunrpc/cache.c           | 36 +++++++++++++++++++-----------------
 2 files changed, 19 insertions(+), 20 deletions(-)

diff --git a/include/linux/sunrpc/cache.h b/include/linux/sunrpc/cache.h
index 656882a50991..532cdbda43da 100644
--- a/include/linux/sunrpc/cache.h
+++ b/include/linux/sunrpc/cache.h
@@ -209,9 +209,6 @@ static inline void cache_put(struct cache_head *h, struct cache_detail *cd)
 
 static inline bool cache_is_expired(struct cache_detail *detail, struct cache_head *h)
 {
-	if (!test_bit(CACHE_VALID, &h->flags))
-		return false;
-
 	return  (h->expiry_time < seconds_since_boot()) ||
 		(detail->flush_time >= h->last_refresh);
 }
diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
index 5e14513603cb..b7ddb2affb7e 100644
--- a/net/sunrpc/cache.c
+++ b/net/sunrpc/cache.c
@@ -64,13 +64,14 @@ static struct cache_head *sunrpc_cache_find_rcu(struct cache_detail *detail,
 
 	rcu_read_lock();
 	hlist_for_each_entry_rcu(tmp, head, cache_list) {
-		if (detail->match(tmp, key)) {
-			if (cache_is_expired(detail, tmp))
-				continue;
-			tmp = cache_get_rcu(tmp);
-			rcu_read_unlock();
-			return tmp;
-		}
+		if (!detail->match(tmp, key))
+			continue;
+		if (test_bit(CACHE_VALID, &tmp->flags) &&
+		    cache_is_expired(detail, tmp))
+			continue;
+		tmp = cache_get_rcu(tmp);
+		rcu_read_unlock();
+		return tmp;
 	}
 	rcu_read_unlock();
 	return NULL;
@@ -113,17 +114,18 @@ static struct cache_head *sunrpc_cache_add_entry(struct cache_detail *detail,
 
 	/* check if entry appeared while we slept */
 	hlist_for_each_entry_rcu(tmp, head, cache_list) {
-		if (detail->match(tmp, key)) {
-			if (cache_is_expired(detail, tmp)) {
-				sunrpc_begin_cache_remove_entry(tmp, detail);
-				freeme = tmp;
-				break;
-			}
-			cache_get(tmp);
-			spin_unlock(&detail->hash_lock);
-			cache_put(new, detail);
-			return tmp;
+		if (!detail->match(tmp, key))
+			continue;
+		if (test_bit(CACHE_VALID, &tmp->flags) &&
+		    cache_is_expired(detail, tmp)) {
+			sunrpc_begin_cache_remove_entry(tmp, detail);
+			freeme = tmp;
+			break;
 		}
+		cache_get(tmp);
+		spin_unlock(&detail->hash_lock);
+		cache_put(new, detail);
+		return tmp;
 	}
 
 	hlist_add_head_rcu(&new->cache_list, head);
-- 
2.24.1


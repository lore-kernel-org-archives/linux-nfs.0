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
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9E0F0C67863
	for <linux-nfs@archiver.kernel.org>; Tue, 23 Oct 2018 16:35:16 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 6689220652
	for <linux-nfs@archiver.kernel.org>; Tue, 23 Oct 2018 16:35:16 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="A+eHMo7o"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6689220652
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728225AbeJXA7W (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 23 Oct 2018 20:59:22 -0400
Received: from mail-it1-f196.google.com ([209.85.166.196]:50831 "EHLO
        mail-it1-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727402AbeJXA7W (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 23 Oct 2018 20:59:22 -0400
Received: by mail-it1-f196.google.com with SMTP id k206-v6so2652079ite.0
        for <linux-nfs@vger.kernel.org>; Tue, 23 Oct 2018 09:35:15 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=8Z3o4QM1IxOGWHcDKPR0hMPuASNpttKTaXdBXsxzMn0=;
        b=A+eHMo7ojTfVFdEZaSBeb21u4l87+aXjnJf1EfRSrobOj0HhfEoQ/+zC0L40t0s3Ud
         valWQAervBomD1BIhWfa4RPWVw3WnHvjYqhXkyojEDkFyXBwi++5cay7PBK8OuWnymTm
         tv5b+lyd0HJD//IFCWg4xoS1ff1RnJMRRZpgSmwVZpi4mns9Eo/S0yIo7f32LNIhvxd8
         lhHcxrq1WbGrLgfzilxp3+UnltGapUybJNQ12WLtnXIDkEKBBlrJDmvNQanXFhbBbu/9
         dvFruFhaOqX208j9a3Dvw31s8MlQspAl1GpCFgiDpm0vbX0JP8jn19dmHAgywO0pALK5
         dZWg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=8Z3o4QM1IxOGWHcDKPR0hMPuASNpttKTaXdBXsxzMn0=;
        b=gB8vCglh1ASnde33DOlokWvDjnwD89Ocb3ZkglyHIKCJNeiN5wTj5wdnnFjFRu69W5
         DipsS1bZxRx/jrUu5t34u8Pxkwo2D5dSxMmZychwNXibXQU6mB1zOt30iZ9wsm9vg8lN
         xS7Ma5I7/vGePGAfWaqeyzdXCRaR9LECx5fr51/IiPKp9HqGHC3llgPlCAAj408t5IRb
         Ub3/FxS+2/aX3wZyuExBHcHr8epi3raComg9nVqYlEnTjg9WSfKRbDklyDm9shbhRIBa
         jA97Q7Ht3RkuzlKQWQBYE6WOmHpJi0NZYoohgejuuzf5eJN7EiBvA7bqX6TLOJJSooIr
         gdqQ==
X-Gm-Message-State: ABuFfohQgndFcfXB4tUOlqlJo+9im6I0pwa06J78Q0we41N/zYeq1305
        ZpCOwIkZ96rl4uA7GMwdE18Lui0=
X-Google-Smtp-Source: ACcGV62rBOXL7D+/kg4G6mUVNmXdc6ndVXI8JnLb5Y2qfpixrF8qt6zaAaZ/SXsWtKTRyf2fBlWzeA==
X-Received: by 2002:a02:764c:: with SMTP id z73-v6mr4231401jab.73.1540312514179;
        Tue, 23 Oct 2018 09:35:14 -0700 (PDT)
Received: from localhost.localdomain (c-68-40-195-73.hsd1.mi.comcast.net. [68.40.195.73])
        by smtp.gmail.com with ESMTPSA id w20-v6sm573065ioa.82.2018.10.23.09.35.13
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 23 Oct 2018 09:35:13 -0700 (PDT)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     linux-nfs@vger.kernel.org
Subject: [PATCH 2/4] SUNRPC: Simplify lookup code
Date:   Tue, 23 Oct 2018 12:34:02 -0400
Message-Id: <20181023163404.27777-2-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.17.2
In-Reply-To: <20181023163404.27777-1-trond.myklebust@hammerspace.com>
References: <20181023163404.27777-1-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

We no longer need to worry about whether or not the entry is hashed in
order to figure out if the contents are valid. We only care whether or
not the refcount is non-zero.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 include/linux/sunrpc/auth.h | 12 +++++-------
 net/sunrpc/auth.c           | 19 ++++++++-----------
 2 files changed, 13 insertions(+), 18 deletions(-)

diff --git a/include/linux/sunrpc/auth.h b/include/linux/sunrpc/auth.h
index 2c97a3933ef9..a7fc8f5a2dad 100644
--- a/include/linux/sunrpc/auth.h
+++ b/include/linux/sunrpc/auth.h
@@ -206,11 +206,11 @@ bool			rpcauth_cred_key_to_expire(struct rpc_auth *, struct rpc_cred *);
 char *			rpcauth_stringify_acceptor(struct rpc_cred *);
 
 static inline
-struct rpc_cred *	get_rpccred(struct rpc_cred *cred)
+struct rpc_cred *get_rpccred(struct rpc_cred *cred)
 {
-	if (cred != NULL)
-		atomic_inc(&cred->cr_count);
-	return cred;
+	if (cred != NULL && atomic_inc_not_zero(&cred->cr_count))
+		return cred;
+	return NULL;
 }
 
 /**
@@ -226,9 +226,7 @@ struct rpc_cred *	get_rpccred(struct rpc_cred *cred)
 static inline struct rpc_cred *
 get_rpccred_rcu(struct rpc_cred *cred)
 {
-	if (atomic_inc_not_zero(&cred->cr_count))
-		return cred;
-	return NULL;
+	return get_rpccred(cred);
 }
 
 #endif /* __KERNEL__ */
diff --git a/net/sunrpc/auth.c b/net/sunrpc/auth.c
index c1576b110974..77748e572686 100644
--- a/net/sunrpc/auth.c
+++ b/net/sunrpc/auth.c
@@ -588,19 +588,15 @@ rpcauth_lookup_credcache(struct rpc_auth *auth, struct auth_cred * acred,
 		if (!entry->cr_ops->crmatch(acred, entry, flags))
 			continue;
 		if (flags & RPCAUTH_LOOKUP_RCU) {
-			if (test_bit(RPCAUTH_CRED_HASHED, &entry->cr_flags) &&
-			    !test_bit(RPCAUTH_CRED_NEW, &entry->cr_flags))
-				cred = entry;
+			if (test_bit(RPCAUTH_CRED_NEW, &entry->cr_flags) ||
+			    atomic_read(&entry->cr_count) == 0)
+				continue;
+			cred = entry;
 			break;
 		}
-		spin_lock(&cache->lock);
-		if (test_bit(RPCAUTH_CRED_HASHED, &entry->cr_flags) == 0) {
-			spin_unlock(&cache->lock);
-			continue;
-		}
 		cred = get_rpccred(entry);
-		spin_unlock(&cache->lock);
-		break;
+		if (cred)
+			break;
 	}
 	rcu_read_unlock();
 
@@ -621,7 +617,8 @@ rpcauth_lookup_credcache(struct rpc_auth *auth, struct auth_cred * acred,
 		if (!entry->cr_ops->crmatch(acred, entry, flags))
 			continue;
 		cred = get_rpccred(entry);
-		break;
+		if (cred)
+			break;
 	}
 	if (cred == NULL) {
 		cred = new;
-- 
2.17.2


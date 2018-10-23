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
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8F07BC46475
	for <linux-nfs@archiver.kernel.org>; Tue, 23 Oct 2018 16:35:17 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 54C3020652
	for <linux-nfs@archiver.kernel.org>; Tue, 23 Oct 2018 16:35:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="ChntdTfZ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 54C3020652
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728259AbeJXA7X (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 23 Oct 2018 20:59:23 -0400
Received: from mail-it1-f196.google.com ([209.85.166.196]:53029 "EHLO
        mail-it1-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727402AbeJXA7X (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 23 Oct 2018 20:59:23 -0400
Received: by mail-it1-f196.google.com with SMTP id 134-v6so2647745itz.2
        for <linux-nfs@vger.kernel.org>; Tue, 23 Oct 2018 09:35:15 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=AGzVrNyvQxT4e0ShzHAkd+qHSRExjetCeA7b4UwYbFg=;
        b=ChntdTfZEBSY6WGZFG6ss2EWLMIpn9rz4Hauerh6QVplSRzCUZxOPBoR1SyI7+I4wf
         sxTTaOfLUwi0oY1waStwd2kuxq5tKtKKLxs2+GFfoM5bL1VKLz46YjooG+Y8Qrd/4RxK
         Rzi+Jv5DuHpNmeSRHQoygxXAwZ68+dAzK9GGxKac9WQkEgHSvAFVxFLdFPjLfDNIJYt1
         7S0mtc1L6B3aLWbCA/6sniZuKkfZpjHYw9FFYn1IHK9q+ejp6Vu0UPYRJkxRMoV7+1QD
         +YyJw5+6drLpl+7p8ZddxrM77PdaFNv6keP6bUJZDlLEtKRMlAR62Gh9iVwxw2UdFKNj
         1t8w==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=AGzVrNyvQxT4e0ShzHAkd+qHSRExjetCeA7b4UwYbFg=;
        b=SUrIS+3PlRzOBlU3ChVLtqi7tR8BCVjR4/DBWL/NZyuWbsPbB/AhMr+/ehNyT4M6JB
         ETFgysrF0B2j3fXqvNkhTa4mZrvoJkwa3O98rgBcZ8BzDp6ekGPAZO6thsp9EmPxmluf
         hNr4UljnENyCAf210car8bu3pu16hMGuZSqUkkjmFHWewnwFZqBRfp8+FvirQkEDZfHV
         tcbz77uEJxZlugB/JsvovFwfRaRn9HklYVTt1aIsHVfRpqITj579f0mJoEvpOUBb1tG4
         9ZillelNbStadqdvs6mkWpmyXllaPio4bwALj/2aYHq0zZyxWZSWHDfUCL1kAZcQRnT/
         9DYQ==
X-Gm-Message-State: ABuFfojx5CRWp1WmvdXnx8952UO+YOluPT7rUS8dfHbkGfpnzSvQspHe
        b5LE1UQItUzP+1mzZQK1mKQahTo=
X-Google-Smtp-Source: ACcGV62Mb+014WVeY5QKxEqdiPS0cxA9302yFRh0hnVpWZKs7+98C/ekxtwaSsr/ZWoWwzyW/8L9cQ==
X-Received: by 2002:a24:9b83:: with SMTP id o125-v6mr6741755itd.66.1540312514968;
        Tue, 23 Oct 2018 09:35:14 -0700 (PDT)
Received: from localhost.localdomain (c-68-40-195-73.hsd1.mi.comcast.net. [68.40.195.73])
        by smtp.gmail.com with ESMTPSA id w20-v6sm573065ioa.82.2018.10.23.09.35.14
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 23 Oct 2018 09:35:14 -0700 (PDT)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     linux-nfs@vger.kernel.org
Subject: [PATCH 3/4] SUNRPC: Convert auth creds to use refcount_t
Date:   Tue, 23 Oct 2018 12:34:03 -0400
Message-Id: <20181023163404.27777-3-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.17.2
In-Reply-To: <20181023163404.27777-2-trond.myklebust@hammerspace.com>
References: <20181023163404.27777-1-trond.myklebust@hammerspace.com>
 <20181023163404.27777-2-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 include/linux/sunrpc/auth.h |  4 ++--
 net/sunrpc/auth.c           | 14 +++++++-------
 net/sunrpc/auth_null.c      |  2 +-
 3 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/include/linux/sunrpc/auth.h b/include/linux/sunrpc/auth.h
index a7fc8f5a2dad..a71d4bd191e7 100644
--- a/include/linux/sunrpc/auth.h
+++ b/include/linux/sunrpc/auth.h
@@ -67,7 +67,7 @@ struct rpc_cred {
 	const struct rpc_credops *cr_ops;
 	unsigned long		cr_expire;	/* when to gc */
 	unsigned long		cr_flags;	/* various flags */
-	atomic_t		cr_count;	/* ref count */
+	refcount_t		cr_count;	/* ref count */
 
 	kuid_t			cr_uid;
 
@@ -208,7 +208,7 @@ char *			rpcauth_stringify_acceptor(struct rpc_cred *);
 static inline
 struct rpc_cred *get_rpccred(struct rpc_cred *cred)
 {
-	if (cred != NULL && atomic_inc_not_zero(&cred->cr_count))
+	if (cred != NULL && refcount_inc_not_zero(&cred->cr_count))
 		return cred;
 	return NULL;
 }
diff --git a/net/sunrpc/auth.c b/net/sunrpc/auth.c
index 77748e572686..4903eda5dd61 100644
--- a/net/sunrpc/auth.c
+++ b/net/sunrpc/auth.c
@@ -495,7 +495,7 @@ rpcauth_prune_expired(struct list_head *free, int nr_to_scan)
 
 		if (nr_to_scan-- == 0)
 			break;
-		if (atomic_read(&cred->cr_count) > 1) {
+		if (refcount_read(&cred->cr_count) > 1) {
 			rpcauth_lru_remove_locked(cred);
 			continue;
 		}
@@ -589,7 +589,7 @@ rpcauth_lookup_credcache(struct rpc_auth *auth, struct auth_cred * acred,
 			continue;
 		if (flags & RPCAUTH_LOOKUP_RCU) {
 			if (test_bit(RPCAUTH_CRED_NEW, &entry->cr_flags) ||
-			    atomic_read(&entry->cr_count) == 0)
+			    refcount_read(&entry->cr_count) == 0)
 				continue;
 			cred = entry;
 			break;
@@ -623,7 +623,7 @@ rpcauth_lookup_credcache(struct rpc_auth *auth, struct auth_cred * acred,
 	if (cred == NULL) {
 		cred = new;
 		set_bit(RPCAUTH_CRED_HASHED, &cred->cr_flags);
-		atomic_inc(&cred->cr_count);
+		refcount_inc(&cred->cr_count);
 		hlist_add_head_rcu(&cred->cr_hash, &cache->hashtable[nr]);
 	} else
 		list_add_tail(&new->cr_lru, &free);
@@ -670,7 +670,7 @@ rpcauth_init_cred(struct rpc_cred *cred, const struct auth_cred *acred,
 {
 	INIT_HLIST_NODE(&cred->cr_hash);
 	INIT_LIST_HEAD(&cred->cr_lru);
-	atomic_set(&cred->cr_count, 1);
+	refcount_set(&cred->cr_count, 1);
 	cred->cr_auth = auth;
 	cred->cr_ops = ops;
 	cred->cr_expire = jiffies;
@@ -739,9 +739,9 @@ put_rpccred(struct rpc_cred *cred)
 	if (cred == NULL)
 		return;
 	rcu_read_lock();
-	if (atomic_dec_and_test(&cred->cr_count))
+	if (refcount_dec_and_test(&cred->cr_count))
 		goto destroy;
-	if (atomic_read(&cred->cr_count) != 1 ||
+	if (refcount_read(&cred->cr_count) != 1 ||
 	    !test_bit(RPCAUTH_CRED_HASHED, &cred->cr_flags))
 		goto out;
 	if (test_bit(RPCAUTH_CRED_UPTODATE, &cred->cr_flags) != 0) {
@@ -752,7 +752,7 @@ put_rpccred(struct rpc_cred *cred)
 			rpcauth_lru_remove(cred);
 	} else if (rpcauth_unhash_cred(cred)) {
 		rpcauth_lru_remove(cred);
-		if (atomic_dec_and_test(&cred->cr_count))
+		if (refcount_dec_and_test(&cred->cr_count))
 			goto destroy;
 	}
 out:
diff --git a/net/sunrpc/auth_null.c b/net/sunrpc/auth_null.c
index a7c00b4959f3..ea816d7000a4 100644
--- a/net/sunrpc/auth_null.c
+++ b/net/sunrpc/auth_null.c
@@ -138,6 +138,6 @@ struct rpc_cred null_cred = {
 	.cr_lru		= LIST_HEAD_INIT(null_cred.cr_lru),
 	.cr_auth	= &null_auth,
 	.cr_ops		= &null_credops,
-	.cr_count	= ATOMIC_INIT(2),
+	.cr_count	= REFCOUNT_INIT(2),
 	.cr_flags	= 1UL << RPCAUTH_CRED_UPTODATE,
 };
-- 
2.17.2


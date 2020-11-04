Return-Path: <SRS0=n/TU=EK=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-12.6 required=3.0 tests=BAYES_00,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9B77FC55179
	for <linux-nfs@archiver.kernel.org>; Wed,  4 Nov 2020 16:27:19 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 46268206DB
	for <linux-nfs@archiver.kernel.org>; Wed,  4 Nov 2020 16:27:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="AQIoWqwx"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1731232AbgKDQ1R (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 4 Nov 2020 11:27:17 -0500
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:36144 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1731220AbgKDQ1P (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 4 Nov 2020 11:27:15 -0500
Received: from mail-qv1-xf43.google.com (mail-qv1-xf43.google.com [IPv6:2607:f8b0:4864:20::f43])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id C1E5DC0613D3
        for <linux-nfs@vger.kernel.org>; Wed,  4 Nov 2020 08:27:14 -0800 (PST)
Received: by mail-qv1-xf43.google.com with SMTP id i17so8100226qvp.11
        for <linux-nfs@vger.kernel.org>; Wed, 04 Nov 2020 08:27:14 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=ODBqyBWEMtA4MaYYlZB5CrxKv2YKgiVoECc3FXd34GI=;
        b=AQIoWqwxydda1r/0fSLXicqjE9Cl17R6Cya7jUxQLtcuVtYYm8fSsL9H3SD/HvUqEe
         YsabFB9yLVDiOGJ/PT3f7/0TVMIli2jCHwUpkmb6jVKXs0iUjpmwEqfr4FaYsFbdmbUM
         +DNqsFVkQUXwNenLtOOOPpJWKUDVaDlSakTL7knKmb0tyEwdWq1Ozgi/8Et2sJKi8I2A
         E9NrmoCIv7fowSiX/D1nXPweKZpyOAlg5TN+r5UNbWofvs2jcnmObq81Q93c09Gac2YX
         26YdiJSVyrP9Ku/KDrrEVVMJBbm3smGeP9a8nqWECgquqHQAsnv9wNaMaRavEpOgwWpd
         jlFQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=ODBqyBWEMtA4MaYYlZB5CrxKv2YKgiVoECc3FXd34GI=;
        b=m5Wa9o+DEOJ2J0hRkuUkSx+x4zGTLBMkvwx0FzbrwdNqOocMDn0A6gxhxD5rlSpxBe
         lKNaoE0JmBqoGxlwzOdVscIkCJtR3ISARIEMTuOd39vBUWuMNWjJdvBudz6JEbqq21RH
         gJFnVcD/D5Z62p9uwQr/V2liXRDqKjBEfaR4JvaSOpBPV5Jd4IXx46hTqP+0qssYKALc
         Q9e6I4ivZhTB++CSCOTc65QwzG24iIhQmJ9Lv/lSP9aJquMYrDsUTCdeNFrNwWcNvIhO
         YucdCSauCkAKcozaoFXPe9NxQF+gfckAWMFEguFQRWBFceO2yCtwb2j+fNHEOkiA4WHE
         maLA==
X-Gm-Message-State: AOAM533LRxefFnwYTq8XwD0/nTNjQ3tgwmgxiyPg7y63mozIdAYVuM0s
        owg5duP2iMXKLgXjkSa55azbcgINciJu
X-Google-Smtp-Source: ABdhPJz1AN9JyJVj+Ts+7exxv/3AUHsb8e4VNp63aqokh4fVjcKTHQ7WieRYtd4jtLc+hKwwbQFFCg==
X-Received: by 2002:a0c:a5a2:: with SMTP id z31mr34682746qvz.15.1604507233602;
        Wed, 04 Nov 2020 08:27:13 -0800 (PST)
Received: from localhost.localdomain (c-68-36-133-222.hsd1.mi.comcast.net. [68.36.133.222])
        by smtp.gmail.com with ESMTPSA id g78sm2896924qke.88.2020.11.04.08.27.12
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 04 Nov 2020 08:27:12 -0800 (PST)
From:   trondmy@gmail.com
X-Google-Original-From: trond.myklebust@hammerspace.com
To:     linux-nfs@vger.kernel.org
Subject: [PATCH v3 11/17] NFS: nfs_do_filldir() does not return a value
Date:   Wed,  4 Nov 2020 11:16:32 -0500
Message-Id: <20201104161638.300324-12-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.28.0
In-Reply-To: <20201104161638.300324-11-trond.myklebust@hammerspace.com>
References: <20201104161638.300324-1-trond.myklebust@hammerspace.com>
 <20201104161638.300324-2-trond.myklebust@hammerspace.com>
 <20201104161638.300324-3-trond.myklebust@hammerspace.com>
 <20201104161638.300324-4-trond.myklebust@hammerspace.com>
 <20201104161638.300324-5-trond.myklebust@hammerspace.com>
 <20201104161638.300324-6-trond.myklebust@hammerspace.com>
 <20201104161638.300324-7-trond.myklebust@hammerspace.com>
 <20201104161638.300324-8-trond.myklebust@hammerspace.com>
 <20201104161638.300324-9-trond.myklebust@hammerspace.com>
 <20201104161638.300324-10-trond.myklebust@hammerspace.com>
 <20201104161638.300324-11-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Trond Myklebust <trond.myklebust@hammerspace.com>

Clean up nfs_do_filldir().

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/dir.c | 21 +++++++--------------
 1 file changed, 7 insertions(+), 14 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index bc366bd8e8f3..48856cee10de 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -881,13 +881,11 @@ int readdir_search_pagecache(nfs_readdir_descriptor_t *desc)
 /*
  * Once we've found the start of the dirent within a page: fill 'er up...
  */
-static 
-int nfs_do_filldir(nfs_readdir_descriptor_t *desc)
+static void nfs_do_filldir(struct nfs_readdir_descriptor *desc)
 {
 	struct file	*file = desc->file;
-	int i = 0;
-	int res = 0;
-	struct nfs_cache_array *array = NULL;
+	struct nfs_cache_array *array;
+	unsigned int i = 0;
 
 	array = kmap(desc->page);
 	for (i = desc->cache_entry_index; i < array->size; i++) {
@@ -914,9 +912,8 @@ int nfs_do_filldir(nfs_readdir_descriptor_t *desc)
 		desc->eof = true;
 
 	kunmap(desc->page);
-	dfprintk(DIRCACHE, "NFS: nfs_do_filldir() filling ended @ cookie %Lu; returning = %d\n",
-			(unsigned long long)desc->dir_cookie, res);
-	return res;
+	dfprintk(DIRCACHE, "NFS: nfs_do_filldir() filling ended @ cookie %llu\n",
+			(unsigned long long)desc->dir_cookie);
 }
 
 /*
@@ -957,7 +954,7 @@ int uncached_readdir(nfs_readdir_descriptor_t *desc)
 	if (status < 0)
 		goto out_release;
 
-	status = nfs_do_filldir(desc);
+	nfs_do_filldir(desc);
 
  out_release:
 	nfs_readdir_clear_array(desc->page);
@@ -1032,10 +1029,8 @@ static int nfs_readdir(struct file *file, struct dir_context *ctx)
 		if (res < 0)
 			break;
 
-		res = nfs_do_filldir(desc);
+		nfs_do_filldir(desc);
 		nfs_readdir_page_unlock_and_put_cached(desc);
-		if (res < 0)
-			break;
 	} while (!desc->eof);
 
 	spin_lock(&file->f_lock);
@@ -1046,8 +1041,6 @@ static int nfs_readdir(struct file *file, struct dir_context *ctx)
 	spin_unlock(&file->f_lock);
 
 out:
-	if (res > 0)
-		res = 0;
 	dfprintk(FILE, "NFS: readdir(%pD2) returns %d\n", file, res);
 	return res;
 }
-- 
2.28.0


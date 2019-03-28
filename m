Return-Path: <SRS0=umLH=R7=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D008DC43381
	for <linux-nfs@archiver.kernel.org>; Thu, 28 Mar 2019 20:56:26 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id A11402184E
	for <linux-nfs@archiver.kernel.org>; Thu, 28 Mar 2019 20:56:26 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="TvDmu9e9"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727539AbfC1U4Z (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 28 Mar 2019 16:56:25 -0400
Received: from mail-it1-f194.google.com ([209.85.166.194]:35549 "EHLO
        mail-it1-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726769AbfC1U4Z (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 28 Mar 2019 16:56:25 -0400
Received: by mail-it1-f194.google.com with SMTP id w15so506342itc.0
        for <linux-nfs@vger.kernel.org>; Thu, 28 Mar 2019 13:56:24 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=q8TSoPO9kXJFJoeGK9oXZX+ELAH+5w6/Bv+37JBTH1s=;
        b=TvDmu9e9cTraNmmZE9fxbQv6z2JBDI8qKJ2JGe6zSXAAI1Bb2TyfTjkHuG2PA47qVW
         ydvD8AknRy8pJ0nW3I5r1EiMH3fsUYd38VI+00sCp0BI8KNHOTxV5pE49Nmm5/ou5lab
         THB0GuxRwAXIIvthahQ5/BgdTrE9UxWYodrY2bxK2VDUXmhTDjryzmIUsb3zsqqohfMZ
         o1UOHYL8Wxn4Pn3r8K9CR45Hk5DQoDHjzyAk7k1ZKvYJhA+Q1lEBYW71GlD85Xi6/5gE
         lkzqNOUhQ4anZuNnKpysjeTc/5a7nDZ28Ch/nNWvN9zjjynW6d0y3UQR3HANLU/+7nqd
         X1OQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=q8TSoPO9kXJFJoeGK9oXZX+ELAH+5w6/Bv+37JBTH1s=;
        b=Pa6UItGu6H9PzzDPsoxjCV4ZNhhJXAimb0LmZ8NB7BCGG+2p8grg2F6QvajmuGtUK8
         /8gCILc6fvCdbv5zF9OZED/ebZP8ve2cRc2PUe6ufngUkaXlfrZ7jPNMYwtBz2qfxnMB
         ylzBhly0nrvq7UFh35mpqokgwF3l8BLnTClYrtY5VMa4kXPgv/WM2f4+0wyXCJeAt4+P
         t/DSAbAjg11SSHt/C1gwWesF7uKIqLlrr2hEOmRWffWS5HWBOpWsvxg1Gmg+Fepad2dc
         l9ji6m1kEfuDdKmR5eW5qROMZL5W8s4eR+m+vM+6x+lB79bezvQ5Ut4k7bl1BpGKBIR7
         RCPQ==
X-Gm-Message-State: APjAAAXYx7Poj9LbJBZa0Lb7Sr3EjFr+K8yznEl40/lWHyLiH2vobP1D
        ULeemLyDF7P/AeMRCc+kKB6w66w=
X-Google-Smtp-Source: APXvYqzwiSayTg/LJPCeeXqXYgSTt+6M0FUvv612OoKCz8O1s/mugjs/8xh1KhXHu/fPv5ETkb75Sg==
X-Received: by 2002:a02:938f:: with SMTP id z15mr16623826jah.108.1553806584060;
        Thu, 28 Mar 2019 13:56:24 -0700 (PDT)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id t67sm1084750ita.35.2019.03.28.13.56.23
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 28 Mar 2019 13:56:23 -0700 (PDT)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     linux-nfs@vger.kernel.org
Subject: [PATCH 17/25] NFS: Don't call generic_error_remove_page() while holding locks
Date:   Thu, 28 Mar 2019 16:52:31 -0400
Message-Id: <20190328205239.29674-18-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190328205239.29674-17-trond.myklebust@hammerspace.com>
References: <20190328205239.29674-1-trond.myklebust@hammerspace.com>
 <20190328205239.29674-2-trond.myklebust@hammerspace.com>
 <20190328205239.29674-3-trond.myklebust@hammerspace.com>
 <20190328205239.29674-4-trond.myklebust@hammerspace.com>
 <20190328205239.29674-5-trond.myklebust@hammerspace.com>
 <20190328205239.29674-6-trond.myklebust@hammerspace.com>
 <20190328205239.29674-7-trond.myklebust@hammerspace.com>
 <20190328205239.29674-8-trond.myklebust@hammerspace.com>
 <20190328205239.29674-9-trond.myklebust@hammerspace.com>
 <20190328205239.29674-10-trond.myklebust@hammerspace.com>
 <20190328205239.29674-11-trond.myklebust@hammerspace.com>
 <20190328205239.29674-12-trond.myklebust@hammerspace.com>
 <20190328205239.29674-13-trond.myklebust@hammerspace.com>
 <20190328205239.29674-14-trond.myklebust@hammerspace.com>
 <20190328205239.29674-15-trond.myklebust@hammerspace.com>
 <20190328205239.29674-16-trond.myklebust@hammerspace.com>
 <20190328205239.29674-17-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

The NFS read code can trigger writeback while holding the page lock.
If an error then triggers a call to nfs_write_error_remove_page(),
we can deadlock.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/write.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 9198a23bb58b..64cf6a340ba6 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -584,9 +584,8 @@ nfs_lock_and_join_requests(struct page *page)
 
 static void nfs_write_error_remove_page(struct nfs_page *req)
 {
+	SetPageError(req->wb_page);
 	nfs_end_page_writeback(req);
-	generic_error_remove_page(page_file_mapping(req->wb_page),
-				  req->wb_page);
 	nfs_release_request(req);
 }
 
-- 
2.20.1


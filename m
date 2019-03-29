Return-Path: <SRS0=26It=SA=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 145CFC43381
	for <linux-nfs@archiver.kernel.org>; Fri, 29 Mar 2019 22:02:15 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id D52992184D
	for <linux-nfs@archiver.kernel.org>; Fri, 29 Mar 2019 22:02:14 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="JR8fk4D9"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1730360AbfC2WCO (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 29 Mar 2019 18:02:14 -0400
Received: from mail-it1-f193.google.com ([209.85.166.193]:36182 "EHLO
        mail-it1-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1730345AbfC2WCN (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 29 Mar 2019 18:02:13 -0400
Received: by mail-it1-f193.google.com with SMTP id y10so4316092itc.1
        for <linux-nfs@vger.kernel.org>; Fri, 29 Mar 2019 15:02:13 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=ZNzFiMu8itV3v5Vrx3+5yHnGrXhs8IiM/vQEXnDIaCE=;
        b=JR8fk4D9opBFQVAZritYCRtICwb7jDM+SKMoBW5jtdJzZ+xaZId7pW8UPrbTbyfKOV
         1jCBh6p7J4Hj8sSL5cSgw0Ifc7L2dNMe6fljU/Tp2dSkfoVES1OzpTrqaGQcpxW0urpm
         zhTvv/WnIzF64OKaXqo7n6iNTn5CppJUu0tTOprnutVCSNecz7OsmdhJdD3z53TfoIFb
         /91T8DRzzcUZXNYIDPPZoY/eMJZOMAOT9vL06W3qDVR7lT2DEG98qxkdMexSTxXj48yh
         4nybr9C7RRVGfFWP+Qy20bXzSawRouoBCtAzZEsLae886jaTrVu4AbBopJaaitGHd04e
         ApJA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=ZNzFiMu8itV3v5Vrx3+5yHnGrXhs8IiM/vQEXnDIaCE=;
        b=K72/1rye1eM5nJTIt+7ryWtdJ9fP8CW12Rs45lUEi0ISz+uPx6PJKWTIsBBBG929NU
         kJ7KZcWYij4t0SzosJYLWjQvHXuHxmLCoPlTaa3xCd5IUF9GWnhZGsdl9VvH37KeaKwP
         YcYxjdkvbiM9DW+h4eDWkPNxaZ33V/0+gGVPBuoGoLYb9K+uWsCJMH0iz5Jee4JMyvcH
         G7jjocMZr+Wue86njqMLiuPNt2CoSOW6Ukovs21BvXVgq2GFd7hQfhCNf47f2jrsUog1
         55DgPRxFh9nNAgvXyW9z5LGOluYgCQHtNqej/xgN4oguA+5zcHkwvf83inMdChX2LnHZ
         JGJQ==
X-Gm-Message-State: APjAAAVj/kaK3nPPO058Il5haGDK0x/LGUgkQTzylvFgcSJNNGiL4sZ0
        ZoCMY76WvdNavnGIN9ZxMdY3Wvw=
X-Google-Smtp-Source: APXvYqzGt5ob1gw7Ba4POjotldGhmyIkzYCyM0AAASxl4lREz1TAqwqa6rRXrK8c+8GEcg7j2AAl2g==
X-Received: by 2002:a05:660c:18b:: with SMTP id v11mr6065143itj.147.1553896932432;
        Fri, 29 Mar 2019 15:02:12 -0700 (PDT)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id v20sm1376796ioh.17.2019.03.29.15.02.11
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 29 Mar 2019 15:02:11 -0700 (PDT)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     linux-nfs@vger.kernel.org
Subject: [PATCH v2 19/28] NFS: Don't interrupt file writeout due to fatal errors
Date:   Fri, 29 Mar 2019 17:59:39 -0400
Message-Id: <20190329215948.107328-20-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190329215948.107328-19-trond.myklebust@hammerspace.com>
References: <20190329215948.107328-1-trond.myklebust@hammerspace.com>
 <20190329215948.107328-2-trond.myklebust@hammerspace.com>
 <20190329215948.107328-3-trond.myklebust@hammerspace.com>
 <20190329215948.107328-4-trond.myklebust@hammerspace.com>
 <20190329215948.107328-5-trond.myklebust@hammerspace.com>
 <20190329215948.107328-6-trond.myklebust@hammerspace.com>
 <20190329215948.107328-7-trond.myklebust@hammerspace.com>
 <20190329215948.107328-8-trond.myklebust@hammerspace.com>
 <20190329215948.107328-9-trond.myklebust@hammerspace.com>
 <20190329215948.107328-10-trond.myklebust@hammerspace.com>
 <20190329215948.107328-11-trond.myklebust@hammerspace.com>
 <20190329215948.107328-12-trond.myklebust@hammerspace.com>
 <20190329215948.107328-13-trond.myklebust@hammerspace.com>
 <20190329215948.107328-14-trond.myklebust@hammerspace.com>
 <20190329215948.107328-15-trond.myklebust@hammerspace.com>
 <20190329215948.107328-16-trond.myklebust@hammerspace.com>
 <20190329215948.107328-17-trond.myklebust@hammerspace.com>
 <20190329215948.107328-18-trond.myklebust@hammerspace.com>
 <20190329215948.107328-19-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

When flushing out dirty pages, the fact that we may hit fatal errors
is not a reason to stop writeback. Those errors are reported through
fsync(), not through the flush mechanism.

Fixes: a6598813a4c5b ("NFS: Don't write back further requests if there...")
Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/write.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index f3ebabaa291d..9198a23bb58b 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -647,7 +647,7 @@ static int nfs_page_async_flush(struct nfs_pageio_descriptor *pgio,
 	return ret;
 out_launder:
 	nfs_write_error_remove_page(req);
-	return ret;
+	return 0;
 }
 
 static int nfs_do_writepage(struct page *page, struct writeback_control *wbc,
-- 
2.20.1


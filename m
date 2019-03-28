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
	by smtp.lore.kernel.org (Postfix) with ESMTP id BCB57C10F06
	for <linux-nfs@archiver.kernel.org>; Thu, 28 Mar 2019 20:56:25 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 8D09D2184E
	for <linux-nfs@archiver.kernel.org>; Thu, 28 Mar 2019 20:56:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="KBP3DWzR"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726410AbfC1U4Y (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 28 Mar 2019 16:56:24 -0400
Received: from mail-it1-f193.google.com ([209.85.166.193]:38672 "EHLO
        mail-it1-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727533AbfC1U4Y (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 28 Mar 2019 16:56:24 -0400
Received: by mail-it1-f193.google.com with SMTP id f22so477146ita.3
        for <linux-nfs@vger.kernel.org>; Thu, 28 Mar 2019 13:56:24 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=ZNzFiMu8itV3v5Vrx3+5yHnGrXhs8IiM/vQEXnDIaCE=;
        b=KBP3DWzRMq5mbNvaZHPbEskJkryOQEkgr4qlSFe4Wf6f4bp38EJw5Tjqe4gxTnFkcW
         pgATsE/v691VTP3W6a0AtYvIB+iGx4XBlpqh83C9QOK1wXzAfd9MVC9Oz0F6ZikYQSbp
         dXKRZ1hC+I4reP/eUCf1Vn3Xcf9JMXBkgXdjSgAlw2Ym3Xx3lltk4mshmfe0nUFeWA/B
         FPh+RTyC1q9q1dp54jpe6fvnxnD/dZSEJWm/VjCAVXJexB/Efq9IqWGvyoole+zsWbp4
         ylQNc0pSliSo6IVAGz13eHUk/ikmSW0O5Wu7eDRa3Za/hl2wo/RToqqDCsSpbUPxQEpD
         Nerg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=ZNzFiMu8itV3v5Vrx3+5yHnGrXhs8IiM/vQEXnDIaCE=;
        b=h5AFFmdpWd9TGkAa3EgNOX/ZDQxfqOM7d+vYELJbVOqhNtevZ7hY/rl4jet8fhBjxM
         G7WBD6bvdKjJgSL/k6FmW5l7ZEuYLGLKYKSCNtSjPGiyzlnBlZXRDn2UKUpX2ffcW7f7
         3GJs2X7n1jAnbTjPeKBd4YuyY0wAMaiN62Bergui5BhJcVfCetdzNFvHskF+6Zs7dbP6
         DucGNafluydEL6U/s6ePFNPBo26WlyDkvNIFRCEfITtRp33HblE/kLK/0g5WOpq+AM3N
         Jh81qjdI64+MnwvW6zN9RWCjcWFoB3B5BAqeixArlYgFfUiiWLJrS8ifKdPhN/te3ZgU
         vznA==
X-Gm-Message-State: APjAAAWNk3c3CtYSIayKPgOCVLGFBPnXrA1EAz23bqSpgqeAOlQIegZ2
        FZIh7D+85UInRjY4Fcf/QTT3pXk=
X-Google-Smtp-Source: APXvYqx49m3bV0EWSDAo9Or16FsUlkI6b/CZYylJVB7GFsot0bn1ts9w+BldTc2Tgf32vDxspNJ6ig==
X-Received: by 2002:a02:c955:: with SMTP id u21mr16476062jao.105.1553806583272;
        Thu, 28 Mar 2019 13:56:23 -0700 (PDT)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id t67sm1084750ita.35.2019.03.28.13.56.22
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 28 Mar 2019 13:56:22 -0700 (PDT)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     linux-nfs@vger.kernel.org
Subject: [PATCH 16/25] NFS: Don't interrupt file writeout due to fatal errors
Date:   Thu, 28 Mar 2019 16:52:30 -0400
Message-Id: <20190328205239.29674-17-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190328205239.29674-16-trond.myklebust@hammerspace.com>
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


Return-Path: <SRS0=hGI+=SJ=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5E3EAC282DE
	for <linux-nfs@archiver.kernel.org>; Sun,  7 Apr 2019 18:01:42 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 31CC020896
	for <linux-nfs@archiver.kernel.org>; Sun,  7 Apr 2019 18:01:42 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="jFUh7rVp"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726462AbfDGSBl (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sun, 7 Apr 2019 14:01:41 -0400
Received: from mail-io1-f66.google.com ([209.85.166.66]:46241 "EHLO
        mail-io1-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726466AbfDGSBl (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 7 Apr 2019 14:01:41 -0400
Received: by mail-io1-f66.google.com with SMTP id p23so8460648iol.13
        for <linux-nfs@vger.kernel.org>; Sun, 07 Apr 2019 11:01:40 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=ZNzFiMu8itV3v5Vrx3+5yHnGrXhs8IiM/vQEXnDIaCE=;
        b=jFUh7rVpzG/n68NXP7Ykyho7oaFlPVMoW21KId2hm9InDsj4n49nD1JrjPAY+Qhf7m
         s3cgoGuNFbJ2jvf1mbRly79ebja+twCcMBClAzxJg5TX98BfNz3c2HXloQ1mY3lNwnXR
         kyKD9Sl5Vlf8W22SzwqcDZ2hr5ofGRKlLbpplCHBTCSrKJXO4gg/hfU78FIcLByE67bo
         iLzwJvd4s41VPNCs1ShLnJ5THjbN/A6kvizEcH5flU5THIUwPGFF9K5ACr83dj+4STyc
         3oWIbv8iMeXlfa1onzkqAHJgOUokwZVdp1St3cySLR7aRweb8ZbWWiCnpVnATJFzQqDd
         Xrfw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=ZNzFiMu8itV3v5Vrx3+5yHnGrXhs8IiM/vQEXnDIaCE=;
        b=ctps1L1veAgR5t2CCd67PkijlSIB3CxTOaMFyLFBMssLeEiMvr5MR9jog7TodfGew0
         fc4bKZ0/jX5XMHBhdNCo0Jbk7qOjLdAnDboEHPGKysskQGe8BtS+6q5eESOoEqXwRR2X
         dKD+VZunT0Y0hbELoRG3AoQgW715CYHxzRJ8x/ruPnSw/vkqi7Y3ZLFTgxjqKaBsGQ9M
         /0tYmiJ0jMqq2hfip71+XWPel7whsZfj5AveyhyMDI49IzH1xD9JXTHVGln2VCwBznF0
         hqJ5kfPBUgdRULD8hpKcZenPTX2GmV6OUGKMxIc6xH+zYCFo3x88JW2qVYKobU9+LjAf
         9Suw==
X-Gm-Message-State: APjAAAXjgAhTdCVvdVHNEBx2ijhl1Q/gMblTIEnBvpsoNetjhVVM1me2
        FU/hDrvhgJsLoJMBzfn7Cg==
X-Google-Smtp-Source: APXvYqypkXOGa75vPPv7fA1k1t372ug9Gq5zE1XfvuB0eEPE+/iXXAv9p1GEPDhaDRjBi7DkxHIESw==
X-Received: by 2002:a5e:9805:: with SMTP id s5mr17173405ioj.149.1554660100345;
        Sun, 07 Apr 2019 11:01:40 -0700 (PDT)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id m6sm10807362ioj.36.2019.04.07.11.01.39
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 07 Apr 2019 11:01:39 -0700 (PDT)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     Anna Schumaker <Anna.Schumaker@netapp.com>
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH v3 19/29] NFS: Don't interrupt file writeout due to fatal errors
Date:   Sun,  7 Apr 2019 13:59:02 -0400
Message-Id: <20190407175912.23528-20-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190407175912.23528-19-trond.myklebust@hammerspace.com>
References: <20190407175912.23528-1-trond.myklebust@hammerspace.com>
 <20190407175912.23528-2-trond.myklebust@hammerspace.com>
 <20190407175912.23528-3-trond.myklebust@hammerspace.com>
 <20190407175912.23528-4-trond.myklebust@hammerspace.com>
 <20190407175912.23528-5-trond.myklebust@hammerspace.com>
 <20190407175912.23528-6-trond.myklebust@hammerspace.com>
 <20190407175912.23528-7-trond.myklebust@hammerspace.com>
 <20190407175912.23528-8-trond.myklebust@hammerspace.com>
 <20190407175912.23528-9-trond.myklebust@hammerspace.com>
 <20190407175912.23528-10-trond.myklebust@hammerspace.com>
 <20190407175912.23528-11-trond.myklebust@hammerspace.com>
 <20190407175912.23528-12-trond.myklebust@hammerspace.com>
 <20190407175912.23528-13-trond.myklebust@hammerspace.com>
 <20190407175912.23528-14-trond.myklebust@hammerspace.com>
 <20190407175912.23528-15-trond.myklebust@hammerspace.com>
 <20190407175912.23528-16-trond.myklebust@hammerspace.com>
 <20190407175912.23528-17-trond.myklebust@hammerspace.com>
 <20190407175912.23528-18-trond.myklebust@hammerspace.com>
 <20190407175912.23528-19-trond.myklebust@hammerspace.com>
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


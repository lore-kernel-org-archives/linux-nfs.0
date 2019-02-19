Return-Path: <SRS0=cCtV=Q2=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3FAE1C10F00
	for <linux-nfs@archiver.kernel.org>; Tue, 19 Feb 2019 13:55:18 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 0E9EC2147A
	for <linux-nfs@archiver.kernel.org>; Tue, 19 Feb 2019 13:55:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="FaLjLu4x"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726384AbfBSNzR (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 19 Feb 2019 08:55:17 -0500
Received: from mail-it1-f193.google.com ([209.85.166.193]:35122 "EHLO
        mail-it1-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725794AbfBSNzR (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 19 Feb 2019 08:55:17 -0500
Received: by mail-it1-f193.google.com with SMTP id v72so6329886itc.0
        for <linux-nfs@vger.kernel.org>; Tue, 19 Feb 2019 05:55:16 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=njCUfkgXUj/lPfViFXNEQbF8PDFKgBs5hgYZS/IoSVw=;
        b=FaLjLu4xMKqMkPCuTEJ36ptHJrCrHxoM5Mk0M0ZMiE1hGH9kdYZFsGgiAFhM9RzYYZ
         J7Amymo8OZ+PvoMdP7vjMK7vBNWu1w/gopimyqZefVLNcI6NG0d2VxCD6fpxOBmsdXXP
         DqZO5duF2O6UQ7Anrj4CzMRMeStet92nUgDqGu6/v/CaUM/ocuUnm/dNiVqcPoeATCjF
         F7hkcATqKDtmPTtlCSNn/XMt9UEW/QTZpqoxp+Sa2oDp81zgObQSuMI4EM3v5IxE0mCM
         NiLapkvpMzZEwmnPVW0ROj3kiwNVLAks88wRRRG2SaxwONWsNfgjCqRM/6Z8iMiFs+sv
         2Gjw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=njCUfkgXUj/lPfViFXNEQbF8PDFKgBs5hgYZS/IoSVw=;
        b=k/i3QsDK46TRirQuMyKrkloguw2mxHpylhDweTAs56ycBWqXCXyUrlrISCPDtifhtE
         AinlKXwzxFH/jHzwFW2GaOQKn2BwLU6c1kuW0eRgk82DMCgqep4gyXJr6whINKMHjSVQ
         BAGH8jZ7mmGDHED3EwGcKX2mQ01O7olK/ikPkh2dk06cO7el9YXllYhK2Pazm6ful94C
         SWElOGZt2vK3ftjaonUOVSvgPLGQ37Ur7yOuiFbMp3on4FX3fxeNF08dp3kdtZMxvX+q
         hvg2j7ZFlBjk9E2ydL04RcrgufD4qsz5Gxg1AjRiUHijCvbDNZ6iirNdBvT9xzXHkuwf
         t1Lw==
X-Gm-Message-State: AHQUAuaC0HXZM0X5HO6gckvxytGMNxteINa6+j6CtiSPo6qbqSwUP5oN
        7Vnlt0rmofE31uM9Z/Zu1qbSohU=
X-Google-Smtp-Source: AHgI3Iba/lPxgXaWYVuzWFq8+Bx3j+wX2SBnie/OyUlUbRsTH7hozmjTjBY1pXxrxaWQ5kKYbjefdQ==
X-Received: by 2002:a05:6638:398:: with SMTP id y24mr5455491jap.33.1550584515749;
        Tue, 19 Feb 2019 05:55:15 -0800 (PST)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id c133sm1196313itc.24.2019.02.19.05.55.14
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 19 Feb 2019 05:55:15 -0800 (PST)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     linux-nfs@vger.kernel.org
Subject: [PATCH v3 2/8] NFS: Fix an I/O request leakage in nfs_do_recoalesce
Date:   Tue, 19 Feb 2019 08:53:05 -0500
Message-Id: <20190219135311.119300-3-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190219135311.119300-2-trond.myklebust@hammerspace.com>
References: <20190219135311.119300-1-trond.myklebust@hammerspace.com>
 <20190219135311.119300-2-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Whether we need to exit early, or just reprocess the list, we
must not lost track of the request which failed to get recoalesced.

Fixes: 03d5eb65b538 ("NFS: Fix a memory leak in nfs_do_recoalesce")
Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
Cc: stable@vger.kernel.org # v4.0+
---
 fs/nfs/pagelist.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index 301880a3ad8e..03bde9a41451 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -1092,7 +1092,6 @@ static int nfs_do_recoalesce(struct nfs_pageio_descriptor *desc)
 			struct nfs_page *req;
 
 			req = list_first_entry(&head, struct nfs_page, wb_list);
-			nfs_list_remove_request(req);
 			if (__nfs_pageio_add_request(desc, req))
 				continue;
 			if (desc->pg_error < 0) {
-- 
2.20.1


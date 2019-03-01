Return-Path: <SRS0=Psyw=RE=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A13CCC43381
	for <linux-nfs@archiver.kernel.org>; Fri,  1 Mar 2019 19:27:03 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 6E13E2084F
	for <linux-nfs@archiver.kernel.org>; Fri,  1 Mar 2019 19:27:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="mhWYDS4S"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725999AbfCAT1C (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 1 Mar 2019 14:27:02 -0500
Received: from mail-yw1-f65.google.com ([209.85.161.65]:41027 "EHLO
        mail-yw1-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726034AbfCAT1C (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 1 Mar 2019 14:27:02 -0500
Received: by mail-yw1-f65.google.com with SMTP id q128so14917336ywg.8
        for <linux-nfs@vger.kernel.org>; Fri, 01 Mar 2019 11:27:02 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=3FjYAgyQDPnJRMFDf7E+6u7e/wnIaQzb/2/jz4gy8nA=;
        b=mhWYDS4SCmC+x/+9i27lzPC//FnM2GjEnQGh53ods+Bh1jUBIIUubpu2r0Z0OqAi8C
         g5W2jNG410xoloG9rNr6rBfX9supfutY0J1xCYnXfIfdgyHTnoKdL6t7CI48syyub6bl
         JzwOt92HMhUGzFq5bnJmwiYbAcsygrGfa3SdpnyINPB03ot4BImoMJ6PVfv0KlRXKkuT
         Ho0DTko/YIXukfUC91wkPG1V7DLfbGEsaqUk3k4yUcbQ3DbYeJt4tJK4cPlJs0WhaZNx
         i/GsIcAc7eo8xFQ4yE6r3WQfAhccat+/6kV1xkmNDffaBEExTYHeJH4OCzbYoZwPAQO+
         iJAQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=3FjYAgyQDPnJRMFDf7E+6u7e/wnIaQzb/2/jz4gy8nA=;
        b=o0ih2J+4TMRre2WW1YsHQr/XS6W44l6ne5M0xHXNgJBEYVwLY5lEf8PPUDiSWTqEpp
         eT7LqG+iNOzMADI/P4JSk06Jha54NLPSctx1xe72OUH+N3+QJSKO82mIajqdf4ghoRSZ
         RPVF+8ZH6bnDluUxdFx/kfxzeF2N/sehI3VLLim+e8+K1kTpO2QVBq9cFtMXotuRVkJP
         rKKEi399WQziS5D/6jfsc9ueFBDJWa/4SrRVMKM3byBTJxlYZDYRKtL+XstxsfEE6XwW
         nceUrDliyk/VP+tIa5Jq/HIYLESpAQySaab0aAYk/zucy883Q94PDsp4M7uv017uPkgr
         EAtA==
X-Gm-Message-State: APjAAAUGPJwfrVgCG4b3+IBX3cjDcfaVrgZ6GxJQl0n1ciMUmyDEGWTB
        FiDXHZqmnPe30t/o8ynoYB/QMnI=
X-Google-Smtp-Source: APXvYqwFl7YM0buxCJylPTDViOMLTiYkP4xxr8bJEWJ1jVLPNG/9Heub8NlcJG5pyLx2xq5FHWqOmw==
X-Received: by 2002:a81:9907:: with SMTP id q7mr4804342ywg.81.1551468421160;
        Fri, 01 Mar 2019 11:27:01 -0800 (PST)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id l71sm7509193ywl.65.2019.03.01.11.27.00
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 01 Mar 2019 11:27:00 -0800 (PST)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     linux-nfs@vger.kernel.org
Subject: [PATCH 09/19] NFS/flexfiles: Avoid unnecessary layout invalidations
Date:   Fri,  1 Mar 2019 14:24:45 -0500
Message-Id: <20190301192455.104943-10-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190301192455.104943-9-trond.myklebust@hammerspace.com>
References: <20190301192455.104943-1-trond.myklebust@hammerspace.com>
 <20190301192455.104943-2-trond.myklebust@hammerspace.com>
 <20190301192455.104943-3-trond.myklebust@hammerspace.com>
 <20190301192455.104943-4-trond.myklebust@hammerspace.com>
 <20190301192455.104943-5-trond.myklebust@hammerspace.com>
 <20190301192455.104943-6-trond.myklebust@hammerspace.com>
 <20190301192455.104943-7-trond.myklebust@hammerspace.com>
 <20190301192455.104943-8-trond.myklebust@hammerspace.com>
 <20190301192455.104943-9-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

In ff_layout_mirror_valid() we may not want to invalidate the layout
segment despite the call to GETDEVICEINFO failing. The reason is that
a read may still be able to make progress on another mirror.

So instead we let the caller (in this case nfs4_ff_layout_prepare_ds())
decide whether or not it needs to invalidate.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/flexfilelayout/flexfilelayoutdev.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayoutdev.c b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
index e16ddf2d4768..9d56926f4845 100644
--- a/fs/nfs/flexfilelayout/flexfilelayoutdev.c
+++ b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
@@ -196,7 +196,7 @@ static bool ff_layout_mirror_valid(struct pnfs_layout_segment *lseg,
 				   struct nfs4_ff_layout_mirror *mirror,
 				   bool create)
 {
-	if (mirror == NULL || IS_ERR(mirror->mirror_ds))
+	if (mirror == NULL)
 		goto outerr;
 	if (mirror->mirror_ds == NULL) {
 		if (create) {
@@ -229,7 +229,6 @@ static bool ff_layout_mirror_valid(struct pnfs_layout_segment *lseg,
 	}
 	return true;
 outerr:
-	pnfs_error_mark_layout_for_return(lseg->pls_layout->plh_inode, lseg);
 	return false;
 }
 
@@ -418,7 +417,7 @@ nfs4_ff_layout_prepare_ds(struct pnfs_layout_segment *lseg,
 	int status;
 
 	if (!ff_layout_mirror_valid(lseg, mirror, true))
-		goto out;
+		goto noconnect;
 
 	ds = mirror->mirror_ds->ds;
 	/* matching smp_wmb() in _nfs4_pnfs_v3/4_ds_connect */
@@ -445,6 +444,7 @@ nfs4_ff_layout_prepare_ds(struct pnfs_layout_segment *lseg,
 			mirror->mirror_ds->ds_versions[0].wsize = max_payload;
 		goto out;
 	}
+noconnect:
 	ff_layout_track_ds_error(FF_LAYOUT_FROM_HDR(lseg->pls_layout),
 				 mirror, lseg->pls_range.offset,
 				 lseg->pls_range.length, NFS4ERR_NXIO,
-- 
2.20.1


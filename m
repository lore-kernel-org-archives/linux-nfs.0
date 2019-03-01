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
	by smtp.lore.kernel.org (Postfix) with ESMTP id DD875C10F03
	for <linux-nfs@archiver.kernel.org>; Fri,  1 Mar 2019 19:26:56 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id AD4B82084F
	for <linux-nfs@archiver.kernel.org>; Fri,  1 Mar 2019 19:26:56 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="bfluqCvJ"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725988AbfCAT04 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 1 Mar 2019 14:26:56 -0500
Received: from mail-yw1-f65.google.com ([209.85.161.65]:46389 "EHLO
        mail-yw1-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725905AbfCAT0z (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 1 Mar 2019 14:26:55 -0500
Received: by mail-yw1-f65.google.com with SMTP id n12so14911120ywn.13
        for <linux-nfs@vger.kernel.org>; Fri, 01 Mar 2019 11:26:55 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=nJFBhEOlZ3nJuZrBWuxE2iOl/WFwKdya9WR0Q2DDQTk=;
        b=bfluqCvJHLIvCs/eqJeXixHXrefmbEWSnLA/s3R+zT+O5vyN5XfLdwXxUB366AP/ps
         BXYiGExkmImZOKXDsrP7E4LCstdTMAEsfjNW1mJX5zsc/Y3yn+hK+G1TvBbb9b831iXQ
         EQyUEsQ/JcOJHgTFTBZbOQR+5YWRpfpR0oQtvTFjVY/At9bLcJSYXVaas6/B8xVDkKsu
         rYra9GnY7IsUVYY0A/wayENSqMAZ4zIH7A4iPgLScjUkzjoHydzxEfpPqnzQCXGgbSKZ
         s9aBA+VXdQEaqXVSLi2jTm25s/X8RFZKr0B9I0O/cO7I8ot0MIBIdPzkneRk6OZi63lt
         LGFQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=nJFBhEOlZ3nJuZrBWuxE2iOl/WFwKdya9WR0Q2DDQTk=;
        b=Ltk0iMVny8zJbH9Mf5A1Y5R8HuWRyNa3AOuDbPZNiC56TpbXPbe/BX2tdJFCORjKbM
         VfYlx4mFuiVFU+CPYMbqDm6pUM8OAMSny7pmRzrKOMuBeFz23N/dOFGSwhO9sEX+78Ls
         dm4SOOCXGVSRzUv6k0nGtNpmI3aNQgCUYdlXO61PpA31ywaO3FwGwKy2HQkMID2kVllH
         9oMMjcsS4yIatJyZ/xBjUBgRaIimCBdURmO/ZAGqM/yNfDW5DzZC2oEYluYPMC135Xl9
         VuWJhOpCCvFLfS3Yk+oRy8KAe2iBmdP1i5wtkW6bewQxVTfPv5NQGo8w4filrps6LwP8
         eYCw==
X-Gm-Message-State: APjAAAWsLDyYCkCHSo0JZDV8tKb3Ozenhq91IAxzEkpxmFMpPZNL1/kz
        2n0UT8zawO+CITuo7SMCqgu8yUI=
X-Google-Smtp-Source: APXvYqzYfYvGvViENNL+3B1IkGdZ0x+HzOxvcz0KqH40GyIr46TX72pkX3LW7d15f1QL61vszfuUhA==
X-Received: by 2002:a25:6085:: with SMTP id u127mr5655648ybb.291.1551468414244;
        Fri, 01 Mar 2019 11:26:54 -0800 (PST)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id l71sm7509193ywl.65.2019.03.01.11.26.53
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 01 Mar 2019 11:26:53 -0800 (PST)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     linux-nfs@vger.kernel.org
Subject: [PATCH 01/19] NFSv4/flexfiles: Fix invalid deref in FF_LAYOUT_DEVID_NODE()
Date:   Fri,  1 Mar 2019 14:24:37 -0500
Message-Id: <20190301192455.104943-2-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190301192455.104943-1-trond.myklebust@hammerspace.com>
References: <20190301192455.104943-1-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

If the attempt to instantiate the mirror's layout DS pointer failed,
then that pointer may hold a value of type ERR_PTR(), so we need
to check that before we dereference it.

Fixes: 65990d1afbd2d ("pNFS/flexfiles: Fix a deadlock on LAYOUTGET")
Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/flexfilelayout/flexfilelayout.h | 32 +++++++++++++++-----------
 1 file changed, 19 insertions(+), 13 deletions(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.h b/fs/nfs/flexfilelayout/flexfilelayout.h
index c2626bad466b..8a2d5d630af9 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.h
+++ b/fs/nfs/flexfilelayout/flexfilelayout.h
@@ -132,16 +132,6 @@ FF_LAYOUT_LSEG(struct pnfs_layout_segment *lseg)
 			    generic_hdr);
 }
 
-static inline struct nfs4_deviceid_node *
-FF_LAYOUT_DEVID_NODE(struct pnfs_layout_segment *lseg, u32 idx)
-{
-	if (idx >= FF_LAYOUT_LSEG(lseg)->mirror_array_cnt ||
-	    FF_LAYOUT_LSEG(lseg)->mirror_array[idx] == NULL ||
-	    FF_LAYOUT_LSEG(lseg)->mirror_array[idx]->mirror_ds == NULL)
-		return NULL;
-	return &FF_LAYOUT_LSEG(lseg)->mirror_array[idx]->mirror_ds->id_node;
-}
-
 static inline struct nfs4_ff_layout_ds *
 FF_LAYOUT_MIRROR_DS(struct nfs4_deviceid_node *node)
 {
@@ -151,9 +141,25 @@ FF_LAYOUT_MIRROR_DS(struct nfs4_deviceid_node *node)
 static inline struct nfs4_ff_layout_mirror *
 FF_LAYOUT_COMP(struct pnfs_layout_segment *lseg, u32 idx)
 {
-	if (idx >= FF_LAYOUT_LSEG(lseg)->mirror_array_cnt)
-		return NULL;
-	return FF_LAYOUT_LSEG(lseg)->mirror_array[idx];
+	struct nfs4_ff_layout_segment *fls = FF_LAYOUT_LSEG(lseg);
+
+	if (idx < fls->mirror_array_cnt)
+		return fls->mirror_array[idx];
+	return NULL;
+}
+
+static inline struct nfs4_deviceid_node *
+FF_LAYOUT_DEVID_NODE(struct pnfs_layout_segment *lseg, u32 idx)
+{
+	struct nfs4_ff_layout_mirror *mirror = FF_LAYOUT_COMP(lseg, idx);
+
+	if (mirror != NULL) {
+		struct nfs4_ff_layout_ds *mirror_ds = mirror->mirror_ds;
+
+		if (!IS_ERR_OR_NULL(mirror_ds))
+			return &mirror_ds->id_node;
+	}
+	return NULL;
 }
 
 static inline u32
-- 
2.20.1


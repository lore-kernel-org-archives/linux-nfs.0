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
	by smtp.lore.kernel.org (Postfix) with ESMTP id 279A9C10F03
	for <linux-nfs@archiver.kernel.org>; Fri,  1 Mar 2019 19:27:05 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id ECE4E2084F
	for <linux-nfs@archiver.kernel.org>; Fri,  1 Mar 2019 19:27:04 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="pfjAlTiD"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726051AbfCAT1E (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 1 Mar 2019 14:27:04 -0500
Received: from mail-yw1-f68.google.com ([209.85.161.68]:36151 "EHLO
        mail-yw1-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726042AbfCAT1D (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 1 Mar 2019 14:27:03 -0500
Received: by mail-yw1-f68.google.com with SMTP id 189so14929700ywi.3
        for <linux-nfs@vger.kernel.org>; Fri, 01 Mar 2019 11:27:02 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=8oVymjydCnvwUKTWUbAQtDva4shwTB1aXlONT6b+AXg=;
        b=pfjAlTiDHTADSj5n6HZM675l+QOYXeYomroFoj227ao2knVT0mS0ljMT/vw9vxDKdM
         nZ7JHA/KLJvEhtU0nEWOC5JEXl7m5qwKcYSBiphvi/4CA+aFgEDzI6yuRVY3/+1GnmBX
         0DuWDoNNiSedIEfOPz5XdB4D6ajmPvrHyM/9F4f2Gm2JceC+qg3OPpEyCddmtrq8f0x0
         AkS93LzB2hCMW3b9NmtAQfIxehB7HqYdX8WKI7YvydGypV3aIC/5NT2StE8XWIprst0d
         WEB6zWPuxt2mxGsDBUvpbyE3TWs6F2acdDaoMU9hXULdycttaC73HZeGO9JpmuliO6mL
         qeIQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=8oVymjydCnvwUKTWUbAQtDva4shwTB1aXlONT6b+AXg=;
        b=mCIqw4sH1aX+lgJjUvoceF1wkU+Tcd9GatIFDCH6XvuM/z8riqApi+2NxiULi7zTNR
         GlVrH1UjP0vfyfb/ewF7UO0NVyHSxDG0wRZYqBBypqfC4/nVrIlKpquvheuTgKOrB92v
         ltRY4BvxPzn11uTxIg7nY/IBgdgRT7qQkAsur8DYpO4ZQ6dAoPIIjZ4y8C9eMq6kNnY6
         Py3SAfzZdFltuoTCqJo1GbZTWIhgz5pv+MrDjF8X+Zv4SBFYQAuAGcaMSyjHnGSpxDWS
         EUvfDfC/7bKTp+TvG8mgd8KsUAxt50oh5IayRAzo6CyvywU58b0sdHFWrA/wAuBZRUkL
         Y6/g==
X-Gm-Message-State: APjAAAVJs63Xck5tT28ek10e0cXJJhvyCLAHnU9Pj7CSvs6QqnqYKxx6
        kWay53tDzLNA0HEySGfFKoJz6Mk=
X-Google-Smtp-Source: APXvYqypDTxZjxLSJvEiUQyCEI1wRzxc9I2eLW9/RmV+xMXJPdxnLgvMwNYL+4gMFxrjkaqB1ulnOg==
X-Received: by 2002:a81:100a:: with SMTP id 10mr5019708ywq.341.1551468421976;
        Fri, 01 Mar 2019 11:27:01 -0800 (PST)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id l71sm7509193ywl.65.2019.03.01.11.27.01
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 01 Mar 2019 11:27:01 -0800 (PST)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     linux-nfs@vger.kernel.org
Subject: [PATCH 10/19] NFS/flexfiles: Remove bogus checks for invalid deviceids
Date:   Fri,  1 Mar 2019 14:24:46 -0500
Message-Id: <20190301192455.104943-11-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190301192455.104943-10-trond.myklebust@hammerspace.com>
References: <20190301192455.104943-1-trond.myklebust@hammerspace.com>
 <20190301192455.104943-2-trond.myklebust@hammerspace.com>
 <20190301192455.104943-3-trond.myklebust@hammerspace.com>
 <20190301192455.104943-4-trond.myklebust@hammerspace.com>
 <20190301192455.104943-5-trond.myklebust@hammerspace.com>
 <20190301192455.104943-6-trond.myklebust@hammerspace.com>
 <20190301192455.104943-7-trond.myklebust@hammerspace.com>
 <20190301192455.104943-8-trond.myklebust@hammerspace.com>
 <20190301192455.104943-9-trond.myklebust@hammerspace.com>
 <20190301192455.104943-10-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

We already check the deviceids before we start the RPC call.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/flexfilelayout/flexfilelayout.c | 20 --------------------
 1 file changed, 20 deletions(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index 4cf6fb5df3c8..c4a9f7f2f0e4 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -932,8 +932,6 @@ ff_layout_pg_init_write(struct nfs_pageio_descriptor *pgio,
 
 	for (i = 0; i < pgio->pg_mirror_count; i++) {
 		mirror = FF_LAYOUT_COMP(pgio->pg_lseg, i);
-		if (ff_layout_test_devid_unavailable(&mirror->mirror_ds->id_node))
-			continue;
 		ds = nfs4_ff_layout_prepare_ds(pgio->pg_lseg, mirror, true);
 		if (!ds) {
 			if (!ff_layout_no_fallback_to_mds(pgio->pg_lseg))
@@ -1306,15 +1304,6 @@ ff_layout_set_layoutcommit(struct inode *inode,
 		(unsigned long long) NFS_I(inode)->layout->plh_lwb);
 }
 
-static bool
-ff_layout_device_unavailable(struct pnfs_layout_segment *lseg, int idx)
-{
-	/* No mirroring for now */
-	struct nfs4_deviceid_node *node = FF_LAYOUT_DEVID_NODE(lseg, idx);
-
-	return ff_layout_test_devid_unavailable(node);
-}
-
 static void ff_layout_read_record_layoutstats_start(struct rpc_task *task,
 		struct nfs_pgio_header *hdr)
 {
@@ -1345,10 +1334,6 @@ static int ff_layout_read_prepare_common(struct rpc_task *task,
 		rpc_exit(task, -EIO);
 		return -EIO;
 	}
-	if (ff_layout_device_unavailable(hdr->lseg, hdr->pgio_mirror_idx)) {
-		rpc_exit(task, -EHOSTDOWN);
-		return -EAGAIN;
-	}
 
 	ff_layout_read_record_layoutstats_start(task, hdr);
 	return 0;
@@ -1537,11 +1522,6 @@ static int ff_layout_write_prepare_common(struct rpc_task *task,
 		return -EIO;
 	}
 
-	if (ff_layout_device_unavailable(hdr->lseg, hdr->pgio_mirror_idx)) {
-		rpc_exit(task, -EHOSTDOWN);
-		return -EAGAIN;
-	}
-
 	ff_layout_write_record_layoutstats_start(task, hdr);
 	return 0;
 }
-- 
2.20.1


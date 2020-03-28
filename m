Return-Path: <SRS0=390i=5N=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B6580C2D0EB
	for <linux-nfs@archiver.kernel.org>; Sat, 28 Mar 2020 15:34:45 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 8A9F12073B
	for <linux-nfs@archiver.kernel.org>; Sat, 28 Mar 2020 15:34:45 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1585409685;
	bh=N2F+UWkB32txK8mb0OmAnuzV4O09A/+ZXa4KFe+L4BM=;
	h=From:To:Subject:Date:In-Reply-To:References:List-ID:From;
	b=bVlgFpBX281u3OrckJIKuaqjQb1jEAK/FTLeNhn0tHKgrdUH+b1CnI9WGLjxRxgq4
	 i2nHCtlJk2svVELSoiV31wip3WXEsQ+tFKMGNfq/DX61RkM0RTvKbRGWz2rI762NFz
	 hj/xTj439ZgLQKaDxiQjDbM3WHuZ+nKX9KBEVuxw=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727176AbgC1Peo (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sat, 28 Mar 2020 11:34:44 -0400
Received: from mail.kernel.org ([198.145.29.99]:40334 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727178AbgC1Pen (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sat, 28 Mar 2020 11:34:43 -0400
Received: from localhost.localdomain (c-68-36-133-222.hsd1.mi.comcast.net [68.36.133.222])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id D0E8120748
        for <linux-nfs@vger.kernel.org>; Sat, 28 Mar 2020 15:34:42 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1585409683;
        bh=N2F+UWkB32txK8mb0OmAnuzV4O09A/+ZXa4KFe+L4BM=;
        h=From:To:Subject:Date:In-Reply-To:References:From;
        b=oFDWD09+IKI5kO6f0E6dbQQbk7n5PyAvBgWp5KYZfidYhDtyq5pvofgdUjGpY+qG1
         qkYa+DiXegKDugzSTiF0nbq6d4HQ68Tsgfyc7O2dtZLkZeRkvqkN3KsMEqdtHLUM4+
         +2bbH24GKyrjI3fHLmYDK9gO8jxQ+w6raSUkG6MA=
From:   trondmy@kernel.org
To:     linux-nfs@vger.kernel.org
Subject: [PATCH v2 22/22] pNFS/flexfiles: Specify the layout segment range in LAYOUTGET
Date:   Sat, 28 Mar 2020 11:32:20 -0400
Message-Id: <20200328153220.1352010-23-trondmy@kernel.org>
X-Mailer: git-send-email 2.25.1
In-Reply-To: <20200328153220.1352010-22-trondmy@kernel.org>
References: <20200328153220.1352010-1-trondmy@kernel.org>
 <20200328153220.1352010-2-trondmy@kernel.org>
 <20200328153220.1352010-3-trondmy@kernel.org>
 <20200328153220.1352010-4-trondmy@kernel.org>
 <20200328153220.1352010-5-trondmy@kernel.org>
 <20200328153220.1352010-6-trondmy@kernel.org>
 <20200328153220.1352010-7-trondmy@kernel.org>
 <20200328153220.1352010-8-trondmy@kernel.org>
 <20200328153220.1352010-9-trondmy@kernel.org>
 <20200328153220.1352010-10-trondmy@kernel.org>
 <20200328153220.1352010-11-trondmy@kernel.org>
 <20200328153220.1352010-12-trondmy@kernel.org>
 <20200328153220.1352010-13-trondmy@kernel.org>
 <20200328153220.1352010-14-trondmy@kernel.org>
 <20200328153220.1352010-15-trondmy@kernel.org>
 <20200328153220.1352010-16-trondmy@kernel.org>
 <20200328153220.1352010-17-trondmy@kernel.org>
 <20200328153220.1352010-18-trondmy@kernel.org>
 <20200328153220.1352010-19-trondmy@kernel.org>
 <20200328153220.1352010-20-trondmy@kernel.org>
 <20200328153220.1352010-21-trondmy@kernel.org>
 <20200328153220.1352010-22-trondmy@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Trond Myklebust <trond.myklebust@hammerspace.com>

Move from requesting only full file layout segments, to requesting
layout segments that match our I/O size. This means the server is
still free to return a full file layout, but we will no longer
error out if it does not.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/flexfilelayout/flexfilelayout.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index 42f581e213cc..7d399f72ebbb 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -798,8 +798,8 @@ ff_layout_pg_get_read(struct nfs_pageio_descriptor *pgio,
 	pnfs_put_lseg(pgio->pg_lseg);
 	pgio->pg_lseg = pnfs_update_layout(pgio->pg_inode,
 					   nfs_req_openctx(req),
-					   0,
-					   NFS4_MAX_UINT64,
+					   req_offset(req),
+					   req->wb_bytes,
 					   IOMODE_READ,
 					   strict_iomode,
 					   GFP_KERNEL);
@@ -891,8 +891,8 @@ ff_layout_pg_init_write(struct nfs_pageio_descriptor *pgio,
 	if (!pgio->pg_lseg) {
 		pgio->pg_lseg = pnfs_update_layout(pgio->pg_inode,
 						   nfs_req_openctx(req),
-						   0,
-						   NFS4_MAX_UINT64,
+						   req_offset(req),
+						   req->wb_bytes,
 						   IOMODE_RW,
 						   false,
 						   GFP_NOFS);
-- 
2.25.1


Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-19.4 required=3.0 tests=BAYES_00,DKIMWL_WL_HIGH,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 02DBDC2B9F8
	for <linux-nfs@archiver.kernel.org>; Tue, 25 May 2021 15:32:38 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id CC8B161260
	for <linux-nfs@archiver.kernel.org>; Tue, 25 May 2021 15:32:37 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S232917AbhEYPeG (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 25 May 2021 11:34:06 -0400
Received: from mail.kernel.org ([198.145.29.99]:60752 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S231442AbhEYPeD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 25 May 2021 11:34:03 -0400
Received: by mail.kernel.org (Postfix) with ESMTPSA id 2B281613A9
        for <linux-nfs@vger.kernel.org>; Tue, 25 May 2021 15:32:33 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=k20201202; t=1621956753;
        bh=kFSDor3o68xMSqIvc+AiRQRGf4YlJZMthZPY0fF6Wlg=;
        h=From:To:Subject:Date:In-Reply-To:References:From;
        b=h0CyhStl7LRbCHEtdOaa0YSm3N0z77IotmIwazj/YnWEqM8/zdUp9Z8+zVSKji/D8
         xwlrNtr0PsQ82y1Ej/BGeR8m3RGoe9CDi4RF2V02uU6SEMI6pglIB6EOTAsd0pH+fO
         o3yM2i38PmoDV7aHjuNo7hSea9sLhXG3tgxJRR+Pd29AeSzmvOJXhwvtLz0BGLj/aG
         Jt+bgiV1AAQRxWPXOgo5oWm7mrbh+e/GLdm9miUQyy3zEqnTBTmtwIl4h5JKNvbu4u
         XYu6zkqOtdW08CYfJnbJfqo8VTPy20Ixb+A1Oju394PKNsm+MgRUHLq9DdMNPoVf3S
         erHQvaZ5quG4A==
From:   trondmy@kernel.org
To:     linux-nfs@vger.kernel.org
Subject: [PATCH 2/3] NFS: Don't corrupt the value of pg_bytes_written in nfs_do_recoalesce()
Date:   Tue, 25 May 2021 11:32:30 -0400
Message-Id: <20210525153231.240329-2-trondmy@kernel.org>
X-Mailer: git-send-email 2.31.1
In-Reply-To: <20210525153231.240329-1-trondmy@kernel.org>
References: <20210525153231.240329-1-trondmy@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Trond Myklebust <trond.myklebust@hammerspace.com>

The value of mirror->pg_bytes_written should only be updated after a
successful attempt to flush out the requests on the list.

Fixes: a7d42ddb3099 ("nfs: add mirroring support to pgio layer")
Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/pagelist.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index 76869728c44e..a5d3e2a12ae9 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -1126,17 +1126,16 @@ static void nfs_pageio_doio(struct nfs_pageio_descriptor *desc)
 {
 	struct nfs_pgio_mirror *mirror = nfs_pgio_current_mirror(desc);
 
-
 	if (!list_empty(&mirror->pg_list)) {
 		int error = desc->pg_ops->pg_doio(desc);
 		if (error < 0)
 			desc->pg_error = error;
-		else
-			mirror->pg_bytes_written += mirror->pg_count;
 	}
 	if (list_empty(&mirror->pg_list)) {
+		mirror->pg_bytes_written += mirror->pg_count;
 		mirror->pg_count = 0;
 		mirror->pg_base = 0;
+		mirror->pg_recoalesce = 0;
 	}
 }
 
@@ -1226,7 +1225,6 @@ static int nfs_do_recoalesce(struct nfs_pageio_descriptor *desc)
 
 	do {
 		list_splice_init(&mirror->pg_list, &head);
-		mirror->pg_bytes_written -= mirror->pg_count;
 		mirror->pg_count = 0;
 		mirror->pg_base = 0;
 		mirror->pg_recoalesce = 0;
-- 
2.31.1


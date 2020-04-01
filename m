Return-Path: <SRS0=udTg=5R=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8EF55C2BA13
	for <linux-nfs@archiver.kernel.org>; Wed,  1 Apr 2020 18:59:05 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 59E5B206F5
	for <linux-nfs@archiver.kernel.org>; Wed,  1 Apr 2020 18:59:05 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1585767545;
	bh=R3HnzG3rRA/khxAnMTumPyGZNLC1LXkJBrIE9cUA9BM=;
	h=From:To:Subject:Date:In-Reply-To:References:List-ID:From;
	b=CZmrq7B2weHd8ilbu0lN7FIKuPrO+mh/nYIWPvGBXlmCnurtdo1FlTabF03lsU1Z1
	 eaZFczInU4lj8s3O4kCb2kItWzMZBVo7iTt8JnZtgNZytkwTXFr3uTYCBzqUcDwPHw
	 z3ihUnf9sGfXXcGo66V7BDW/n23DNZUWgb2utvIA=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1732241AbgDAS7E (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 1 Apr 2020 14:59:04 -0400
Received: from mail.kernel.org ([198.145.29.99]:36690 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1731541AbgDAS7E (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 1 Apr 2020 14:59:04 -0400
Received: from localhost.localdomain (c-68-36-133-222.hsd1.mi.comcast.net [68.36.133.222])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id 0D4F720787
        for <linux-nfs@vger.kernel.org>; Wed,  1 Apr 2020 18:59:02 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1585767543;
        bh=R3HnzG3rRA/khxAnMTumPyGZNLC1LXkJBrIE9cUA9BM=;
        h=From:To:Subject:Date:In-Reply-To:References:From;
        b=e6IYlzSy8/dNHC8FZDtIYICnPi8COISM+yDLln+MZeYg2igvkwO1ThfRvc0/N6kF0
         QRfkhCdkEWF1MIUsTl2oJ2vl7cy4TDkUkoNqMzEMGclKk+CF7v7dZWG7qtpWxIb9Pi
         5m4CAcDNkZ5OlF8JF0KpMVVyVfD/ZuGd23lYZGnc=
From:   trondmy@kernel.org
To:     linux-nfs@vger.kernel.org
Subject: [PATCH 06/10] NFS: Remove the redundant function nfs_pgio_has_mirroring()
Date:   Wed,  1 Apr 2020 14:56:48 -0400
Message-Id: <20200401185652.1904777-7-trondmy@kernel.org>
X-Mailer: git-send-email 2.25.1
In-Reply-To: <20200401185652.1904777-6-trondmy@kernel.org>
References: <20200401185652.1904777-1-trondmy@kernel.org>
 <20200401185652.1904777-2-trondmy@kernel.org>
 <20200401185652.1904777-3-trondmy@kernel.org>
 <20200401185652.1904777-4-trondmy@kernel.org>
 <20200401185652.1904777-5-trondmy@kernel.org>
 <20200401185652.1904777-6-trondmy@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Trond Myklebust <trond.myklebust@hammerspace.com>

We need to trust that desc->pg_mirror_idx is set correctly, whether
or not mirroring is enabled.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/internal.h | 6 ------
 fs/nfs/pagelist.c | 7 ++-----
 2 files changed, 2 insertions(+), 11 deletions(-)

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 78f317fac940..1f32a9fbfdaf 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -274,12 +274,6 @@ void nfs_free_request(struct nfs_page *req);
 struct nfs_pgio_mirror *
 nfs_pgio_current_mirror(struct nfs_pageio_descriptor *desc);
 
-static inline bool nfs_pgio_has_mirroring(struct nfs_pageio_descriptor *desc)
-{
-	WARN_ON_ONCE(desc->pg_mirror_count < 1);
-	return desc->pg_mirror_count > 1;
-}
-
 static inline bool nfs_match_open_context(const struct nfs_open_context *ctx1,
 		const struct nfs_open_context *ctx2)
 {
diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index 1fd4862217e0..f535a92403bf 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -33,9 +33,7 @@ static const struct rpc_call_ops nfs_pgio_common_ops;
 struct nfs_pgio_mirror *
 nfs_pgio_current_mirror(struct nfs_pageio_descriptor *desc)
 {
-	return nfs_pgio_has_mirroring(desc) ?
-		&desc->pg_mirrors[desc->pg_mirror_idx] :
-		&desc->pg_mirrors[0];
+	return &desc->pg_mirrors[desc->pg_mirror_idx];
 }
 EXPORT_SYMBOL_GPL(nfs_pgio_current_mirror);
 
@@ -1231,8 +1229,7 @@ static void nfs_pageio_complete_mirror(struct nfs_pageio_descriptor *desc,
 	struct nfs_pgio_mirror *mirror = &desc->pg_mirrors[mirror_idx];
 	u32 restore_idx = desc->pg_mirror_idx;
 
-	if (nfs_pgio_has_mirroring(desc))
-		desc->pg_mirror_idx = mirror_idx;
+	desc->pg_mirror_idx = mirror_idx;
 	for (;;) {
 		nfs_pageio_doio(desc);
 		if (desc->pg_error < 0 || !mirror->pg_recoalesce)
-- 
2.25.1


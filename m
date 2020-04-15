Return-Path: <SRS0=vByh=57=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B04E3C2BA19
	for <linux-nfs@archiver.kernel.org>; Wed, 15 Apr 2020 12:09:48 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 85ED9206A2
	for <linux-nfs@archiver.kernel.org>; Wed, 15 Apr 2020 12:09:48 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1586952588;
	bh=+KmynoHUM8GPQn2SP+1MLZiKCFKLZrqLb2uvnd1KsQY=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:List-ID:From;
	b=qKPVdAPrE0+12h0EJ2sTIesyGBppcKBCUeGCm7VB1SijBbEzLWc21ab8glnmZwV5K
	 rGYeo5s9jAC2aoIsv7MZNvP1d+tY+uk5aiTq45fLqKkNa5IaIhFbn5zCt9Tr/n7gGc
	 TOqRbUNsbrTlWVSBn+7guNfHprSiWubFQKwx3iRk=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S368494AbgDOMJm (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 15 Apr 2020 08:09:42 -0400
Received: from mail.kernel.org ([198.145.29.99]:42096 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S2897580AbgDOLq6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 15 Apr 2020 07:46:58 -0400
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
        (using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id 77C8420775;
        Wed, 15 Apr 2020 11:46:57 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1586951218;
        bh=+KmynoHUM8GPQn2SP+1MLZiKCFKLZrqLb2uvnd1KsQY=;
        h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
        b=TctTorNHWNDfHeJ5FmYNSogh/zZyQw8cN+4pTZn73C+TRHB3Kt1J9lfCRk+ZznnhI
         7geEfCnR5FNhlVXZE5YJNiXT/Y9TAcQ8jCp1/EPke2k1ij95Us2eAl+OIqRkxh6Nyf
         ihSC1CzYOOWtI/f6hEP3+l2hK1lTR5GAHIYwj1lo=
From:   Sasha Levin <sashal@kernel.org>
To:     linux-kernel@vger.kernel.org, stable@vger.kernel.org
Cc:     Trond Myklebust <trond.myklebust@hammerspace.com>,
        Sasha Levin <sashal@kernel.org>, linux-nfs@vger.kernel.org
Subject: [PATCH AUTOSEL 4.19 29/40] NFS: Fix memory leaks in nfs_pageio_stop_mirroring()
Date:   Wed, 15 Apr 2020 07:46:12 -0400
Message-Id: <20200415114623.14972-29-sashal@kernel.org>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20200415114623.14972-1-sashal@kernel.org>
References: <20200415114623.14972-1-sashal@kernel.org>
MIME-Version: 1.0
X-stable: review
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Trond Myklebust <trond.myklebust@hammerspace.com>

[ Upstream commit 862f35c94730c9270833f3ad05bd758a29f204ed ]

If we just set the mirror count to 1 without first clearing out
the mirrors, we can leak queued up requests.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 fs/nfs/pagelist.c | 17 ++++++++---------
 1 file changed, 8 insertions(+), 9 deletions(-)

diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index 9cf59e2622f8e..5dae7c85d9b6e 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -865,15 +865,6 @@ static void nfs_pageio_setup_mirroring(struct nfs_pageio_descriptor *pgio,
 	pgio->pg_mirror_count = mirror_count;
 }
 
-/*
- * nfs_pageio_stop_mirroring - stop using mirroring (set mirror count to 1)
- */
-void nfs_pageio_stop_mirroring(struct nfs_pageio_descriptor *pgio)
-{
-	pgio->pg_mirror_count = 1;
-	pgio->pg_mirror_idx = 0;
-}
-
 static void nfs_pageio_cleanup_mirroring(struct nfs_pageio_descriptor *pgio)
 {
 	pgio->pg_mirror_count = 1;
@@ -1302,6 +1293,14 @@ void nfs_pageio_cond_complete(struct nfs_pageio_descriptor *desc, pgoff_t index)
 	}
 }
 
+/*
+ * nfs_pageio_stop_mirroring - stop using mirroring (set mirror count to 1)
+ */
+void nfs_pageio_stop_mirroring(struct nfs_pageio_descriptor *pgio)
+{
+	nfs_pageio_complete(pgio);
+}
+
 int __init nfs_init_nfspagecache(void)
 {
 	nfs_page_cachep = kmem_cache_create("nfs_page",
-- 
2.20.1


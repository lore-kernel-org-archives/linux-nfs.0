Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9DE61C433FE
	for <linux-nfs@archiver.kernel.org>; Sun, 27 Feb 2022 23:18:39 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S231630AbiB0XTP (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sun, 27 Feb 2022 18:19:15 -0500
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:42240 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S232187AbiB0XTO (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 27 Feb 2022 18:19:14 -0500
Received: from ams.source.kernel.org (ams.source.kernel.org [145.40.68.75])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 8051322505
        for <linux-nfs@vger.kernel.org>; Sun, 27 Feb 2022 15:18:37 -0800 (PST)
Received: from smtp.kernel.org (relay.kernel.org [52.25.139.140])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by ams.source.kernel.org (Postfix) with ESMTPS id 1BC63B80B9D
        for <linux-nfs@vger.kernel.org>; Sun, 27 Feb 2022 23:18:36 +0000 (UTC)
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 69EC0C340EE
        for <linux-nfs@vger.kernel.org>; Sun, 27 Feb 2022 23:18:34 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=k20201202; t=1646003914;
        bh=Y1ipazY3pl3WZgPz62B3OLONuRP4E1z7/Fuod/m3bP0=;
        h=From:To:Subject:Date:In-Reply-To:References:From;
        b=prcUhqnh5XTlVVohOJpLPtq+5YKUp4SWctcKxjs51wRmoJeJ+HnClqeAxJsga1D1L
         hS7Hm4XekJyABbl79uzLxj8SNrKpSJuE0WXJovU3IucgdyVdDnU3xDfBr4riSBUctY
         gnNnHCeJa0UsLAk4zDDBlEM0m7g7UBOdmNmXh37XHz9JVyZZX2CyTwHy7QdzRW62B5
         85XGhNAOUudhtiEOS6H40lvxYKYpHcBwwVpgV3ZENDfirvYtKhZFux8VHHanqicIpM
         EpNsOuAVoO5oKMj0iFloPNaB50ROX9V5MOwfZRcB4NNi1/8OdsewXDTXygfss0/0n4
         SPTDbEBbjf+KA==
From:   trondmy@kernel.org
To:     linux-nfs@vger.kernel.org
Subject: [PATCH v9 02/27] NFS: constify nfs_server_capable() and nfs_have_writebacks()
Date:   Sun, 27 Feb 2022 18:12:02 -0500
Message-Id: <20220227231227.9038-3-trondmy@kernel.org>
X-Mailer: git-send-email 2.35.1
In-Reply-To: <20220227231227.9038-2-trondmy@kernel.org>
References: <20220227231227.9038-1-trondmy@kernel.org>
 <20220227231227.9038-2-trondmy@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Trond Myklebust <trond.myklebust@hammerspace.com>

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 include/linux/nfs_fs.h | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index 72a732a5103c..6e10725887d1 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -363,7 +363,7 @@ static inline void nfs_mark_for_revalidate(struct inode *inode)
 	spin_unlock(&inode->i_lock);
 }
 
-static inline int nfs_server_capable(struct inode *inode, int cap)
+static inline int nfs_server_capable(const struct inode *inode, int cap)
 {
 	return NFS_SERVER(inode)->caps & cap;
 }
@@ -587,12 +587,11 @@ extern struct nfs_commit_data *nfs_commitdata_alloc(bool never_fail);
 extern void nfs_commit_free(struct nfs_commit_data *data);
 bool nfs_commit_end(struct nfs_mds_commit_info *cinfo);
 
-static inline int
-nfs_have_writebacks(struct inode *inode)
+static inline bool nfs_have_writebacks(const struct inode *inode)
 {
 	if (S_ISREG(inode->i_mode))
 		return atomic_long_read(&NFS_I(inode)->nrequests) != 0;
-	return 0;
+	return false;
 }
 
 /*
-- 
2.35.1


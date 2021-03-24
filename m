Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-19.2 required=3.0 tests=BAYES_00,DKIMWL_WL_HIGH,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 39D5BC433DB
	for <linux-nfs@archiver.kernel.org>; Wed, 24 Mar 2021 19:54:58 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id F305D61A24
	for <linux-nfs@archiver.kernel.org>; Wed, 24 Mar 2021 19:54:57 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S237807AbhCXTy0 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 24 Mar 2021 15:54:26 -0400
Received: from mail.kernel.org ([198.145.29.99]:45516 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S237988AbhCXTxz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 24 Mar 2021 15:53:55 -0400
Received: by mail.kernel.org (Postfix) with ESMTPSA id B53FE61A25;
        Wed, 24 Mar 2021 19:53:54 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=k20201202; t=1616615635;
        bh=ecFlRpAXfv6ERDufsKh1iuuuyOp8pPZVV3oduTd3dMc=;
        h=From:To:Cc:Subject:Date:From;
        b=mp72TLmIf6+F8KfEvTYw+7sHFBeRt5U2mn6gme6PCVcL+1HOT4Y+uDHFbxRg5L+Mf
         JajdaPbqLhxDxoX8wr72RGqMYKCZyUOWOg5gqj3q9A+IQc7UzwOP6BYgUSA/22bpJV
         wSPy1qcr1/YRcjlfiaOUt5FPW2XfC6SruQI57dNlde7F97ipgaVPePk9xbQn29B6kd
         ZDizlFot8nByuYhtEhjlf7JfV/+a05clq01H/cD3HzNHjg1HKNXeWwtHC28wvVgoja
         Oyq50T5W8LeoLAFaRH2PoUoOYmP6DkgtyN/IWG6RbyY3zjPSrho2T0wImsmhmaUdye
         ZmykpyTjeLxrQ==
From:   trondmy@kernel.org
To:     linux-nfs@vger.kernel.org
Cc:     "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH] NFS: fix nfs_fetch_iversion()
Date:   Wed, 24 Mar 2021 15:53:53 -0400
Message-Id: <20210324195353.577432-1-trondmy@kernel.org>
X-Mailer: git-send-email 2.30.2
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Trond Myklebust <trond.myklebust@hammerspace.com>

The change attribute is always set by all NFS client versions so get rid
of the open-coded version.

Fixes: 3cc55f4434b4 ("nfs: use change attribute for NFS re-exports")
Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/export.c | 15 ++++-----------
 1 file changed, 4 insertions(+), 11 deletions(-)

diff --git a/fs/nfs/export.c b/fs/nfs/export.c
index f2b34cfe286c..b347e3ce0cc8 100644
--- a/fs/nfs/export.c
+++ b/fs/nfs/export.c
@@ -171,17 +171,10 @@ static u64 nfs_fetch_iversion(struct inode *inode)
 {
 	struct nfs_server *server = NFS_SERVER(inode);
 
-	/* Is this the right call?: */
-	nfs_revalidate_inode(server, inode);
-	/*
-	 * Also, note we're ignoring any returned error.  That seems to be
-	 * the practice for cache consistency information elsewhere in
-	 * the server, but I'm not sure why.
-	 */
-	if (server->nfs_client->rpc_ops->version >= 4)
-		return inode_peek_iversion_raw(inode);
-	else
-		return time_to_chattr(&inode->i_ctime);
+	if (nfs_check_cache_invalid(inode, NFS_INO_INVALID_CHANGE |
+						   NFS_INO_REVAL_PAGECACHE))
+		__nfs_revalidate_inode(server, inode);
+	return inode_peek_iversion_raw(inode);
 }
 
 const struct export_operations nfs_export_ops = {
-- 
2.30.2


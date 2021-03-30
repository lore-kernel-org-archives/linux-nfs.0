Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-19.2 required=3.0 tests=BAYES_00,DKIMWL_WL_HIGH,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9D06AC433E5
	for <linux-nfs@archiver.kernel.org>; Tue, 30 Mar 2021 00:19:51 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 70F09619A6
	for <linux-nfs@archiver.kernel.org>; Tue, 30 Mar 2021 00:19:51 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S229628AbhC3ATM (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 29 Mar 2021 20:19:12 -0400
Received: from mail.kernel.org ([198.145.29.99]:50354 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S229655AbhC3ASk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 29 Mar 2021 20:18:40 -0400
Received: by mail.kernel.org (Postfix) with ESMTPSA id B36D261920
        for <linux-nfs@vger.kernel.org>; Tue, 30 Mar 2021 00:18:38 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=k20201202; t=1617063518;
        bh=Av2mTAvTPBRR6n/iApvQ7Kz11QtjqJfgvAB+6CQmYVc=;
        h=From:To:Subject:Date:In-Reply-To:References:From;
        b=jp7L5oYkLAXQ4QN89wy1N/yMcX6I4RvNrkS08FEkpb8RNZaR9pP8OGdSZcdGfsCcX
         jJ4d5u0sfTSIX3dNViCNitcUVfsFAKsS8F0GbpXvgYy5oKwhe6le/ogRCjx8Rml6nj
         4HLYYT65wmwAM2Q1NaNRH1QQ3QBZlqP4bPlE8mOOzYJxzPq8RaOgEqNinkb+a8vMCe
         OECeFD/A+JnGqy3k7cgoCbeqCFnPFfM+w9VYkKoZVm6YZTLu9hRPthtuEZRVbQkBq+
         Qwt/9k3+W2Md4E27Xc0KoH1aN31NPEEC8HdZQ/UpOwUdwc6l9THXRA3XHlN2fi/vV+
         xkgYFnNcXhFVQ==
From:   trondmy@kernel.org
To:     linux-nfs@vger.kernel.org
Subject: [PATCH 01/17] NFS: Deal correctly with attribute generation counter overflow
Date:   Mon, 29 Mar 2021 20:18:19 -0400
Message-Id: <20210330001835.41914-2-trondmy@kernel.org>
X-Mailer: git-send-email 2.30.2
In-Reply-To: <20210330001835.41914-1-trondmy@kernel.org>
References: <20210330001835.41914-1-trondmy@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Trond Myklebust <trond.myklebust@hammerspace.com>

We need to use unsigned long subtraction and then convert to signed in
order to deal correcly with C overflow rules.

Fixes: f5062003465c ("NFS: Set an attribute barrier on all updates")
Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/inode.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index ff737be559dc..8de5b3b9da91 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -1662,10 +1662,10 @@ EXPORT_SYMBOL_GPL(_nfs_display_fhandle);
  */
 static int nfs_inode_attrs_need_update(const struct inode *inode, const struct nfs_fattr *fattr)
 {
-	const struct nfs_inode *nfsi = NFS_I(inode);
+	unsigned long attr_gencount = NFS_I(inode)->attr_gencount;
 
-	return ((long)fattr->gencount - (long)nfsi->attr_gencount) > 0 ||
-		((long)nfsi->attr_gencount - (long)nfs_read_attr_generation_counter() > 0);
+	return (long)(fattr->gencount - attr_gencount) > 0 ||
+	       (long)(attr_gencount - nfs_read_attr_generation_counter()) > 0;
 }
 
 static int nfs_refresh_inode_locked(struct inode *inode, struct nfs_fattr *fattr)
@@ -2094,7 +2094,7 @@ static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr)
 			nfsi->attrtimeo_timestamp = now;
 		}
 		/* Set the barrier to be more recent than this fattr */
-		if ((long)fattr->gencount - (long)nfsi->attr_gencount > 0)
+		if ((long)(fattr->gencount - nfsi->attr_gencount) > 0)
 			nfsi->attr_gencount = fattr->gencount;
 	}
 
-- 
2.30.2


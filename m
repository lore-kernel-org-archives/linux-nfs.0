Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,DKIMWL_WL_HIGH,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,UNWANTED_LANGUAGE_BODY,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C9DCBC433DB
	for <linux-nfs@archiver.kernel.org>; Mon,  8 Feb 2021 21:47:29 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 7BA9E64E9D
	for <linux-nfs@archiver.kernel.org>; Mon,  8 Feb 2021 21:47:29 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S236847AbhBHVrI (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 8 Feb 2021 16:47:08 -0500
Received: from mail.kernel.org ([198.145.29.99]:39598 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S236331AbhBHVqb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 8 Feb 2021 16:46:31 -0500
Received: by mail.kernel.org (Postfix) with ESMTPSA id 86CA664E9C;
        Mon,  8 Feb 2021 21:45:50 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=k20201202; t=1612820750;
        bh=+bRUchUNflt75+aPBeC0ybws3CrVRueJ6ZW6HEjaY24=;
        h=From:To:Cc:Subject:Date:From;
        b=A3jCd+f7ygaIkPP5Prpz8ygHQ8juywTI3iYjA9rNjhS8IK2/FVYigaS2kx7MXdFRg
         08uSyEwt5hpUQ767Lv/raR3mVE72Any5OmZfw/8d98PgawWKzuTkNR1SxpeNEUOws6
         fIp6jAobpAb6CMud2KGYhkEDSnBTZl9K/X3Zyt0lycHTc57HP+jQMdVmblrFbmvzZb
         wBOBvVQaYOfK9nwLoWzMkinynBWX2mvuUk8lgPAp4nHHrSWuH8CJ794TbVg58D4VFx
         tUDYGOMFk5NuVoK/0IIilzUKgpMDcb8d81KMS8lirw8LC/lvcuv27pNREZVxQtzfge
         J2tAghe8GvDiw==
From:   trondmy@kernel.org
To:     Anna Schumaker <anna.schumaker@netapp.com>
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH] NFS: Don't set NFS_INO_INVALID_XATTR if there is no xattr cache
Date:   Mon,  8 Feb 2021 16:45:49 -0500
Message-Id: <20210208214549.289957-1-trondmy@kernel.org>
X-Mailer: git-send-email 2.29.2
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Trond Myklebust <trond.myklebust@hammerspace.com>

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/inode.c | 14 ++++++++++++++
 1 file changed, 14 insertions(+)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 2533053d764a..1575e3e1dda9 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -195,6 +195,18 @@ bool nfs_check_cache_invalid(struct inode *inode, unsigned long flags)
 }
 EXPORT_SYMBOL_GPL(nfs_check_cache_invalid);
 
+#ifdef CONFIG_NFS_V4_2
+static bool nfs_has_xattr_cache(const struct nfs_inode *nfsi)
+{
+	return nfsi->xattr_cache != NULL;
+}
+#else
+static bool nfs_has_xattr_cache(const struct nfs_inode *nfsi)
+{
+	return false;
+}
+#endif
+
 static void nfs_set_cache_invalid(struct inode *inode, unsigned long flags)
 {
 	struct nfs_inode *nfsi = NFS_I(inode);
@@ -209,6 +221,8 @@ static void nfs_set_cache_invalid(struct inode *inode, unsigned long flags)
 				| NFS_INO_INVALID_XATTR);
 	}
 
+	if (!nfs_has_xattr_cache(nfsi))
+		flags &= ~NFS_INO_INVALID_XATTR;
 	if (inode->i_mapping->nrpages == 0)
 		flags &= ~(NFS_INO_INVALID_DATA|NFS_INO_DATA_INVAL_DEFER);
 	nfsi->cache_validity |= flags;
-- 
2.29.2


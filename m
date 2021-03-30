Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-19.2 required=3.0 tests=BAYES_00,DKIMWL_WL_HIGH,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 02811C433E8
	for <linux-nfs@archiver.kernel.org>; Tue, 30 Mar 2021 00:19:52 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id CB34B61920
	for <linux-nfs@archiver.kernel.org>; Tue, 30 Mar 2021 00:19:51 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S229861AbhC3ATN (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 29 Mar 2021 20:19:13 -0400
Received: from mail.kernel.org ([198.145.29.99]:50376 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S229911AbhC3ASo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 29 Mar 2021 20:18:44 -0400
Received: by mail.kernel.org (Postfix) with ESMTPSA id D4F9161985
        for <linux-nfs@vger.kernel.org>; Tue, 30 Mar 2021 00:18:42 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=k20201202; t=1617063523;
        bh=6MtErt9FfUDl52MMK2uZItzbolaPS6ow/Og4Mbj4Rvk=;
        h=From:To:Subject:Date:In-Reply-To:References:From;
        b=j+5Lw6ax411uYxJ32FGtItyocjLtwHlGSfpnVbe5D8XZJKBC+DQ2vKcjxbVylNoxr
         GROaKdJs9m+pJ4kDhPzCNTCRvhgTRbKI2BeW6HN8Qx9N7C34HqRPHMeWNXnm3bxDYp
         yrBm5I0S6NDsd/tykneZPE6cSVwSfGROEMhSVFQB/xNBb741nXcDsLS7J5B7pjFBOm
         L8m0NGcOETcFEQSpEQeo1DyFHPKPNc2eTGmNNymbUtCR+LarTJZ8Haorczy2F6obM9
         +VabJ8v/IMVJB3/K/yP9wflP8XDzdFIBSLaqe7t2W2SIV6Dn0wpYqsvoTL8gKc9mvP
         68EBqFh0UFpAw==
From:   trondmy@kernel.org
To:     linux-nfs@vger.kernel.org
Subject: [PATCH 07/17] NFS: Fix up statx() results
Date:   Mon, 29 Mar 2021 20:18:25 -0400
Message-Id: <20210330001835.41914-8-trondmy@kernel.org>
X-Mailer: git-send-email 2.30.2
In-Reply-To: <20210330001835.41914-7-trondmy@kernel.org>
References: <20210330001835.41914-1-trondmy@kernel.org>
 <20210330001835.41914-2-trondmy@kernel.org>
 <20210330001835.41914-3-trondmy@kernel.org>
 <20210330001835.41914-4-trondmy@kernel.org>
 <20210330001835.41914-5-trondmy@kernel.org>
 <20210330001835.41914-6-trondmy@kernel.org>
 <20210330001835.41914-7-trondmy@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Trond Myklebust <trond.myklebust@hammerspace.com>

If statx has valid attributes available that weren't asked for, then
return them and set the result mask appropriately.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/inode.c | 29 ++++++++++++++++++++++++++---
 1 file changed, 26 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 5280f28a67a7..538ea8a0e171 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -806,6 +806,28 @@ static bool nfs_need_revalidate_inode(struct inode *inode)
 	return false;
 }
 
+static u32 nfs_get_valid_attrmask(struct inode *inode)
+{
+	unsigned long cache_validity = READ_ONCE(NFS_I(inode)->cache_validity);
+	u32 reply_mask = STATX_INO | STATX_TYPE;
+
+	if (!(cache_validity & NFS_INO_INVALID_ATIME))
+		reply_mask |= STATX_ATIME;
+	if (!(cache_validity & NFS_INO_REVAL_PAGECACHE)) {
+		if (!(cache_validity & NFS_INO_INVALID_CTIME))
+			reply_mask |= STATX_CTIME;
+		if (!(cache_validity & NFS_INO_INVALID_MTIME))
+			reply_mask |= STATX_MTIME;
+		if (!(cache_validity & NFS_INO_INVALID_SIZE))
+			reply_mask |= STATX_SIZE;
+	}
+	if (!(cache_validity & NFS_INO_INVALID_OTHER))
+		reply_mask |= STATX_UID | STATX_GID | STATX_MODE | STATX_NLINK;
+	if (!(cache_validity & NFS_INO_INVALID_BLOCKS))
+		reply_mask |= STATX_BLOCKS;
+	return reply_mask;
+}
+
 int nfs_getattr(struct user_namespace *mnt_userns, const struct path *path,
 		struct kstat *stat, u32 request_mask, unsigned int query_flags)
 {
@@ -824,7 +846,7 @@ int nfs_getattr(struct user_namespace *mnt_userns, const struct path *path,
 
 	if ((query_flags & AT_STATX_DONT_SYNC) && !force_sync) {
 		nfs_readdirplus_parent_cache_hit(path->dentry);
-		goto out_no_update;
+		goto out_no_revalidate;
 	}
 
 	/* Flush out writes to the server in order to update c/mtime.  */
@@ -870,6 +892,7 @@ int nfs_getattr(struct user_namespace *mnt_userns, const struct path *path,
 		do_update |= cache_validity & NFS_INO_INVALID_OTHER;
 	if (request_mask & STATX_BLOCKS)
 		do_update |= cache_validity & NFS_INO_INVALID_BLOCKS;
+
 	if (do_update) {
 		/* Update the attribute cache */
 		if (!(server->flags & NFS_MOUNT_NOAC))
@@ -883,8 +906,8 @@ int nfs_getattr(struct user_namespace *mnt_userns, const struct path *path,
 		nfs_readdirplus_parent_cache_hit(path->dentry);
 out_no_revalidate:
 	/* Only return attributes that were revalidated. */
-	stat->result_mask &= request_mask;
-out_no_update:
+	stat->result_mask = nfs_get_valid_attrmask(inode) | request_mask;
+
 	generic_fillattr(&init_user_ns, inode, stat);
 	stat->ino = nfs_compat_user_ino64(NFS_FILEID(inode));
 	if (S_ISDIR(inode->i_mode))
-- 
2.30.2


Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-19.2 required=3.0 tests=BAYES_00,DKIMWL_WL_HIGH,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B0753C433E4
	for <linux-nfs@archiver.kernel.org>; Tue, 30 Mar 2021 00:19:51 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 8CFB061920
	for <linux-nfs@archiver.kernel.org>; Tue, 30 Mar 2021 00:19:51 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S230202AbhC3ATO (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 29 Mar 2021 20:19:14 -0400
Received: from mail.kernel.org ([198.145.29.99]:50394 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S230089AbhC3ASp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 29 Mar 2021 20:18:45 -0400
Received: by mail.kernel.org (Postfix) with ESMTPSA id 478C560295
        for <linux-nfs@vger.kernel.org>; Tue, 30 Mar 2021 00:18:44 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=k20201202; t=1617063524;
        bh=J67vLtRvz42GCjVC65Be19f7hcrnAW6aklVdUkkLOAo=;
        h=From:To:Subject:Date:In-Reply-To:References:From;
        b=OYrNfL7NcNSrxuV2GXWsB8NEBZzKVGzNa8s8CLOgPUl7qFq5IEfBoKW5VC1l7NWZq
         MK2zlaeTOVJ/Y7SSlCRBGhbQEPwG/Qsh/G8DtEr5UkKlkKPd2RZBvp+++WyTzzaXCV
         L+x0RBAREKugQIVYuT5qhu1fuLS1vxcjNA+Yk8jtCVIYms62ozeLovkZZx9dCFzeNT
         v2FNI67sXdsD1mBC5LzvYdUczWp0qlV6Rhi2pLdUhTocSYqvQPpjr+IxRzE5nR9OtT
         IzdEciaqNk9tUkPNtijxsVOpQfMp3P2gPP2V4Upcq3oAFs62Sl9LmSXd+wtHMi9tRR
         X3S1Y3+6h8ggQ==
From:   trondmy@kernel.org
To:     linux-nfs@vger.kernel.org
Subject: [PATCH 09/17] NFS: Replace use of NFS_INO_REVAL_PAGECACHE when checking cache validity
Date:   Mon, 29 Mar 2021 20:18:27 -0400
Message-Id: <20210330001835.41914-10-trondmy@kernel.org>
X-Mailer: git-send-email 2.30.2
In-Reply-To: <20210330001835.41914-9-trondmy@kernel.org>
References: <20210330001835.41914-1-trondmy@kernel.org>
 <20210330001835.41914-2-trondmy@kernel.org>
 <20210330001835.41914-3-trondmy@kernel.org>
 <20210330001835.41914-4-trondmy@kernel.org>
 <20210330001835.41914-5-trondmy@kernel.org>
 <20210330001835.41914-6-trondmy@kernel.org>
 <20210330001835.41914-7-trondmy@kernel.org>
 <20210330001835.41914-8-trondmy@kernel.org>
 <20210330001835.41914-9-trondmy@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Trond Myklebust <trond.myklebust@hammerspace.com>

When checking cache validity, be more specific than just 'we want to
check the page cache validity'. In almost all cases, we want to check
that change attribute, and possibly also the size.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/file.c     |  2 +-
 fs/nfs/inode.c    | 19 +++++++++----------
 fs/nfs/nfs4proc.c |  4 ++--
 fs/nfs/write.c    |  2 +-
 4 files changed, 13 insertions(+), 14 deletions(-)

diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index 16ad5050e046..1fef107961bc 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -105,7 +105,7 @@ static int nfs_revalidate_file_size(struct inode *inode, struct file *filp)
 
 	if (filp->f_flags & O_DIRECT)
 		goto force_reval;
-	if (nfs_check_cache_invalid(inode, NFS_INO_REVAL_PAGECACHE))
+	if (nfs_check_cache_invalid(inode, NFS_INO_INVALID_SIZE))
 		goto force_reval;
 	return 0;
 force_reval:
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index be014c492c8a..484e1e3c500e 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -169,7 +169,8 @@ static bool nfs_check_cache_invalid_delegated(struct inode *inode, unsigned long
 	unsigned long cache_validity = READ_ONCE(NFS_I(inode)->cache_validity);
 
 	/* Special case for the pagecache or access cache */
-	if (flags == NFS_INO_REVAL_PAGECACHE &&
+	if (flags & (NFS_INO_INVALID_SIZE | NFS_INO_INVALID_CHANGE) &&
+	    !(flags & ~(NFS_INO_INVALID_SIZE | NFS_INO_INVALID_CHANGE)) &&
 	    !(cache_validity & NFS_INO_REVAL_FORCED))
 		return false;
 	return (cache_validity & flags) != 0;
@@ -803,14 +804,12 @@ static u32 nfs_get_valid_attrmask(struct inode *inode)
 
 	if (!(cache_validity & NFS_INO_INVALID_ATIME))
 		reply_mask |= STATX_ATIME;
-	if (!(cache_validity & NFS_INO_REVAL_PAGECACHE)) {
-		if (!(cache_validity & NFS_INO_INVALID_CTIME))
-			reply_mask |= STATX_CTIME;
-		if (!(cache_validity & NFS_INO_INVALID_MTIME))
-			reply_mask |= STATX_MTIME;
-		if (!(cache_validity & NFS_INO_INVALID_SIZE))
-			reply_mask |= STATX_SIZE;
-	}
+	if (!(cache_validity & NFS_INO_INVALID_CTIME))
+		reply_mask |= STATX_CTIME;
+	if (!(cache_validity & NFS_INO_INVALID_MTIME))
+		reply_mask |= STATX_MTIME;
+	if (!(cache_validity & NFS_INO_INVALID_SIZE))
+		reply_mask |= STATX_SIZE;
 	if (!(cache_validity & NFS_INO_INVALID_OTHER))
 		reply_mask |= STATX_UID | STATX_GID | STATX_MODE | STATX_NLINK;
 	if (!(cache_validity & NFS_INO_INVALID_BLOCKS))
@@ -1356,7 +1355,7 @@ int nfs_clear_invalid_mapping(struct address_space *mapping)
 
 bool nfs_mapping_need_revalidate_inode(struct inode *inode)
 {
-	return nfs_check_cache_invalid(inode, NFS_INO_REVAL_PAGECACHE) ||
+	return nfs_check_cache_invalid(inode, NFS_INO_INVALID_CHANGE) ||
 		NFS_STALE(inode);
 }
 
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index b53c312fc982..2f2cea64f40a 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5451,9 +5451,9 @@ static void nfs4_bitmask_set(__u32 bitmask[NFS4_BITMASK_SZ], const __u32 *src,
 		goto out;
 	}
 
-	if (cache_validity & (NFS_INO_INVALID_CHANGE | NFS_INO_REVAL_PAGECACHE))
+	if (cache_validity & NFS_INO_INVALID_CHANGE)
 		bitmask[0] |= FATTR4_WORD0_CHANGE;
-	if (cache_validity & (NFS_INO_INVALID_SIZE | NFS_INO_REVAL_PAGECACHE))
+	if (cache_validity & NFS_INO_INVALID_SIZE)
 		bitmask[0] |= FATTR4_WORD0_SIZE;
 out:
 	for (i = 0; i < NFS4_BITMASK_SZ; i++)
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index f05a90338a76..7a39b3d424da 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1293,7 +1293,7 @@ static bool nfs_write_pageuptodate(struct page *page, struct inode *inode,
 	if (nfs_have_delegated_attributes(inode))
 		goto out;
 	if (nfsi->cache_validity &
-	    (NFS_INO_REVAL_PAGECACHE | NFS_INO_INVALID_SIZE))
+	    (NFS_INO_INVALID_CHANGE | NFS_INO_INVALID_SIZE))
 		return false;
 	smp_rmb();
 	if (test_bit(NFS_INO_INVALIDATING, &nfsi->flags) && pagelen != 0)
-- 
2.30.2


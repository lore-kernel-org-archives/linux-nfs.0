Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-19.0 required=3.0 tests=BAYES_00,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EC64AC41602
	for <linux-nfs@archiver.kernel.org>; Wed, 14 Apr 2021 13:44:19 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id E1C6F611B0
	for <linux-nfs@archiver.kernel.org>; Wed, 14 Apr 2021 13:44:19 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1351580AbhDNNok (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 14 Apr 2021 09:44:40 -0400
Received: from mail.kernel.org ([198.145.29.99]:52172 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1351616AbhDNNo0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 14 Apr 2021 09:44:26 -0400
Received: by mail.kernel.org (Postfix) with ESMTPSA id AFA7F61220
        for <linux-nfs@vger.kernel.org>; Wed, 14 Apr 2021 13:44:04 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=k20201202; t=1618407844;
        bh=5ilTz7jzkLZ0bTvhaqWAlN/JNQVQkww1lFJcy5vfh90=;
        h=From:To:Subject:Date:In-Reply-To:References:From;
        b=dzm54Sdn/UcdER+kKkjSqLjqJv89lXia+G4+HNlsArqHpRMsFUg6Vxz5+hCnEGJ7s
         ERqJCBFiZnF3UXqgN7u/gDOWALkGVN0zqCua4nR8ipbrqdUAIoNtExhl1BSz4QwE/O
         GCpDRqEvKRHcc4oyvk9zzi/TV7KTfHJqk8KO2DKVESQjwPcdncgTplbfckPixI87Nx
         QWPjbOWS2ojP5FD/WjXiZ2fTW3pEAAdcbyU5wzQoBx69syH8XNwJXhwJMbsXf6UtVo
         pkzIgyPLVcscixGMykU9h3XQyZIlD4rODd+SJFjcgy0IjNDqVSHHxsTsgxcx5j7rAq
         NI6/keoHZ3IPw==
From:   trondmy@kernel.org
To:     linux-nfs@vger.kernel.org
Subject: [PATCH v2 22/26] NFS: Another inode revalidation improvement
Date:   Wed, 14 Apr 2021 09:43:49 -0400
Message-Id: <20210414134353.11860-23-trondmy@kernel.org>
X-Mailer: git-send-email 2.30.2
In-Reply-To: <20210414134353.11860-22-trondmy@kernel.org>
References: <20210414134353.11860-1-trondmy@kernel.org>
 <20210414134353.11860-2-trondmy@kernel.org>
 <20210414134353.11860-3-trondmy@kernel.org>
 <20210414134353.11860-4-trondmy@kernel.org>
 <20210414134353.11860-5-trondmy@kernel.org>
 <20210414134353.11860-6-trondmy@kernel.org>
 <20210414134353.11860-7-trondmy@kernel.org>
 <20210414134353.11860-8-trondmy@kernel.org>
 <20210414134353.11860-9-trondmy@kernel.org>
 <20210414134353.11860-10-trondmy@kernel.org>
 <20210414134353.11860-11-trondmy@kernel.org>
 <20210414134353.11860-12-trondmy@kernel.org>
 <20210414134353.11860-13-trondmy@kernel.org>
 <20210414134353.11860-14-trondmy@kernel.org>
 <20210414134353.11860-15-trondmy@kernel.org>
 <20210414134353.11860-16-trondmy@kernel.org>
 <20210414134353.11860-17-trondmy@kernel.org>
 <20210414134353.11860-18-trondmy@kernel.org>
 <20210414134353.11860-19-trondmy@kernel.org>
 <20210414134353.11860-20-trondmy@kernel.org>
 <20210414134353.11860-21-trondmy@kernel.org>
 <20210414134353.11860-22-trondmy@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Trond Myklebust <trond.myklebust@hammerspace.com>

If we're trying to update the inode because a previous update left the
cache in a partially unrevalidated state, then allow the update if the
change attrs match.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/inode.c | 30 +++++++++++++++++++++++++++++-
 1 file changed, 29 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index d218d164414f..b88e9dc72eec 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -1754,6 +1754,34 @@ static int nfs_inode_attrs_cmp(const struct nfs_fattr *fattr,
 	return 0;
 }
 
+/**
+ * nfs_inode_finish_partial_attr_update - complete a previous inode update
+ * @fattr: attributes
+ * @inode: pointer to inode
+ *
+ * Returns '1' if the last attribute update left the inode cached
+ * attributes in a partially unrevalidated state, and @fattr
+ * matches the change attribute of that partial update.
+ * Otherwise returns '0'.
+ */
+static int nfs_inode_finish_partial_attr_update(const struct nfs_fattr *fattr,
+						const struct inode *inode)
+{
+	const unsigned long check_valid =
+		NFS_INO_INVALID_ATIME | NFS_INO_INVALID_CTIME |
+		NFS_INO_INVALID_MTIME | NFS_INO_INVALID_SIZE |
+		NFS_INO_INVALID_BLOCKS | NFS_INO_INVALID_OTHER |
+		NFS_INO_INVALID_NLINK;
+	unsigned long cache_validity = NFS_I(inode)->cache_validity;
+
+	if (!(cache_validity & NFS_INO_INVALID_CHANGE) &&
+	    (cache_validity & check_valid) != 0 &&
+	    (fattr->valid & NFS_ATTR_FATTR_CHANGE) != 0 &&
+	    nfs_inode_attrs_cmp_monotonic(fattr, inode) == 0)
+		return 1;
+	return 0;
+}
+
 static int nfs_refresh_inode_locked(struct inode *inode,
 				    struct nfs_fattr *fattr)
 {
@@ -1762,7 +1790,7 @@ static int nfs_refresh_inode_locked(struct inode *inode,
 
 	trace_nfs_refresh_inode_enter(inode);
 
-	if (attr_cmp > 0)
+	if (attr_cmp > 0 || nfs_inode_finish_partial_attr_update(fattr, inode))
 		ret = nfs_update_inode(inode, fattr);
 	else if (attr_cmp == 0)
 		ret = nfs_check_inode_attributes(inode, fattr);
-- 
2.30.2


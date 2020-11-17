Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-12.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BF612C63798
	for <linux-nfs@archiver.kernel.org>; Tue, 17 Nov 2020 03:18:30 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 7CFBB246A4
	for <linux-nfs@archiver.kernel.org>; Tue, 17 Nov 2020 03:18:30 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726085AbgKQDSK (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 16 Nov 2020 22:18:10 -0500
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:51272 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726097AbgKQDSJ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 16 Nov 2020 22:18:09 -0500
Received: from fieldses.org (fieldses.org [IPv6:2600:3c00:e000:2f7::1])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 5CDC0C0613D3
        for <linux-nfs@vger.kernel.org>; Mon, 16 Nov 2020 19:18:09 -0800 (PST)
Received: by fieldses.org (Postfix, from userid 2815)
        id CBBE61C29; Mon, 16 Nov 2020 22:18:08 -0500 (EST)
DKIM-Filter: OpenDKIM Filter v2.11.0 fieldses.org CBBE61C29
From:   "J. Bruce Fields" <bfields@redhat.com>
To:     Jeff Layton <jlayton@kernel.org>
Cc:     Daire Byrne <daire@dneg.com>,
        Trond Myklebust <trondmy@hammerspace.com>,
        linux-cachefs <linux-cachefs@redhat.com>,
        linux-nfs <linux-nfs@vger.kernel.org>,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 3/4] nfs: don't mangle i_version on NFS
Date:   Mon, 16 Nov 2020 22:18:05 -0500
Message-Id: <1605583086-19869-3-git-send-email-bfields@redhat.com>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1605583086-19869-1-git-send-email-bfields@redhat.com>
References: <20201117031601.GB10526@fieldses.org>
 <1605583086-19869-1-git-send-email-bfields@redhat.com>
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: "J. Bruce Fields" <bfields@redhat.com>

The i_version on NFS has pretty much opaque to the client, so we don't
want to give the low bit any special interpretation.

Define a new FS_PRIVATE_I_VERSION flag for filesystems that manage the
i_version on their own.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfs/export.c          | 1 +
 include/linux/exportfs.h | 1 +
 include/linux/iversion.h | 4 ++++
 3 files changed, 6 insertions(+)

diff --git a/fs/nfs/export.c b/fs/nfs/export.c
index 3430d6891e89..c2eb915a54ca 100644
--- a/fs/nfs/export.c
+++ b/fs/nfs/export.c
@@ -171,4 +171,5 @@ const struct export_operations nfs_export_ops = {
 	.encode_fh = nfs_encode_fh,
 	.fh_to_dentry = nfs_fh_to_dentry,
 	.get_parent = nfs_get_parent,
+	.fetch_iversion = inode_peek_iversion_raw,
 };
diff --git a/include/linux/exportfs.h b/include/linux/exportfs.h
index 3ceb72b67a7a..6000121a201f 100644
--- a/include/linux/exportfs.h
+++ b/include/linux/exportfs.h
@@ -213,6 +213,7 @@ struct export_operations {
 			  bool write, u32 *device_generation);
 	int (*commit_blocks)(struct inode *inode, struct iomap *iomaps,
 			     int nr_iomaps, struct iattr *iattr);
+	u64 (*fetch_iversion)(const struct inode *);
 };
 
 extern int exportfs_encode_inode_fh(struct inode *inode, struct fid *fid,
diff --git a/include/linux/iversion.h b/include/linux/iversion.h
index 2917ef990d43..481b3debf6bb 100644
--- a/include/linux/iversion.h
+++ b/include/linux/iversion.h
@@ -3,6 +3,7 @@
 #define _LINUX_IVERSION_H
 
 #include <linux/fs.h>
+#include <linux/exportfs.h>
 
 /*
  * The inode->i_version field:
@@ -306,6 +307,9 @@ inode_query_iversion(struct inode *inode)
 {
 	u64 cur, old, new;
 
+	if (inode->i_sb->s_export_op->fetch_iversion)
+		return inode->i_sb->s_export_op->fetch_iversion(inode);
+
 	cur = inode_peek_iversion_raw(inode);
 	for (;;) {
 		/* If flag is already set, then no need to swap */
-- 
2.28.0


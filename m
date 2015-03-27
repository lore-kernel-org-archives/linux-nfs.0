Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wi0-f177.google.com ([209.85.212.177]:36655 "EHLO
	mail-wi0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752839AbbC0Qvu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 27 Mar 2015 12:51:50 -0400
From: Andreas Gruenbacher <andreas.gruenbacher@gmail.com>
To: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org
Subject: [RFC 07/39] vfs: Make the inode passed to inode_change_ok non-const
Date: Fri, 27 Mar 2015 17:50:05 +0100
Message-Id: <17e0f0da452317ba05c035b0c23bd96966ea0e81.1427471526.git.agruenba@redhat.com>
In-Reply-To: <cover.1427471526.git.agruenba@redhat.com>
References: <cover.1427471526.git.agruenba@redhat.com>
In-Reply-To: <cover.1427471526.git.agruenba@redhat.com>
References: <cover.1427471526.git.agruenba@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We will need to call iop->permission and iop->get_acl from
inode_change_ok() for additional permission checks, and both take a
non-const inode.

Signed-off-by: Andreas Gruenbacher <agruenba@redhat.com>
---
 fs/attr.c          | 2 +-
 include/linux/fs.h | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/attr.c b/fs/attr.c
index 6530ced..328be71 100644
--- a/fs/attr.c
+++ b/fs/attr.c
@@ -28,7 +28,7 @@
  * Should be called as the first thing in ->setattr implementations,
  * possibly after taking additional locks.
  */
-int inode_change_ok(const struct inode *inode, struct iattr *attr)
+int inode_change_ok(struct inode *inode, struct iattr *attr)
 {
 	unsigned int ia_valid = attr->ia_valid;
 
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 101abcf..f688ea6 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -2760,7 +2760,7 @@ extern int buffer_migrate_page(struct address_space *,
 #define buffer_migrate_page NULL
 #endif
 
-extern int inode_change_ok(const struct inode *, struct iattr *);
+extern int inode_change_ok(struct inode *, struct iattr *);
 extern int inode_newsize_ok(const struct inode *, loff_t offset);
 extern void setattr_copy(struct inode *inode, const struct iattr *attr);
 
-- 
2.1.0


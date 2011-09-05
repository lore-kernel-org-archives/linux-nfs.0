Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from e28smtp07.in.ibm.com ([122.248.162.7]:50232 "EHLO
	e28smtp07.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752048Ab1IER1W (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 5 Sep 2011 13:27:22 -0400
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
To: agruen@kernel.org, bfields@fieldses.org, akpm@linux-foundation.org,
        dhowells@redhat.com
Cc: aneesh.kumar@linux.vnet.ibm.com, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: [PATCH -V6 10/26] vfs: Make the inode passed to inode_change_ok non-const
Date: Mon,  5 Sep 2011 22:55:32 +0530
Message-Id: <1315243548-18664-11-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1315243548-18664-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1315243548-18664-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Andreas Gruenbacher <agruen@kernel.org>

We will need to call iop->permission and iop->get_acl from
inode_change_ok() for additional permission checks, and both take a
non-const inode.

Signed-off-by: Andreas Gruenbacher <agruen@kernel.org>
Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 fs/attr.c          |    2 +-
 include/linux/fs.h |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/attr.c b/fs/attr.c
index 538e279..f15e9e3 100644
--- a/fs/attr.c
+++ b/fs/attr.c
@@ -26,7 +26,7 @@
  * Should be called as the first thing in ->setattr implementations,
  * possibly after taking additional locks.
  */
-int inode_change_ok(const struct inode *inode, struct iattr *attr)
+int inode_change_ok(struct inode *inode, struct iattr *attr)
 {
 	unsigned int ia_valid = attr->ia_valid;
 
diff --git a/include/linux/fs.h b/include/linux/fs.h
index c5c98c5..8afb054 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -2568,7 +2568,7 @@ extern int buffer_migrate_page(struct address_space *,
 #define buffer_migrate_page NULL
 #endif
 
-extern int inode_change_ok(const struct inode *, struct iattr *);
+extern int inode_change_ok(struct inode *, struct iattr *);
 extern int inode_newsize_ok(const struct inode *, loff_t offset);
 extern void setattr_copy(struct inode *inode, const struct iattr *attr);
 
-- 
1.7.4.1


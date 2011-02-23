Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from e28smtp01.in.ibm.com ([122.248.162.1]:60248 "EHLO
	e28smtp01.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755399Ab1BWNxA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 23 Feb 2011 08:53:00 -0500
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
To: sfrench@us.ibm.com, agruen@linbit.com, dilger.kernel@dilger.ca,
        sandeen@redhat.com, tytso@mit.edu, bfields@fieldses.org,
        jlayton@redhat.com
Cc: aneesh.kumar@linux.vnet.ibm.com, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-ext4@vger.kernel.org,
        linux-kernel@vger.kernel.org, Andreas Gruenbacher <agruen@suse.de>
Subject: [PATCH -V5 03/24] vfs: Add a comment to inode_permission()
Date: Wed, 23 Feb 2011 19:21:50 +0530
Message-Id: <1298469131-16555-4-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1298469131-16555-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1298469131-16555-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Andreas Gruenbacher <agruen@suse.de>

Signed-off-by: Andreas Gruenbacher <agruen@suse.de>
Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 fs/namei.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/fs/namei.c b/fs/namei.c
index f09ab1f..0bfc546 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -167,7 +167,7 @@ EXPORT_SYMBOL(putname);
 #endif
 
 /*
- * This does basic POSIX ACL permission checking
+ * This does the basic permission checking
  */
 static int acl_permission_check(struct inode *inode, int mask, unsigned int flags,
 		int (*check_acl)(struct inode *inode, int mask, unsigned int flags))
@@ -217,7 +217,7 @@ int generic_permission(struct inode *inode, int mask, unsigned int flags,
 	int ret;
 
 	/*
-	 * Do the basic POSIX ACL permission checks.
+	 * Do the basic permission checks.
 	 */
 	ret = acl_permission_check(inode, mask, flags, check_acl);
 	if (ret != -EACCES)
@@ -251,6 +251,8 @@ int generic_permission(struct inode *inode, int mask, unsigned int flags,
  * We use "fsuid" for this, letting us set arbitrary permissions
  * for filesystem access without changing the "normal" uids which
  * are used for other things.
+ *
+ * When checking for MAY_APPEND, MAY_WRITE must also be set in @mask.
  */
 int inode_permission(struct inode *inode, int mask)
 {
-- 
1.7.1


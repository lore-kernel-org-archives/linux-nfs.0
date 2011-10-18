Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e23smtp09.au.ibm.com ([202.81.31.142]:50050 "EHLO
	e23smtp09.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932713Ab1JRPeV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 18 Oct 2011 11:34:21 -0400
Received: from /spool/local
	by au.ibm.com with XMail ESMTP
	for <linux-nfs@vger.kernel.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Tue, 18 Oct 2011 16:29:35 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
To: agruen@kernel.org, bfields@fieldses.org, akpm@linux-foundation.org,
        viro@zeniv.linux.org.uk, dhowells@redhat.com
Cc: aneesh.kumar@linux.vnet.ibm.com, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: [PATCH -V7 04/26] vfs: Add a comment to inode_permission()
Date: Tue, 18 Oct 2011 21:02:39 +0530
Message-Id: <1318951981-5508-5-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1318951981-5508-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1318951981-5508-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andreas Gruenbacher <agruen@kernel.org>

Acked-by: David Howells <dhowells@redhat.com>
Signed-off-by: Andreas Gruenbacher <agruen@kernel.org>
Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 fs/namei.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/fs/namei.c b/fs/namei.c
index 276cd30..9061157 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -221,7 +221,7 @@ static int check_acl(struct inode *inode, int mask)
 }
 
 /*
- * This does basic POSIX ACL permission checking
+ * This does the basic permission checking
  */
 static int acl_permission_check(struct inode *inode, int mask)
 {
@@ -271,7 +271,7 @@ int generic_permission(struct inode *inode, int mask)
 	int ret;
 
 	/*
-	 * Do the basic POSIX ACL permission checks.
+	 * Do the basic permission checks.
 	 */
 	ret = acl_permission_check(inode, mask);
 	if (ret != -EACCES)
@@ -335,6 +335,8 @@ static inline int do_inode_permission(struct inode *inode, int mask)
  * We use "fsuid" for this, letting us set arbitrary permissions
  * for filesystem access without changing the "normal" uids which
  * are used for other things.
+ *
+ * When checking for MAY_APPEND, MAY_WRITE must also be set in @mask.
  */
 int inode_permission(struct inode *inode, int mask)
 {
-- 
1.7.5.4


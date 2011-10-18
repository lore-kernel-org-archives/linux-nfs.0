Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e23smtp06.au.ibm.com ([202.81.31.148]:51267 "EHLO
	e23smtp06.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932669Ab1JRPeP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 18 Oct 2011 11:34:15 -0400
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
To: agruen@kernel.org, bfields@fieldses.org, akpm@linux-foundation.org,
        viro@zeniv.linux.org.uk, dhowells@redhat.com
Cc: aneesh.kumar@linux.vnet.ibm.com, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: [PATCH -V7 03/26] vfs: Pass all mask flags down to iop->check_acl
Date: Tue, 18 Oct 2011 21:02:38 +0530
Message-Id: <1318951981-5508-4-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1318951981-5508-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1318951981-5508-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andreas Gruenbacher <agruen@kernel.org>

Some file permission models differentiate between writing to a file
(MAY_WRITE) and appending to it (MAY_WRITE | MAY_APPEND).  Pass all the
mask flags down to iop->check_acl so that filesystems can distinguish
between writing and appending.

All users of iop->check_acl pass the mask value back into
posix_acl_permission(); strip off the additional mask flags there.

Acked-by: David Howells <dhowells@redhat.com>
Signed-off-by: Andreas Gruenbacher <agruen@kernel.org>
Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 fs/namei.c     |    2 --
 fs/posix_acl.c |    2 ++
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/namei.c b/fs/namei.c
index 2a4574f..276cd30 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -227,8 +227,6 @@ static int acl_permission_check(struct inode *inode, int mask)
 {
 	unsigned int mode = inode->i_mode;
 
-	mask &= MAY_READ | MAY_WRITE | MAY_EXEC | MAY_NOT_BLOCK;
-
 	if (current_user_ns() != inode_userns(inode))
 		goto other_perms;
 
diff --git a/fs/posix_acl.c b/fs/posix_acl.c
index 10027b4..cea4623 100644
--- a/fs/posix_acl.c
+++ b/fs/posix_acl.c
@@ -218,6 +218,8 @@ posix_acl_permission(struct inode *inode, const struct posix_acl *acl, int want)
 	const struct posix_acl_entry *pa, *pe, *mask_obj;
 	int found = 0;
 
+	want &= MAY_READ | MAY_WRITE | MAY_EXEC | MAY_NOT_BLOCK;
+
 	FOREACH_ACL_ENTRY(pa, acl, pe) {
                 switch(pa->e_tag) {
                         case ACL_USER_OBJ:
-- 
1.7.5.4


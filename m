Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from e28smtp03.in.ibm.com ([122.248.162.3]:36677 "EHLO
	e28smtp03.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755294Ab1BWNw5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 23 Feb 2011 08:52:57 -0500
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
To: sfrench@us.ibm.com, agruen@linbit.com, dilger.kernel@dilger.ca,
        sandeen@redhat.com, tytso@mit.edu, bfields@fieldses.org,
        jlayton@redhat.com
Cc: aneesh.kumar@linux.vnet.ibm.com, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-ext4@vger.kernel.org,
        linux-kernel@vger.kernel.org, Andreas Gruenbacher <agruen@suse.de>
Subject: [PATCH -V5 02/24] vfs: Pass all mask flags down to iop->check_acl
Date: Wed, 23 Feb 2011 19:21:49 +0530
Message-Id: <1298469131-16555-3-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1298469131-16555-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1298469131-16555-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Andreas Gruenbacher <agruen@suse.de>

Some file permission models differentiate between writing to a file
(MAY_WRITE) and appending to it (MAY_WRITE | MAY_APPEND).  Pass all the
mask flags down to iop->check_acl so that filesystems can distinguish
between writing and appending.

All users of iop->check_acl pass the mask value back into
posix_acl_permission(); strip off the additional mask flags there.

Signed-off-by: Andreas Gruenbacher <agruen@suse.de>
Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 fs/namei.c     |    4 +---
 fs/posix_acl.c |    2 ++
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/fs/namei.c b/fs/namei.c
index b01eab8..f09ab1f 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -174,8 +174,6 @@ static int acl_permission_check(struct inode *inode, int mask, unsigned int flag
 {
 	umode_t			mode = inode->i_mode;
 
-	mask &= MAY_READ | MAY_WRITE | MAY_EXEC;
-
 	if (current_fsuid() == inode->i_uid)
 		mode >>= 6;
 	else {
@@ -192,7 +190,7 @@ static int acl_permission_check(struct inode *inode, int mask, unsigned int flag
 	/*
 	 * If the DACs are ok we don't need any capability check.
 	 */
-	if ((mask & ~mode) == 0)
+	if ((mask & (MAY_READ | MAY_WRITE | MAY_EXEC) & ~mode) == 0)
 		return 0;
 	return -EACCES;
 }
diff --git a/fs/posix_acl.c b/fs/posix_acl.c
index b1cf6bf..ad40df2 100644
--- a/fs/posix_acl.c
+++ b/fs/posix_acl.c
@@ -222,6 +222,8 @@ posix_acl_permission(struct inode *inode, const struct posix_acl *acl, int want)
 	const struct posix_acl_entry *pa, *pe, *mask_obj;
 	int found = 0;
 
+	want &= MAY_READ | MAY_WRITE | MAY_EXEC;
+
 	FOREACH_ACL_ENTRY(pa, acl, pe) {
                 switch(pa->e_tag) {
                         case ACL_USER_OBJ:
-- 
1.7.1


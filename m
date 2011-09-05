Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from e28smtp02.in.ibm.com ([122.248.162.2]:33123 "EHLO
	e28smtp02.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751387Ab1IER1O (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 5 Sep 2011 13:27:14 -0400
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
To: agruen@kernel.org, bfields@fieldses.org, akpm@linux-foundation.org,
        dhowells@redhat.com
Cc: aneesh.kumar@linux.vnet.ibm.com, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: [PATCH -V6 03/26] vfs: Pass all mask flags down to iop->check_acl
Date: Mon,  5 Sep 2011 22:55:25 +0530
Message-Id: <1315243548-18664-4-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1315243548-18664-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1315243548-18664-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Andreas Gruenbacher <agruen@kernel.org>

Some file permission models differentiate between writing to a file
(MAY_WRITE) and appending to it (MAY_WRITE | MAY_APPEND).  Pass all the
mask flags down to iop->check_acl so that filesystems can distinguish
between writing and appending.

All users of iop->check_acl pass the mask value back into
posix_acl_permission(); strip off the additional mask flags there.

Signed-off-by: Andreas Gruenbacher <agruen@kernel.org>
Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 fs/namei.c     |    2 --
 fs/posix_acl.c |    2 ++
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/namei.c b/fs/namei.c
index 9efc638..f34a4d4 100644
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
1.7.4.1


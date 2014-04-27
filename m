Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e23smtp06.au.ibm.com ([202.81.31.148]:40745 "EHLO
	e23smtp06.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753354AbaD0QPk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 27 Apr 2014 12:15:40 -0400
Received: from /spool/local
	by e23smtp06.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Mon, 28 Apr 2014 02:15:38 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
To: agruen@kernel.org, bfields@fieldses.org, akpm@linux-foundation.org,
        viro@zeniv.linux.org.uk, dhowells@redhat.com
Cc: aneesh.kumar@linux.vnet.ibm.com, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: [PATCH -V1 09/22] vfs: Make acl_permission_check() work for richacls
Date: Sun, 27 Apr 2014 21:44:40 +0530
Message-Id: <1398615293-22931-10-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1398615293-22931-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1398615293-22931-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andreas Gruenbacher <agruen@kernel.org>

Signed-off-by: Andreas Gruenbacher <agruen@kernel.org>
Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 fs/namei.c | 13 +++++++++++++
 1 file changed, 13 insertions(+)

diff --git a/fs/namei.c b/fs/namei.c
index 26b9a8212837..06474553c08d 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -284,6 +284,19 @@ static int acl_permission_check(struct inode *inode, int mask)
 {
 	unsigned int mode = inode->i_mode;
 
+	if (IS_RICHACL(inode)) {
+		int error = check_acl(inode, mask);
+		if (error != -EAGAIN)
+			return error;
+		if (mask & (MAY_DELETE_SELF | MAY_TAKE_OWNERSHIP |
+			    MAY_CHMOD | MAY_SET_TIMES)) {
+			/*
+			 * The file permission bit cannot grant these
+			 * permissions.
+			 */
+			return -EACCES;
+		}
+	}
 	if (likely(uid_eq(current_fsuid(), inode->i_uid)))
 		mode >>= 6;
 	else {
-- 
1.9.1


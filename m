Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from e28smtp04.in.ibm.com ([122.248.162.4]:58786 "EHLO
	e28smtp04.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752067Ab1IER1Y (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 5 Sep 2011 13:27:24 -0400
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
To: agruen@kernel.org, bfields@fieldses.org, akpm@linux-foundation.org,
        dhowells@redhat.com
Cc: aneesh.kumar@linux.vnet.ibm.com, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: [PATCH -V6 12/26] vfs: Make acl_permission_check() work for richacls
Date: Mon,  5 Sep 2011 22:55:34 +0530
Message-Id: <1315243548-18664-13-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1315243548-18664-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1315243548-18664-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Andreas Gruenbacher <agruen@kernel.org>

Signed-off-by: Andreas Gruenbacher <agruen@kernel.org>
Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 fs/namei.c |   14 ++++++++++++++
 1 files changed, 14 insertions(+), 0 deletions(-)

diff --git a/fs/namei.c b/fs/namei.c
index a4d61d1..ce67eb1 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -230,6 +230,20 @@ static int acl_permission_check(struct inode *inode, int mask)
 	if (current_user_ns() != inode_userns(inode))
 		goto other_perms;
 
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
+
 	if (likely(current_fsuid() == inode->i_uid))
 		mode >>= 6;
 	else {
-- 
1.7.4.1


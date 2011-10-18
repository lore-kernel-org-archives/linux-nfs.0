Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e23smtp04.au.ibm.com ([202.81.31.146]:51472 "EHLO
	e23smtp04.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932583Ab1JRPeI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 18 Oct 2011 11:34:08 -0400
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
To: agruen@kernel.org, bfields@fieldses.org, akpm@linux-foundation.org,
        viro@zeniv.linux.org.uk, dhowells@redhat.com
Cc: aneesh.kumar@linux.vnet.ibm.com, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: [PATCH -V7 01/26] vfs: Indicate that the permission functions take all the MAY_* flags
Date: Tue, 18 Oct 2011 21:02:36 +0530
Message-Id: <1318951981-5508-2-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1318951981-5508-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1318951981-5508-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andreas Gruenbacher <agruen@kernel.org>

Acked-by: David Howells <dhowells@redhat.com>
Signed-off-by: Andreas Gruenbacher <agruen@kernel.org>
Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 fs/namei.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/namei.c b/fs/namei.c
index 0b3138d..2a4574f 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -257,7 +257,7 @@ other_perms:
 /**
  * generic_permission -  check for access rights on a Posix-like filesystem
  * @inode:	inode to check access rights for
- * @mask:	right to check for (%MAY_READ, %MAY_WRITE, %MAY_EXEC)
+ * @mask:	right to check for (%MAY_READ, %MAY_WRITE, %MAY_EXEC, ...)
  *
  * Used to check for read/write/execute permissions on a file.
  * We use "fsuid" for this, letting us set arbitrary permissions
@@ -331,7 +331,7 @@ static inline int do_inode_permission(struct inode *inode, int mask)
 /**
  * inode_permission  -  check for access rights to a given inode
  * @inode:	inode to check permission on
- * @mask:	right to check for (%MAY_READ, %MAY_WRITE, %MAY_EXEC)
+ * @mask:	right to check for (%MAY_READ, %MAY_WRITE, %MAY_EXEC, ...)
  *
  * Used to check for read/write/execute permissions on an inode.
  * We use "fsuid" for this, letting us set arbitrary permissions
-- 
1.7.5.4


Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from e28smtp08.in.ibm.com ([122.248.162.8]:33448 "EHLO
	e28smtp08.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755299Ab1BWNwz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 23 Feb 2011 08:52:55 -0500
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
To: sfrench@us.ibm.com, agruen@linbit.com, dilger.kernel@dilger.ca,
        sandeen@redhat.com, tytso@mit.edu, bfields@fieldses.org,
        jlayton@redhat.com
Cc: aneesh.kumar@linux.vnet.ibm.com, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-ext4@vger.kernel.org,
        linux-kernel@vger.kernel.org, Andreas Gruenbacher <agruen@suse.de>
Subject: [PATCH -V5 01/24] vfs: Indicate that the permission functions take all the MAY_* flags
Date: Wed, 23 Feb 2011 19:21:48 +0530
Message-Id: <1298469131-16555-2-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
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
 fs/namei.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/fs/namei.c b/fs/namei.c
index 0087cf9..b01eab8 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -200,7 +200,7 @@ static int acl_permission_check(struct inode *inode, int mask, unsigned int flag
 /**
  * generic_permission -  check for access rights on a Posix-like filesystem
  * @inode:	inode to check access rights for
- * @mask:	right to check for (%MAY_READ, %MAY_WRITE, %MAY_EXEC)
+ * @mask:	right to check for (%MAY_READ, %MAY_WRITE, %MAY_EXEC, ...)
  * @check_acl:	optional callback to check for Posix ACLs
  * @flags:	IPERM_FLAG_ flags.
  *
@@ -247,7 +247,7 @@ int generic_permission(struct inode *inode, int mask, unsigned int flags,
 /**
  * inode_permission  -  check for access rights to a given inode
  * @inode:	inode to check permission on
- * @mask:	right to check for (%MAY_READ, %MAY_WRITE, %MAY_EXEC)
+ * @mask:	right to check for (%MAY_READ, %MAY_WRITE, %MAY_EXEC, ...)
  *
  * Used to check for read/write/execute permissions on an inode.
  * We use "fsuid" for this, letting us set arbitrary permissions
@@ -294,7 +294,7 @@ int inode_permission(struct inode *inode, int mask)
 /**
  * file_permission  -  check for additional access rights to a given file
  * @file:	file to check access rights for
- * @mask:	right to check for (%MAY_READ, %MAY_WRITE, %MAY_EXEC)
+ * @mask:	right to check for (%MAY_READ, %MAY_WRITE, %MAY_EXEC, ...)
  *
  * Used to check for read/write/execute permissions on an already opened
  * file.
-- 
1.7.1


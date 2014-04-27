Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e23smtp02.au.ibm.com ([202.81.31.144]:55824 "EHLO
	e23smtp02.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753288AbaD0QPU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 27 Apr 2014 12:15:20 -0400
Received: from /spool/local
	by e23smtp02.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Mon, 28 Apr 2014 02:15:17 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
To: agruen@kernel.org, bfields@fieldses.org, akpm@linux-foundation.org,
        viro@zeniv.linux.org.uk, dhowells@redhat.com
Cc: aneesh.kumar@linux.vnet.ibm.com, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: [PATCH -V1 02/22] vfs: Add IS_RICHACL() test for richacl support
Date: Sun, 27 Apr 2014 21:44:33 +0530
Message-Id: <1398615293-22931-3-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1398615293-22931-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1398615293-22931-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andreas Gruenbacher <agruen@kernel.org>

Introduce a new MS_RICHACL super-block flag and a new IS_RICHACL() test
which file systems like nfs can use.  IS_ACL() is true if IS_POSIXACL()
or IS_RICHACL() is true.

Signed-off-by: Andreas Gruenbacher <agruen@kernel.org>
Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 include/linux/fs.h      | 3 ++-
 include/uapi/linux/fs.h | 1 +
 2 files changed, 3 insertions(+), 1 deletion(-)

diff --git a/include/linux/fs.h b/include/linux/fs.h
index 9fb63b71a014..1a7fe920f956 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1601,6 +1601,7 @@ struct super_operations {
 #define IS_APPEND(inode)	((inode)->i_flags & S_APPEND)
 #define IS_IMMUTABLE(inode)	((inode)->i_flags & S_IMMUTABLE)
 #define IS_POSIXACL(inode)	__IS_FLG(inode, MS_POSIXACL)
+#define IS_RICHACL(inode)	__IS_FLG(inode, MS_RICHACL)
 
 #define IS_DEADDIR(inode)	((inode)->i_flags & S_DEAD)
 #define IS_NOCMTIME(inode)	((inode)->i_flags & S_NOCMTIME)
@@ -1614,7 +1615,7 @@ struct super_operations {
  * IS_ACL() tells the VFS to not apply the umask
  * and use check_acl for acl permission checks when defined.
  */
-#define IS_ACL(inode)		__IS_FLG(inode, MS_POSIXACL)
+#define IS_ACL(inode)		__IS_FLG(inode, MS_POSIXACL | MS_RICHACL)
 
 /*
  * Inode state bits.  Protected by inode->i_lock
diff --git a/include/uapi/linux/fs.h b/include/uapi/linux/fs.h
index 1e14b9c82703..894fbc2bebb3 100644
--- a/include/uapi/linux/fs.h
+++ b/include/uapi/linux/fs.h
@@ -89,6 +89,7 @@ struct inodes_stat_t {
 #define MS_KERNMOUNT	(1<<22) /* this is a kern_mount call */
 #define MS_I_VERSION	(1<<23) /* Update inode I_version field */
 #define MS_STRICTATIME	(1<<24) /* Always perform atime updates */
+#define MS_RICHACL	(1<<25) /* Supports richacls */
 
 /* These sb flags are internal to the kernel */
 #define MS_NOSEC	(1<<28)
-- 
1.9.1


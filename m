Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e23smtp08.au.ibm.com ([202.81.31.141]:51968 "EHLO
	e23smtp08.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753928Ab1JWRoj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 23 Oct 2011 13:44:39 -0400
Received: from /spool/local
	by e23smtp08.au.ibm.com with XMail ESMTP
	for <linux-nfs@vger.kernel.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Sun, 23 Oct 2011 17:43:19 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
To: agruen@kernel.org, bfields@fieldses.org, akpm@linux-foundation.org,
        viro@zeniv.linux.org.uk, dhowells@redhat.com
Cc: aneesh.kumar@linux.vnet.ibm.com, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: [PATCH -V8 06/26] vfs: Add IS_RICHACL() test for richacl support
Date: Sun, 23 Oct 2011 23:13:35 +0530
Message-Id: <1319391835-5829-7-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1319391835-5829-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1319391835-5829-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andreas Gruenbacher <agruen@kernel.org>

Introduce a new MS_RICHACL super-block flag and a new IS_RICHACL() test
which file systems like nfs can use.  IS_ACL() is true if IS_POSIXACL()
or IS_RICHACL() is true.

Acked-by: J. Bruce Fields <bfields@redhat.com>
Acked-by: David Howells <dhowells@redhat.com>
Signed-off-by: Andreas Gruenbacher <agruen@kernel.org>
Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 include/linux/fs.h |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/include/linux/fs.h b/include/linux/fs.h
index 1994b84..7b4bfe6 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -210,6 +210,7 @@ struct inodes_stat_t {
 #define MS_KERNMOUNT	(1<<22) /* this is a kern_mount call */
 #define MS_I_VERSION	(1<<23) /* Update inode I_version field */
 #define MS_STRICTATIME	(1<<24) /* Always perform atime updates */
+#define MS_RICHACL	(1<<25) /* Supports richacls */
 #define MS_NOSEC	(1<<28)
 #define MS_BORN		(1<<29)
 #define MS_ACTIVE	(1<<30)
@@ -270,6 +271,7 @@ struct inodes_stat_t {
 #define IS_APPEND(inode)	((inode)->i_flags & S_APPEND)
 #define IS_IMMUTABLE(inode)	((inode)->i_flags & S_IMMUTABLE)
 #define IS_POSIXACL(inode)	__IS_FLG(inode, MS_POSIXACL)
+#define IS_RICHACL(inode)	__IS_FLG(inode, MS_RICHACL)
 
 #define IS_DEADDIR(inode)	((inode)->i_flags & S_DEAD)
 #define IS_NOCMTIME(inode)	((inode)->i_flags & S_NOCMTIME)
@@ -283,7 +285,7 @@ struct inodes_stat_t {
  * IS_ACL() tells the VFS to not apply the umask
  * and use check_acl for acl permission checks when defined.
  */
-#define IS_ACL(inode)		__IS_FLG(inode, MS_POSIXACL)
+#define IS_ACL(inode)		__IS_FLG(inode, MS_POSIXACL | MS_RICHACL)
 
 /* the read-only stuff doesn't really belong here, but any other place is
    probably as bad and I don't want to create yet another include file. */
-- 
1.7.5.4


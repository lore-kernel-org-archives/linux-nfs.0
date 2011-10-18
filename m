Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e23smtp01.au.ibm.com ([202.81.31.143]:37395 "EHLO
	e23smtp01.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932759Ab1JRPea (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 18 Oct 2011 11:34:30 -0400
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
To: agruen@kernel.org, bfields@fieldses.org, akpm@linux-foundation.org,
        viro@zeniv.linux.org.uk, dhowells@redhat.com
Cc: aneesh.kumar@linux.vnet.ibm.com, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: [PATCH -V7 07/26] vfs: Optimize out IS_RICHACL() if CONFIG_FS_RICHACL is not defined
Date: Tue, 18 Oct 2011 21:02:42 +0530
Message-Id: <1318951981-5508-8-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1318951981-5508-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1318951981-5508-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andreas Gruenbacher <agruen@kernel.org>

if CONFIG_FS_RICHACL is not defined optimize out
the ACL check function.

Acked-by: David Howells <dhowells@redhat.com>
Signed-off-by: Andreas Gruenbacher <agruen@kernel.org>
Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 fs/Kconfig         |    3 +++
 include/linux/fs.h |    5 +++++
 2 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/fs/Kconfig b/fs/Kconfig
index 9fe0b34..7939190 100644
--- a/fs/Kconfig
+++ b/fs/Kconfig
@@ -46,6 +46,9 @@ endif # BLOCK
 config FS_POSIX_ACL
 	def_bool n
 
+config FS_RICHACL
+	def_bool n
+
 config EXPORTFS
 	tristate
 
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 7b4bfe6..f3ebf86 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -271,7 +271,12 @@ struct inodes_stat_t {
 #define IS_APPEND(inode)	((inode)->i_flags & S_APPEND)
 #define IS_IMMUTABLE(inode)	((inode)->i_flags & S_IMMUTABLE)
 #define IS_POSIXACL(inode)	__IS_FLG(inode, MS_POSIXACL)
+
+#ifdef CONFIG_FS_RICHACL
 #define IS_RICHACL(inode)	__IS_FLG(inode, MS_RICHACL)
+#else
+#define IS_RICHACL(inode)	0
+#endif
 
 #define IS_DEADDIR(inode)	((inode)->i_flags & S_DEAD)
 #define IS_NOCMTIME(inode)	((inode)->i_flags & S_NOCMTIME)
-- 
1.7.5.4


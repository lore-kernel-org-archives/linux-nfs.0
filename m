Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from e28smtp09.in.ibm.com ([122.248.162.9]:40979 "EHLO
	e28smtp09.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752058Ab1IER1X (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 5 Sep 2011 13:27:23 -0400
Received: from /spool/local
	by in.ibm.com with XMail ESMTP
	for <linux-nfs@vger.kernel.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Mon, 5 Sep 2011 22:57:21 +0530
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
To: agruen@kernel.org, bfields@fieldses.org, akpm@linux-foundation.org,
        dhowells@redhat.com
Cc: aneesh.kumar@linux.vnet.ibm.com, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: [PATCH -V6 07/26] vfs: Optimize out IS_RICHACL() if CONFIG_FS_RICHACL is not defined
Date: Mon,  5 Sep 2011 22:55:29 +0530
Message-Id: <1315243548-18664-8-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1315243548-18664-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1315243548-18664-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Andreas Gruenbacher <agruen@kernel.org>

if CONFIG_FS_RICHACL is not defined optimize out
the ACL check function.

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
index 6eac730..1ddec24 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -273,7 +273,12 @@ struct inodes_stat_t {
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
1.7.4.1


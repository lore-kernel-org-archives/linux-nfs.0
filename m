From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [RFC PATCH 3/8] nfsv4: Add support for posix ACL
Date: Wed,  2 Sep 2009 17:54:23 +0530
Message-ID: <1251894268-1555-4-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1251894268-1555-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@netapp.com, bfields@fieldses.org,
	nfsv4@linux-nfs.org, ffilzlnx@us.ibm.com, agruen@suse.de,
	aneesh.kumar@linux.vnet.ibm.com, sfrench@us.ibm.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from e28smtp04.in.ibm.com ([59.145.155.4]:53347 "EHLO
	e28smtp04.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751405AbZIBMZC (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 2 Sep 2009 08:25:02 -0400
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by e28smtp04.in.ibm.com (8.14.3/8.13.1) with ESMTP id n82CP1um029471
	for <linux-nfs@vger.kernel.org>; Wed, 2 Sep 2009 17:55:01 +0530
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n82CP1m21941728
	for <linux-nfs@vger.kernel.org>; Wed, 2 Sep 2009 17:55:01 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id n82COxdK001407
	for <linux-nfs@vger.kernel.org>; Wed, 2 Sep 2009 22:25:00 +1000
In-Reply-To: <1251894268-1555-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add posix ACL support. This implements POSIX over NFSV4 ACL.

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 fs/nfs/Kconfig    |    6 +++++
 fs/nfs/Makefile   |    1 +
 fs/nfs/nfs4pacl.c |   62 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 fs/nfs/nfs4proc.c |    7 +++++-
 4 files changed, 75 insertions(+), 1 deletions(-)
 create mode 100644 fs/nfs/nfs4pacl.c

diff --git a/fs/nfs/Kconfig b/fs/nfs/Kconfig
index 2a77bc2..744ea00 100644
--- a/fs/nfs/Kconfig
+++ b/fs/nfs/Kconfig
@@ -101,3 +101,9 @@ config NFS_FSCACHE
 	help
 	  Say Y here if you want NFS data to be cached locally on disc through
 	  the general filesystem cache manager
+
+config NFS4_FS_POSIX_ACL
+       bool "NFS client support for NFSV4 posix acl support"
+       depends on NFS_V4
+       help
+         This option enables support for modifying POSIX ACL from NFS clients
diff --git a/fs/nfs/Makefile b/fs/nfs/Makefile
index 8451598..f888f5c 100644
--- a/fs/nfs/Makefile
+++ b/fs/nfs/Makefile
@@ -16,3 +16,4 @@ nfs-$(CONFIG_NFS_V4)	+= nfs4proc.o nfs4xdr.o nfs4state.o nfs4renewd.o \
 			   nfs4namespace.o
 nfs-$(CONFIG_SYSCTL) += sysctl.o
 nfs-$(CONFIG_NFS_FSCACHE) += fscache.o fscache-index.o
+nfs-$(CONFIG_NFS4_FS_POSIX_ACL) += nfs4pacl.o
diff --git a/fs/nfs/nfs4pacl.c b/fs/nfs/nfs4pacl.c
new file mode 100644
index 0000000..c1c2b04
--- /dev/null
+++ b/fs/nfs/nfs4pacl.c
@@ -0,0 +1,62 @@
+#include <linux/fs.h>
+#include <linux/nfs.h>
+#include <linux/nfs3.h>
+#include <linux/nfs_fs.h>
+#include <linux/posix_acl_xattr.h>
+#include <linux/nfsacl.h>
+#include <linux/xattr.h>
+
+#include "internal.h"
+
+static size_t nfs4_xattr_list_pacl_default(struct inode *inode, char *list,
+				size_t list_len, const char *name,
+				size_t name_len)
+{
+	return 0;
+}
+
+static int nfs4_xattr_get_pacl_default(struct inode *inode, const char *key,
+				void *buf, size_t buflen)
+{
+	return -EOPNOTSUPP;
+}
+
+static int nfs4_xattr_set_pacl_default(struct inode *inode, const char *key,
+			const void *buf, size_t buflen, int flags)
+{
+	return -EOPNOTSUPP;
+}
+
+struct xattr_handler nfs4_xattr_pacl_default_handler = {
+	.prefix	= POSIX_ACL_XATTR_DEFAULT,
+	.list	= nfs4_xattr_list_pacl_default,
+	.get	= nfs4_xattr_get_pacl_default,
+	.set	= nfs4_xattr_set_pacl_default,
+};
+
+static size_t nfs4_xattr_list_pacl_access(struct inode *inode, char *list,
+				size_t list_len, const char *name,
+				size_t name_len)
+{
+	return 0;
+}
+
+static int nfs4_xattr_get_pacl_access(struct inode *inode, const char *key,
+				void *buf, size_t buflen)
+{
+	return -EOPNOTSUPP;
+}
+
+static int nfs4_xattr_set_pacl_access(struct inode *inode, const char *key,
+			const void *buf, size_t buflen, int flags)
+{
+	return -EOPNOTSUPP;
+}
+
+
+struct xattr_handler nfs4_xattr_pacl_access_handler = {
+	.prefix	= POSIX_ACL_XATTR_ACCESS,
+	.list	= nfs4_xattr_list_pacl_access,
+	.get	= nfs4_xattr_get_pacl_access,
+	.set	= nfs4_xattr_set_pacl_access,
+};
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index fa60261..eb93426 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5035,9 +5035,14 @@ struct xattr_handler nfs4_xattr_nfs4_acl_handler = {
 	.get	= nfs4_xattr_get_nfs4_acl,
 	.set	= nfs4_xattr_set_nfs4_acl,
 };
-
+extern struct xattr_handler nfs4_xattr_pacl_access_handler;
+extern struct xattr_handler nfs4_xattr_pacl_default_handler;
 struct xattr_handler *nfs4_xattr_handlers[] = {
 	&nfs4_xattr_nfs4_acl_handler,
+#ifdef CONFIG_NFS4_FS_POSIX_ACL
+	&nfs4_xattr_pacl_access_handler,
+	&nfs4_xattr_pacl_default_handler,
+#endif
 	NULL
 };
 
-- 
1.6.4.2.253.g0b1fac


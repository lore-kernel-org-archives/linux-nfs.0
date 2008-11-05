From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 2/8] NFS: Move declaration of nfs_mount() to fs/nfs/internal.h
Date: Wed, 05 Nov 2008 15:24:58 -0500
Message-ID: <20081105202458.14469.28846.stgit@ingres.1015granger.net>
References: <20081105202040.14469.32458.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:38392 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756714AbYKEUZ3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Nov 2008 15:25:29 -0500
In-Reply-To: <20081105202040.14469.32458.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up:  The nfs_mount() function is not to be used outside of the
NFS client.  Move its public declaration to fs/nfs/internal.h.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/internal.h      |    4 ++++
 fs/nfs/nfsroot.c       |    2 ++
 include/linux/nfs_fs.h |    6 ------
 3 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 4f484fe..0134e59 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -63,6 +63,10 @@ struct nfs_parsed_mount_data {
 	struct security_mnt_opts lsm_opts;
 };
 
+/* mount_clnt.c */
+extern int nfs_mount(struct sockaddr *, size_t, char *, char *,
+					int, int, struct nfs_fh *);
+
 /* client.c */
 extern struct rpc_program nfs_program;
 
diff --git a/fs/nfs/nfsroot.c b/fs/nfs/nfsroot.c
index f1c0a06..a96e5fd 100644
--- a/fs/nfs/nfsroot.c
+++ b/fs/nfs/nfsroot.c
@@ -86,6 +86,8 @@
 #include <net/ipconfig.h>
 #include <linux/parser.h>
 
+#include "internal.h"
+
 /* Define this to allow debugging output */
 #undef NFSROOT_DEBUG
 #define NFSDBG_FACILITY NFSDBG_ROOT
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index 4eaa834..f110772 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -533,12 +533,6 @@ static inline void nfs3_forget_cached_acls(struct inode *inode)
 #endif /* CONFIG_NFS_V3_ACL */
 
 /*
- * linux/fs/mount_clnt.c
- */
-extern int  nfs_mount(struct sockaddr *, size_t, char *, char *,
-		      int, int, struct nfs_fh *);
-
-/*
  * inline functions
  */
 


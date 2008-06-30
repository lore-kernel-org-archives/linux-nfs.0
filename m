From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 3/7] mount command: don't include headers multiple times
Date: Mon, 30 Jun 2008 13:10:24 -0400
Message-ID: <20080630171023.9905.21675.stgit@ellison.1015granger.net>
References: <20080630170420.9905.90111.stgit@ellison.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:29995 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752563AbYF3RLi (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Jun 2008 13:11:38 -0400
In-Reply-To: <20080630170420.9905.90111.stgit-ewv44WTpT0t9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: add the traditional pre-processor safety check in headers under
utils/mount to prevent them from being included multiple times.

For headers that already have this, use a more unique macro name to reduce the
probability that some other header may use the same macro.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/error.h           |    5 +++++
 utils/mount/fstab.h           |    7 +++----
 utils/mount/mount_constants.h |    6 +++---
 utils/mount/network.h         |    5 +++++
 utils/mount/nfs_mount.h       |    6 +++---
 utils/mount/parse_opt.h       |    5 +++++
 utils/mount/stropts.h         |    5 +++++
 utils/mount/token.h           |    5 +++++
 8 files changed, 34 insertions(+), 10 deletions(-)


diff --git a/utils/mount/error.h b/utils/mount/error.h
index 8b8e9ae..7126de5 100644
--- a/utils/mount/error.h
+++ b/utils/mount/error.h
@@ -21,6 +21,9 @@
  *
  */
 
+#ifndef _NFS_UTILS_MOUNT_ERROR_H
+#define _NFS_UTILS_MOUNT_ERROR_H
+
 char *nfs_strerror(int);
 
 void mount_error(const char *, const char *, int);
@@ -28,3 +31,5 @@ void rpc_mount_errors(char *, int, int);
 void sys_mount_errors(char *, int, int, int);
 
 void umount_error(int, const char *);
+
+#endif	/* _NFS_UTILS_MOUNT_ERROR_H */
diff --git a/utils/mount/fstab.h b/utils/mount/fstab.h
index 64c8355..37f17e1 100644
--- a/utils/mount/fstab.h
+++ b/utils/mount/fstab.h
@@ -1,5 +1,5 @@
-#ifndef _NFS_FSTAB_H
-#define _NFS_FSTAB_H
+#ifndef _NFS_UTILS_MOUNT_FSTAB_H
+#define _NFS_UTILS_MOUNT_FSTAB_H
 
 #include "nfs_mntent.h"
 
@@ -26,5 +26,4 @@ void lock_mtab (void);
 void unlock_mtab (void);
 void update_mtab (const char *special, struct mntent *with);
 
-#endif /* _NFS_FSTAB_H */
-
+#endif	/* _NFS_UTILS_MOUNT_FSTAB_H */
diff --git a/utils/mount/mount_constants.h b/utils/mount/mount_constants.h
index 4f3c729..cbfb099 100644
--- a/utils/mount/mount_constants.h
+++ b/utils/mount/mount_constants.h
@@ -1,5 +1,5 @@
-#ifndef _NFS_MOUNT_CONSTANTS_H
-#define _NFS_MOUNT_CONSTANTS_H
+#ifndef _NFS_UTILS_MOUNT_CONSTANTS_H
+#define _NFS_UTILS_MOUNT_CONSTANTS_H
 
 #ifndef MS_DIRSYNC
 #define MS_DIRSYNC	128	/* Directory modifications are synchronous */
@@ -64,4 +64,4 @@ if we have a stack or plain mount - mount atop of it, forming a stack. */
 #define MS_MGC_MSK 0xffff0000	/* magic flag number mask */
 #endif
 
-#endif /* _NFS_MOUNT_CONSTANTS_H */
+#endif	/* _NFS_UTILS_MOUNT_CONSTANTS_H */
diff --git a/utils/mount/network.h b/utils/mount/network.h
index 99ecc1e..e0a5dd5 100644
--- a/utils/mount/network.h
+++ b/utils/mount/network.h
@@ -21,6 +21,9 @@
  *
  */
 
+#ifndef _NFS_UTILS_MOUNT_NETWORK_H
+#define _NFS_UTILS_MOUNT_NETWORK_H
+
 #include <rpc/pmap_prot.h>
 #include <rpc/clnt.h>
 
@@ -60,3 +63,5 @@ unsigned long nfsvers_to_mnt(const unsigned long);
 
 CLIENT *mnt_openclnt(clnt_addr_t *, int *);
 void mnt_closeclnt(CLIENT *, int);
+
+#endif	/* _NFS_UTILS_MOUNT_NETWORK_H */
diff --git a/utils/mount/nfs_mount.h b/utils/mount/nfs_mount.h
index 7df8fb2..2becfb1 100644
--- a/utils/mount/nfs_mount.h
+++ b/utils/mount/nfs_mount.h
@@ -8,8 +8,8 @@
  * so it is easiest to ignore the kernel altogether (at compile time).
  */
 
-#ifndef _NFS_MOUNT_H
-#define _NFS_MOUNT_H
+#ifndef _NFS_UTILS_MOUNT_NFS_MOUNT_H
+#define _NFS_UTILS_MOUNT_NFS_MOUNT_H
 
 #include <netinet/in.h>
 #include <arpa/inet.h>
@@ -83,4 +83,4 @@ struct nfs_mount_data {
 int	nfsmount(const char *, const char *, int , char **, int, int);
 int	nfsumount(int, char **);
 
-#endif /* _NFS_MOUNT_H */
+#endif	/* _NFS_UTILS_MOUNT_NFS_MOUNT_H */
diff --git a/utils/mount/parse_opt.h b/utils/mount/parse_opt.h
index e7924dd..fb003c3 100644
--- a/utils/mount/parse_opt.h
+++ b/utils/mount/parse_opt.h
@@ -21,6 +21,9 @@
  *
  */
 
+#ifndef _NFS_UTILS_PARSE_OPT_H
+#define _NFS_UTILS_PARSE_OPT_H
+
 typedef enum {
 	PO_FAILED = 0,
 	PO_SUCCEEDED = 1,
@@ -50,3 +53,5 @@ char *			po_get(struct mount_options *, char *);
 po_rightmost_t		po_rightmost(struct mount_options *, char *, char *);
 po_found_t		po_remove_all(struct mount_options *, char *);
 void			po_destroy(struct mount_options *);
+
+#endif	/* _NFS_UTILS_PARSE_OPT_H */
diff --git a/utils/mount/stropts.h b/utils/mount/stropts.h
index b926d68..b4fd888 100644
--- a/utils/mount/stropts.h
+++ b/utils/mount/stropts.h
@@ -21,5 +21,10 @@
  *
  */
 
+#ifndef _NFS_UTILS_MOUNT_STROPTS_H
+#define _NFS_UTILS_MOUNT_STROPTS_H
+
 int nfsmount_string(const char *, const char *, const char *, int,
 			char **, int, int);
+
+#endif	/* _NFS_UTILS_MOUNT_STROPTS_H */
diff --git a/utils/mount/token.h b/utils/mount/token.h
index 47762dc..5a675ed 100644
--- a/utils/mount/token.h
+++ b/utils/mount/token.h
@@ -21,9 +21,14 @@
  *
  */
 
+#ifndef _NFS_UTILS_MOUNT_TOKEN_H
+#define _NFS_UTILS_MOUNT_TOKEN_H
+
 struct tokenizer_state;
 
 char *next_token(struct tokenizer_state *);
 struct tokenizer_state *init_tokenizer(char *, char);
 int tokenizer_error(struct tokenizer_state *);
 void end_tokenizer(struct tokenizer_state *);
+
+#endif	/* _NFS_UTILS_MOUNT_TOKEN_H */


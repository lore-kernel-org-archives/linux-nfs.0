From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 1/2] nfsd: move nfsd/auth.h into fs/nfsd
Date: Thu, 15 Nov 2007 17:53:51 -0500
Message-ID: <1195167232-30238-1-git-send-email-bfields@citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-nfs@vger.kernel.org,
	"Robert P. J. Day" <rpjday@crashcourse.ca>,
	nfs@lists.sourceforge.net, "J. Bruce Fields" <bfields@citi.umich.edu>
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net
List-ID: <linux-nfs.vger.kernel.org>

This header is used only in a few places in fs/nfsd, so there seems to
be little point to having it in include/.  (Thanks to Robert Day for
pointing this out.)

Cc: Robert P. J. Day <rpjday@crashcourse.ca>
Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/nfsd/auth.h               |   27 +++++++++++++++++++++++++++
 fs/nfsd/nfs3xdr.c            |    1 +
 fs/nfsd/nfsfh.c              |    1 +
 fs/nfsd/nfsxdr.c             |    1 +
 include/linux/nfsd/Kbuild    |    1 -
 include/linux/nfsd/auth.h    |   27 ---------------------------
 include/linux/nfsd/nfsd.h    |    1 -
 include/linux/nfsd/syscall.h |    1 -
 8 files changed, 30 insertions(+), 30 deletions(-)
 create mode 100644 fs/nfsd/auth.h
 delete mode 100644 include/linux/nfsd/auth.h

diff --git a/fs/nfsd/auth.h b/fs/nfsd/auth.h
new file mode 100644
index 0000000..0fb9f72
--- /dev/null
+++ b/fs/nfsd/auth.h
@@ -0,0 +1,27 @@
+/*
+ * include/linux/nfsd/auth.h
+ *
+ * nfsd-specific authentication stuff.
+ * uid/gid mapping not yet implemented.
+ *
+ * Copyright (C) 1995, 1996 Olaf Kirch <okir@monad.swb.de>
+ */
+
+#ifndef LINUX_NFSD_AUTH_H
+#define LINUX_NFSD_AUTH_H
+
+#ifdef __KERNEL__
+
+#define nfsd_luid(rq, uid)	((u32)(uid))
+#define nfsd_lgid(rq, gid)	((u32)(gid))
+#define nfsd_ruid(rq, uid)	((u32)(uid))
+#define nfsd_rgid(rq, gid)	((u32)(gid))
+
+/*
+ * Set the current process's fsuid/fsgid etc to those of the NFS
+ * client user
+ */
+int nfsd_setuser(struct svc_rqst *, struct svc_export *);
+
+#endif /* __KERNEL__ */
+#endif /* LINUX_NFSD_AUTH_H */
diff --git a/fs/nfsd/nfs3xdr.c b/fs/nfsd/nfs3xdr.c
index 9aefa95..1fd897d 100644
--- a/fs/nfsd/nfs3xdr.c
+++ b/fs/nfsd/nfs3xdr.c
@@ -21,6 +21,7 @@
 #include <linux/sunrpc/svc.h>
 #include <linux/nfsd/nfsd.h>
 #include <linux/nfsd/xdr3.h>
+#include "auth.h"
 
 #define NFSDDBG_FACILITY		NFSDDBG_XDR
 
diff --git a/fs/nfsd/nfsfh.c b/fs/nfsd/nfsfh.c
index 468f17a..8fbd2dc 100644
--- a/fs/nfsd/nfsfh.c
+++ b/fs/nfsd/nfsfh.c
@@ -22,6 +22,7 @@
 #include <linux/sunrpc/svc.h>
 #include <linux/sunrpc/svcauth_gss.h>
 #include <linux/nfsd/nfsd.h>
+#include "auth.h"
 
 #define NFSDDBG_FACILITY		NFSDDBG_FH
 
diff --git a/fs/nfsd/nfsxdr.c b/fs/nfsd/nfsxdr.c
index 1c16885..383d6d2 100644
--- a/fs/nfsd/nfsxdr.c
+++ b/fs/nfsd/nfsxdr.c
@@ -15,6 +15,7 @@
 #include <linux/nfsd/nfsd.h>
 #include <linux/nfsd/xdr.h>
 #include <linux/mm.h>
+#include "auth.h"
 
 #define NFSDDBG_FACILITY		NFSDDBG_XDR
 
diff --git a/include/linux/nfsd/Kbuild b/include/linux/nfsd/Kbuild
index d9c5455..e726fc3 100644
--- a/include/linux/nfsd/Kbuild
+++ b/include/linux/nfsd/Kbuild
@@ -4,4 +4,3 @@ unifdef-y += stats.h
 unifdef-y += syscall.h
 unifdef-y += nfsfh.h
 unifdef-y += debug.h
-unifdef-y += auth.h
diff --git a/include/linux/nfsd/auth.h b/include/linux/nfsd/auth.h
deleted file mode 100644
index 0fb9f72..0000000
--- a/include/linux/nfsd/auth.h
+++ /dev/null
@@ -1,27 +0,0 @@
-/*
- * include/linux/nfsd/auth.h
- *
- * nfsd-specific authentication stuff.
- * uid/gid mapping not yet implemented.
- *
- * Copyright (C) 1995, 1996 Olaf Kirch <okir@monad.swb.de>
- */
-
-#ifndef LINUX_NFSD_AUTH_H
-#define LINUX_NFSD_AUTH_H
-
-#ifdef __KERNEL__
-
-#define nfsd_luid(rq, uid)	((u32)(uid))
-#define nfsd_lgid(rq, gid)	((u32)(gid))
-#define nfsd_ruid(rq, uid)	((u32)(uid))
-#define nfsd_rgid(rq, gid)	((u32)(gid))
-
-/*
- * Set the current process's fsuid/fsgid etc to those of the NFS
- * client user
- */
-int nfsd_setuser(struct svc_rqst *, struct svc_export *);
-
-#endif /* __KERNEL__ */
-#endif /* LINUX_NFSD_AUTH_H */
diff --git a/include/linux/nfsd/nfsd.h b/include/linux/nfsd/nfsd.h
index a51a30f..8caf4c4 100644
--- a/include/linux/nfsd/nfsd.h
+++ b/include/linux/nfsd/nfsd.h
@@ -20,7 +20,6 @@
 #include <linux/nfsd/debug.h>
 #include <linux/nfsd/nfsfh.h>
 #include <linux/nfsd/export.h>
-#include <linux/nfsd/auth.h>
 #include <linux/nfsd/stats.h>
 /*
  * nfsd version
diff --git a/include/linux/nfsd/syscall.h b/include/linux/nfsd/syscall.h
index 8bcddcc..4e43976 100644
--- a/include/linux/nfsd/syscall.h
+++ b/include/linux/nfsd/syscall.h
@@ -18,7 +18,6 @@
 #include <linux/nfsd/const.h>
 #include <linux/nfsd/export.h>
 #include <linux/nfsd/nfsfh.h>
-#include <linux/nfsd/auth.h>
 
 /*
  * Version of the syscall interface
-- 
1.5.3.5.561.g140d


-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

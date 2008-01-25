From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 024/100] nfsd: move nfsd/auth.h into fs/nfsd
Date: Fri, 25 Jan 2008 18:16:04 -0500
Message-ID: <1201303040-7779-24-git-send-email-bfields@citi.umich.edu>
References: <20080125231521.GG25141@fieldses.org>
 <1201303040-7779-1-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-2-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-3-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-4-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-5-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-6-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-7-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-8-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-9-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-10-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-11-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-12-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-13-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-14-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-15-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-16-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-17-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-18-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-19-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-20-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-21-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-22-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-23-git-send-email-bfields@citi.umich.edu>
Cc: "J. Bruce Fields" <bfields@citi.umich.edu>,
	"Robert P. J. Day" <rpjday-L09J2beyid0N/H6P543EQg@public.gmane.org>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:47376 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762135AbYAYXRe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jan 2008 18:17:34 -0500
In-Reply-To: <1201303040-7779-23-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This header is used only in a few places in fs/nfsd, so there seems to
be little point to having it in include/.  (Thanks to Robert Day for
pointing this out.)

Cc: Robert P. J. Day <rpjday-L09J2beyid0N/H6P543EQg@public.gmane.org>
Acked-by: NeilBrown <neilb@suse.de>
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
+ * Copyright (C) 1995, 1996 Olaf Kirch <okir-pn4DOG8n3UYbFoVRYvo4fw@public.gmane.org>
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
index be515c5..4b1ffe3 100644
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
index 7003c31..61ad617 100644
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
- * Copyright (C) 1995, 1996 Olaf Kirch <okir-pn4DOG8n3UYbFoVRYvo4fw@public.gmane.org>
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
1.5.4.rc2.60.gb2e62


From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 21/27] NSM: Remove include/linux/lockd/sm_inter.h
Date: Fri, 05 Dec 2008 19:04:32 -0500
Message-ID: <20081206000431.24075.28601.stgit@ingres.1015granger.net>
References: <20081205235557.24075.12511.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:25922 "EHLO
	rgminet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755848AbYLFAJl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 5 Dec 2008 19:09:41 -0500
In-Reply-To: <20081205235557.24075.12511.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: The include/linux/lockd/sm_inter.h header is nearly empty
now.  Remove it.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/lockd/clntproc.c            |    1 -
 fs/lockd/host.c                |    1 -
 fs/lockd/mon.c                 |    2 --
 fs/lockd/svc.c                 |    1 -
 fs/lockd/svc4proc.c            |    2 --
 fs/lockd/svcproc.c             |    2 --
 fs/lockd/svcsubs.c             |    1 -
 fs/lockd/xdr.c                 |    1 -
 fs/lockd/xdr4.c                |    1 -
 include/linux/lockd/lockd.h    |    1 +
 include/linux/lockd/sm_inter.h |   16 ----------------
 include/linux/lockd/xdr.h      |    1 +
 12 files changed, 2 insertions(+), 28 deletions(-)
 delete mode 100644 include/linux/lockd/sm_inter.h

diff --git a/fs/lockd/clntproc.c b/fs/lockd/clntproc.c
index 5ce42e0..dd79570 100644
--- a/fs/lockd/clntproc.c
+++ b/fs/lockd/clntproc.c
@@ -16,7 +16,6 @@
 #include <linux/sunrpc/clnt.h>
 #include <linux/sunrpc/svc.h>
 #include <linux/lockd/lockd.h>
-#include <linux/lockd/sm_inter.h>
 
 #define NLMDBG_FACILITY		NLMDBG_CLIENT
 #define NLMCLNT_GRACE_WAIT	(5*HZ)
diff --git a/fs/lockd/host.c b/fs/lockd/host.c
index e5a65df..99d737b 100644
--- a/fs/lockd/host.c
+++ b/fs/lockd/host.c
@@ -15,7 +15,6 @@
 #include <linux/sunrpc/clnt.h>
 #include <linux/sunrpc/svc.h>
 #include <linux/lockd/lockd.h>
-#include <linux/lockd/sm_inter.h>
 #include <linux/mutex.h>
 
 #include <net/ipv6.h>
diff --git a/fs/lockd/mon.c b/fs/lockd/mon.c
index 4113ed1..97011ee 100644
--- a/fs/lockd/mon.c
+++ b/fs/lockd/mon.c
@@ -13,8 +13,6 @@
 #include <linux/sunrpc/xprtsock.h>
 #include <linux/sunrpc/svc.h>
 #include <linux/lockd/lockd.h>
-#include <linux/lockd/sm_inter.h>
-
 
 #define NLMDBG_FACILITY		NLMDBG_MONITOR
 #define NSM_PROGRAM		100024
diff --git a/fs/lockd/svc.c b/fs/lockd/svc.c
index c631a83..50de426 100644
--- a/fs/lockd/svc.c
+++ b/fs/lockd/svc.c
@@ -35,7 +35,6 @@
 #include <linux/sunrpc/svcsock.h>
 #include <net/ip.h>
 #include <linux/lockd/lockd.h>
-#include <linux/lockd/sm_inter.h>
 #include <linux/nfs.h>
 
 #define NLMDBG_FACILITY		NLMDBG_SVC
diff --git a/fs/lockd/svc4proc.c b/fs/lockd/svc4proc.c
index bb79a53..1725037 100644
--- a/fs/lockd/svc4proc.c
+++ b/fs/lockd/svc4proc.c
@@ -16,8 +16,6 @@
 #include <linux/nfsd/nfsd.h>
 #include <linux/lockd/lockd.h>
 #include <linux/lockd/share.h>
-#include <linux/lockd/sm_inter.h>
-
 
 #define NLMDBG_FACILITY		NLMDBG_CLIENT
 
diff --git a/fs/lockd/svcproc.c b/fs/lockd/svcproc.c
index e44310c..3688e55 100644
--- a/fs/lockd/svcproc.c
+++ b/fs/lockd/svcproc.c
@@ -16,8 +16,6 @@
 #include <linux/nfsd/nfsd.h>
 #include <linux/lockd/lockd.h>
 #include <linux/lockd/share.h>
-#include <linux/lockd/sm_inter.h>
-
 
 #define NLMDBG_FACILITY		NLMDBG_CLIENT
 
diff --git a/fs/lockd/svcsubs.c b/fs/lockd/svcsubs.c
index 34c2766..9e4d6aa 100644
--- a/fs/lockd/svcsubs.c
+++ b/fs/lockd/svcsubs.c
@@ -17,7 +17,6 @@
 #include <linux/nfsd/export.h>
 #include <linux/lockd/lockd.h>
 #include <linux/lockd/share.h>
-#include <linux/lockd/sm_inter.h>
 #include <linux/module.h>
 #include <linux/mount.h>
 
diff --git a/fs/lockd/xdr.c b/fs/lockd/xdr.c
index 4cc7d01..0336f2b 100644
--- a/fs/lockd/xdr.c
+++ b/fs/lockd/xdr.c
@@ -16,7 +16,6 @@
 #include <linux/sunrpc/svc.h>
 #include <linux/sunrpc/stats.h>
 #include <linux/lockd/lockd.h>
-#include <linux/lockd/sm_inter.h>
 
 #define NLMDBG_FACILITY		NLMDBG_XDR
 
diff --git a/fs/lockd/xdr4.c b/fs/lockd/xdr4.c
index 61d1714..e1d5286 100644
--- a/fs/lockd/xdr4.c
+++ b/fs/lockd/xdr4.c
@@ -17,7 +17,6 @@
 #include <linux/sunrpc/svc.h>
 #include <linux/sunrpc/stats.h>
 #include <linux/lockd/lockd.h>
-#include <linux/lockd/sm_inter.h>
 
 #define NLMDBG_FACILITY		NLMDBG_XDR
 
diff --git a/include/linux/lockd/lockd.h b/include/linux/lockd/lockd.h
index 1ccd49e..8b57467 100644
--- a/include/linux/lockd/lockd.h
+++ b/include/linux/lockd/lockd.h
@@ -205,6 +205,7 @@ extern struct svc_procedure	nlmsvc_procedures4[];
 extern int			nlmsvc_grace_period;
 extern unsigned long		nlmsvc_timeout;
 extern int			nsm_use_hostnames;
+extern int			nsm_local_state;
 
 /*
  * Lockd client functions
diff --git a/include/linux/lockd/sm_inter.h b/include/linux/lockd/sm_inter.h
deleted file mode 100644
index 5cef5a7..0000000
--- a/include/linux/lockd/sm_inter.h
+++ /dev/null
@@ -1,16 +0,0 @@
-/*
- * linux/include/linux/lockd/sm_inter.h
- *
- * Declarations for the kernel statd client.
- *
- * Copyright (C) 1996, Olaf Kirch <okir-pn4DOG8n3UYbFoVRYvo4fw@public.gmane.org>
- */
-
-#ifndef LINUX_LOCKD_SM_INTER_H
-#define LINUX_LOCKD_SM_INTER_H
-
-#define SM_MAXSTRLEN	1024
-
-extern int	nsm_local_state;
-
-#endif /* LINUX_LOCKD_SM_INTER_H */
diff --git a/include/linux/lockd/xdr.h b/include/linux/lockd/xdr.h
index 6338866..7dc5b6c 100644
--- a/include/linux/lockd/xdr.h
+++ b/include/linux/lockd/xdr.h
@@ -13,6 +13,7 @@
 #include <linux/nfs.h>
 #include <linux/sunrpc/xdr.h>
 
+#define SM_MAXSTRLEN		1024
 #define SM_PRIV_SIZE		16
 
 struct nsm_private {


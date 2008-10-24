From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 12/14] NSM: Remove include/linux/lockd/sm_inter.h
Date: Fri, 24 Oct 2008 14:11:16 -0400
Message-ID: <20081024181116.23810.26120.stgit@ingres.1015granger.net>
References: <20081024180150.23810.9718.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:41719 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753615AbYJXSLY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 24 Oct 2008 14:11:24 -0400
Received: from agmgw1.us.oracle.com (agmgw1.us.oracle.com [152.68.180.212])
	by agminet01.oracle.com (Switch-3.2.4/Switch-3.1.7) with ESMTP id m9OIBJXc009785
	for <linux-nfs@vger.kernel.org>; Fri, 24 Oct 2008 13:11:20 -0500
Received: from acsmt353.oracle.com (acsmt353.oracle.com [141.146.40.153])
	by agmgw1.us.oracle.com (Switch-3.2.0/Switch-3.2.0) with ESMTP id m9O8gNNn013718
	for <linux-nfs@vger.kernel.org>; Fri, 24 Oct 2008 12:11:18 -0600
Received: from ingres.1015granger.net (ingres.1015granger.net [127.0.0.1])
	by ingres.1015granger.net (8.14.2/8.14.2) with ESMTP id m9OIBG8l024035
	for <linux-nfs@vger.kernel.org>; Fri, 24 Oct 2008 14:11:16 -0400
In-Reply-To: <20081024180150.23810.9718.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: The include/linux/lockd/sm_inter.h header has a single item in it
now.  Move that item to include/linux/lockd/xdr.h, and remove sm_inter.h.

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
 include/linux/lockd/sm_inter.h |   14 --------------
 include/linux/lockd/xdr.h      |    1 +
 11 files changed, 1 insertions(+), 26 deletions(-)
 delete mode 100644 include/linux/lockd/sm_inter.h

diff --git a/fs/lockd/clntproc.c b/fs/lockd/clntproc.c
index 31668b6..366099b 100644
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
index 1ecec4f..181cb26 100644
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
index 9fbeca2..78bc36c 100644
--- a/fs/lockd/mon.c
+++ b/fs/lockd/mon.c
@@ -13,8 +13,6 @@
 #include <linux/sunrpc/xprtsock.h>
 #include <linux/sunrpc/svc.h>
 #include <linux/lockd/lockd.h>
-#include <linux/lockd/sm_inter.h>
-
 
 #define NLMDBG_FACILITY		NLMDBG_MONITOR
 
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
 
diff --git a/include/linux/lockd/sm_inter.h b/include/linux/lockd/sm_inter.h
deleted file mode 100644
index 7f22d6f..0000000
--- a/include/linux/lockd/sm_inter.h
+++ /dev/null
@@ -1,14 +0,0 @@
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


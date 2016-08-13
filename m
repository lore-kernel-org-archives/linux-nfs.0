Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:35983 "EHLO
	mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752384AbcHMOUP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 13 Aug 2016 10:20:15 -0400
Received: by mail-wm0-f65.google.com with SMTP id i138so2513663wmf.3
        for <linux-nfs@vger.kernel.org>; Sat, 13 Aug 2016 07:20:15 -0700 (PDT)
From: "Yann E. MORIN" <yann.morin.1998@free.fr>
To: linux-nfs@vger.kernel.org
Cc: "Yann E. MORIN" <yann.morin.1998@free.fr>
Subject: [PATCH rpcbind] src: include cdefs.h for the __P() macro
Date: Sat, 13 Aug 2016 16:05:25 +0200
Message-Id: <1471097125-13193-1-git-send-email-yann.morin.1998@free.fr>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The __P() macro is defined in cdefs.h, so we must include it explicitly
rather than relying on it being included by another header.

cdefs.h is a glibc-ism; glibc includes it almost everywhere from its own
headers. So it automatically gets included for glibc.

However, cdefs.h is not present in musl, so its headers do not include
it. We must thus include it when we need __P() (of course, one will have
to provide his own cdefs.h in this case).

Signed-off-by: "Yann E. MORIN" <yann.morin.1998@free.fr>
---
 src/check_bound.c  | 1 +
 src/pmap_svc.c     | 1 +
 src/rpcb_svc.c     | 1 +
 src/rpcb_svc_4.c   | 1 +
 src/rpcb_svc_com.c | 1 +
 src/rpcbind.c      | 1 +
 src/util.c         | 1 +
 src/warmstart.c    | 1 +
 8 files changed, 8 insertions(+)

diff --git a/src/check_bound.c b/src/check_bound.c
index c70b845..df14fbc 100644
--- a/src/check_bound.c
+++ b/src/check_bound.c
@@ -49,6 +49,7 @@ static	char sccsid[] = "@(#)check_bound.c 1.11 89/04/21 Copyr 1989 Sun Micro";
 
 #include <sys/types.h>
 #include <sys/socket.h>
+#include <sys/cdefs.h>
 #include <rpc/rpc.h>
 #include <stdio.h>
 #include <netconfig.h>
diff --git a/src/pmap_svc.c b/src/pmap_svc.c
index ad28b93..5993c0b 100644
--- a/src/pmap_svc.c
+++ b/src/pmap_svc.c
@@ -49,6 +49,7 @@ static	char sccsid[] = "@(#)pmap_svc.c 1.23 89/04/05 Copyr 1984 Sun Micro";
 #ifdef PORTMAP
 #include <sys/types.h>
 #include <sys/socket.h>
+#include <sys/cdefs.h>
 #include <stdio.h>
 #include <rpc/rpc.h>
 #include <rpc/pmap_prot.h>
diff --git a/src/rpcb_svc.c b/src/rpcb_svc.c
index bd92201..eb5b49c 100644
--- a/src/rpcb_svc.c
+++ b/src/rpcb_svc.c
@@ -42,6 +42,7 @@
  * version 3 of rpcbind.
  */
 #include <sys/types.h>
+#include <sys/cdefs.h>
 #include <rpc/rpc.h>
 #include <rpc/rpcb_prot.h>
 #include <netconfig.h>
diff --git a/src/rpcb_svc_4.c b/src/rpcb_svc_4.c
index b673452..69d75e3 100644
--- a/src/rpcb_svc_4.c
+++ b/src/rpcb_svc_4.c
@@ -44,6 +44,7 @@
 
 #include <sys/types.h>
 #include <sys/stat.h>
+#include <sys/cdefs.h>
 #include <rpc/rpc.h>
 #include <stdio.h>
 #include <unistd.h>
diff --git a/src/rpcb_svc_com.c b/src/rpcb_svc_com.c
index 148fe42..9369e27 100644
--- a/src/rpcb_svc_com.c
+++ b/src/rpcb_svc_com.c
@@ -43,6 +43,7 @@
 #include <sys/stat.h>
 #include <sys/param.h>
 #include <sys/poll.h>
+#include <sys/cdefs.h>
 #include <bits/poll.h>
 #include <sys/socket.h>
 #include <rpc/rpc.h>
diff --git a/src/rpcbind.c b/src/rpcbind.c
index c4265cd..37fc660 100644
--- a/src/rpcbind.c
+++ b/src/rpcbind.c
@@ -50,6 +50,7 @@
 #include <sys/file.h>
 #include <sys/socket.h>
 #include <sys/un.h>
+#include <sys/cdefs.h>
 #include <netinet/in.h>
 #include <rpc/rpc.h>
 #include <rpc/rpc_com.h>
diff --git a/src/util.c b/src/util.c
index a6c835b..5bbec1d 100644
--- a/src/util.c
+++ b/src/util.c
@@ -42,6 +42,7 @@
 #include <sys/types.h>
 #include <sys/socket.h>
 #include <sys/queue.h>
+#include <sys/cdefs.h>
 #include <net/if.h>
 #include <netinet/in.h>
 #include <ifaddrs.h>
diff --git a/src/warmstart.c b/src/warmstart.c
index b6eb73e..f3a9c29 100644
--- a/src/warmstart.c
+++ b/src/warmstart.c
@@ -34,6 +34,7 @@
 
 #include <sys/types.h>
 #include <sys/stat.h>
+#include <sys/cdefs.h>
 #include <stdio.h>
 #include <rpc/rpc.h>
 #include <rpc/rpcb_prot.h>
-- 
2.7.4


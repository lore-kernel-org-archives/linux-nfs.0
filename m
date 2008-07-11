From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 14/14] mount command: Remove RPC headers from network.h
Date: Fri, 11 Jul 2008 16:35:28 -0400
Message-ID: <20080711203528.478.65041.stgit@tarkus.1015granger.net>
References: <20080711203322.478.52095.stgit@tarkus.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:39586 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756297AbYGKUfn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 11 Jul 2008 16:35:43 -0400
In-Reply-To: <20080711203322.478.52095.stgit-lQeC5l55kZ7wdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: Include the bare minimum of legacy RPC headers in
utils/mount/network.h.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/error.c     |    2 --
 utils/mount/mount.c     |    1 -
 utils/mount/network.c   |   11 -----------
 utils/mount/network.h   |   10 ----------
 utils/mount/nfs4mount.c |    2 ++
 utils/mount/nfsmount.c  |    7 +++++++
 6 files changed, 9 insertions(+), 24 deletions(-)


diff --git a/utils/mount/error.c b/utils/mount/error.c
index 5fd5705..5c9d3f2 100644
--- a/utils/mount/error.c
+++ b/utils/mount/error.c
@@ -35,8 +35,6 @@
 #include <fcntl.h>
 #include <syslog.h>
 #include <rpc/rpc.h>
-#include <rpc/pmap_prot.h>
-#include <rpc/pmap_clnt.h>
 
 #include "xcommon.h"
 #include "nls.h"
diff --git a/utils/mount/mount.c b/utils/mount/mount.c
index a7d5733..a806c7a 100644
--- a/utils/mount/mount.c
+++ b/utils/mount/mount.c
@@ -44,7 +44,6 @@
 #include "nfs4_mount.h"
 #include "mount.h"
 #include "error.h"
-#include "network.h"
 #include "stropts.h"
 #include "version.h"
 
diff --git a/utils/mount/network.c b/utils/mount/network.c
index d8e6e10..7d3d09a 100644
--- a/utils/mount/network.c
+++ b/utils/mount/network.c
@@ -48,17 +48,6 @@
 #include "mount_constants.h"
 #include "network.h"
 
-#ifdef HAVE_RPCSVC_NFS_PROT_H
-#include <rpcsvc/nfs_prot.h>
-#else
-#include <linux/nfs.h>
-#define nfsstat nfs_stat
-#endif
-
-#ifndef NFS_PORT
-#define NFS_PORT 2049
-#endif
-
 #define PMAP_TIMEOUT	(10)
 #define CONNECT_TIMEOUT	(20)
 #define MOUNT_TIMEOUT	(30)
diff --git a/utils/mount/network.h b/utils/mount/network.h
index 544ac93..a4dba1b 100644
--- a/utils/mount/network.h
+++ b/utils/mount/network.h
@@ -25,16 +25,6 @@
 #define _NFS_UTILS_MOUNT_NETWORK_H
 
 #include <rpc/pmap_prot.h>
-#include <rpc/clnt.h>
-
-#include "mount.h"
-
-#ifdef HAVE_RPCSVC_NFS_PROT_H
-#include <rpcsvc/nfs_prot.h>
-#else
-#include <linux/nfs.h>
-#define nfsstat nfs_stat
-#endif
 
 #define MNT_SENDBUFSIZE (2048U)
 #define MNT_RECVBUFSIZE (1024U)
diff --git a/utils/mount/nfs4mount.c b/utils/mount/nfs4mount.c
index 2b0fe2e..a2f318f 100644
--- a/utils/mount/nfs4mount.c
+++ b/utils/mount/nfs4mount.c
@@ -34,6 +34,7 @@
 #include <arpa/inet.h>
 #include <rpc/auth.h>
 #include <rpc/rpc.h>
+
 #ifdef HAVE_RPCSVC_NFS_PROT_H
 #include <rpcsvc/nfs_prot.h>
 #else
@@ -45,6 +46,7 @@
 #include "nls.h"
 #include "xcommon.h"
 
+#include "mount.h"
 #include "mount_constants.h"
 #include "nfs4_mount.h"
 #include "nfs_mount.h"
diff --git a/utils/mount/nfsmount.c b/utils/mount/nfsmount.c
index b343a1f..6355681 100644
--- a/utils/mount/nfsmount.c
+++ b/utils/mount/nfsmount.c
@@ -69,6 +69,13 @@
 #include "network.h"
 #include "version.h"
 
+#ifdef HAVE_RPCSVC_NFS_PROT_H
+#include <rpcsvc/nfs_prot.h>
+#else
+#include <linux/nfs.h>
+#define nfsstat nfs_stat
+#endif
+
 #ifndef NFS_PORT
 #define NFS_PORT 2049
 #endif


From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 13/14] text-based mount command: remove unnecessary headers
	from stropts.c
Date: Wed, 09 Jul 2008 20:38:21 -0400
Message-ID: <20080710003821.6137.55322.stgit@tarkus.1015granger.net>
References: <20080710001725.6137.83845.stgit@tarkus.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:61661 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751031AbYGJEII (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Jul 2008 00:08:08 -0400
In-Reply-To: <20080710001725.6137.83845.stgit-lQeC5l55kZ7wdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: remove unneeded headers from utils/mount/stropts.c.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/stropts.c |   14 +++-----------
 1 files changed, 3 insertions(+), 11 deletions(-)

diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index b54df40..e4a4408 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -25,11 +25,7 @@
 #include <config.h>
 #endif
 
-#include <ctype.h>
 #include <unistd.h>
-#include <stdio.h>
-#include <string.h>
-#include <stdlib.h>
 #include <errno.h>
 #include <netdb.h>
 #include <time.h>
@@ -42,7 +38,6 @@
 #include "xcommon.h"
 #include "mount.h"
 #include "nls.h"
-#include "nfs_mount.h"
 #include "mount_constants.h"
 #include "stropts.h"
 #include "error.h"
@@ -51,15 +46,12 @@
 #include "version.h"
 #include "parse_dev.h"
 
-#ifdef HAVE_RPCSVC_NFS_PROT_H
-#include <rpcsvc/nfs_prot.h>
-#else
-#include <linux/nfs.h>
-#define nfsstat nfs_stat
+#ifndef NFS_PROGRAM
+#define NFS_PROGRAM	(100003)
 #endif
 
 #ifndef NFS_PORT
-#define NFS_PORT 2049
+#define NFS_PORT	(2049)
 #endif
 
 #ifndef NFS_MAXHOSTNAME


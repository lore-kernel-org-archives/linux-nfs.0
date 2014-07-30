Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-lb0-f177.google.com ([209.85.217.177]:49359 "EHLO
	mail-lb0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752646AbaG3LXg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 30 Jul 2014 07:23:36 -0400
Received: by mail-lb0-f177.google.com with SMTP id s7so753899lbd.22
        for <linux-nfs@vger.kernel.org>; Wed, 30 Jul 2014 04:23:34 -0700 (PDT)
From: Natanael Copa <natanael.copa@gmail.com>
To: linux-nfs@vger.kernel.org
Cc: Natanael Copa <ncopa@alpinelinux.org>
Subject: [PATCH 08/11] include libgen.h for basename
Date: Wed, 30 Jul 2014 13:23:16 +0200
Message-Id: <1406719399-1735-9-git-send-email-ncopa@alpinelinux.org>
In-Reply-To: <1406719399-1735-1-git-send-email-ncopa@alpinelinux.org>
References: <1406719399-1735-1-git-send-email-ncopa@alpinelinux.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

According POSIX basename(3) should have an #include <libgen.h>

There are a different GNU implementation too, that can be used with
_GNU_SOURCE, but the POSIX version is good enough and more portable.

Signed-off-by: Natanael Copa <ncopa@alpinelinux.org>
---
 tools/rpcdebug/rpcdebug.c    | 1 +
 utils/mount/mount.c          | 1 +
 utils/mount/mount_libmount.c | 1 +
 utils/nfsd/nfsd.c            | 1 +
 utils/nfsidmap/nfsidmap.c    | 1 +
 5 files changed, 5 insertions(+)

diff --git a/tools/rpcdebug/rpcdebug.c b/tools/rpcdebug/rpcdebug.c
index d6e10d3..18b1622 100644
--- a/tools/rpcdebug/rpcdebug.c
+++ b/tools/rpcdebug/rpcdebug.c
@@ -26,6 +26,7 @@
 #include <malloc.h>
 #include <fcntl.h>
 #include <ctype.h>
+#include <libgen.h>
 /* RPC debug flags
    #include <sunrpc/debug.h> */
 /* NFS debug flags
diff --git a/utils/mount/mount.c b/utils/mount/mount.c
index eea00af..91f1087 100644
--- a/utils/mount/mount.c
+++ b/utils/mount/mount.c
@@ -33,6 +33,7 @@
 #include <getopt.h>
 #include <mntent.h>
 #include <pwd.h>
+#include <libgen.h>
 
 #include "fstab.h"
 #include "xcommon.h"
diff --git a/utils/mount/mount_libmount.c b/utils/mount/mount_libmount.c
index 701d41e..6f85dc9 100644
--- a/utils/mount/mount_libmount.c
+++ b/utils/mount/mount_libmount.c
@@ -29,6 +29,7 @@
 #include <string.h>
 #include <errno.h>
 #include <getopt.h>
+#include <libgen.h>
 
 #include <libmount/libmount.h>
 
diff --git a/utils/nfsd/nfsd.c b/utils/nfsd/nfsd.c
index 03e3c81..201bb13 100644
--- a/utils/nfsd/nfsd.c
+++ b/utils/nfsd/nfsd.c
@@ -19,6 +19,7 @@
 #include <errno.h>
 #include <getopt.h>
 #include <netdb.h>
+#include <libgen.h>
 #include <sys/socket.h>
 #include <netinet/in.h>
 #include <arpa/inet.h>
diff --git a/utils/nfsidmap/nfsidmap.c b/utils/nfsidmap/nfsidmap.c
index 3f51b4d..e0d31e7 100644
--- a/utils/nfsidmap/nfsidmap.c
+++ b/utils/nfsidmap/nfsidmap.c
@@ -4,6 +4,7 @@
 #include <stdlib.h>
 #include <string.h>
 #include <errno.h>
+#include <libgen.h>
 
 #include <pwd.h>
 #include <grp.h>
-- 
2.0.3


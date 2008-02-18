From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 02/17] mount command: fix config.h includes in util/mount
Date: Mon, 18 Feb 2008 13:35:30 -0500
Message-ID: <20080218183530.19060.7008.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from flpi101.sbcis.sbc.com ([207.115.20.70]:54767 "EHLO
	flpi101.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752268AbYBRSff (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 18 Feb 2008 13:35:35 -0500
Received: from manray.1015granger.net (adsl-76-241-169-38.dsl.sfldmi.sbcglobal.net [76.241.169.38])
	by flpi101.prodigy.net (8.13.8 out.dk.spool/8.13.8) with ESMTP id m1IIZVR9016286
	for <linux-nfs@vger.kernel.org>; Mon, 18 Feb 2008 10:35:32 -0800
Received: from manray.1015granger.net (manray.1015granger.net [127.0.0.1])
	by manray.1015granger.net (8.14.1/8.14.1) with ESMTP id m1IIZUls019306
	for <linux-nfs@vger.kernel.org>; Mon, 18 Feb 2008 13:35:30 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Recently #include directives for autoconf's config.h file were added in
utils/mount/error.c and utils/mount/mount.c, but appropriate HAVE_CONFIG_H
checks were not added at the same time.

In addition, several other .c files under utils/mount reference
autoconf-generated HAVE_ macros, but don't appear to include config.h

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/error.c     |    5 ++++-
 utils/mount/mount.c     |    5 ++++-
 utils/mount/network.c   |    4 ++++
 utils/mount/nfs4mount.c |    4 ++++
 utils/mount/nfsmount.c  |    4 ++++
 utils/mount/stropts.c   |    4 ++++
 6 files changed, 24 insertions(+), 2 deletions(-)

diff --git a/utils/mount/error.c b/utils/mount/error.c
index 10d4ed2..23a91ff 100644
--- a/utils/mount/error.c
+++ b/utils/mount/error.c
@@ -23,7 +23,10 @@
  *  + Proper support for internationalization
  */
 
-#include "config.h"
+#ifdef HAVE_CONFIG_H
+#include <config.h>
+#endif
+
 #include <unistd.h>
 #include <sys/types.h>
 #include <stdio.h>
diff --git a/utils/mount/mount.c b/utils/mount/mount.c
index 403d6f4..33d8d30 100644
--- a/utils/mount/mount.c
+++ b/utils/mount/mount.c
@@ -18,7 +18,10 @@
  *
  */
 
-#include "config.h"
+#ifdef HAVE_CONFIG_H
+#include <config.h>
+#endif
+
 #include <unistd.h>
 #include <sys/types.h>
 #include <stdio.h>
diff --git a/utils/mount/network.c b/utils/mount/network.c
index 38d0135..ab7f6d0 100644
--- a/utils/mount/network.c
+++ b/utils/mount/network.c
@@ -21,6 +21,10 @@
  *
  */
 
+#ifdef HAVE_CONFIG_H
+#include <config.h>
+#endif
+
 #include <ctype.h>
 #include <unistd.h>
 #include <stdio.h>
diff --git a/utils/mount/nfs4mount.c b/utils/mount/nfs4mount.c
index 0a32c3c..311e5a0 100644
--- a/utils/mount/nfs4mount.c
+++ b/utils/mount/nfs4mount.c
@@ -18,6 +18,10 @@
  * - Moved to nfs-utils/utils/mount from util-linux/mount.
  */
 
+#ifdef HAVE_CONFIG_H
+#include <config.h>
+#endif
+
 #include <unistd.h>
 #include <stdio.h>
 #include <string.h>
diff --git a/utils/mount/nfsmount.c b/utils/mount/nfsmount.c
index 3d2ebb1..c4e90fb 100644
--- a/utils/mount/nfsmount.c
+++ b/utils/mount/nfsmount.c
@@ -35,6 +35,10 @@
  * nfsmount.c,v 1.1.1.1 1993/11/18 08:40:51 jrs Exp
  */
 
+#ifdef HAVE_CONFIG_H
+#include <config.h>
+#endif
+
 #include <ctype.h>
 #include <unistd.h>
 #include <stdio.h>
diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index 0c8d3e1..cadb1f4 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -21,6 +21,10 @@
  *
  */
 
+#ifdef HAVE_CONFIG_H
+#include <config.h>
+#endif
+
 #include <ctype.h>
 #include <unistd.h>
 #include <stdio.h>


From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH] mount command: fix config.h includes in util/mount
Date: Tue, 11 Mar 2008 11:47:35 -0400
Message-ID: <20080311154734.31719.64271.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: arnolds-KXqJB1yYWjE05vS0JrMVqf60q2sDzT0c@public.gmane.org, linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from flpi102.sbcis.sbc.com ([207.115.20.71]:17426 "EHLO
	flpi102.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756977AbYCKPsS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 11 Mar 2008 11:48:18 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Recently #include directives for autoconf's config.h file were added in
utils/mount/error.c and utils/mount/mount.c, but appropriate HAVE_CONFIG_H
checks were not added at the same time.

In addition, several other .c files under utils/mount reference
autoconf-generated HAVE_ macros, but don't appear to include config.h

Also, Heinz-Ado Arnolds <arnolds-KXqJB1yYWjE05vS0JrMVqf60q2sDzT0c@public.gmane.org> reports that this
patch is needed to ensure START_STATD is properly defined in
utils/mount/network.c.  Otherwise start_statd() is always a no-op, even if
the configure script defines an appropriate statd start-up script.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Cc: Heinz-Ado Arnolds <arnolds-KXqJB1yYWjE05vS0JrMVqf60q2sDzT0c@public.gmane.org>
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


Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:11156 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750828Ab0LVTHj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 22 Dec 2010 14:07:39 -0500
Received: from int-mx02.intmail.prod.int.phx2.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id oBMJ7dne018747
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Wed, 22 Dec 2010 14:07:39 -0500
Received: from bighat.boston.devel.redhat.com (bighat.boston.devel.redhat.com [10.16.60.55])
	by int-mx02.intmail.prod.int.phx2.redhat.com (8.13.8/8.13.8) with ESMTP id oBMJ7cdS008381
	for <linux-nfs@vger.kernel.org>; Wed, 22 Dec 2010 14:07:39 -0500
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH] libnfsidmap: Added new --with-pluginpath configuration flag
Date: Wed, 22 Dec 2010 14:07:38 -0500
Message-Id: <1293044858-23455-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Added new configuration flage so the plugin path
can be redefined when the library is built.

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 configure.in  |   13 +++++++++++++
 libnfsidmap.c |    2 ++
 2 files changed, 15 insertions(+), 0 deletions(-)

diff --git a/configure.in b/configure.in
index c105988..7ad3e5f 100644
--- a/configure.in
+++ b/configure.in
@@ -36,7 +36,20 @@ if test "x$enable_gums" = "xyes" ; then
 fi
 AM_CONDITIONAL(ENABLE_GUMS, test "x$enable_gums" = "xyes")
 
+#Where do the Plugins live
+AC_ARG_WITH(pluginpath,
+    [AS_HELP_STRING([--with-pluginpath=/foo],[Causes the library to look in /foo instead of /usr/lib/libnfsidmap for plugins
+    ])],
+    path_plugins=$withval,
+    path_plugins=""
+    )
+if test -n "$path_plugins" ; then
+	AC_DEFINE_UNQUOTED(PATH_PLUGINS, "$path_plugins",
+		[Define this to change the plugins path])
+fi
+AM_CONDITIONAL(PATH_PLUGINS, test -n "$path_plugins")
 
+AC_CONFIG_HEADERS([./config.h])
 # Checks for header files.
 AC_HEADER_STDC
 AC_CHECK_HEADERS([stdlib.h string.h unistd.h errno.h])
diff --git a/libnfsidmap.c b/libnfsidmap.c
index 5dc2652..6415707 100644
--- a/libnfsidmap.c
+++ b/libnfsidmap.c
@@ -36,6 +36,8 @@
  *  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
  */
 
+#include "config.h"
+
 #include <sys/types.h>
 #include <errno.h>
 #include <unistd.h>
-- 
1.7.3.3


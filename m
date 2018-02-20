Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3-rdu2.redhat.com ([66.187.233.73]:43408 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751565AbeBTSug (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 20 Feb 2018 13:50:36 -0500
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.rdu2.redhat.com [10.11.54.3])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 684A579D3E
        for <linux-nfs@vger.kernel.org>; Tue, 20 Feb 2018 18:50:36 +0000 (UTC)
Received: from steved.boston.devel.redhat.com (steved.boston.devel.redhat.com [10.19.60.47])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 4D05E10A9DE7
        for <linux-nfs@vger.kernel.org>; Tue, 20 Feb 2018 18:50:36 +0000 (UTC)
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 6/7] Removed missing-include-dirs warnings
Date: Tue, 20 Feb 2018 13:50:33 -0500
Message-Id: <20180220185034.26301-7-steved@redhat.com>
In-Reply-To: <20180220185034.26301-1-steved@redhat.com>
References: <20180220185034.26301-1-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Added the -Werror=missing-include-dirs warning flag
then moved some include directories around.

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 configure.ac               | 3 ++-
 support/nfs/wildmat.c      | 6 ++++++
 utils/gssd/Makefile.am     | 2 ++
 utils/idmapd/Makefile.am   | 2 ++
 utils/nfsidmap/Makefile.am | 2 ++
 5 files changed, 14 insertions(+), 1 deletion(-)

diff --git a/configure.ac b/configure.ac
index 2364275..b849f43 100644
--- a/configure.ac
+++ b/configure.ac
@@ -448,7 +448,7 @@ if test -n "$path_plugins" ; then
 fi
 AM_CONDITIONAL(PATH_PLUGINS, test -n "$path_plugins")
 
-AC_SUBST(AM_CPPFLAGS, "$AM_CPPFLAGS -I../../support/nfsidmap")
+AC_SUBST(AM_CPPFLAGS, "$AM_CPPFLAGS")
 AC_DEFINE([HAVE_NFS4_SET_DEBUG], 1,
           [Bundled lib always has the `nfs4_set_debug' function.])
 
@@ -553,6 +553,7 @@ my_am_cflags="\
  -Werror=format-overflow=2 \
  -Werror=format=2 \
  -Werror=undef \
+ -Werror=missing-include-dirs \
 "
 
 AC_SUBST([AM_CFLAGS], ["$my_am_cflags"])
diff --git a/support/nfs/wildmat.c b/support/nfs/wildmat.c
index 2f40358..437b2d1 100644
--- a/support/nfs/wildmat.c
+++ b/support/nfs/wildmat.c
@@ -43,8 +43,14 @@
 #include <ctype.h>
 #include "nfslib.h"
 
+#ifndef TRUE
 #define TRUE			1
+#endif
+
+#ifndef FALSE
 #define FALSE			0
+#endif
+
 #define ABORT			-1
 
 
diff --git a/utils/gssd/Makefile.am b/utils/gssd/Makefile.am
index beb3e8e..321046b 100644
--- a/utils/gssd/Makefile.am
+++ b/utils/gssd/Makefile.am
@@ -5,6 +5,8 @@ if CONFIG_SVCGSS
 man8_MANS	+= svcgssd.man
 endif
 
+AM_CPPFLAGS += -I ../../support/nfsidmap
+
 RPCPREFIX	= rpc.
 KPREFIX		= @kprefix@
 sbin_PREFIXED	= gssd
diff --git a/utils/idmapd/Makefile.am b/utils/idmapd/Makefile.am
index d768eec..e09e8c5 100644
--- a/utils/idmapd/Makefile.am
+++ b/utils/idmapd/Makefile.am
@@ -2,6 +2,8 @@
 
 man8_MANS	= idmapd.man
 
+AM_CPPFLAGS += -I ../../support/nfsidmap
+
 RPCPREFIX	= rpc.
 KPREFIX		= @kprefix@
 sbin_PROGRAMS	= idmapd
diff --git a/utils/nfsidmap/Makefile.am b/utils/nfsidmap/Makefile.am
index 49158df..e5d7d04 100644
--- a/utils/nfsidmap/Makefile.am
+++ b/utils/nfsidmap/Makefile.am
@@ -3,6 +3,8 @@
 man8_MANS = nfsidmap.man
 sbin_PROGRAMS	= nfsidmap
 
+AM_CPPFLAGS += -I ../../support/nfsidmap
+
 nfsidmap_SOURCES = nfsidmap.c
 nfsidmap_LDADD = -lkeyutils \
 		 ../../support/nfs/libnfs.la \
-- 
2.14.3


Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44786 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751323AbdH3LzR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 30 Aug 2017 07:55:17 -0400
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 3E812356C7
        for <linux-nfs@vger.kernel.org>; Wed, 30 Aug 2017 11:55:17 +0000 (UTC)
Message-ID: <1504094115.10850.6.camel@redhat.com>
Subject: [PATCH 3/7] nfs-utils: Move nfs.conf handling into a shared lib
From: Justin Mitchell <jumitche@redhat.com>
To: Steve Dickson <steved@redhat.com>
Cc: linux-nfs@vger.kernel.org
Date: Wed, 30 Aug 2017 12:55:15 +0100
In-Reply-To: <1504093866.10850.1.camel@redhat.com>
References: <1504093866.10850.1.camel@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Move the config handling code that is common to all nfs-utils and
make it a shared library so that other projects like libnfsidmap can
also use it. No attempt is made to improve the API at this point
so as to minimize the change size.

Signed-off-by: Justin Mitchell <jumitche@redhat.com>
---
 support/include/Makefile.am   | 5 ++++-
 support/nfs/Makefile.am       | 8 +++++++-
 support/nfs/conffile.c        | 4 +---
 utils/blkmapd/Makefile.am     | 3 ++-
 utils/exportfs/Makefile.am    | 1 +
 utils/gssd/Makefile.am        | 2 ++
 utils/mount/Makefile.am       | 1 +
 utils/mountd/Makefile.am      | 1 +
 utils/nfsd/Makefile.am        | 3 ++-
 utils/nfsdcltrack/Makefile.am | 3 ++-
 utils/statd/Makefile.am       | 2 ++
 11 files changed, 25 insertions(+), 8 deletions(-)

diff --git a/support/include/Makefile.am b/support/include/Makefile.am
index 5c80c8b..c46a340 100644
--- a/support/include/Makefile.am
+++ b/support/include/Makefile.am
@@ -21,7 +21,10 @@ noinst_HEADERS = \
 	xio.h \
 	xlog.h \
 	xmalloc.h \
-	xcommon.h \
+	xcommon.h
+
+include_HEADERS = \
 	conffile.h
 
+
 MAINTAINERCLEANFILES = Makefile.in
diff --git a/support/nfs/Makefile.am b/support/nfs/Makefile.am
index b74c870..e06ebd6 100644
--- a/support/nfs/Makefile.am
+++ b/support/nfs/Makefile.am
@@ -4,8 +4,14 @@ noinst_LIBRARIES = libnfs.a
 libnfs_a_SOURCES = exports.c rmtab.c xio.c rpcmisc.c rpcdispatch.c \
 		   xlog.c xcommon.c wildmat.c mydaemon.c \
 		   rpc_socket.c getport.c \
-		   svc_socket.c cacheio.c closeall.c nfs_mntent.c conffile.c \
+		   svc_socket.c cacheio.c closeall.c nfs_mntent.c \
 		   svc_create.c atomicio.c strlcpy.c strlcat.c
+libnfs_a_CFLAGS = -fPIC
+
+lib_LTLIBRARIES = libnfsconf.la
+libnfsconf_la_SOURCES = conffile.c
+libnfsconf_la_LIBADD = libnfs.a
+
 
 MAINTAINERCLEANFILES = Makefile.in
 
diff --git a/support/nfs/conffile.c b/support/nfs/conffile.c
index d8c4374..9c0fad9 100644
--- a/support/nfs/conffile.c
+++ b/support/nfs/conffile.c
@@ -53,8 +53,6 @@
 #include "conffile.h"
 #include "xlog.h"
 
-#pragma GCC visibility push(hidden)
-
 static void conf_load_defaults(void);
 static char * conf_load(const char *path);
 static int conf_set(int , const char *, const char *, const char *, 
@@ -74,7 +72,7 @@ struct conf_trans {
 	int is_default;
 };
 
-TAILQ_HEAD (conf_trans_head, conf_trans) conf_trans_queue;
+static TAILQ_HEAD (conf_trans_head, conf_trans) conf_trans_queue;
 
 /*
  * Radix-64 Encoding.
diff --git a/utils/blkmapd/Makefile.am b/utils/blkmapd/Makefile.am
index 203f9f2..c04fb2e 100644
--- a/utils/blkmapd/Makefile.am
+++ b/utils/blkmapd/Makefile.am
@@ -13,7 +13,8 @@ blkmapd_SOURCES = \
 	dm-device.c \
 	device-discovery.h
 
-blkmapd_LDADD = -ldevmapper ../../support/nfs/libnfs.a
+blkmapd_LDADD = -ldevmapper ../../support/nfs/libnfs.a \
+	        -L../../support/nfs/ -lnfsconf
 
 MAINTAINERCLEANFILES = Makefile.in
 
diff --git a/utils/exportfs/Makefile.am b/utils/exportfs/Makefile.am
index d0226fc..09e5229 100644
--- a/utils/exportfs/Makefile.am
+++ b/utils/exportfs/Makefile.am
@@ -10,6 +10,7 @@ exportfs_SOURCES = exportfs.c
 exportfs_LDADD = ../../support/export/libexport.a \
 	       	 ../../support/nfs/libnfs.a \
 		 ../../support/misc/libmisc.a \
+		 -L../../support/nfs/ -lnfsconf \
 		 $(LIBWRAP) $(LIBNSL)
 
 MAINTAINERCLEANFILES = Makefile.in
diff --git a/utils/gssd/Makefile.am b/utils/gssd/Makefile.am
index 3f5f59a..b3b8234 100644
--- a/utils/gssd/Makefile.am
+++ b/utils/gssd/Makefile.am
@@ -45,6 +45,7 @@ gssd_SOURCES = \
 
 gssd_LDADD = \
 	../../support/nfs/libnfs.a \
+	-L../../support/nfs/ -lnfsconf \
 	$(LIBEVENT) \
 	$(RPCSECGSS_LIBS) \
 	$(KRBLIBS) \
@@ -75,6 +76,7 @@ svcgssd_SOURCES = \
 
 svcgssd_LDADD = \
 	../../support/nfs/libnfs.a \
+	-L../../support/nfs/ -lnfsconf \
 	$(RPCSECGSS_LIBS) $(LIBNFSIDMAP) \
 	$(KRBLIBS) $(GSSAPI_LIBS) $(LIBTIRPC)
 
diff --git a/utils/mount/Makefile.am b/utils/mount/Makefile.am
index e24f3bd..0d8ef08 100644
--- a/utils/mount/Makefile.am
+++ b/utils/mount/Makefile.am
@@ -27,6 +27,7 @@ endif
 
 mount_nfs_LDADD = ../../support/nfs/libnfs.a \
 		  ../../support/export/libexport.a \
+	          -L../../support/nfs/ -lnfsconf \
 		  $(LIBTIRPC)
 
 mount_nfs_SOURCES = $(mount_common)
diff --git a/utils/mountd/Makefile.am b/utils/mountd/Makefile.am
index 9e1ab5c..4e822d0 100644
--- a/utils/mountd/Makefile.am
+++ b/utils/mountd/Makefile.am
@@ -13,6 +13,7 @@ mountd_SOURCES = mountd.c mount_dispatch.c auth.c rmtab.c cache.c \
 mountd_LDADD = ../../support/export/libexport.a \
 	       ../../support/nfs/libnfs.a \
 	       ../../support/misc/libmisc.a \
+	       -L../../support/nfs/ -lnfsconf \
 	       $(LIBBSD) $(LIBWRAP) $(LIBNSL) $(LIBBLKID) $(LIBDL) $(LIBTIRPC)
 mountd_CPPFLAGS = $(AM_CPPFLAGS) $(CPPFLAGS) \
 		  -I$(top_builddir)/support/include \
diff --git a/utils/nfsd/Makefile.am b/utils/nfsd/Makefile.am
index 39a6e6f..9908f1b 100644
--- a/utils/nfsd/Makefile.am
+++ b/utils/nfsd/Makefile.am
@@ -9,7 +9,8 @@ sbin_PROGRAMS	= nfsd
 
 noinst_HEADERS = nfssvc.h
 nfsd_SOURCES = nfsd.c nfssvc.c
-nfsd_LDADD = ../../support/nfs/libnfs.a $(LIBTIRPC)
+nfsd_LDADD = ../../support/nfs/libnfs.a $(LIBTIRPC) \
+	     -L../../support/nfs/ -lnfsconf
 
 MAINTAINERCLEANFILES = Makefile.in
 
diff --git a/utils/nfsdcltrack/Makefile.am b/utils/nfsdcltrack/Makefile.am
index 0a2858f..91d45c8 100644
--- a/utils/nfsdcltrack/Makefile.am
+++ b/utils/nfsdcltrack/Makefile.am
@@ -13,7 +13,8 @@ sbin_PROGRAMS	= nfsdcltrack
 noinst_HEADERS	= sqlite.h
 
 nfsdcltrack_SOURCES = nfsdcltrack.c sqlite.c
-nfsdcltrack_LDADD = ../../support/nfs/libnfs.a $(LIBSQLITE) $(LIBCAP)
+nfsdcltrack_LDADD = ../../support/nfs/libnfs.a $(LIBSQLITE) $(LIBCAP) \
+	            -L../../support/nfs/ -lnfsconf
 
 MAINTAINERCLEANFILES = Makefile.in
 
diff --git a/utils/statd/Makefile.am b/utils/statd/Makefile.am
index ea32075..ccaf3a6 100644
--- a/utils/statd/Makefile.am
+++ b/utils/statd/Makefile.am
@@ -15,10 +15,12 @@ BUILT_SOURCES = $(GENFILES)
 statd_LDADD = ../../support/nsm/libnsm.a \
 	      ../../support/nfs/libnfs.a \
 	      ../../support/misc/libmisc.a \
+	      -L../../support/nfs/ -lnfsconf \
 	      $(LIBWRAP) $(LIBNSL) $(LIBCAP) $(LIBTIRPC)
 sm_notify_LDADD = ../../support/nsm/libnsm.a \
 		  ../../support/nfs/libnfs.a \
 	          ../../support/misc/libmisc.a \
+	          -L../../support/nfs/ -lnfsconf \
 		  $(LIBNSL) $(LIBCAP) $(LIBTIRPC)
 
 EXTRA_DIST = sim_sm_inter.x $(man8_MANS) simulate.c
-- 
1.8.3.1




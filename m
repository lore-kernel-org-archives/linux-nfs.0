Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56914 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751462AbdINOFc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 14 Sep 2017 10:05:32 -0400
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id A4BFDC058EAE
        for <linux-nfs@vger.kernel.org>; Thu, 14 Sep 2017 14:05:32 +0000 (UTC)
Message-ID: <1505397929.3665.8.camel@redhat.com>
Subject: [PATCH 4/7] nfs-utils: split conffile to a separate convenience lib
From: Justin Mitchell <jumitche@redhat.com>
To: Steve Dickson <steved@redhat.com>
Cc: linux-nfs <linux-nfs@vger.kernel.org>,
        "J. Bruce Fields" <bfields@redhat.com>
Date: Thu, 14 Sep 2017 15:05:29 +0100
In-Reply-To: <1505397745.3665.4.camel@redhat.com>
References: <1505397745.3665.4.camel@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

To allow better reuse of the code we split conffile and xlog
into their own separate convenience library, then merge it
back so as to not create extra dependancies for everything

Signed-off-by: Justin Mitchell <jumitche@redhat.com>
---
 support/nfs/Makefile.am       | 13 +++++++++----
 support/nfs/xlog.c            |  2 ++
 utils/blkmapd/Makefile.am     |  2 +-
 utils/exportfs/Makefile.am    |  2 +-
 utils/gssd/Makefile.am        |  4 ++--
 utils/idmapd/Makefile.am      |  2 +-
 utils/mount/Makefile.am       |  2 +-
 utils/mountd/Makefile.am      |  2 +-
 utils/nfsd/Makefile.am        |  2 +-
 utils/nfsdcltrack/Makefile.am |  2 +-
 utils/nfsidmap/Makefile.am    |  2 +-
 utils/statd/Makefile.am       |  4 ++--
 12 files changed, 23 insertions(+), 16 deletions(-)

diff --git a/support/nfs/Makefile.am b/support/nfs/Makefile.am
index b74c870..c037c46 100644
--- a/support/nfs/Makefile.am
+++ b/support/nfs/Makefile.am
@@ -1,11 +1,16 @@
 ## Process this file with automake to produce Makefile.in
 
-noinst_LIBRARIES = libnfs.a
-libnfs_a_SOURCES = exports.c rmtab.c xio.c rpcmisc.c rpcdispatch.c \
-		   xlog.c xcommon.c wildmat.c mydaemon.c \
+noinst_LIBRARIES = 
+noinst_LTLIBRARIES = libnfs.la libnfsconf.la
+
+libnfs_la_SOURCES = exports.c rmtab.c xio.c rpcmisc.c rpcdispatch.c \
+		   xcommon.c wildmat.c mydaemon.c \
 		   rpc_socket.c getport.c \
-		   svc_socket.c cacheio.c closeall.c nfs_mntent.c conffile.c \
+		   svc_socket.c cacheio.c closeall.c nfs_mntent.c \
 		   svc_create.c atomicio.c strlcpy.c strlcat.c
+libnfs_la_LIBADD = libnfsconf.la
+
+libnfsconf_la_SOURCES = conffile.c xlog.c
 
 MAINTAINERCLEANFILES = Makefile.in
 
diff --git a/support/nfs/xlog.c b/support/nfs/xlog.c
index c8e4263..f75a9ab 100644
--- a/support/nfs/xlog.c
+++ b/support/nfs/xlog.c
@@ -33,6 +33,8 @@
 
 #undef	VERBOSE_PRINTF
 
+#pragma GCC visibility push(hidden)
+
 static int  log_stderr = 1;
 static int  log_syslog = 1;
 static int  logging = 0;		/* enable/disable DEBUG logs	*/
diff --git a/utils/blkmapd/Makefile.am b/utils/blkmapd/Makefile.am
index 203f9f2..56c8a4b 100644
--- a/utils/blkmapd/Makefile.am
+++ b/utils/blkmapd/Makefile.am
@@ -13,7 +13,7 @@ blkmapd_SOURCES = \
 	dm-device.c \
 	device-discovery.h
 
-blkmapd_LDADD = -ldevmapper ../../support/nfs/libnfs.a
+blkmapd_LDADD = -ldevmapper ../../support/nfs/libnfs.la
 
 MAINTAINERCLEANFILES = Makefile.in
 
diff --git a/utils/exportfs/Makefile.am b/utils/exportfs/Makefile.am
index d0226fc..4b29161 100644
--- a/utils/exportfs/Makefile.am
+++ b/utils/exportfs/Makefile.am
@@ -8,7 +8,7 @@ EXTRA_DIST	= $(man5_MANS) $(man7_MANS) $(man8_MANS)
 sbin_PROGRAMS	= exportfs
 exportfs_SOURCES = exportfs.c
 exportfs_LDADD = ../../support/export/libexport.a \
-	       	 ../../support/nfs/libnfs.a \
+	       	 ../../support/nfs/libnfs.la \
 		 ../../support/misc/libmisc.a \
 		 $(LIBWRAP) $(LIBNSL)
 
diff --git a/utils/gssd/Makefile.am b/utils/gssd/Makefile.am
index 3f5f59a..09a455e 100644
--- a/utils/gssd/Makefile.am
+++ b/utils/gssd/Makefile.am
@@ -44,7 +44,7 @@ gssd_SOURCES = \
 	write_bytes.h
 
 gssd_LDADD = \
-	../../support/nfs/libnfs.a \
+	../../support/nfs/libnfs.la \
 	$(LIBEVENT) \
 	$(RPCSECGSS_LIBS) \
 	$(KRBLIBS) \
@@ -74,7 +74,7 @@ svcgssd_SOURCES = \
 	svcgssd.h
 
 svcgssd_LDADD = \
-	../../support/nfs/libnfs.a \
+	../../support/nfs/libnfs.la \
 	$(RPCSECGSS_LIBS) $(LIBNFSIDMAP) \
 	$(KRBLIBS) $(GSSAPI_LIBS) $(LIBTIRPC)
 
diff --git a/utils/idmapd/Makefile.am b/utils/idmapd/Makefile.am
index 1e8e9e6..b4cac93 100644
--- a/utils/idmapd/Makefile.am
+++ b/utils/idmapd/Makefile.am
@@ -15,7 +15,7 @@ idmapd_SOURCES = \
 	nfs_idmap.h \
 	queue.h
 
-idmapd_LDADD = ../../support/nfs/libnfs.a $(LIBEVENT) $(LIBNFSIDMAP)
+idmapd_LDADD = ../../support/nfs/libnfs.la $(LIBEVENT) $(LIBNFSIDMAP)
 
 MAINTAINERCLEANFILES = Makefile.in
 
diff --git a/utils/mount/Makefile.am b/utils/mount/Makefile.am
index e24f3bd..7b97c31 100644
--- a/utils/mount/Makefile.am
+++ b/utils/mount/Makefile.am
@@ -25,7 +25,7 @@ else
 EXTRA_DIST += nfsmount.conf.man
 endif
 
-mount_nfs_LDADD = ../../support/nfs/libnfs.a \
+mount_nfs_LDADD = ../../support/nfs/libnfs.la \
 		  ../../support/export/libexport.a \
 		  $(LIBTIRPC)
 
diff --git a/utils/mountd/Makefile.am b/utils/mountd/Makefile.am
index 9e1ab5c..153a90a 100644
--- a/utils/mountd/Makefile.am
+++ b/utils/mountd/Makefile.am
@@ -11,7 +11,7 @@ noinst_HEADERS = fsloc.h
 mountd_SOURCES = mountd.c mount_dispatch.c auth.c rmtab.c cache.c \
 		 svc_run.c fsloc.c v4root.c mountd.h
 mountd_LDADD = ../../support/export/libexport.a \
-	       ../../support/nfs/libnfs.a \
+	       ../../support/nfs/libnfs.la \
 	       ../../support/misc/libmisc.a \
 	       $(LIBBSD) $(LIBWRAP) $(LIBNSL) $(LIBBLKID) $(LIBDL) $(LIBTIRPC)
 mountd_CPPFLAGS = $(AM_CPPFLAGS) $(CPPFLAGS) \
diff --git a/utils/nfsd/Makefile.am b/utils/nfsd/Makefile.am
index 39a6e6f..8acc9a0 100644
--- a/utils/nfsd/Makefile.am
+++ b/utils/nfsd/Makefile.am
@@ -9,7 +9,7 @@ sbin_PROGRAMS	= nfsd
 
 noinst_HEADERS = nfssvc.h
 nfsd_SOURCES = nfsd.c nfssvc.c
-nfsd_LDADD = ../../support/nfs/libnfs.a $(LIBTIRPC)
+nfsd_LDADD = ../../support/nfs/libnfs.la $(LIBTIRPC)
 
 MAINTAINERCLEANFILES = Makefile.in
 
diff --git a/utils/nfsdcltrack/Makefile.am b/utils/nfsdcltrack/Makefile.am
index 0a2858f..2f7fe3d 100644
--- a/utils/nfsdcltrack/Makefile.am
+++ b/utils/nfsdcltrack/Makefile.am
@@ -13,7 +13,7 @@ sbin_PROGRAMS	= nfsdcltrack
 noinst_HEADERS	= sqlite.h
 
 nfsdcltrack_SOURCES = nfsdcltrack.c sqlite.c
-nfsdcltrack_LDADD = ../../support/nfs/libnfs.a $(LIBSQLITE) $(LIBCAP)
+nfsdcltrack_LDADD = ../../support/nfs/libnfs.la $(LIBSQLITE) $(LIBCAP)
 
 MAINTAINERCLEANFILES = Makefile.in
 
diff --git a/utils/nfsidmap/Makefile.am b/utils/nfsidmap/Makefile.am
index 91cedfd..8af22d0 100644
--- a/utils/nfsidmap/Makefile.am
+++ b/utils/nfsidmap/Makefile.am
@@ -4,7 +4,7 @@ man8_MANS = nfsidmap.man
 sbin_PROGRAMS	= nfsidmap
 
 nfsidmap_SOURCES = nfsidmap.c
-nfsidmap_LDADD = $(LIBNFSIDMAP) -lkeyutils ../../support/nfs/libnfs.a
+nfsidmap_LDADD = $(LIBNFSIDMAP) -lkeyutils ../../support/nfs/libnfs.la
 
 MAINTAINERCLEANFILES = Makefile.in
 EXTRA_DIST = id_resolver.conf $(man8_MANS)
diff --git a/utils/statd/Makefile.am b/utils/statd/Makefile.am
index ea32075..6facc15 100644
--- a/utils/statd/Makefile.am
+++ b/utils/statd/Makefile.am
@@ -13,11 +13,11 @@ sm_notify_SOURCES = sm-notify.c
 
 BUILT_SOURCES = $(GENFILES)
 statd_LDADD = ../../support/nsm/libnsm.a \
-	      ../../support/nfs/libnfs.a \
+	      ../../support/nfs/libnfs.la \
 	      ../../support/misc/libmisc.a \
 	      $(LIBWRAP) $(LIBNSL) $(LIBCAP) $(LIBTIRPC)
 sm_notify_LDADD = ../../support/nsm/libnsm.a \
-		  ../../support/nfs/libnfs.a \
+		  ../../support/nfs/libnfs.la \
 	          ../../support/misc/libmisc.a \
 		  $(LIBNSL) $(LIBCAP) $(LIBTIRPC)
 
-- 
1.8.3.1




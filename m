Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46946 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751380AbdINOGp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 14 Sep 2017 10:06:45 -0400
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 9637E87649
        for <linux-nfs@vger.kernel.org>; Thu, 14 Sep 2017 14:06:45 +0000 (UTC)
Message-ID: <1505398003.3665.10.camel@redhat.com>
Subject: [PATCH 6/7] integrate libnfsidmap code with rest of nfs-utils
From: Justin Mitchell <jumitche@redhat.com>
To: Steve Dickson <steved@redhat.com>
Cc: linux-nfs <linux-nfs@vger.kernel.org>,
        "J. Bruce Fields" <bfields@redhat.com>
Date: Thu, 14 Sep 2017 15:06:43 +0100
In-Reply-To: <1505397745.3665.4.camel@redhat.com>
References: <1505397745.3665.4.camel@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Modify libnfsidmap to use the now shared conffile code,
adjust the build structure to generate everything correctly,
and modify the other utils to use the merged version of libnfsidmap
instead of testing for an external dependancy.

Signed-off-by: Justin Mitchell <jumitche@redhat.com>
---
 configure.ac                   | 50 ++++++++++++++++++++++++++++++++++++------
 support/Makefile.am            |  8 ++++++-
 support/nfsidmap/Makefile.am   |  5 ++---
 support/nfsidmap/libnfsidmap.c |  5 +++--
 support/nfsidmap/nss.c         |  2 +-
 support/nfsidmap/static.c      |  5 ++---
 support/nfsidmap/umich_ldap.c  |  2 +-
 utils/Makefile.am              |  2 --
 utils/gssd/Makefile.am         |  3 ++-
 utils/idmapd/Makefile.am       |  4 +++-
 utils/nfsidmap/Makefile.am     |  4 +++-
 11 files changed, 67 insertions(+), 23 deletions(-)

diff --git a/configure.ac b/configure.ac
index 1ca1603..0513ff7 100644
--- a/configure.ac
+++ b/configure.ac
@@ -304,9 +304,6 @@ if test "$enable_nfsv4" = yes; then
   dnl check for libevent libraries and headers
   AC_LIBEVENT
 
-  dnl check for nfsidmap libraries and headers
-  AC_LIBNFSIDMAP
-
   dnl check for the keyutils libraries and headers
   AC_KEYUTILS
 
@@ -339,7 +336,6 @@ fi
 
 dnl enable nfsidmap when its support by libnfsidmap
 AM_CONDITIONAL(CONFIG_NFSDCLTRACK, [test "$enable_nfsdcltrack" = "yes" ])
-AM_CONDITIONAL(CONFIG_NFSIDMAP, [test "$ac_cv_header_keyutils_h$ac_cv_lib_nfsidmap_nfs4_owner_to_uid" = "yesyes"])
 
 
 if test "$knfsd_cv_glibc2" = no; then
@@ -382,9 +378,6 @@ if test "$enable_gss" = yes; then
   dnl check for libevent libraries and headers
   AC_LIBEVENT
 
-  dnl 'gss' also depends on nfsidmap.h - at least for svcgssd_proc.c
-  AC_LIBNFSIDMAP
-
   dnl Check for Kerberos V5
   AC_KERBEROS_V5
 
@@ -407,6 +400,47 @@ if test "$enable_gss" = yes; then
   fi
 fi
 
+dnl libdnsidmap specific checks
+AC_CHECK_LIB([resolv], [__res_querydomain], , AC_MSG_ERROR(res_querydomain needed))
+
+AC_ARG_ENABLE([ldap],
+	[AS_HELP_STRING([--disable-ldap],[Disable support for LDAP @<:default=detect@:>@])])
+
+dnl will libdnsidmap support LDAP ?
+if test "x$enable_ldap" != "xno" ; then
+        AC_CHECK_HEADER([ldap.h],
+                [AC_CHECK_LIB([ldap], [ldap_initialize],
+                              [have_ldap="yes"],[have_ldap="no"])],
+                [have_ldap="no"])
+        if test "x$have_ldap" = "xyes" ; then
+                AC_DEFINE([ENABLE_LDAP], 1, [Enable LDAP Support])
+        elif test "x$enable_ldap$have_ldap" = "xyesno" ; then
+                AC_MSG_ERROR(LDAP support not found!)
+        fi
+fi
+AM_CONDITIONAL(ENABLE_LDAP, test "x$have_ldap" = "xyes")
+
+dnl Should we build gums mapping library?
+AC_ARG_ENABLE([gums],
+        [AS_HELP_STRING([--enable-gums],[Enable support for the GUMS mapping library @<:@default=false@:>@])])
+if test "x$enable_gums" = "xyes" ; then
+        AC_DEFINE([ENABLE_GUMS], 1, [Enable GUMS mapping library support])
+fi
+AM_CONDITIONAL(ENABLE_GUMS, test "x$enable_gums" = "xyes")
+
+dnl Where do the Plugins live
+AC_ARG_WITH(pluginpath,
+    [AS_HELP_STRING([--with-pluginpath=/foo],[Causes the library to look in /foo instead of /usr/lib/libnfsidmap for plugins
+    ])],
+    path_plugins=$withval,
+    path_plugins=""
+    )
+if test -n "$path_plugins" ; then
+        AC_DEFINE_UNQUOTED(PATH_PLUGINS, "$path_plugins",
+                [Define this to change the plugins path])
+fi
+AM_CONDITIONAL(PATH_PLUGINS, test -n "$path_plugins")
+
 dnl Check for IPv6 support
 AC_IPV6
 
@@ -537,6 +571,8 @@ AC_CONFIG_FILES([
 	support/misc/Makefile
 	support/nfs/Makefile
 	support/nsm/Makefile
+	support/nfsidmap/Makefile
+	support/nfsidmap/libnfsidmap.pc
 	tools/Makefile
 	tools/locktest/Makefile
 	tools/nlmtest/Makefile
diff --git a/support/Makefile.am b/support/Makefile.am
index cb37733..8365d3b 100644
--- a/support/Makefile.am
+++ b/support/Makefile.am
@@ -1,6 +1,12 @@
 ## Process this file with automake to produce Makefile.in
 
-SUBDIRS = export include misc nfs nsm
+OPTDIRS =
+
+if CONFIG_NFSV4
+OPTDIRS += nfsidmap
+endif
+
+SUBDIRS = export include misc nfs nsm $(OPTDIRS)
 
 MAINTAINERCLEANFILES = Makefile.in
 
diff --git a/support/nfsidmap/Makefile.am b/support/nfsidmap/Makefile.am
index 85f19c8..458944f 100644
--- a/support/nfsidmap/Makefile.am
+++ b/support/nfsidmap/Makefile.am
@@ -1,4 +1,3 @@
-ACLOCAL_AMFLAGS = -I m4
 
 if ENABLE_LDAP
 UMICH_LDAP_LIB = umich_ldap.la
@@ -25,9 +24,9 @@ pkglib_LTLIBRARIES = nsswitch.la static.la $(UMICH_LDAP_LIB) $(GUMS_MAPPING_LIB)
 #  <age> 	The number of previous additional interfaces supported
 #  		by this library.
 
-libnfsidmap_la_SOURCES = libnfsidmap.c cfg.c strlcpy.c cfg.h nfsidmap_internal.h queue.h
+libnfsidmap_la_SOURCES = libnfsidmap.c nfsidmap_internal.h
 libnfsidmap_la_LDFLAGS = -version-info 3:0:3
-libnfsidmap_la_LIBADD = -ldl
+libnfsidmap_la_LIBADD = -ldl ../../support/nfs/libnfsconf.la
 
 nsswitch_la_SOURCES = nss.c
 nsswitch_la_LDFLAGS = -module -avoid-version
diff --git a/support/nfsidmap/libnfsidmap.c b/support/nfsidmap/libnfsidmap.c
index d484101..aa368b7 100644
--- a/support/nfsidmap/libnfsidmap.c
+++ b/support/nfsidmap/libnfsidmap.c
@@ -59,7 +59,7 @@
 
 #include "nfsidmap.h"
 #include "nfsidmap_internal.h"
-#include "cfg.h"
+#include "conffile.h"
 
 static char *default_domain;
 static struct conf_list *local_realms;
@@ -340,6 +340,7 @@ int nfs4_init_name_mapping(char *conffile)
 	char *nobody_user, *nobody_group;
 	char *nostrip;
 	char *reformatgroup;
+	char *conf_path;
 
 	/* XXX: need to be able to reload configurations... */
 	if (nfs4_plugins) /* already succesfully initialized */
@@ -348,7 +349,7 @@ int nfs4_init_name_mapping(char *conffile)
 		conf_path = conffile;
 	else
 		conf_path = PATH_IDMAPDCONF;
-	conf_init();
+	conf_init(conf_path);
 	default_domain = conf_get_str("General", "Domain");
 	if (default_domain == NULL) {
 		dflt = 1;
diff --git a/support/nfsidmap/nss.c b/support/nfsidmap/nss.c
index 82799ce..48215ff 100644
--- a/support/nfsidmap/nss.c
+++ b/support/nfsidmap/nss.c
@@ -48,7 +48,7 @@
 #include <ctype.h>
 #include "nfsidmap.h"
 #include "nfsidmap_internal.h"
-#include "cfg.h"
+#include "conffile.h"
 #include <syslog.h>
 
 /*
diff --git a/support/nfsidmap/static.c b/support/nfsidmap/static.c
index 9f587af..37b293b 100644
--- a/support/nfsidmap/static.c
+++ b/support/nfsidmap/static.c
@@ -41,8 +41,7 @@
 #include <errno.h>
 #include <err.h>
 
-#include "queue.h"
-#include "cfg.h"
+#include "conffile.h"
 #include "nfsidmap.h"
 #include "nfsidmap_internal.h"
 
@@ -317,7 +316,7 @@ static int static_init() {
 		LIST_INIT (&uid_mappings[i]);
 
 	//get all principals for which we have mappings
-	princ_list = conf_get_tag_list("Static");
+	princ_list = conf_get_tag_list("Static", NULL);
 
 	if (!princ_list) {
 		return -ENOENT;
diff --git a/support/nfsidmap/umich_ldap.c b/support/nfsidmap/umich_ldap.c
index 886fa0c..664f282 100644
--- a/support/nfsidmap/umich_ldap.c
+++ b/support/nfsidmap/umich_ldap.c
@@ -48,7 +48,7 @@
 #include <ldap.h>
 #include "nfsidmap.h"
 #include "nfsidmap_internal.h"
-#include "cfg.h"
+#include "conffile.h"
 
 /* attribute/objectclass default mappings */
 #define DEFAULT_UMICH_OBJCLASS_REMOTE_PERSON	"NFSv4RemotePerson"
diff --git a/utils/Makefile.am b/utils/Makefile.am
index b892dc8..c75a5a0 100644
--- a/utils/Makefile.am
+++ b/utils/Makefile.am
@@ -4,10 +4,8 @@ OPTDIRS =
 
 if CONFIG_NFSV4
 OPTDIRS += idmapd
-if CONFIG_NFSIDMAP
 OPTDIRS += nfsidmap
 endif
-endif
 
 if CONFIG_NFSV41
 OPTDIRS += blkmapd
diff --git a/utils/gssd/Makefile.am b/utils/gssd/Makefile.am
index 09a455e..beb3e8e 100644
--- a/utils/gssd/Makefile.am
+++ b/utils/gssd/Makefile.am
@@ -75,7 +75,8 @@ svcgssd_SOURCES = \
 
 svcgssd_LDADD = \
 	../../support/nfs/libnfs.la \
-	$(RPCSECGSS_LIBS) $(LIBNFSIDMAP) \
+	../../support/nfsidmap/libnfsidmap.la \
+	$(RPCSECGSS_LIBS) \
 	$(KRBLIBS) $(GSSAPI_LIBS) $(LIBTIRPC)
 
 svcgssd_LDFLAGS = $(KRBLDFLAGS)
diff --git a/utils/idmapd/Makefile.am b/utils/idmapd/Makefile.am
index b4cac93..d768eec 100644
--- a/utils/idmapd/Makefile.am
+++ b/utils/idmapd/Makefile.am
@@ -15,7 +15,9 @@ idmapd_SOURCES = \
 	nfs_idmap.h \
 	queue.h
 
-idmapd_LDADD = ../../support/nfs/libnfs.la $(LIBEVENT) $(LIBNFSIDMAP)
+idmapd_LDADD = ../../support/nfs/libnfs.la \
+	       ../../support/nfsidmap/libnfsidmap.la \
+	       $(LIBEVENT)
 
 MAINTAINERCLEANFILES = Makefile.in
 
diff --git a/utils/nfsidmap/Makefile.am b/utils/nfsidmap/Makefile.am
index 8af22d0..49158df 100644
--- a/utils/nfsidmap/Makefile.am
+++ b/utils/nfsidmap/Makefile.am
@@ -4,7 +4,9 @@ man8_MANS = nfsidmap.man
 sbin_PROGRAMS	= nfsidmap
 
 nfsidmap_SOURCES = nfsidmap.c
-nfsidmap_LDADD = $(LIBNFSIDMAP) -lkeyutils ../../support/nfs/libnfs.la
+nfsidmap_LDADD = -lkeyutils \
+		 ../../support/nfs/libnfs.la \
+		 ../../support/nfsidmap/libnfsidmap.la
 
 MAINTAINERCLEANFILES = Makefile.in
 EXTRA_DIST = id_resolver.conf $(man8_MANS)
-- 
1.8.3.1




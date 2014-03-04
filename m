Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ea0-f170.google.com ([209.85.215.170]:39552 "EHLO
	mail-ea0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756329AbaCDHiN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 4 Mar 2014 02:38:13 -0500
Received: by mail-ea0-f170.google.com with SMTP id g15so139032eak.1
        for <linux-nfs@vger.kernel.org>; Mon, 03 Mar 2014 23:38:12 -0800 (PST)
From: Noam Meltzer <noam@primarydata.com>
To: noam@primarydata.com, linux-nfs@vger.kernel.org,
        sssd-devel@lists.fedorahosted.org
Subject: [PATCH v2 3/5] NFSv4 client: add to build system
Date: Tue,  4 Mar 2014 09:37:54 +0200
Message-Id: <1393918676-20865-4-git-send-email-noam@primarydata.com>
In-Reply-To: <1393918676-20865-1-git-send-email-noam@primarydata.com>
References: <1393918676-20865-1-git-send-email-noam@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

---
 Makefile.am                 | 19 +++++++++++++++++++
 configure.ac                | 10 ++++++++++
 src/conf_macros.m4          | 30 ++++++++++++++++++++++++++++++
 src/external/libnfsidmap.m4 | 17 +++++++++++++++++
 4 files changed, 76 insertions(+)
 create mode 100644 src/external/libnfsidmap.m4

diff --git a/Makefile.am b/Makefile.am
index 9f010d9..23f6093 100644
--- a/Makefile.am
+++ b/Makefile.am
@@ -47,6 +47,7 @@ localedir = @localedir@
 nsslibdir = @nsslibdir@
 pamlibdir = @pammoddir@
 autofslibdir = @appmodpath@
+nfslibdir = @nfsidmaplibdir@
 
 dbpath = @dbpath@
 pluginpath = @pluginpath@
@@ -526,6 +527,7 @@ dist_noinst_HEADERS = \
     src/tests/cmocka/common_mock_sysdb_objects.h \
     src/sss_client/ssh/sss_ssh_client.h \
     src/sss_client/sudo/sss_sudo.h \
+    src/sss_client/nfs/nfsidmap_internal.h \
     src/lib/idmap/sss_idmap_private.h
 
 
@@ -1666,6 +1668,23 @@ libnss_sss_la_LDFLAGS = \
     -version-info 2:0:0 \
     -Wl,--version-script,$(srcdir)/src/sss_client/sss_nss.exports
 
+
+if BUILD_NFS
+nfslib_LTLIBRARIES = sss_nfs.la
+sss_nfs_la_SOURCES = \
+    src/sss_client/common.c \
+    src/sss_client/nss_mc_common.c \
+    src/util/io.c \
+    src/util/murmurhash3.c \
+    src/sss_client/nss_mc_passwd.c \
+    src/sss_client/nss_mc_group.c \
+    src/sss_client/nfs/sss_nfs_client.c \
+    $(NULL)
+sss_nfs_la_CFLAGS = $(AM_CFLAGS)
+sss_nfs_la_LIBADD = $(CLIENT_LIBS) $(NFSIDMAP_LIBS)
+sss_nfs_la_LDFLAGS = -module -avoid-version
+endif
+
 pamlib_LTLIBRARIES = pam_sss.la
 pam_sss_la_SOURCES = \
     src/sss_client/pam_sss.c \
diff --git a/configure.ac b/configure.ac
index 8295139..b440f92 100644
--- a/configure.ac
+++ b/configure.ac
@@ -91,6 +91,13 @@ AC_ARG_ENABLE([pammoddir], [AS_HELP_STRING([--enable-pammoddir],
               [pammoddir=$libdir/security])
 AC_SUBST(pammoddir)
 
+#Set the NFSv4 idmapd library install path
+AC_ARG_ENABLE([nfsidmaplibdir], [AS_HELP_STRING([--enable-nfsidmaplibdir],
+                                        [Where to install libnfsidmap libraries ($libdir/libnfsidmap)])],
+              [nfsidmaplibdir=$enableval],
+              [nfsidmaplibdir=$libdir/libnfsidmap])
+AC_SUBST(nfsidmaplibdir)
+
 #Include here cause WITH_INIT_DIR requires $osname set in platform.m4
 m4_include([src/external/platform.m4])
 
@@ -127,6 +134,8 @@ WITH_AUTOFS
 WITH_SSH
 WITH_CRYPTO
 WITH_SYSLOG
+WITH_NFS
+WITH_NFS_LIB_PATH
 
 m4_include([src/external/pkg.m4])
 m4_include([src/external/libpopt.m4])
@@ -159,6 +168,7 @@ m4_include([src/external/signal.m4])
 m4_include([src/external/inotify.m4])
 m4_include([src/external/libndr_nbt.m4])
 m4_include([src/external/sasl.m4])
+m4_include([src/external/libnfsidmap.m4])
 
 WITH_UNICODE_LIB
 if test x$unicode_lib = xlibunistring; then
diff --git a/src/conf_macros.m4 b/src/conf_macros.m4
index 7111859..3f59b1f 100644
--- a/src/conf_macros.m4
+++ b/src/conf_macros.m4
@@ -646,3 +646,33 @@ AC_DEFUN([WITH_SSH],
     fi
     AM_CONDITIONAL([BUILD_SSH], [test x"$with_ssh" = xyes])
   ])
+
+  AC_DEFUN([WITH_NFS],
+  [ AC_ARG_WITH([nfs],
+                [AC_HELP_STRING([--with-nfs],
+                                [Whether to build with NFSv4 IDMAP support [yes]]
+                               )
+                ],
+                [with_nfs=$withval],
+                with_nfs=yes
+               )
+
+    if test x"$with_nfs" = xyes; then
+        AC_DEFINE(BUILD_NFS, 1, [whether to build with NFSv4 IDMAP support])
+    fi
+    AM_CONDITIONAL([BUILD_NFS], [test x"$with_nfs" = xyes])
+  ])
+
+AC_DEFUN([WITH_NFS_LIB_PATH],
+  [ AC_ARG_WITH([nfs-lib-path],
+                [AC_HELP_STRING([--with-nfs-lib-path=<path>],
+                                [Path to the nfs library [${libdir}]]
+                               )
+                ]
+               )
+    nfslibpath="${libdir}"
+    if test x"$with_nfs_lib_path" != x; then
+        nfslibpath=$with_nfs_lib_path
+    fi
+    AC_SUBST(nfslibpath)
+  ])
diff --git a/src/external/libnfsidmap.m4 b/src/external/libnfsidmap.m4
new file mode 100644
index 0000000..5bb6d86
--- /dev/null
+++ b/src/external/libnfsidmap.m4
@@ -0,0 +1,17 @@
+AC_SUBST(NFSIDMAP_OBJ)
+AC_SUBST(NFSIDMAP_CFLAGS)
+AC_SUBST(NFSIDMAP_LIBS)
+
+PKG_CHECK_MODULES([NFSIDMAP], [libnfsidmap], [found_nfsidmap=yes],
+		  [found_nfsidmap=no])
+
+SSS_AC_EXPAND_LIB_DIR()
+AS_IF([test x"$with_nfs" = xyes -a x"$found_nfsidmap" != xyes],
+    [AC_CHECK_HEADER([nfsidmap.h],
+        [AC_CHECK_LIB([nfsidmap],
+                      [nfs4_init_name_mapping],
+                      [NFSIDMAP_LIBS="-L$sss_extra_libdir -lnfsidmap"],
+                      [AC_MSG_ERROR([libnfsidmap missing nfs4_init_name_mapping])],
+                      [-L$sss_extra_libdir])],
+        [AC_MSG_ERROR([libnfsidmap header files are not installed])])]
+)
-- 
1.8.5.3


From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 2/9] configure: move TI-RPC checks into aclocal/
Date: Thu, 05 Mar 2009 12:41:57 -0500
Message-ID: <20090305174156.30471.35727.stgit@ingres.1015granger.net>
References: <20090305173533.30471.41413.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet13.oracle.com ([148.87.113.125]:36631 "EHLO
	rgminet13.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754133AbZCERn0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 Mar 2009 12:43:26 -0500
In-Reply-To: <20090305173533.30471.41413.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Define an aclocal test for TI-RPC headers and library, and move the
TI-RPC checks earlier in our configure script so other feature checks
can use the availability of TI-RPC to decide what to do.

Since bindresvport_sa is required just for IPv6 support, move that
check to the IPv6 feature tests.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 Makefile.am         |    3 ++-
 aclocal/libtirpc.m4 |   25 +++++++++++++++++++++++++
 configure.ac        |   28 +++++++++-------------------
 3 files changed, 36 insertions(+), 20 deletions(-)
 create mode 100644 aclocal/libtirpc.m4

diff --git a/Makefile.am b/Makefile.am
index 88ae210..cfe2d37 100644
--- a/Makefile.am
+++ b/Makefile.am
@@ -40,7 +40,8 @@ EXTRA_DIST = \
 	aclocal/bsdsignals.m4 \
 	aclocal/nfs-utils.m4 \
 	aclocal/kerberos5.m4 \
-	aclocal/tcp-wrappers.m4
+	aclocal/tcp-wrappers.m4 \
+	aclocal/libtirpc.m4
 
 ACLOCAL_AMFLAGS = -I aclocal
 
diff --git a/aclocal/libtirpc.m4 b/aclocal/libtirpc.m4
new file mode 100644
index 0000000..67c4012
--- /dev/null
+++ b/aclocal/libtirpc.m4
@@ -0,0 +1,25 @@
+dnl Checks for TI-RPC library and headers
+dnl
+AC_DEFUN([AC_LIBTIRPC], [
+
+  dnl if --enable-tirpc was specifed, the following components
+  dnl must be present, and we set up HAVE_ macros for them.
+
+  if test "$enable_tirpc" = yes; then
+
+    dnl look for the library; add to LIBS if found
+    AC_CHECK_LIB([tirpc], [clnt_tli_create], ,
+                 [AC_MSG_ERROR([libtirpc not found.])])
+
+    dnl also must have the headers installed where we expect
+    AC_CHECK_HEADERS([tirpc/netconfig.h], ,
+                     [AC_MSG_ERROR([libtirpc headers not found.])])
+
+    dnl set up HAVE_FOO for various functions
+    AC_CHECK_FUNCS([getnetconfig \
+                    clnt_create clnt_create_timed \
+                    clnt_vc_create clnt_dg_create xdr_rpcb])
+
+  fi
+
+])dnl
diff --git a/configure.ac b/configure.ac
index 97b084b..becbb7c 100644
--- a/configure.ac
+++ b/configure.ac
@@ -118,6 +118,11 @@ AC_ARG_ENABLE(mount,
 	enable_mount=$enableval,
 	enable_mount=yes)
 	AM_CONDITIONAL(CONFIG_MOUNT, [test "$enable_mount" = "yes"])
+AC_ARG_ENABLE(tirpc,
+	[AC_HELP_STRING([--enable-tirpc],
+			[enable use of TI-RPC @<:@default=no@:>@])],
+	enable_tirpc=$enableval,
+	enable_tirpc=no)
 AC_ARG_ENABLE(ipv6,
 	[AC_HELP_STRING([--enable-ipv6],
                         [enable support for IPv6 @<:@default=no@:>@])],
@@ -131,13 +136,8 @@ AC_ARG_ENABLE(ipv6,
 	AC_SUBST(enable_ipv6)
 	AM_CONDITIONAL(CONFIG_IPV6, [test "$enable_ipv6" = "yes"])
 
-AC_ARG_ENABLE(tirpc,
-	[AC_HELP_STRING([--enable-tirpc],
-                        [enable use of TI-RPC @<:@default=no@:>@])],
-	enable_tirpc=$enableval,
-	enable_tirpc=no)
-	AC_SUBST(enable_tirpc)
-	AM_CONDITIONAL(CONFIG_TIRPC, [test "$enable_tirpc" = "yes"])
+dnl Check for TI-RPC library and headers
+AC_LIBTIRPC
 
 # Check whether user wants TCP wrappers support
 AC_TCP_WRAPPERS
@@ -262,22 +262,12 @@ AC_CHECK_DECL([AI_ADDRCONFIG],
                          [Define this to 1 if AI_ADDRCONFIG macro is defined]), ,
               [ #include <netdb.h> ] )
 
-if test "$enable_tirpc" = yes; then
-  AC_CHECK_LIB(tirpc, clnt_tli_create, ,
-           AC_MSG_ERROR([libtirpc not found.]))
-  AC_CHECK_HEADERS(tirpc/netconfig.h, ,
-                   AC_MSG_ERROR([libtirpc headers not found.]))
-  AC_CHECK_FUNCS([bindresvport_sa getnetconfig \
-                  clnt_create clnt_create_timed \
-                  clnt_vc_create clnt_dg_create xdr_rpcb])
-fi
-
 if test "$enable_ipv6" = yes; then
   if test "$enable_tirpc" = no; then
     AC_MSG_ERROR('--enable-ipv6' requires '--enable-tirpc'.)
   fi
-  AC_CHECK_FUNC(getnameinfo, , ,
-               AC_MSG_ERROR(Function 'getnameinfo' not found.))
+  AC_CHECK_FUNCS([getnameinfo bindresvport_sa], , ,
+                 [AC_MSG_ERROR([Missing functions needed for IPv6.])])
   AC_CHECK_DECL([AI_ADDRCONFIG], ,
                AC_MSG_ERROR([full getaddrinfo(3) implementation needed for IPv6 support]),
                [ #include <netdb.h> ] )


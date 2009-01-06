From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 2/3] configure: Add new build option "--enable-tirpc"
Date: Tue, 06 Jan 2009 18:22:49 -0500
Message-ID: <20090106232249.24661.81435.stgit@ingres.1015granger.net>
References: <20090106231909.24661.92964.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet13.oracle.com ([148.87.113.125]:20140 "EHLO
	rgminet13.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754155AbZAFXYk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 6 Jan 2009 18:24:40 -0500
In-Reply-To: <20090106231909.24661.92964.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Allow easier testing of nfs-utils in legacy environments by providing
a "configure" option to force the build not to use libtirpc, even if
it's present on the build system.  This can also be tried as a
fallback if problems are found with the new TI-RPC-based nfs-utils
code.

The new option is:

  --enable-tirpc          enable use of TI-RPC [default=no]

Build option matrix:

   --disable-tirpc   --disable-ipv6	Default; IPv4 only, glibc RPC
   --disable-tirpc   --enable-ipv6	'configure' will fail
   --enable-tirpc    --disable-ipv6	IPv4 only, TI-RPC
   --enable-tirpc    --enable-ipv6	IPv4 and IPv6, TI-RPC

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 configure.ac |   30 ++++++++++++++++++++++--------
 1 files changed, 22 insertions(+), 8 deletions(-)

diff --git a/configure.ac b/configure.ac
index 4448743..c8508f1 100644
--- a/configure.ac
+++ b/configure.ac
@@ -131,6 +131,14 @@ AC_ARG_ENABLE(ipv6,
 	AC_SUBST(enable_ipv6)
 	AM_CONDITIONAL(CONFIG_IPV6, [test "$enable_ipv6" = "yes"])
 
+AC_ARG_ENABLE(tirpc,
+	[AC_HELP_STRING([--enable-tirpc],
+                        [enable use of TI-RPC @<:@default=no@:>@])],
+	enable_tirpc=$enableval,
+	enable_tirpc=no)
+	AC_SUBST(enable_tirpc)
+	AM_CONDITIONAL(CONFIG_TIRPC, [test "$enable_tirpc" = "yes"])
+
 # Check whether user wants TCP wrappers support
 AC_TCP_WRAPPERS
 
@@ -251,13 +259,22 @@ AC_CHECK_DECL([AI_ADDRCONFIG],
                          [Define this to 1 if AI_ADDRCONFIG macro is defined]), ,
               [ #include <netdb.h> ] )
 
+if test "$enable_tirpc" = yes; then
+  AC_CHECK_LIB(tirpc, clnt_tli_create, ,
+           AC_MSG_ERROR([libtirpc not found.]))
+  AC_CHECK_HEADERS(tirpc/netconfig.h, ,
+                   AC_MSG_ERROR([libtirpc headers not found.]))
+  AC_CHECK_FUNCS([bindresvport_sa getnetconfig \
+                  clnt_create clnt_create_timed \
+                  clnt_vc_create clnt_dg_create xdr_rpcb])
+fi
+
 if test "$enable_ipv6" = yes; then
+  if test "$enable_tirpc" = no; then
+    AC_MSG_ERROR('--enable-ipv6' requires '--enable-tirpc'.)
+  fi
   AC_CHECK_FUNC(getnameinfo, , ,
                AC_MSG_ERROR(Function 'getnameinfo' not found.))
-  AC_CHECK_LIB(tirpc, clnt_tli_create, ,
-               AC_MSG_ERROR([libtirpc needed for IPv6 support]))
-  AC_CHECK_HEADERS(tirpc/netconfig.h, ,
-               AC_MSG_ERROR([libtirpc headers needed for IPv6 support]))
   AC_CHECK_DECL([AI_ADDRCONFIG], ,
                AC_MSG_ERROR([full getaddrinfo(3) implementation needed for IPv6 support]),
                [ #include <netdb.h> ] )
@@ -271,7 +288,7 @@ AC_CHECK_HEADERS([arpa/inet.h fcntl.h libintl.h limits.h \
                  stdlib.h string.h sys/file.h sys/ioctl.h sys/mount.h \
                  sys/param.h sys/socket.h sys/time.h sys/vfs.h \
                  syslog.h unistd.h com_err.h et/com_err.h \
-                 ifaddrs.h tirpc/netconfig.h])
+                 ifaddrs.h])
 
 dnl *************************************************************
 dnl Checks for typedefs, structures, and compiler characteristics
@@ -308,9 +325,6 @@ AC_FUNC_VPRINTF
 AC_CHECK_FUNCS([alarm atexit dup2 fdatasync ftruncate getcwd \
                gethostbyaddr gethostbyname gethostname getmntent \
                getnameinfo getrpcbyname \
-               bindresvport_sa getnetconfig \
-               clnt_create clnt_create_timed \
-               clnt_tli_create clnt_vc_create clnt_dg_create xdr_rpcb \
                gettimeofday hasmntopt inet_ntoa innetgr memset mkdir pathconf \
                realpath rmdir select socket strcasecmp strchr strdup \
                strerror strrchr strtol strtoul sigprocmask])


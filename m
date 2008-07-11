From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 01/14] nfs-utils: Introduce new ./configure option:
	"--enable-ipv6"
Date: Fri, 11 Jul 2008 16:34:18 -0400
Message-ID: <20080711203418.478.78446.stgit@tarkus.1015granger.net>
References: <20080711203322.478.52095.stgit@tarkus.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:12252 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755548AbYGKUel (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 11 Jul 2008 16:34:41 -0400
In-Reply-To: <20080711203322.478.52095.stgit-lQeC5l55kZ7wdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We want to continue to support building nfs-utils on systems that do not
have IPv6-enabled RPC libraries and headers installed, so add a
./configure switch that allows distros to disable IPv6 functionality.

This patch introduces the nfs-utils autotools configuration to the library
and header dependencies that will be required in subsequent patches.
Later patches can then be reordered more easily if these new dependencies
are added in one heap.

For now, --enable-ipv6 defaults to "no", so this patch should not result in
any behavioral changes to the nfs-utils build process, by default.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 configure.ac |   29 ++++++++++++++++++++++++++++-
 1 files changed, 28 insertions(+), 1 deletions(-)


diff --git a/configure.ac b/configure.ac
index d508c28..e6bcb62 100644
--- a/configure.ac
+++ b/configure.ac
@@ -127,6 +127,18 @@ AC_ARG_ENABLE(mount,
 	enable_mount=$enableval,
 	enable_mount=yes)
 	AM_CONDITIONAL(CONFIG_MOUNT, [test "$enable_mount" = "yes"])
+AC_ARG_ENABLE(ipv6,
+	[AC_HELP_STRING([--enable-ipv6],
+                        [enable support for IPv6 @<:@default=no@:>@])],
+	enable_ipv6=$enableval,
+	enable_ipv6=no)
+	if test "$enable_ipv6" = yes; then
+		AC_DEFINE(IPV6_SUPPORTED, 1, [Define this if you want IPv6 support compiled in])
+	else
+		enable_ipv6=
+	fi
+	AC_SUBST(enable_ipv6)
+	AM_CONDITIONAL(CONFIG_IPV6, [test "$enable_ipv6" = "yes"])
 
 # Check whether user wants TCP wrappers support
 AC_TCP_WRAPPERS
@@ -237,6 +249,17 @@ if test "$enable_gss" = yes; then
 
 fi
 
+if test "$enable_ipv6" = yes; then
+  AC_CHECK_FUNC(inet_ntop, , ,
+               AC_MSG_ERROR(Function 'inet_ntop' not found.))
+  AC_CHECK_FUNC(getnameinfo, , ,
+               AC_MSG_ERROR(Function 'getnameinfo' not found.))
+  AC_CHECK_LIB(tirpc, clnt_tli_create, ,
+               AC_MSG_ERROR([libtirpc needed for IPv6 support]))
+  AC_CHECK_HEADERS(tirpc/netconfig.h, ,
+               AC_MSG_ERROR([libtirpc-devel needed for IPv6 support]))
+fi
+
 dnl *************************************************************
 dnl Check for headers
 dnl *************************************************************
@@ -245,7 +268,7 @@ AC_CHECK_HEADERS([arpa/inet.h fcntl.h libintl.h limits.h \
                  stdlib.h string.h sys/file.h sys/ioctl.h sys/mount.h \
                  sys/param.h sys/socket.h sys/time.h sys/vfs.h \
                  syslog.h unistd.h com_err.h et/com_err.h \
-                 ifaddrs.h])
+                 ifaddrs.h tirpc/netconfig.h])
 
 dnl *************************************************************
 dnl Checks for typedefs, structures, and compiler characteristics
@@ -281,6 +304,10 @@ AC_FUNC_STAT
 AC_FUNC_VPRINTF
 AC_CHECK_FUNCS([alarm atexit dup2 fdatasync ftruncate getcwd \
                gethostbyaddr gethostbyname gethostname getmntent \
+               inet_ntop getnameinfo getrpcbyname \
+               bindresvport_sa getnetconfig \
+               clnt_create clnt_create_timed \
+               clnt_tli_create clnt_vc_create clnt_dg_create xdr_rpcb \
                gettimeofday hasmntopt inet_ntoa innetgr memset mkdir pathconf \
                realpath rmdir select socket strcasecmp strchr strdup \
                strerror strrchr strtol strtoul sigprocmask])


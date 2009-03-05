From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 8/9] nfs-utils: Include legacy or TI-RPC headers, not both
Date: Thu, 05 Mar 2009 12:42:29 -0500
Message-ID: <20090305174229.30471.42159.stgit@ingres.1015granger.net>
References: <20090305173533.30471.41413.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:49838 "EHLO
	rgminet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754749AbZCERnu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 Mar 2009 12:43:50 -0500
In-Reply-To: <20090305173533.30471.41413.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Data type incompatibilities between the legacy RPC headers and the
TI-RPC headers mean we can't use libtirpc with code that was compiled
against the legacy RPC headers.  The definition of rpcprog_t for
example is "unsigned long" in the legacy library, but it's "uint32_t"
for TI-RPC.  On 32-bit systems, these types happen to have the same
width, but on 64-bit systems they don't, making more complex data
structures that use these types in fields ABI incompatible.

Adopt a new strategy to deal with this issue.  When --enable-tirpc is
set, append "-I/usr/include/tirpc" to the compilation steps.  This
should cause the compiler to grab the tirpc/ headers instead of the
legacy headers.  Now, for TI-RPC builds, the TI-RPC legacy functions
and the TI-RPC headers will be used.  On legacy systems, the legacy
headers and legacy glibc RPC implementation will be used.

A new ./configure option is introduced to allow system integrators to
use TI-RPC headers in some other location than /usr/include/tirpc.
/usr/include/tirpc remains the default setting for this new option.

The gssd implementation presents a few challenges, but it turns out
the gssglue library is similar to the auth_gss pieces of TI-RPC.  To
avoid similar header incompatibility issues, gssd now uses libtirpc
instead of libgssglue if --enable-tirpc is specified.  There may be
other issues to tackle with gssd, but for now, we just make sure it
builds with --enable-tirpc.

Note also: svc_getcaller() is a macro in both cases that points to
a sockaddr field in the svc_req structure.  The legacy version points
to a sockaddr_in type field, but the TI-RPC version points to a
sockaddr_in6 type field.

rpc.mountd unconditionally casts the result of svc_getcaller() to a
sockaddr_in *.  This should be OK for TI-RPC as well, since rpc.mountd
still uses legacy RPC calls (provided by glibc, or emulated by TI-RPC)
to set up its listeners, and therefore rpc.mountd callers will always
be from AF_INET addresses for now.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 aclocal/librpcsecgss.m4  |   17 +++++++++++------
 aclocal/libtirpc.m4      |   10 +++++++++-
 aclocal/rpcsec_vers.m4   |    7 +++++--
 support/nfs/getport.c    |    4 ++--
 support/nfs/rpc_socket.c |   45 ++-------------------------------------------
 utils/gssd/gssd_proc.c   |    3 ++-
 utils/gssd/krb5_util.c   |    1 -
 utils/gssd/krb5_util.h   |    6 ++++++
 utils/mountd/svc_run.c   |    4 ++++
 9 files changed, 41 insertions(+), 56 deletions(-)

diff --git a/aclocal/librpcsecgss.m4 b/aclocal/librpcsecgss.m4
index 5791260..d1dd25e 100644
--- a/aclocal/librpcsecgss.m4
+++ b/aclocal/librpcsecgss.m4
@@ -3,12 +3,17 @@ dnl KRB5LIBS must be set before this function is invoked.
 dnl
 AC_DEFUN([AC_LIBRPCSECGSS], [
 
-  dnl Check for library, but do not add -lrpcsecgss to LIBS
-  AC_CHECK_LIB([rpcsecgss], [authgss_create_default], [librpcsecgss=1],
-               [AC_MSG_ERROR([librpcsecgss not found.])])
+  dnl libtirpc provides an rpcsecgss API
+  if test "$enable_tirpc" = no; then
 
-  AC_CHECK_LIB([rpcsecgss], [authgss_set_debug_level],
-               [AC_DEFINE([HAVE_AUTHGSS_SET_DEBUG_LEVEL], 1,
-               [Define to 1 if you have the `authgss_set_debug_level' function.])])
+    dnl Check for library, but do not add -lrpcsecgss to LIBS
+    AC_CHECK_LIB([rpcsecgss], [authgss_create_default], [librpcsecgss=1],
+                 [AC_MSG_ERROR([librpcsecgss not found.])])
+
+    AC_CHECK_LIB([rpcsecgss], [authgss_set_debug_level],
+                 [AC_DEFINE([HAVE_AUTHGSS_SET_DEBUG_LEVEL], 1,
+                 [Define to 1 if you have the `authgss_set_debug_level' function.])])
+
+  fi
 
 ])dnl
diff --git a/aclocal/libtirpc.m4 b/aclocal/libtirpc.m4
index b1f3669..af4c7d3 100644
--- a/aclocal/libtirpc.m4
+++ b/aclocal/libtirpc.m4
@@ -2,6 +2,12 @@ dnl Checks for TI-RPC library and headers
 dnl
 AC_DEFUN([AC_LIBTIRPC], [
 
+  AC_ARG_WITH([tirpcinclude],
+              [AC_HELP_STRING([--with-tirpcinclude=DIR],
+                              [use TI-RPC headers in DIR])],
+              [tirpc_header_dir=$withval],
+              [tirpc_header_dir=/usr/include/tirpc])
+
   dnl if --enable-tirpc was specifed, the following components
   dnl must be present, and we set up HAVE_ macros for them.
 
@@ -12,8 +18,10 @@ AC_DEFUN([AC_LIBTIRPC], [
                  [AC_MSG_ERROR([libtirpc not found.])])
 
     dnl also must have the headers installed where we expect
-    AC_CHECK_HEADERS([tirpc/netconfig.h], ,
+    dnl look for headers; add -I compiler option if found
+    AC_CHECK_HEADERS([${tirpc_header_dir}/netconfig.h], ,
                      [AC_MSG_ERROR([libtirpc headers not found.])])
+    AC_SUBST([AM_CPPFLAGS], ["-I${tirpc_header_dir}"])
 
   fi
 
diff --git a/aclocal/rpcsec_vers.m4 b/aclocal/rpcsec_vers.m4
index df7cfb9..5d13db3 100644
--- a/aclocal/rpcsec_vers.m4
+++ b/aclocal/rpcsec_vers.m4
@@ -1,8 +1,11 @@
 dnl Checks librpcsec version
 AC_DEFUN([AC_RPCSEC_VERSION], [
 
-  PKG_CHECK_MODULES([RPCSECGSS], [librpcsecgss >= 0.16], ,
-                    [AC_MSG_ERROR([Unable to locate information required to use librpcsecgss.  If you have pkgconfig installed, you might try setting environment variable PKG_CONFIG_PATH to /usr/local/lib/pkgconfig])])
+  dnl TI-RPC replaces librpcsecgss
+  if test "$enable_tirpc" = no; then
+    PKG_CHECK_MODULES([RPCSECGSS], [librpcsecgss >= 0.16], ,
+                      [AC_MSG_ERROR([Unable to locate information required to use librpcsecgss.  If you have pkgconfig installed, you might try setting environment variable PKG_CONFIG_PATH to /usr/local/lib/pkgconfig])])
+  fi
 
   PKG_CHECK_MODULES([GSSGLUE], [libgssglue >= 0.1])
 
diff --git a/support/nfs/getport.c b/support/nfs/getport.c
index 2255b7d..734d21a 100644
--- a/support/nfs/getport.c
+++ b/support/nfs/getport.c
@@ -41,8 +41,8 @@
 #include <rpc/pmap_prot.h>
 
 #ifdef HAVE_LIBTIRPC
-#include <tirpc/netconfig.h>
-#include <tirpc/rpc/rpcb_prot.h>
+#include <netconfig.h>
+#include <rpc/rpcb_prot.h>
 #endif
 
 #include "nfsrpc.h"
diff --git a/support/nfs/rpc_socket.c b/support/nfs/rpc_socket.c
index 4b4b0be..2b11e35 100644
--- a/support/nfs/rpc_socket.c
+++ b/support/nfs/rpc_socket.c
@@ -41,49 +41,8 @@
 #include "nfsrpc.h"
 
 #ifdef HAVE_LIBTIRPC
-
-/*
- * Most of the headers under /usr/include/tirpc are currently
- * unusable for various reasons.  We statically define the bits
- * we need here until the official headers are fixed.
- *
- * The commonly used RPC calls such as CLNT_CALL and CLNT_DESTROY
- * are actually virtual functions in both the legacy and TI-RPC
- * implementations.  The proper _CALL or _DESTROY will be invoked
- * no matter if we used a legacy clnt_create() or clnt_tli_create()
- * from libtirpc.
- */
-
-#include <tirpc/netconfig.h>
-#include <tirpc/rpc/rpcb_prot.h>
-
-/* definitions from tirpc/rpc/types.h */
-
-/*
- * The netbuf structure is used for transport-independent address storage.
- */
-struct netbuf {
-	unsigned int	maxlen;
-	unsigned int	len;
-	void		*buf;
-};
-
-/* definitions from tirpc/rpc/clnt.h */
-
-/*
- * Low level clnt create routine for connectionless transports, e.g. udp.
- */
-extern CLIENT *clnt_dg_create(const int, const struct netbuf *,
-			      const rpcprog_t, const rpcvers_t,
-			      const u_int, const u_int);
-
-/*
- * Low level clnt create routine for connectionful transports, e.g. tcp.
- */
-extern CLIENT *clnt_vc_create(const int, const struct netbuf *,
-			      const rpcprog_t, const rpcvers_t,
-			      u_int, u_int);
-
+#include <netconfig.h>
+#include <rpc/rpcb_prot.h>
 #endif	/* HAVE_LIBTIRPC */
 
 /*
diff --git a/utils/gssd/gssd_proc.c b/utils/gssd/gssd_proc.c
index d0d3f7f..295c37d 100644
--- a/utils/gssd/gssd_proc.c
+++ b/utils/gssd/gssd_proc.c
@@ -70,7 +70,6 @@
 #include "gssd.h"
 #include "err_util.h"
 #include "gss_util.h"
-#include "gss_oids.h"
 #include "krb5_util.h"
 #include "context.h"
 
@@ -778,8 +777,10 @@ handle_krb5_upcall(struct clnt_info *clp)
 out:
 	if (token.value)
 		free(token.value);
+#ifndef HAVE_LIBTIRPC
 	if (pd.pd_ctx_hndl.length != 0)
 		authgss_free_private_data(&pd);
+#endif
 	if (auth)
 		AUTH_DESTROY(auth);
 	if (rpc_clnt)
diff --git a/utils/gssd/krb5_util.c b/utils/gssd/krb5_util.c
index 8923b3b..e3c6f5e 100644
--- a/utils/gssd/krb5_util.c
+++ b/utils/gssd/krb5_util.c
@@ -124,7 +124,6 @@
 #include "gssd.h"
 #include "err_util.h"
 #include "gss_util.h"
-#include "gss_oids.h"
 #include "krb5_util.h"
 
 /* Global list of principals/cache file names for machine credentials */
diff --git a/utils/gssd/krb5_util.h b/utils/gssd/krb5_util.h
index 4b2da6b..7d808f5 100644
--- a/utils/gssd/krb5_util.h
+++ b/utils/gssd/krb5_util.h
@@ -3,6 +3,12 @@
 
 #include <krb5.h>
 
+#ifdef HAVE_LIBTIRPC
+#include <rpc/auth_gss.h>
+#else
+#include "gss_oids.h"
+#endif
+
 /*
  * List of principals from our keytab that we
  * will try to use to obtain credentials
diff --git a/utils/mountd/svc_run.c b/utils/mountd/svc_run.c
index 422e839..5ba5af6 100644
--- a/utils/mountd/svc_run.c
+++ b/utils/mountd/svc_run.c
@@ -54,6 +54,10 @@
 #include <errno.h>
 #include <time.h>
 
+#ifdef HAVE_LIBTIRPC
+#include <rpc/rpc_com.h>
+#endif
+
 void cache_set_fds(fd_set *fdset);
 int cache_process_req(fd_set *readfds);
 


From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 1/9] configure: add defensive quoting in some function checks
Date: Thu, 05 Mar 2009 12:41:51 -0500
Message-ID: <20090305174151.30471.97859.stgit@ingres.1015granger.net>
References: <20090305173533.30471.41413.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:64411 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751187AbZCERm2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 Mar 2009 12:42:28 -0500
In-Reply-To: <20090305173533.30471.41413.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: Add proper m4 quoting in macros that check for the presence
of some functions in configure.ac.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 configure.ac |   25 ++++++++++++++-----------
 1 files changed, 14 insertions(+), 11 deletions(-)

diff --git a/configure.ac b/configure.ac
index 5db4417..97b084b 100644
--- a/configure.ac
+++ b/configure.ac
@@ -176,23 +176,26 @@ AC_BSD_SIGNALS
 dnl *************************************************************
 dnl * Check for required libraries
 dnl *************************************************************
-AC_CHECK_FUNC(gethostbyname, , [AC_CHECK_LIB(nsl, gethostbyname, [LIBNSL="-lnsl"])])
+
+AC_CHECK_FUNC([gethostbyname], ,
+              [AC_CHECK_LIB([nsl], [gethostbyname], [LIBNSL="-lnsl"])])
 AC_SUBST(LIBNSL)
 
-AC_CHECK_FUNC(connect, ,
-      AC_CHECK_LIB(socket, connect, [LIBSOCKET="-lsocket"],
-                AC_MSG_ERROR(Function 'socket' not found.), $LIBNSL))
+AC_CHECK_FUNC([connect], ,
+              [AC_CHECK_LIB([socket], [connect], [LIBSOCKET="-lsocket"],
+                    [AC_MSG_ERROR([Function 'socket' not found.])], [$LIBNSL])])
+
+AC_CHECK_FUNC([getaddrinfo], , ,
+              [AC_MSG_ERROR([Function 'getaddrinfo' not found.])])
 
-AC_CHECK_FUNC(getaddrinfo, , ,
-                AC_MSG_ERROR(Function 'getaddrinfo' not found.))
+AC_CHECK_FUNC([getrpcbynumber], , ,
+              [AC_MSG_ERROR([Function 'getrpcbynumber' not found.])])
 
-AC_CHECK_FUNC(getrpcbynumber, , ,
-                AC_MSG_ERROR(Function 'getrpcbynumber' not found.))
+AC_CHECK_FUNC([getservbyname], , ,
+              [AC_MSG_ERROR([Function 'getservbyname' not found.])])
 
-AC_CHECK_FUNC(getservbyname, , ,
-                AC_MSG_ERROR(Function 'getservbyname' not found.))
+AC_CHECK_LIB([crypt], [crypt], [LIBCRYPT="-lcrypt"])
 
-AC_CHECK_LIB(crypt, crypt, [LIBCRYPT="-lcrypt"])
 if test "$enable_nfsv4" = yes; then
     AC_CHECK_LIB(event, event_dispatch, [libevent=1], AC_MSG_ERROR([libevent needed for nfsv4 support]))
     AC_CHECK_LIB(nfsidmap, nfs4_init_name_mapping, [libnfsidmap=1], AC_MSG_ERROR([libnfsidmap needed for nfsv4 support]))


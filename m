From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH] nfs-utils: fix AC_CHECK_FUNC calls in configure.ac
Date: Mon, 16 Mar 2009 14:51:14 -0400
Message-ID: <20090316185007.13728.1047.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: jlayton@redhat.com, linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:25079 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752743AbZCPSwL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 16 Mar 2009 14:52:11 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Jeff Layton <jlayton@redhat.com>

AC_CHECK_FUNC and AC_CHECK_FUNCS take 3 args. Any ones beyond that are
ignored. In several places, we're passing the "action-if-not-found" in
as the 4th arg so it's being ignored.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

Steve-

Thanks for committing the other patches.  Here's one more nit that Jeff
found recently.

 aclocal/ipv6.m4 |    2 +-
 configure.ac    |    6 +++---
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/aclocal/ipv6.m4 b/aclocal/ipv6.m4
index 0564b3e..ba9dcc2 100644
--- a/aclocal/ipv6.m4
+++ b/aclocal/ipv6.m4
@@ -15,7 +15,7 @@ AC_DEFUN([AC_IPV6], [
     fi
 
     dnl IPv6-enabled networking functions required for IPv6
-    AC_CHECK_FUNCS([getnameinfo bindresvport_sa], , ,
+    AC_CHECK_FUNCS([getnameinfo bindresvport_sa], ,
                    [AC_MSG_ERROR([Missing functions needed for IPv6.])])
 
     dnl Need to detect presence of IPv6 networking at run time via
diff --git a/configure.ac b/configure.ac
index e34b7e2..f942238 100644
--- a/configure.ac
+++ b/configure.ac
@@ -185,13 +185,13 @@ AC_CHECK_FUNC([connect], ,
               [AC_CHECK_LIB([socket], [connect], [LIBSOCKET="-lsocket"],
                     [AC_MSG_ERROR([Function 'socket' not found.])], [$LIBNSL])])
 
-AC_CHECK_FUNC([getaddrinfo], , ,
+AC_CHECK_FUNC([getaddrinfo], ,
               [AC_MSG_ERROR([Function 'getaddrinfo' not found.])])
 
-AC_CHECK_FUNC([getrpcbynumber], , ,
+AC_CHECK_FUNC([getrpcbynumber], ,
               [AC_MSG_ERROR([Function 'getrpcbynumber' not found.])])
 
-AC_CHECK_FUNC([getservbyname], , ,
+AC_CHECK_FUNC([getservbyname], ,
               [AC_MSG_ERROR([Function 'getservbyname' not found.])])
 
 AC_CHECK_LIB([crypt], [crypt], [LIBCRYPT="-lcrypt"])


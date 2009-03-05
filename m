From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 6/9] nfs-utils: don't need extra libs to do AC_CHECK_LIBS for
	librpcsecgss
Date: Thu, 05 Mar 2009 12:42:18 -0500
Message-ID: <20090305174218.30471.72288.stgit@ingres.1015granger.net>
References: <20090305173533.30471.41413.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:53956 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753489AbZCERmn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 Mar 2009 12:42:43 -0500
In-Reply-To: <20090305173533.30471.41413.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Jeff Layton <jlayton@redhat.com>

The conftest should work without these extra libs being included.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 aclocal/librpcsecgss.m4 |    8 +++-----
 1 files changed, 3 insertions(+), 5 deletions(-)

diff --git a/aclocal/librpcsecgss.m4 b/aclocal/librpcsecgss.m4
index a81819e..5791260 100644
--- a/aclocal/librpcsecgss.m4
+++ b/aclocal/librpcsecgss.m4
@@ -5,12 +5,10 @@ AC_DEFUN([AC_LIBRPCSECGSS], [
 
   dnl Check for library, but do not add -lrpcsecgss to LIBS
   AC_CHECK_LIB([rpcsecgss], [authgss_create_default], [librpcsecgss=1],
-               [AC_MSG_ERROR([librpcsecgss not found.])],
-               [-lgssglue -ldl])
+               [AC_MSG_ERROR([librpcsecgss not found.])])
 
   AC_CHECK_LIB([rpcsecgss], [authgss_set_debug_level],
-  	       [AC_DEFINE([HAVE_AUTHGSS_SET_DEBUG_LEVEL], 1,
-               [Define to 1 if you have the `authgss_set_debug_level' function.])],,
-               [-lgssglue -ldl])
+               [AC_DEFINE([HAVE_AUTHGSS_SET_DEBUG_LEVEL], 1,
+               [Define to 1 if you have the `authgss_set_debug_level' function.])])
 
 ])dnl


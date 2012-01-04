Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vw0-f46.google.com ([209.85.212.46]:65160 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755819Ab2ADT4v (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 4 Jan 2012 14:56:51 -0500
Received: by vbbfc26 with SMTP id fc26so13670466vbb.19
        for <linux-nfs@vger.kernel.org>; Wed, 04 Jan 2012 11:56:51 -0800 (PST)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 2/5] configure.ac: Don't check for AI_ADDRCONFIG
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Date: Wed, 04 Jan 2012 14:56:49 -0500
Message-ID: <20120104195649.21904.64711.stgit@degas.1015granger.net>
In-Reply-To: <20120104194136.21904.36616.stgit@degas.1015granger.net>
References: <20120104194136.21904.36616.stgit@degas.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Commit 1ea2c3be: "nfs-utils: Remove all uses of AI_ADDRCONFIG,"
(October 28, 2010) removed the last use of AI_ADDRCONFIG.  Even so,
ipv6.m4 uses this check to ensure that the local getaddrinfo(3)
implementation is recent.  Maybe we shouldn't bother.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 aclocal/ipv6.m4 |   11 -----------
 1 files changed, 0 insertions(+), 11 deletions(-)

diff --git a/aclocal/ipv6.m4 b/aclocal/ipv6.m4
index 5ee8fb6..4e39fbe 100644
--- a/aclocal/ipv6.m4
+++ b/aclocal/ipv6.m4
@@ -2,11 +2,6 @@ dnl Checks for IPv6 support
 dnl
 AC_DEFUN([AC_IPV6], [
 
-  AC_CHECK_DECL([AI_ADDRCONFIG],
-                [AC_DEFINE([HAVE_DECL_AI_ADDRCONFIG], 1,
-                           [Define this to 1 if AI_ADDRCONFIG macro is defined])], ,
-                [ #include <netdb.h> ])
-
   if test "$enable_ipv6" = yes; then
 
     dnl TI-RPC required for IPv6
@@ -18,12 +13,6 @@ AC_DEFUN([AC_IPV6], [
     AC_CHECK_FUNCS([getifaddrs getnameinfo bindresvport_sa], ,
                    [AC_MSG_ERROR([Missing library functions needed for IPv6.])])
 
-    dnl Need to detect presence of IPv6 networking at run time via
-    dnl getaddrinfo(3); old versions of glibc do not support ADDRCONFIG
-    AC_CHECK_DECL([AI_ADDRCONFIG], ,
-                  [AC_MSG_ERROR([full getaddrinfo(3) implementation needed for IPv6 support])],
-                  [ #include <netdb.h> ])
-
   fi
 
 ])dnl


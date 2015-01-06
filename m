Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wg0-f48.google.com ([74.125.82.48]:39264 "EHLO
	mail-wg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751827AbbAFXIE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 6 Jan 2015 18:08:04 -0500
Received: by mail-wg0-f48.google.com with SMTP id l2so189278wgh.21
        for <linux-nfs@vger.kernel.org>; Tue, 06 Jan 2015 15:08:02 -0800 (PST)
From: "Yann E. MORIN" <yann.morin.1998@free.fr>
To: linux-nfs@vger.kernel.org
Cc: "Yann E. MORIN" <yann.morin.1998@free.fr>,
        Chuck Lever <check.lever@oracle.com>,
        Steve Dickson <SteveD@redhat.com>
Subject: [PATCH 1/4] configure: do not fail if libtirpc is missing but not requested
Date: Wed,  7 Jan 2015 00:07:57 +0100
Message-Id: <7b77f91268fcbb942affb41afc0272c1439121e9.1420585444.git.yann.morin.1998@free.fr>
In-Reply-To: <cover.1420585444.git.yann.morin.1998@free.fr>
References: <cover.1420585444.git.yann.morin.1998@free.fr>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The current code bails out if libtirpc is not found, making it a
mandatory dependency of nfs-utils, which it is not: it is only an
optional dependency.

The culprit (introduced by me) is the action-if-not-found in
PKG_CHECK_MODULES, that improerly checks the value of the --enable-tirpc
flag.

Fix that by checking against a 'yes'. Any other value means either
'auto' (in which case we do not want to fail), or 'no' (in which case we
do not even run the test to start with).

Signed-off-by: "Yann E. MORIN" <yann.morin.1998@free.fr>
Cc: Chuck Lever <check.lever@oracle.com>
Cc: Steve Dickson <SteveD@redhat.com>
---
 aclocal/libtirpc.m4 | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/aclocal/libtirpc.m4 b/aclocal/libtirpc.m4
index ebc1bea..c46f16a 100644
--- a/aclocal/libtirpc.m4
+++ b/aclocal/libtirpc.m4
@@ -10,7 +10,7 @@ AC_DEFUN([AC_LIBTIRPC], [
                        AM_CPPFLAGS="${AM_CPPFLAGS} ${TIRPC_CFLAGS}"
                        AC_DEFINE([HAVE_LIBTIRPC], [1],
                                  [Define to 1 if you have and wish to use libtirpc.])],
-                      [AS_IF([test "$enable_tirpc" != "no"], [AC_MSG_ERROR([libtirpc not found.])],
+                      [AS_IF([test "$enable_tirpc" = "yes"], [AC_MSG_ERROR([libtirpc not found.])],
                              [LIBTIRPC=""])])])
 
   AC_SUBST([AM_CPPFLAGS])
-- 
1.9.1


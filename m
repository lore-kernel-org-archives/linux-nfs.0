Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wg0-f51.google.com ([74.125.82.51]:43537 "EHLO
	mail-wg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751958AbbAFXII (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 6 Jan 2015 18:08:08 -0500
Received: by mail-wg0-f51.google.com with SMTP id x12so185996wgg.24
        for <linux-nfs@vger.kernel.org>; Tue, 06 Jan 2015 15:08:07 -0800 (PST)
From: "Yann E. MORIN" <yann.morin.1998@free.fr>
To: linux-nfs@vger.kernel.org
Cc: "Yann E. MORIN" <yann.morin.1998@free.fr>,
        Chuck Lever <check.lever@oracle.com>,
        Steve Dickson <SteveD@redhat.com>
Subject: [PATCH 4/4] configure: restore checking for authgss_free_private_data in libtirpc
Date: Wed,  7 Jan 2015 00:08:00 +0100
Message-Id: <f3aaa3c4f47cd75629b60b913d97ef9d7dfd19ea.1420585444.git.yann.morin.1998@free.fr>
In-Reply-To: <cover.1420585444.git.yann.morin.1998@free.fr>
References: <cover.1420585444.git.yann.morin.1998@free.fr>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Since commit 8534063 (configure: use pkg-config to find libtirpc), we
are missing the check for authgss_free_private_data in libtirpc.

Restore this check, and adapt so that it works in both the pkg-config
case and in the "old code" case.

Signed-off-by: "Yann E. MORIN" <yann.morin.1998@free.fr>
Cc: Chuck Lever <check.lever@oracle.com>
Cc: Steve Dickson <SteveD@redhat.com>
---
 aclocal/libtirpc.m4 | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/aclocal/libtirpc.m4 b/aclocal/libtirpc.m4
index 5e9d76e..b7de636 100644
--- a/aclocal/libtirpc.m4
+++ b/aclocal/libtirpc.m4
@@ -14,6 +14,12 @@ AC_DEFUN([AC_LIBTIRPC], [
                        AS_IF([test "$enable_tirpc" = "yes" -a -z "${LIBTIRPC}"],
                              [AC_MSG_ERROR([libtirpc not found.])])])])
 
+     AS_IF([test -n "${LIBTIRPC}"],
+           [AC_CHECK_LIB([tirpc], [authgss_free_private_data],
+                         [AC_DEFINE([HAVE_AUTHGSS_FREE_PRIVATE_DATA], [1],
+                                    [Define to 1 if your rpcsec library provides authgss_free_private_data])],,
+                         [${LIBS}])])
+
   AC_SUBST([AM_CPPFLAGS])
   AC_SUBST(LIBTIRPC)
 
-- 
1.9.1


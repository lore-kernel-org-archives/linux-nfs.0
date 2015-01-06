Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-we0-f175.google.com ([74.125.82.175]:41679 "EHLO
	mail-we0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751827AbbAFXIF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 6 Jan 2015 18:08:05 -0500
Received: by mail-we0-f175.google.com with SMTP id k11so194440wes.20
        for <linux-nfs@vger.kernel.org>; Tue, 06 Jan 2015 15:08:04 -0800 (PST)
From: "Yann E. MORIN" <yann.morin.1998@free.fr>
To: linux-nfs@vger.kernel.org
Cc: "Yann E. MORIN" <yann.morin.1998@free.fr>,
        Steve Dickson <SteveD@redhat.com>
Subject: [PATCH 2/4] configure: be more laxist on the required libtirpc version
Date: Wed,  7 Jan 2015 00:07:58 +0100
Message-Id: <14543c304f80f352fada0d4c1bb23496936c3609.1420585444.git.yann.morin.1998@free.fr>
In-Reply-To: <cover.1420585444.git.yann.morin.1998@free.fr>
References: <cover.1420585444.git.yann.morin.1998@free.fr>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Currently, we check for libtirpc >= 0.2.4 with pkg-config, because that
is the one version I had to test against.

As reported on the list, however, older versions are also supported.

Relax the check to not require a version at all, and accept any version
of libtirpc.

Reported-by: Chuck Lever <check.lever@oracle.com>
Signed-off-by: "Yann E. MORIN" <yann.morin.1998@free.fr>
Cc: Steve Dickson <SteveD@redhat.com>
---
 aclocal/libtirpc.m4 | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/aclocal/libtirpc.m4 b/aclocal/libtirpc.m4
index c46f16a..9ea17c5 100644
--- a/aclocal/libtirpc.m4
+++ b/aclocal/libtirpc.m4
@@ -5,7 +5,7 @@ AC_DEFUN([AC_LIBTIRPC], [
   PKG_PROG_PKG_CONFIG([0.9.0])
   AS_IF(
     [test "$enable_tirpc" != "no"],
-    [PKG_CHECK_MODULES([TIRPC], [libtirpc >= 0.2.4],
+    [PKG_CHECK_MODULES([TIRPC], [libtirpc],
                       [LIBTIRPC="${TIRPC_LIBS}"
                        AM_CPPFLAGS="${AM_CPPFLAGS} ${TIRPC_CFLAGS}"
                        AC_DEFINE([HAVE_LIBTIRPC], [1],
-- 
1.9.1


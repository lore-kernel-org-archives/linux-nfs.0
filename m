Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51908 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1730254AbeIFUea (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 6 Sep 2018 16:34:30 -0400
Received: from smtp.corp.redhat.com (int-mx11.intmail.prod.int.phx2.redhat.com [10.5.11.26])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 2F7A9308FBA1
        for <linux-nfs@vger.kernel.org>; Thu,  6 Sep 2018 15:58:22 +0000 (UTC)
Received: from steved.boston.devel.redhat.com (ovpn-116-194.phx2.redhat.com [10.3.116.194])
        by smtp.corp.redhat.com (Postfix) with ESMTP id DE7D23091384
        for <linux-nfs@vger.kernel.org>; Thu,  6 Sep 2018 15:58:21 +0000 (UTC)
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH] tcp-wrappers.m4: Only look for TCP wrappers lib when requested
Date: Thu,  6 Sep 2018 11:58:20 -0400
Message-Id: <20180906155820.59424-1-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

TCP wrappers is a pretty old and obsolete technology.  The
support has be terminated in current distro release, so
only require the library to exist when asked for via the
--with-tcp-wrappers

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 aclocal/tcp-wrappers.m4 | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/aclocal/tcp-wrappers.m4 b/aclocal/tcp-wrappers.m4
index 35ac8e0..f5de8bc 100644
--- a/aclocal/tcp-wrappers.m4
+++ b/aclocal/tcp-wrappers.m4
@@ -4,7 +4,7 @@ AC_DEFUN([AC_TCP_WRAPPERS],[
   AC_ARG_WITH(tcp-wrappers,
     [  --with-tcp-wrappers[[=PATH]]      Enable tcpwrappers support
                  (optionally in PATH)],
-    with_tcpw=$withval, with_tcpw=yes)
+    with_tcpw=$withval, with_tcpw=no)
         if test "x$with_tcpw" != "xno" ; then
             saved_LIBS="$LIBS"
             saved_LDFLAGS="$LDFLAGS"
-- 
2.17.1

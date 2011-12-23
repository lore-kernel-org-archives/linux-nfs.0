Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qw0-f46.google.com ([209.85.216.46]:57298 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753570Ab1LWTrN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 23 Dec 2011 14:47:13 -0500
Received: by qadc12 with SMTP id c12so5224840qad.19
        for <linux-nfs@vger.kernel.org>; Fri, 23 Dec 2011 11:47:12 -0800 (PST)
From: Jeff Layton <jlayton@redhat.com>
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 1/3] autoconf: fix up libevent autoconf test
Date: Fri, 23 Dec 2011 14:47:03 -0500
Message-Id: <1324669625-2948-2-git-send-email-jlayton@redhat.com>
In-Reply-To: <1324669625-2948-1-git-send-email-jlayton@redhat.com>
References: <1324669625-2948-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Have it set LIBEVENT to -levent and use that in the Makefiles instead
of hardcoding it.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 aclocal/libevent.m4      |    3 ++-
 utils/idmapd/Makefile.am |    2 +-
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/aclocal/libevent.m4 b/aclocal/libevent.m4
index 3c962b3..b5ac00f 100644
--- a/aclocal/libevent.m4
+++ b/aclocal/libevent.m4
@@ -2,8 +2,9 @@ dnl Checks for libevent
 AC_DEFUN([AC_LIBEVENT], [
 
   dnl Check for libevent, but do not add -levent to LIBS
-  AC_CHECK_LIB([event], [event_dispatch], [libevent=1],
+  AC_CHECK_LIB([event], [event_dispatch], [LIBEVENT=-levent],
                [AC_MSG_ERROR([libevent not found.])])
+  AC_SUBST(LIBEVENT)
 
   AC_CHECK_HEADERS([event.h], ,
                    [AC_MSG_ERROR([libevent headers not found.])])
diff --git a/utils/idmapd/Makefile.am b/utils/idmapd/Makefile.am
index 4328e41..f8578b0 100644
--- a/utils/idmapd/Makefile.am
+++ b/utils/idmapd/Makefile.am
@@ -16,7 +16,7 @@ idmapd_SOURCES = \
 	nfs_idmap.h \
 	queue.h
 
-idmapd_LDADD = -levent -lnfsidmap ../../support/nfs/libnfs.a
+idmapd_LDADD = $(LIBEVENT) -lnfsidmap ../../support/nfs/libnfs.a
 
 MAINTAINERCLEANFILES = Makefile.in
 
-- 
1.7.7.4


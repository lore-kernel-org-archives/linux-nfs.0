Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:62595 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754050Ab1LUUf3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 21 Dec 2011 15:35:29 -0500
From: Jeff Layton <jlayton@redhat.com>
To: bfields@fieldses.org, steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v3 01/10] autoconf: fix up libevent autoconf test
Date: Wed, 21 Dec 2011 15:35:13 -0500
Message-Id: <1324499722-10363-2-git-send-email-jlayton@redhat.com>
In-Reply-To: <1324499722-10363-1-git-send-email-jlayton@redhat.com>
References: <1324499722-10363-1-git-send-email-jlayton@redhat.com>
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
1.7.1


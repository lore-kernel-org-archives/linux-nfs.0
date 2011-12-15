Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:28463 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758954Ab1LOSoC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 15 Dec 2011 13:44:02 -0500
Received: from int-mx12.intmail.prod.int.phx2.redhat.com (int-mx12.intmail.prod.int.phx2.redhat.com [10.5.11.25])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id pBFIi2Dt010871
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Thu, 15 Dec 2011 13:44:02 -0500
Received: from dantu.rdu.redhat.com (dantu.rdu.redhat.com [10.11.228.66])
	by int-mx12.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id pBFIi17d010403
	for <linux-nfs@vger.kernel.org>; Thu, 15 Dec 2011 13:44:01 -0500
From: Jeff Layton <jlayton@redhat.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v2 1/7] autoconf: fix up libevent autoconf test
Date: Thu, 15 Dec 2011 13:43:55 -0500
Message-Id: <1323974641-16515-2-git-send-email-jlayton@redhat.com>
In-Reply-To: <1323974641-16515-1-git-send-email-jlayton@redhat.com>
References: <1323974641-16515-1-git-send-email-jlayton@redhat.com>
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


Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:40160 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755831AbaISMvu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 19 Sep 2014 08:51:50 -0400
Received: from int-mx11.intmail.prod.int.phx2.redhat.com (int-mx11.intmail.prod.int.phx2.redhat.com [10.5.11.24])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id s8JCpnia022439
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <linux-nfs@vger.kernel.org>; Fri, 19 Sep 2014 08:51:49 -0400
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Cc: Simo Sorce <simo@redhat.com>
Subject: [PATCH 2/2] svcgssd: Remove rules from the Makefile.am
Date: Fri, 19 Sep 2014 08:51:43 -0400
Message-Id: <1411131103-17254-3-git-send-email-steved@redhat.com>
In-Reply-To: <1411131103-17254-1-git-send-email-steved@redhat.com>
References: <1411131103-17254-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The managing of GSSAPI credentials is now done
with the gssproxy(8) daemon so svcgssd no longer
needs to be build or installed.

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 utils/gssd/Makefile.am | 25 ++-----------------------
 1 file changed, 2 insertions(+), 23 deletions(-)

diff --git a/utils/gssd/Makefile.am b/utils/gssd/Makefile.am
index af59791..716dd0b 100644
--- a/utils/gssd/Makefile.am
+++ b/utils/gssd/Makefile.am
@@ -1,10 +1,10 @@
 ## Process this file with automake to produce Makefile.in
 
-man8_MANS	= gssd.man svcgssd.man
+man8_MANS	= gssd.man
 
 RPCPREFIX	= rpc.
 KPREFIX		= @kprefix@
-sbin_PREFIXED	= gssd svcgssd
+sbin_PREFIXED	= gssd
 sbin_PROGRAMS	= $(sbin_PREFIXED)
 
 EXTRA_DIST = \
@@ -45,27 +45,6 @@ gssd_LDFLAGS = $(KRBLDFLAGS) $(LIBTIRPC)
 gssd_CFLAGS = $(AM_CFLAGS) $(CFLAGS) \
 	      $(RPCSECGSS_CFLAGS) $(KRBCFLAGS) $(GSSAPI_CFLAGS)
 
-svcgssd_SOURCES = \
-	$(COMMON_SRCS) \
-	svcgssd.c \
-	svcgssd_main_loop.c \
-	svcgssd_mech2file.c \
-	svcgssd_proc.c \
-	svcgssd_krb5.c \
-	\
-	svcgssd_krb5.h \
-	svcgssd.h
-
-svcgssd_LDADD = \
-	../../support/nfs/libnfs.a \
-	$(RPCSECGSS_LIBS) $(LIBNFSIDMAP) \
-	$(KRBLIBS) $(GSSAPI_LIBS) $(LIBTIRPC)
-
-svcgssd_LDFLAGS = $(KRBLDFLAGS)
-
-svcgssd_CFLAGS = $(AM_CFLAGS) $(CFLAGS) \
-		 $(RPCSECGSS_CFLAGS) $(KRBCFLAGS) $(GSSAPI_CFLAGS)
-
 MAINTAINERCLEANFILES = Makefile.in
 
 #######################################################################
-- 
1.9.3


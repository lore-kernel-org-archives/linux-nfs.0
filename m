Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:43848 "EHLO smtp.gentoo.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1033462AbeE1KWD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 28 May 2018 06:22:03 -0400
From: Lars Wendler <polynomial-c@gentoo.org>
To: linux-nfs@vger.kernel.org
Cc: Lars Wendler <polynomial-c@gentoo.org>
Subject: [PATCH] Fix undefined references and bad include when build with junction support
Date: Mon, 28 May 2018 12:21:48 +0200
Message-Id: <20180528102148.10201-1-polynomial-c@gentoo.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

---
 support/junction/Makefile.am | 2 +-
 utils/nfsref/Makefile.am     | 6 +++---
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/support/junction/Makefile.am b/support/junction/Makefile.am
index 97e7426..89cb532 100644
--- a/support/junction/Makefile.am
+++ b/support/junction/Makefile.am
@@ -31,4 +31,4 @@ libjunction_la_SOURCES	= display.c export-cache.c junction.c \
 
 MAINTAINERCLEANFILES	= Makefile.in
 
-AM_CPPFLAGS		= -I. -I../include -I/usr/include/libxml2
+AM_CPPFLAGS		= -I. -I../include -I/usr/include/libxml2 @TIRPC_CFLAGS@
diff --git a/utils/nfsref/Makefile.am b/utils/nfsref/Makefile.am
index 2b2bb53..a652b03 100644
--- a/utils/nfsref/Makefile.am
+++ b/utils/nfsref/Makefile.am
@@ -27,13 +27,13 @@ noinst_HEADERS		= nfsref.h
 
 sbin_PROGRAMS		= nfsref
 nfsref_SOURCES		= add.c lookup.c nfsref.c remove.c
-LDADD			= $(LIBXML2) $(LIBCAP) \
-			  ../../support/nfs/libnfs.la \
+LIBS			+= $(LIBXML2) $(LIBCAP)
+LDADD			=  ../../support/nfs/libnfs.la \
 			  ../../support/junction/libjunction.la
 
 man8_MANS		= nfsref.man
 
 MAINTAINERCLEANFILES	= Makefile.in
 
-AM_CPPFLAGS		= -I. -I../../support/include
+AM_CPPFLAGS		= -I. -I../../support/include @TIRPC_CFLAGS@
 ##AM_LDFLAGS		= -Wl,--as-needed
-- 
2.17.0


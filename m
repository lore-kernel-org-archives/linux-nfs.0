From: Ihar Hrachyshka <ihar.hrachyshka@gmail.com>
Subject: [PATCH] Fixed cross-compilation of nfs-utils tools.
Date: Tue,  3 Mar 2009 19:49:18 +0200
Message-ID: <1236102558-18099-1-git-send-email-ihar.hrachyshka@gmail.com>
Cc: Ihar Hrachyshka <ihar.hrachyshka@gmail.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ew0-f177.google.com ([209.85.219.177]:50725 "EHLO
	mail-ew0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750768AbZCCRt1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 3 Mar 2009 12:49:27 -0500
Received: by ewy25 with SMTP id 25so2430880ewy.37
        for <linux-nfs@vger.kernel.org>; Tue, 03 Mar 2009 09:49:24 -0800 (PST)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Build nfs-utils tools with compiler defined by ./configure script.
---
 tools/locktest/Makefile.am |    4 ----
 tools/rpcdebug/Makefile.am |    4 ----
 tools/rpcgen/Makefile.am   |    5 -----
 3 files changed, 0 insertions(+), 13 deletions(-)

diff --git a/tools/locktest/Makefile.am b/tools/locktest/Makefile.am
index 3156815..e89fbad 100644
--- a/tools/locktest/Makefile.am
+++ b/tools/locktest/Makefile.am
@@ -1,12 +1,8 @@
 ## Process this file with automake to produce Makefile.in
 
-CC=$(CC_FOR_BUILD)
 LIBTOOL = @LIBTOOL@ --tag=CC
 
 noinst_PROGRAMS = testlk
 testlk_SOURCES = testlk.c
-testlk_CFLAGS=$(CFLAGS_FOR_BUILD)
-testlk_CPPFLAGS=$(CPPFLAGS_FOR_BUILD)
-testlk_LDFLAGS=$(LDFLAGS_FOR_BUILD)
 
 MAINTAINERCLEANFILES = Makefile.in
diff --git a/tools/rpcdebug/Makefile.am b/tools/rpcdebug/Makefile.am
index 39b70c9..c627b01 100644
--- a/tools/rpcdebug/Makefile.am
+++ b/tools/rpcdebug/Makefile.am
@@ -1,6 +1,5 @@
 ## Process this file with automake to produce Makefile.in
 
-CC=$(CC_FOR_BUILD)
 LIBTOOL = @LIBTOOL@ --tag=CC
 
 man8_MANS = rpcdebug.man
@@ -8,8 +7,5 @@ EXTRA_DIST = $(man8_MANS)
 
 sbin_PROGRAMS = rpcdebug
 rpcdebug_SOURCES = rpcdebug.c
-rpcdebug_CFLAGS=$(CFLAGS_FOR_BUILD)
-rpcdebug_CPPFLAGS=$(CPPFLAGS_FOR_BUILD) -I$(top_srcdir)/support/include
-rpcdebug_LDFLAGS=$(LDFLAGS_FOR_BUILD)
 
 MAINTAINERCLEANFILES = Makefile.in
diff --git a/tools/rpcgen/Makefile.am b/tools/rpcgen/Makefile.am
index 51a2bfa..fc75108 100644
--- a/tools/rpcgen/Makefile.am
+++ b/tools/rpcgen/Makefile.am
@@ -1,6 +1,5 @@
 ## Process this file with automake to produce Makefile.in
 
-CC=$(CC_FOR_BUILD)
 LIBTOOL = @LIBTOOL@ --tag=CC
 
 noinst_PROGRAMS = rpcgen
@@ -9,10 +8,6 @@ rpcgen_SOURCES = rpc_clntout.c rpc_cout.c rpc_hout.c rpc_main.c \
 		 rpc_util.c rpc_sample.c rpc_output.h rpc_parse.h \
 		 rpc_scan.h rpc_util.h
 
-rpcgen_CFLAGS=$(CFLAGS_FOR_BUILD)
-rpcgen_CPPLAGS=$(CPPFLAGS_FOR_BUILD)
-rpcgen_LDFLAGS=$(LDFLAGS_FOR_BUILD)
-
 MAINTAINERCLEANFILES = Makefile.in
 
 EXTRA_DIST = rpcgen.new.1
-- 
1.5.6.3


Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp.gentoo.org ([140.211.166.183]:46576 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754767Ab3CXWBO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 24 Mar 2013 18:01:14 -0400
Received: from localhost.localdomain (localhost [127.0.0.1])
	by smtp.gentoo.org (Postfix) with ESMTP id 4B2EC33BE3D
	for <linux-nfs@vger.kernel.org>; Sun, 24 Mar 2013 22:01:13 +0000 (UTC)
From: Mike Frysinger <vapier@gentoo.org>
To: linux-nfs@vger.kernel.org
Subject: [PATCH [nfs-utils]] rpcdebug: do not use build toolchain
Date: Sun, 24 Mar 2013 18:05:28 -0400
Message-Id: <1364162728-3032-1-git-send-email-vapier@gentoo.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The rpcdebug program gets installed, so we don't want to use the build
toolchain to compile it.  I can't find any scripts in the build system
that try to execute it, so this shouldn't be a problem.

Signed-off-by: Mike Frysinger <vapier@gentoo.org>
---
 tools/rpcdebug/Makefile.am | 6 ------
 1 file changed, 6 deletions(-)

diff --git a/tools/rpcdebug/Makefile.am b/tools/rpcdebug/Makefile.am
index 39b70c9..b0a3e1f 100644
--- a/tools/rpcdebug/Makefile.am
+++ b/tools/rpcdebug/Makefile.am
@@ -1,15 +1,9 @@
 ## Process this file with automake to produce Makefile.in
 
-CC=$(CC_FOR_BUILD)
-LIBTOOL = @LIBTOOL@ --tag=CC
-
 man8_MANS = rpcdebug.man
 EXTRA_DIST = $(man8_MANS)
 
 sbin_PROGRAMS = rpcdebug
 rpcdebug_SOURCES = rpcdebug.c
-rpcdebug_CFLAGS=$(CFLAGS_FOR_BUILD)
-rpcdebug_CPPFLAGS=$(CPPFLAGS_FOR_BUILD) -I$(top_srcdir)/support/include
-rpcdebug_LDFLAGS=$(LDFLAGS_FOR_BUILD)
 
 MAINTAINERCLEANFILES = Makefile.in
-- 
1.8.1.2


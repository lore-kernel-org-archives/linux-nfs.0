Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wg0-f45.google.com ([74.125.82.45]:34789 "EHLO
	mail-wg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934196AbbDXA1s (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 23 Apr 2015 20:27:48 -0400
Received: by wgso17 with SMTP id o17so34829916wgs.1
        for <linux-nfs@vger.kernel.org>; Thu, 23 Apr 2015 17:27:47 -0700 (PDT)
From: Bernhard Reutner-Fischer <rep.dot.nop@gmail.com>
To: libtirpc-devel@lists.sourceforge.net
Cc: Bernhard Reutner-Fischer <rep.dot.nop@gmail.com>,
        Steve Dickson <SteveD@redhat.com>, linux-nfs@vger.kernel.org
Subject: [PATCH v2 3/7] Make sure to include config.h
Date: Fri, 24 Apr 2015 02:27:38 +0200
Message-Id: <1429835262-16861-4-git-send-email-rep.dot.nop@gmail.com>
In-Reply-To: <1429835262-16861-1-git-send-email-rep.dot.nop@gmail.com>
References: <1429835262-16861-1-git-send-email-rep.dot.nop@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I really think the -DINET6 is wrong.

Signed-off-by: Bernhard Reutner-Fischer <rep.dot.nop@gmail.com>
---
 src/Makefile.am | 4 ++--
 src/auth_time.c | 3 +++
 src/getrpcent.c | 8 ++++----
 3 files changed, 9 insertions(+), 6 deletions(-)

diff --git a/src/Makefile.am b/src/Makefile.am
index 26ccbdf..38d0c3d 100644
--- a/src/Makefile.am
+++ b/src/Makefile.am
@@ -7,8 +7,8 @@
 
 noinst_HEADERS = rpc_com.h debug.h
 
-AM_CPPFLAGS = -I$(top_srcdir)/tirpc -DPORTMAP -DINET6 \
-		-D_GNU_SOURCE -Wall -pipe  
+AM_CPPFLAGS = -I$(top_srcdir)/tirpc -include config.h -DPORTMAP -DINET6 \
+		-D_GNU_SOURCE -Wall -pipe
 
 lib_LTLIBRARIES = libtirpc.la
 
diff --git a/src/auth_time.c b/src/auth_time.c
index 13717ff..10e58eb 100644
--- a/src/auth_time.c
+++ b/src/auth_time.c
@@ -25,6 +25,9 @@
  *	needed to deal with TCP connections.
  */
 
+#ifdef HAVE_CONFIG_H
+#include "config.h"
+#endif
 #include <stdio.h>
 #include <syslog.h>
 #include <string.h>
diff --git a/src/getrpcent.c b/src/getrpcent.c
index fbb2da4..c374673 100644
--- a/src/getrpcent.c
+++ b/src/getrpcent.c
@@ -30,6 +30,10 @@
  * Copyright (c) 1984 by Sun Microsystems, Inc.
  */
 
+#ifdef HAVE_CONFIG_H
+#include "config.h"
+#endif
+
 #include <sys/types.h>
 
 #include <netinet/in.h>
@@ -50,10 +54,6 @@
 #include <libc_private.h>
 #endif
 
-#if HAVE_CONFIG_H
-#include "config.h"
-#endif
-
 /*
  * Internet version.
  */
-- 
2.1.4


Return-Path: linux-nfs-owner@vger.kernel.org
Received: from filtteri6.pp.htv.fi ([213.243.153.189]:59873 "EHLO
	filtteri6.pp.htv.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751576AbaB1VGN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 28 Feb 2014 16:06:13 -0500
From: Aaro Koskinen <aaro.koskinen@iki.fi>
To: linux-nfs@vger.kernel.org
Cc: Aaro Koskinen <aaro.koskinen@iki.fi>
Subject: [PATCH nfs-utils] tools: use install -m instead of --mode
Date: Fri, 28 Feb 2014 23:06:24 +0200
Message-Id: <1393621584-15467-1-git-send-email-aaro.koskinen@iki.fi>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Use install -m instead of--mode for better compatibility.
E.g. busybox's install doesn't support the long option.

Signed-off-by: Aaro Koskinen <aaro.koskinen@iki.fi>
---
 tools/mountstats/Makefile.am | 2 +-
 tools/nfs-iostat/Makefile.am | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/tools/mountstats/Makefile.am b/tools/mountstats/Makefile.am
index ca617a2..c2e9f99 100644
--- a/tools/mountstats/Makefile.am
+++ b/tools/mountstats/Makefile.am
@@ -8,6 +8,6 @@ EXTRA_DIST	= $(man8_MANS) $(PYTHON_FILES)
 all-local: $(PYTHON_FILES)
 
 install-data-hook:
-	$(INSTALL) --mode 755 mountstats.py $(DESTDIR)$(sbindir)/mountstats
+	$(INSTALL) -m 755 mountstats.py $(DESTDIR)$(sbindir)/mountstats
 
 MAINTAINERCLEANFILES=Makefile.in
diff --git a/tools/nfs-iostat/Makefile.am b/tools/nfs-iostat/Makefile.am
index 30f4054..3ae0f29 100644
--- a/tools/nfs-iostat/Makefile.am
+++ b/tools/nfs-iostat/Makefile.am
@@ -8,6 +8,6 @@ EXTRA_DIST	= $(man8_MANS) $(PYTHON_FILES)
 all-local: $(PYTHON_FILES)
 
 install-data-hook:
-	$(INSTALL) --mode 755 nfs-iostat.py $(DESTDIR)$(sbindir)/nfsiostat
+	$(INSTALL) -m 755 nfs-iostat.py $(DESTDIR)$(sbindir)/nfsiostat
 
 MAINTAINERCLEANFILES=Makefile.in
-- 
1.8.3.3


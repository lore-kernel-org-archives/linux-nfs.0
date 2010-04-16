From: Steve Dickson <steved@redhat.com>
Subject: [RFC PATCH 3/3] Add autoconf support for mountstats and nfsiostats
Date: Fri, 16 Apr 2010 11:10:21 -0400
Message-ID: <1271430621-8663-4-git-send-email-steved@redhat.com>
References: <1271430621-8663-1-git-send-email-steved@redhat.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from 4dicksons.org ([207.22.49.45]:47353 "EHLO
	Dobby.Home.4dicksons.org" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1757065Ab0DPPKY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 16 Apr 2010 11:10:24 -0400
Received: from [192.168.62.20] (helo=localhost.localdomain)
	by Dobby.Home.4dicksons.org with esmtp (Exim 4.63)
	(envelope-from <steved@redhat.com>)
	id 1O2nBX-00018J-1e
	for linux-nfs@vger.kernel.org; Fri, 16 Apr 2010 11:10:23 -0400
In-Reply-To: <1271430621-8663-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 configure.ac                 |    2 ++
 tools/Makefile.am            |    2 +-
 tools/mountstats/Makefile.am |   13 +++++++++++++
 tools/nfs-iostat/Makefile.am |   13 +++++++++++++
 4 files changed, 29 insertions(+), 1 deletions(-)
 create mode 100644 tools/mountstats/Makefile.am
 create mode 100644 tools/nfs-iostat/Makefile.am

diff --git a/configure.ac b/configure.ac
index 518b6d8..d90a88f 100644
--- a/configure.ac
+++ b/configure.ac
@@ -425,6 +425,8 @@ AC_CONFIG_FILES([
 	tools/nlmtest/Makefile
 	tools/rpcdebug/Makefile
 	tools/rpcgen/Makefile
+	tools/mountstats/Makefile
+	tools/nfs-iostat/Makefile
 	utils/Makefile
 	utils/exportfs/Makefile
 	utils/gssd/Makefile
diff --git a/tools/Makefile.am b/tools/Makefile.am
index db15346..f2ce282 100644
--- a/tools/Makefile.am
+++ b/tools/Makefile.am
@@ -6,6 +6,6 @@ if CONFIG_RPCGEN
 OPTDIRS += rpcgen
 endif
 
-SUBDIRS = locktest rpcdebug nlmtest $(OPTDIRS)
+SUBDIRS = locktest rpcdebug nlmtest mountstats nfs-iostat $(OPTDIRS)
 
 MAINTAINERCLEANFILES = Makefile.in
diff --git a/tools/mountstats/Makefile.am b/tools/mountstats/Makefile.am
new file mode 100644
index 0000000..ca617a2
--- /dev/null
+++ b/tools/mountstats/Makefile.am
@@ -0,0 +1,13 @@
+## Process this file with automake to produce Makefile.in
+PYTHON_FILES =  mountstats.py
+
+man8_MANS	= mountstats.man
+
+EXTRA_DIST	= $(man8_MANS) $(PYTHON_FILES)
+
+all-local: $(PYTHON_FILES)
+
+install-data-hook:
+	$(INSTALL) --mode 755 mountstats.py $(DESTDIR)$(sbindir)/mountstats
+
+MAINTAINERCLEANFILES=Makefile.in
diff --git a/tools/nfs-iostat/Makefile.am b/tools/nfs-iostat/Makefile.am
new file mode 100644
index 0000000..30f4054
--- /dev/null
+++ b/tools/nfs-iostat/Makefile.am
@@ -0,0 +1,13 @@
+## Process this file with automake to produce Makefile.in
+PYTHON_FILES =  nfs-iostat.py
+
+man8_MANS	= nfsiostat.man
+
+EXTRA_DIST	= $(man8_MANS) $(PYTHON_FILES)
+
+all-local: $(PYTHON_FILES)
+
+install-data-hook:
+	$(INSTALL) --mode 755 nfs-iostat.py $(DESTDIR)$(sbindir)/nfsiostat
+
+MAINTAINERCLEANFILES=Makefile.in
-- 
1.6.6.1


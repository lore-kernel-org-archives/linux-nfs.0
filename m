Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f180.google.com ([209.85.213.180]:38769 "EHLO
	mail-ig0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750992AbbDNGAu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 14 Apr 2015 02:00:50 -0400
Received: by igbqf9 with SMTP id qf9so6822516igb.1
        for <linux-nfs@vger.kernel.org>; Mon, 13 Apr 2015 23:00:50 -0700 (PDT)
From: Calvin Walton <calvin.walton@kepstin.ca>
To: linux-nfs@vger.kernel.org
Cc: Steve Dickson <steved@redhat.com>,
        Calvin Walton <calvin.walton@kepstin.ca>
Subject: [PATCH] nfs-utils: Run rpcgen using the cpp found by configure.
Date: Tue, 14 Apr 2015 02:00:29 -0400
Message-Id: <1428991229-19835-1-git-send-email-calvin.walton@kepstin.ca>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

rpcgen normally runs with a hardcoded cpp path of e.g. /lib/cpp,
but not all Linux distributions install a cpp there.

Grab a trick from glibc, and run rpcgen with a cpp-path pointing at
a script; the script then runs the cpp specified in the CPP
environment variable - which was set by the configure script to
something reasonable.
---
 support/export/Makefile.am   | 13 +++++++------
 support/nsm/Makefile.am      | 17 +++++++++--------
 tests/nsm_client/Makefile.am | 17 +++++++++--------
 tools/rpcgen/cpp             |  6 ++++++
 utils/statd/Makefile.am      | 17 +++++++++--------
 5 files changed, 40 insertions(+), 30 deletions(-)
 create mode 100755 tools/rpcgen/cpp

diff --git a/support/export/Makefile.am b/support/export/Makefile.am
index 1ea1539..d33516d 100644
--- a/support/export/Makefile.am
+++ b/support/export/Makefile.am
@@ -22,22 +22,23 @@ dist-hook:
 	done
 
 if CONFIG_RPCGEN
-RPCGEN		= $(top_builddir)/tools/rpcgen/rpcgen
-$(RPCGEN):
+RPCGEN_DEP = $(top_builddir)/tools/rpcgen/rpcgen
+$(RPCGEN_DEP):
 	make -C $(top_srcdir)/tools/rpcgen all
+RPCGEN = $(RPCGEN_DEP) -Y $(top_srcdir)/tools/rpcgen
 else
-RPCGEN = @RPCGEN_PATH@
+RPCGEN = @RPCGEN_PATH@ -Y $(top_srcdir)/tools/rpcgen
 endif
 
-$(GENFILES_CLNT): %_clnt.c: %.x $(RPCGEN)
+$(GENFILES_CLNT): %_clnt.c: %.x $(RPCGEN_DEP)
 	test -f $@ && rm -rf $@ || true
 	$(RPCGEN) -l -o $@ $<
 
-$(GENFILES_XDR): %_xdr.c: %.x $(RPCGEN)
+$(GENFILES_XDR): %_xdr.c: %.x $(RPCGEN_DEP)
 	test -f $@ && rm -rf $@ || true
 	$(RPCGEN) -c -o $@ $<
 
-$(GENFILES_H): %.h: %.x $(RPCGEN)
+$(GENFILES_H): %.h: %.x $(RPCGEN_DEP)
 	test -f $@ && rm -rf $@ || true
 	$(RPCGEN) -h -o $@ $<
 	rm -f $(top_builddir)/support/include/mount.h
diff --git a/support/nsm/Makefile.am b/support/nsm/Makefile.am
index 2038e68..bbbc199 100644
--- a/support/nsm/Makefile.am
+++ b/support/nsm/Makefile.am
@@ -15,26 +15,27 @@ libnsm_a_SOURCES = $(GENFILES) file.c rpc.c
 BUILT_SOURCES = $(GENFILES)
 
 if CONFIG_RPCGEN
-RPCGEN	= $(top_builddir)/tools/rpcgen/rpcgen
-$(RPCGEN):
-	make -C ../../tools/rpcgen all
+RPCGEN_DEP = $(top_builddir)/tools/rpcgen/rpcgen
+$(RPCGEN_DEP):
+	make -C $(top_srcdir)/tools/rpcgen all
+RPCGEN = $(RPCGEN_DEP) -Y $(top_srcdir)/tools/rpcgen
 else
-RPCGEN = @RPCGEN_PATH@
+RPCGEN = @RPCGEN_PATH@ -Y $(top_srcdir)/tools/rpcgen
 endif
 
-$(GENFILES_CLNT): %_clnt.c: %.x $(RPCGEN)
+$(GENFILES_CLNT): %_clnt.c: %.x $(RPCGEN_DEP)
 	test -f $@ && rm -rf $@ || true
 	$(RPCGEN) -l -o $@ $<
 
-$(GENFILES_SVC): %_svc.c: %.x $(RPCGEN)
+$(GENFILES_SVC): %_svc.c: %.x $(RPCGEN_DEP)
 	test -f $@ && rm -rf $@ || true
 	$(RPCGEN) -m -o $@ $<
 
-$(GENFILES_XDR): %_xdr.c: %.x $(RPCGEN)
+$(GENFILES_XDR): %_xdr.c: %.x $(RPCGEN_DEP)
 	test -f $@ && rm -rf $@ || true
 	$(RPCGEN) -c -o $@ $<
 
-$(GENFILES_H): %.h: %.x $(RPCGEN)
+$(GENFILES_H): %.h: %.x $(RPCGEN_DEP)
 	test -f $@ && rm -rf $@ || true
 	$(RPCGEN) -h -o $@ $<
 	rm -f $(top_builddir)/support/include/sm_inter.h
diff --git a/tests/nsm_client/Makefile.am b/tests/nsm_client/Makefile.am
index a8fc131..aeaa05f 100644
--- a/tests/nsm_client/Makefile.am
+++ b/tests/nsm_client/Makefile.am
@@ -17,26 +17,27 @@ nsm_client_LDADD = ../../support/nfs/libnfs.a \
 		   ../../support/nsm/libnsm.a $(LIBCAP) $(LIBTIRPC)
 
 if CONFIG_RPCGEN
-RPCGEN	= $(top_builddir)/tools/rpcgen/rpcgen
-$(RPCGEN):
-	make -C ../../tools/rpcgen all
+RPCGEN_DEP = $(top_builddir)/tools/rpcgen/rpcgen
+$(RPCGEN_DEP):
+	make -C $(top_srcdir)/tools/rpcgen all
+RPCGEN = $(RPCGEN_DEP) -Y $(top_srcdir)/tools/rpcgen
 else
-RPCGEN = @RPCGEN_PATH@
+RPCGEN = @RPCGEN_PATH@ -Y $(top_srcdir)/tools/rpcgen
 endif
 
-$(GENFILES_CLNT): %_clnt.c: %.x $(RPCGEN)
+$(GENFILES_CLNT): %_clnt.c: %.x $(RPCGEN_DEP)
 	test -f $@ && rm -rf $@ || true
 	$(RPCGEN) -l -o $@ $<
 
-$(GENFILES_SVC): %_svc.c: %.x $(RPCGEN)
+$(GENFILES_SVC): %_svc.c: %.x $(RPCGEN_DEP)
 	test -f $@ && rm -rf $@ || true
 	$(RPCGEN) -m -o $@ $<
 
-$(GENFILES_XDR): %_xdr.c: %.x $(RPCGEN)
+$(GENFILES_XDR): %_xdr.c: %.x $(RPCGEN_DEP)
 	test -f $@ && rm -rf $@ || true
 	$(RPCGEN) -c -o $@ $<
 
-$(GENFILES_H): %.h: %.x $(RPCGEN)
+$(GENFILES_H): %.h: %.x $(RPCGEN_DEP)
 	test -f $@ && rm -rf $@ || true
 	$(RPCGEN) -h -o $@ $<
 
diff --git a/tools/rpcgen/cpp b/tools/rpcgen/cpp
new file mode 100755
index 0000000..73a5522
--- /dev/null
+++ b/tools/rpcgen/cpp
@@ -0,0 +1,6 @@
+#!/bin/sh
+
+# This script is use solely by rpcgen when run during the build.
+# It allows using CPP from the environment rather than a hardcoded path.
+
+exec ${CPP} "$@"
diff --git a/utils/statd/Makefile.am b/utils/statd/Makefile.am
index 152b680..9c016ed 100644
--- a/utils/statd/Makefile.am
+++ b/utils/statd/Makefile.am
@@ -23,26 +23,27 @@ sm_notify_LDADD = ../../support/nsm/libnsm.a \
 EXTRA_DIST = sim_sm_inter.x $(man8_MANS) simulate.c
 
 if CONFIG_RPCGEN
-RPCGEN	= $(top_builddir)/tools/rpcgen/rpcgen
-$(RPCGEN):
-	make -C ../../tools/rpcgen all
+RPCGEN_DEP = $(top_builddir)/tools/rpcgen/rpcgen
+$(RPCGEN_DEP):
+	make -C $(top_srcdir)/tools/rpcgen all
+RPCGEN = $(RPCGEN_DEP) -Y $(top_srcdir)/tools/rpcgen
 else
-RPCGEN = @RPCGEN_PATH@
+RPCGEN = @RPCGEN_PATH@ -Y $(top_srcdir)/tools/rpcgen
 endif
 
-$(GENFILES_CLNT): %_clnt.c: %.x $(RPCGEN)
+$(GENFILES_CLNT): %_clnt.c: %.x $(RPCGEN_DEP)
 	test -f $@ && rm -rf $@ || true
 	$(RPCGEN) -l -o $@ $<
 
-$(GENFILES_SVC): %_svc.c: %.x $(RPCGEN)
+$(GENFILES_SVC): %_svc.c: %.x $(RPCGEN_DEP)
 	test -f $@ && rm -rf $@ || true
 	$(RPCGEN) -m -o $@ $<
 
-$(GENFILES_XDR): %_xdr.c: %.x $(RPCGEN)
+$(GENFILES_XDR): %_xdr.c: %.x $(RPCGEN_DEP)
 	test -f $@ && rm -rf $@ || true
 	$(RPCGEN) -c -o $@ $<
 
-$(GENFILES_H): %.h: %.x $(RPCGEN)
+$(GENFILES_H): %.h: %.x $(RPCGEN_DEP)
 	test -f $@ && rm -rf $@ || true
 	$(RPCGEN) -h -o $@ $<
 
-- 
2.3.3


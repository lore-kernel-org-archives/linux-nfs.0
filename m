Return-Path: linux-nfs-owner@vger.kernel.org
Received: from ares08.inai.de ([46.4.84.70]:52495 "EHLO ares08.inai.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752545AbaJFV0y (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 6 Oct 2014 17:26:54 -0400
From: Jan Engelhardt <jengelh@inai.de>
To: steved@redhat.com
Cc: bfields@citi.umich.edu, linux-nfs@vger.kernel.org
Subject: [PATCH 3/5] build: use a separate tool directory and update .gitignore
Date: Mon,  6 Oct 2014 23:19:32 +0200
Message-Id: <1412630374-23246-4-git-send-email-jengelh@inai.de>
In-Reply-To: <1412630374-23246-1-git-send-email-jengelh@inai.de>
References: <1412630374-23246-1-git-send-email-jengelh@inai.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

With m4/.gitignore, we ensure that the m4 directory exists in any
git checkout such that aclocal/libtoolize won't complain about
its absence during `autoreconf`.

Signed-off-by: Jan Engelhardt <jengelh@inai.de>
---
 .gitignore    | 13 +++----------
 configure.ac  |  1 +
 m4/.gitignore |  2 ++
 3 files changed, 6 insertions(+), 10 deletions(-)
 create mode 100644 m4/.gitignore

diff --git a/.gitignore b/.gitignore
index d24d727..fd87695 100644
--- a/.gitignore
+++ b/.gitignore
@@ -1,15 +1,9 @@
 Makefile.in
-aclocal.m4
-autom4te.cache/
-config.guess
-config.sub
+/aclocal.m4
+/autom4te.cache/
+/build-aux/
 configure
-depcomp
-ltmain.sh
-missing
-install-sh
 Makefile
-install-sh
 .deps/
 config.log
 config.status
@@ -21,7 +15,6 @@ nsswitch.la
 static.la
 umich_ldap.la
 configure.in~
-m4/
 *.o
 *.lo
 cscope.*
diff --git a/configure.ac b/configure.ac
index cb5740b..84a2ab0 100644
--- a/configure.ac
+++ b/configure.ac
@@ -3,6 +3,7 @@
 
 AC_PREREQ([2.66])
 AC_INIT([libnfsidmap],[0.25],[linux-nfs@vger.kernel.org])
+AC_CONFIG_AUX_DIR([build-aux])
 AC_CONFIG_SRCDIR([nfsidmap.h])
 AC_CONFIG_MACRO_DIR([m4])
 AM_INIT_AUTOMAKE
diff --git a/m4/.gitignore b/m4/.gitignore
new file mode 100644
index 0000000..64d9bbc
--- /dev/null
+++ b/m4/.gitignore
@@ -0,0 +1,2 @@
+/libtool.m4
+/lt*.m4
-- 
2.0.0


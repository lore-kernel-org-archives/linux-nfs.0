Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:18601 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750772Ab1ITQ5y (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 20 Sep 2011 12:57:54 -0400
Received: from int-mx09.intmail.prod.int.phx2.redhat.com (int-mx09.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id p8KGvsL3007070
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Tue, 20 Sep 2011 12:57:54 -0400
Received: from bighat.boston.devel.redhat.com (bighat.boston.devel.redhat.com [10.16.60.55])
	by int-mx09.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id p8KGvsqC025192
	for <linux-nfs@vger.kernel.org>; Tue, 20 Sep 2011 12:57:54 -0400
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 1/1 v2] statd: Decouple statd's state directory from the NFS state directory
Date: Tue, 20 Sep 2011 12:57:49 -0400
Message-Id: <1316537869-2257-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

To allow greater flexibility to where statd's state is kept,
statd's state path can now be decoupled from the normal
NFS state directory.

In configure.ac, the NSM_STATD_PATH definition will now define
the path to where the state information is kept.  The default
value, /var/lib/nfs, can be redefined with the --with-statdpath
flag.

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 configure.ac       |    9 +++++++++
 support/nsm/file.c |    8 --------
 2 files changed, 9 insertions(+), 8 deletions(-)

diff --git a/configure.ac b/configure.ac
index b5934c4..500172b 100644
--- a/configure.ac
+++ b/configure.ac
@@ -23,6 +23,14 @@ AC_ARG_WITH(statedir,
 	statedir=$withval,
 	statedir=/var/lib/nfs)
 	AC_SUBST(statedir)
+AC_ARG_WITH(statdpath,
+	[AC_HELP_STRING([--with-statdpath=/foo @<:@default=/var/lib/nfs@:>@],
+		[define statd's state dir as /foo instead of the NFS statedir]
+	)],
+	statdpath=$withval,
+	statdpath=$statedir
+	)
+	AC_SUBST(statdpath)
 AC_ARG_WITH(statduser,
 	[AC_HELP_STRING([--with-statduser=rpcuser],
                         [statd to run under @<:@rpcuser or nobody@:>@]
@@ -387,6 +395,7 @@ dnl *************************************************************
 dnl Export some path names to config.h
 dnl *************************************************************
 AC_DEFINE_UNQUOTED(NFS_STATEDIR, "$statedir", [This defines the location of the NFS state files. Warning: this must match definitions in config.mk!])
+AC_DEFINE_UNQUOTED(NSM_DEFAULT_STATEDIR, "$statdpath", [Define this to the pathname where statd keeps its state file])
 
 if test "x$cross_compiling" = "xno"; then
 	CFLAGS_FOR_BUILD=${CFLAGS_FOR_BUILD-"$CFLAGS"}
diff --git a/support/nsm/file.c b/support/nsm/file.c
index a12c753..5dd52c1 100644
--- a/support/nsm/file.c
+++ b/support/nsm/file.c
@@ -94,14 +94,6 @@
 
 #define NSM_KERNEL_STATE_FILE	"/proc/sys/fs/nfs/nsm_local_state"
 
-/*
- * Some distributions place statd's files in a subdirectory
- */
-#define NSM_PATH_EXTENSION
-/* #define NSM_PATH_EXTENSION	"/statd" */
-
-#define NSM_DEFAULT_STATEDIR		NFS_STATEDIR NSM_PATH_EXTENSION
-
 static char nsm_base_dirname[PATH_MAX] = NSM_DEFAULT_STATEDIR;
 
 #define NSM_MONITOR_DIR	"sm"
-- 
1.7.6.2


Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:40238 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755154Ab1ILWM2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 12 Sep 2011 18:12:28 -0400
Received: by gyg10 with SMTP id 10so572760gyg.19
        for <linux-nfs@vger.kernel.org>; Mon, 12 Sep 2011 15:12:28 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 3/8] configure.ac: Add --with-statd-extension configure option
To: linux-nfs@vger.kernel.org
Date: Mon, 12 Sep 2011 18:06:23 -0400
Message-ID: <20110912220623.10854.69881.stgit@matisse.1015granger.net>
In-Reply-To: <20110912220304.10854.20972.stgit@matisse.1015granger.net>
References: <20110912220304.10854.20972.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Currently some distributions patch nfs-utils to put NSM state in a
subdirectory of /var/lib/nfs.  Make this a configure option instead.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 configure.ac       |    8 ++++++++
 support/nsm/file.c |    9 +--------
 2 files changed, 9 insertions(+), 8 deletions(-)

diff --git a/configure.ac b/configure.ac
index 461a96a..ba704e2 100644
--- a/configure.ac
+++ b/configure.ac
@@ -23,6 +23,14 @@ AC_ARG_WITH(statedir,
 	statedir=$withval,
 	statedir=/var/lib/nfs)
 	AC_SUBST(statedir)
+AC_ARG_WITH(statd-extension,
+	[AC_HELP_STRING([--with-statd-extension=foo],
+                        [Put NSM state in subdir foo of statedir])],
+	statdext=$withval,
+	statdext="")
+	AC_SUBST(statdext)
+	AC_DEFINE_UNQUOTED(NSM_PATH_EXTENSION, "$statdext",
+			   [This defines the statedir subdirectory containing NSM state files.])
 AC_ARG_WITH(statduser,
 	[AC_HELP_STRING([--with-statduser=rpcuser],
                         [statd to run under @<:@rpcuser or nobody@:>@]
diff --git a/support/nsm/file.c b/support/nsm/file.c
index a12c753..b4a5af1 100644
--- a/support/nsm/file.c
+++ b/support/nsm/file.c
@@ -93,14 +93,7 @@
 #define LINELEN		(RPCARGSLEN + SM_PRIV_SIZE * 2 + 1)
 
 #define NSM_KERNEL_STATE_FILE	"/proc/sys/fs/nfs/nsm_local_state"
-
-/*
- * Some distributions place statd's files in a subdirectory
- */
-#define NSM_PATH_EXTENSION
-/* #define NSM_PATH_EXTENSION	"/statd" */
-
-#define NSM_DEFAULT_STATEDIR		NFS_STATEDIR NSM_PATH_EXTENSION
+#define NSM_DEFAULT_STATEDIR	NFS_STATEDIR "/" NSM_PATH_EXTENSION
 
 static char nsm_base_dirname[PATH_MAX] = NSM_DEFAULT_STATEDIR;
 


From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 1/5] NFS: Fix up new minorversion= option
Date: Mon, 13 Jul 2009 15:17:17 -0400
Message-ID: <20090713191717.1951.20958.stgit@matisse.1015granger.net>
References: <20090713191417.1951.75470.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from adsl-76-241-169-38.dsl.sfldmi.sbcglobal.net ([76.241.169.38]:45013
	"EHLO matisse.1015granger.net" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751732AbZGMTRV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Jul 2009 15:17:21 -0400
In-Reply-To: <20090713191417.1951.75470.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The new minorversion= mount option (commit 3fd5be9e) was merged at
the same time as the recent sloppy parser fixes (commit a5a16bae),
so minorversion= still uses the old value parsing logic.

If the minorversion= option specifies a bogus value, it should fail
with "bad value" not "bad option."

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/super.c |   18 +++++++++++-------
 1 files changed, 11 insertions(+), 7 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 0b4cbdc..83a3107 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -158,7 +158,7 @@ static const match_table_t nfs_mount_option_tokens = {
 	{ Opt_mountvers, "mountvers=%s" },
 	{ Opt_nfsvers, "nfsvers=%s" },
 	{ Opt_nfsvers, "vers=%s" },
-	{ Opt_minorversion, "minorversion=%u" },
+	{ Opt_minorversion, "minorversion=%s" },
 
 	{ Opt_sec, "sec=%s" },
 	{ Opt_proto, "proto=%s" },
@@ -1001,7 +1001,6 @@ static int nfs_parse_mount_options(char *raw,
 	while ((p = strsep(&raw, ",")) != NULL) {
 		substring_t args[MAX_OPT_ARGS];
 		unsigned long option;
-		int int_option;
 		int token;
 
 		if (!*p)
@@ -1273,11 +1272,16 @@ static int nfs_parse_mount_options(char *raw,
 			}
 			break;
 		case Opt_minorversion:
-			if (match_int(args, &int_option))
-				return 0;
-			if (int_option < 0 || int_option > NFS4_MAX_MINOR_VERSION)
-				return 0;
-			mnt->minorversion = int_option;
+			string = match_strdup(args);
+			if (string == NULL)
+				goto out_nomem;
+			rc = strict_strtoul(string, 10, &option);
+			kfree(string);
+			if (rc != 0)
+				goto out_invalid_value;
+			if (option > NFS4_MAX_MINOR_VERSION)
+				goto out_invalid_value;
+			mnt->minorversion = option;
 			break;
 
 		/*


From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 4/9] NFS: Clean up fscache_uniq mount option
Date: Wed, 21 Apr 2010 13:43:33 -0400
Message-ID: <20100421174332.2037.91471.stgit@localhost.localdomain>
References: <20100421173628.2037.54635.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pv0-f174.google.com ([74.125.83.174]:36444 "EHLO
	mail-pv0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753978Ab0DURne (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 21 Apr 2010 13:43:34 -0400
Received: by mail-pv0-f174.google.com with SMTP id 13so1004163pvg.19
        for <linux-nfs@vger.kernel.org>; Wed, 21 Apr 2010 10:43:34 -0700 (PDT)
In-Reply-To: <20100421173628.2037.54635.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: fscache_uniq takes a string, so it should be included
with the other string mount option definitions, by convention.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/super.c |   18 +++++++++---------
 1 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index e016372..67a4f09 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -141,7 +141,6 @@ static const match_table_t nfs_mount_option_tokens = {
 	{ Opt_resvport, "resvport" },
 	{ Opt_noresvport, "noresvport" },
 	{ Opt_fscache, "fsc" },
-	{ Opt_fscache_uniq, "fsc=%s" },
 	{ Opt_nofscache, "nofsc" },
 
 	{ Opt_port, "port=%s" },
@@ -171,6 +170,7 @@ static const match_table_t nfs_mount_option_tokens = {
 	{ Opt_mountaddr, "mountaddr=%s" },
 
 	{ Opt_lookupcache, "lookupcache=%s" },
+	{ Opt_fscache_uniq, "fsc=%s" },
 
 	{ Opt_err, NULL }
 };
@@ -1046,14 +1046,6 @@ static int nfs_parse_mount_options(char *raw,
 			kfree(mnt->fscache_uniq);
 			mnt->fscache_uniq = NULL;
 			break;
-		case Opt_fscache_uniq:
-			string = match_strdup(args);
-			if (!string)
-				goto out_nomem;
-			kfree(mnt->fscache_uniq);
-			mnt->fscache_uniq = string;
-			mnt->options |= NFS_OPTION_FSCACHE;
-			break;
 
 		/*
 		 * options that take numeric values
@@ -1384,6 +1376,14 @@ static int nfs_parse_mount_options(char *raw,
 					return 0;
 			};
 			break;
+		case Opt_fscache_uniq:
+			string = match_strdup(args);
+			if (string == NULL)
+				goto out_nomem;
+			kfree(mnt->fscache_uniq);
+			mnt->fscache_uniq = string;
+			mnt->options |= NFS_OPTION_FSCACHE;
+			break;
 
 		/*
 		 * Special options


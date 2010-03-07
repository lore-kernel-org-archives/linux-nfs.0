From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 3/3] mountd: fix crossmnt options in v2/v3 case
Date: Sun,  7 Mar 2010 15:08:01 -0500
Message-ID: <1267992481-13332-3-git-send-email-bfields@citi.umich.edu>
References: <20100307200607.GA13006@fieldses.org>
 <1267992481-13332-1-git-send-email-bfields@citi.umich.edu>
 <1267992481-13332-2-git-send-email-bfields@citi.umich.edu>
Cc: linux-nfs@vger.kernel.org,
	"J. Bruce Fields" <bfields@citi.umich.edu>
To: Steve Dickson <steved@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:58515 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754800Ab0CGUGk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 7 Mar 2010 15:06:40 -0500
In-Reply-To: <1267992481-13332-2-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The extra cache entries added here all get the options of the parent
export.  This is incorrect, since once of the children may be explicitly
exported with different options, and the parent crossmnt shouldn't
override the explicit child export.

What's more, this is unnecessary, since in the newcache case we'll
request these on demand when we need them.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 utils/mountd/cache.c |   40 ----------------------------------------
 1 files changed, 0 insertions(+), 40 deletions(-)

diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
index 7dec468..200e179 100644
--- a/utils/mountd/cache.c
+++ b/utils/mountd/cache.c
@@ -817,46 +817,6 @@ int cache_export_ent(char *domain, struct exportent *exp, char *path)
 		     " fsid= required", exp->e_path);
 	}
 
-	while (err == 0 && (exp->e_flags & NFSEXP_CROSSMOUNT) && path) {
-		/* really an 'if', but we can break out of
-		 * a 'while' more easily */
-		/* Look along 'path' for other filesystems
-		 * and export them with the same options
-		 */
-		struct stat stb;
-		int l = strlen(exp->e_path);
-		int dev;
-
-		if (strlen(path) <= l || path[l] != '/' ||
-		    strncmp(exp->e_path, path, l) != 0)
-			break;
-		if (stat(exp->e_path, &stb) != 0)
-			break;
-		dev = stb.st_dev;
-		while(path[l] == '/') {
-			char c;
-			/* errors for submount should fail whole filesystem */
-			int err2;
-
-			l++;
-			while (path[l] != '/' && path[l])
-				l++;
-			c = path[l];
-			path[l] = 0;
-			err2 = lstat(path, &stb);
-			path[l] = c;
-			if (err2 < 0)
-				break;
-			if (stb.st_dev == dev)
-				continue;
-			dev = stb.st_dev;
-			path[l] = 0;
-			dump_to_cache(f, domain, path, exp);
-			path[l] = c;
-		}
-		break;
-	}
-
 	fclose(f);
 	return err;
 }
-- 
1.6.3.3


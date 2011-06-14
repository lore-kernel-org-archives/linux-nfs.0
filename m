Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:58450 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751769Ab1FNO6P (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 14 Jun 2011 10:58:15 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Steve Dickson <steved@redhat.com>
Cc: linux-nfs@vger.kernel.org, "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 4/4] mountd: don't automatically add subexports to kernel cache
Date: Tue, 14 Jun 2011 10:58:12 -0400
Message-Id: <1308063492-30103-5-git-send-email-bfields@redhat.com>
In-Reply-To: <1308063492-30103-1-git-send-email-bfields@redhat.com>
References: <1308063492-30103-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Given a crossmnt export and a child path, search for all mountpoints in
between and add exports for them to the kernel.

This isn't necessary; if the the kernel needs one of the subexports, it
can always ask.

It might be some sort of minor optimization to add exports preemptively.
But if so, why not just add them all?  Why this particular subset?

Given the chance to delete some code I can't justify, I'll take it.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 utils/mountd/cache.c |   42 +-----------------------------------------
 1 files changed, 1 insertions(+), 41 deletions(-)

diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
index d2ae4563..c77eb27 100644
--- a/utils/mountd/cache.c
+++ b/utils/mountd/cache.c
@@ -945,53 +945,13 @@ static int cache_export_ent(char *domain, struct exportent *exp, char *path)
 	if (!f)
 		return -1;
 
-	err = dump_to_cache(f, domain, exp->e_path, exp);
+	err = dump_to_cache(f, domain, path, exp);
 	if (err) {
 		xlog(L_WARNING,
 		     "Cannot export %s, possibly unsupported filesystem or"
 		     " fsid= required", exp->e_path);
 	}
 
-	while (err == 0 && (exp->e_flags & NFSEXP_CROSSMOUNT) && path) {
-		/* really an 'if', but we can break out of
-		 * a 'while' more easily */
-		/* Look along 'path' for other filesystems
-		 * and export them with the same options
-		 */
-		struct stat stb;
-		size_t l = strlen(exp->e_path);
-		__dev_t dev;
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
1.7.4.1


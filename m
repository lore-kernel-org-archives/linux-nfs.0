Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:47258 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752035Ab3ISU5W (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 19 Sep 2013 16:57:22 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org, root <root@pip4.fieldses.org>,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 1/3] gssd: fix strncmp bug causing client removals
Date: Thu, 19 Sep 2013 16:57:17 -0400
Message-Id: <1379624239-31199-2-git-send-email-bfields@redhat.com>
In-Reply-To: <1379624239-31199-1-git-send-email-bfields@redhat.com>
References: <1379624239-31199-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: root <root@pip4.fieldses.org>

Both dirname and pdir are null-terminated strings, so there's no reason
I can see for the strncmp.

And this gives the wrong result when comparing the "nfsd" and "nfsd4_cb"
directories!  The results were callback clients being removed
immediately after creation, when lack of a client with the corresponding
name under "nfsd" lead gssd to believe it had disappeared from
"nfsd4_cb".

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 utils/gssd/gssd_proc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/utils/gssd/gssd_proc.c b/utils/gssd/gssd_proc.c
index 2d3dbec..0383883 100644
--- a/utils/gssd/gssd_proc.c
+++ b/utils/gssd/gssd_proc.c
@@ -525,7 +525,7 @@ update_old_clients(struct dirent **namelist, int size, char *pdir)
 		/* only compare entries in the global list that are from the
 		 * same pipefs parent directory as "pdir"
 		 */
-		if (strncmp(clp->dirname, pdir, strlen(pdir)) != 0) continue;
+		if (strcmp(clp->dirname, pdir) != 0) continue;
 
 		stillhere = 0;
 		for (i=0; i < size; i++) {
-- 
1.8.3.1


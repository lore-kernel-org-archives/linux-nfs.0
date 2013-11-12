Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:48365 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756319Ab3KLXi1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 12 Nov 2013 18:38:27 -0500
From: Weston Andros Adamson <dros@netapp.com>
To: <steved@redhat.com>
CC: <linux-nfs@vger.kernel.org>, Weston Andros Adamson <dros@netapp.com>
Subject: [PATCH] gssd: Fix file descriptor leak of old pipe dirs
Date: Tue, 12 Nov 2013 18:38:20 -0500
Message-ID: <1384299500-67986-1-git-send-email-dros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

gssd doesn't properly clean up internal state for old pipes and never
closes the (since deleted) clnt_info directory. This leads to eventual
fd exhaustion.

To reproduce, run a lot of mount / umounts in a loop and watch the
output of 'ls /proc/$PID/fdinfo | wc -l' (where PID is the pid of gssd)
steadily grow until gssd eventually crashes with "Too many open files".

This regression was introduced by 841e83c1, which was trying to fix a
similar bug in the skip matching logic of update_old_clients. The problem
with that patch is that pdir will never match dirname, because dirname is
"<pname>/clntXXX".

Signed-off-by: Weston Andros Adamson <dros@netapp.com>
---
 utils/gssd/gssd.h      | 1 +
 utils/gssd/gssd_proc.c | 6 +++++-
 2 files changed, 6 insertions(+), 1 deletion(-)

diff --git a/utils/gssd/gssd.h b/utils/gssd/gssd.h
index 86472a1..e44ea40 100644
--- a/utils/gssd/gssd.h
+++ b/utils/gssd/gssd.h
@@ -73,6 +73,7 @@ TAILQ_HEAD(clnt_list_head, clnt_info) clnt_list;
 struct clnt_info {
 	TAILQ_ENTRY(clnt_info)	list;
 	char			*dirname;
+	char			*pdir;
 	int			dir_fd;
 	char			*servicename;
 	char			*servername;
diff --git a/utils/gssd/gssd_proc.c b/utils/gssd/gssd_proc.c
index b48d163..02994f6 100644
--- a/utils/gssd/gssd_proc.c
+++ b/utils/gssd/gssd_proc.c
@@ -322,6 +322,7 @@ destroy_client(struct clnt_info *clp)
 	if (clp->krb5_fd != -1) close(clp->krb5_fd);
 	if (clp->gssd_fd != -1) close(clp->gssd_fd);
 	free(clp->dirname);
+	free(clp->pdir);
 	free(clp->servicename);
 	free(clp->servername);
 	free(clp->protocol);
@@ -463,6 +464,9 @@ process_clnt_dir(char *dir, char *pdir)
 	if (!(clp = insert_new_clnt()))
 		goto fail_destroy_client;
 
+	if (!(clp->pdir = strdup(pdir)))
+		goto fail_destroy_client;
+
 	/* An extra for the '/', and an extra for the null */
 	if (!(clp->dirname = calloc(strlen(dir) + strlen(pdir) + 2, 1))) {
 		goto fail_destroy_client;
@@ -527,7 +531,7 @@ update_old_clients(struct dirent **namelist, int size, char *pdir)
 		/* only compare entries in the global list that are from the
 		 * same pipefs parent directory as "pdir"
 		 */
-		if (strcmp(clp->dirname, pdir) != 0) continue;
+		if (strcmp(clp->pdir, pdir) != 0) continue;
 
 		stillhere = 0;
 		for (i=0; i < size; i++) {
-- 
1.8.3.1 (Apple Git-46)


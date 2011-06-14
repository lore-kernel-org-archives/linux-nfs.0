Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:58446 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751502Ab1FNO6O (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 14 Jun 2011 10:58:14 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Steve Dickson <steved@redhat.com>
Cc: linux-nfs@vger.kernel.org, "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 1/4] mountd: prefer explicit subexports over crossmnt parents
Date: Tue, 14 Jun 2011 10:58:09 -0400
Message-Id: <1308063492-30103-2-git-send-email-bfields@redhat.com>
In-Reply-To: <1308063492-30103-1-git-send-email-bfields@redhat.com>
References: <1308063492-30103-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

If a parent is exported with crossmnt, and if a child is also explicitly
exported, then both exports could potentially produce matches in this
loop; that isn't a bug.

Instead of warning and ignoring the second match we find, we should
instead prefer whichever export is deeper in the tree, so that
children's options can override those of their parents.

Reported-by: Olga Kornievskaia <aglo@citi.umich.edu>
Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 utils/mountd/cache.c |   18 +++++++++++++++---
 1 files changed, 15 insertions(+), 3 deletions(-)

diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
index 68cccdf..c3dee13 100644
--- a/utils/mountd/cache.c
+++ b/utils/mountd/cache.c
@@ -341,6 +341,17 @@ static char *next_mnt(void **v, char *p)
 	return me->mnt_dir;
 }
 
+/* True iff e1 is a child of e2 and e2 has crossmnt set: */
+static bool subexport(struct exportent *e1, struct exportent *e2)
+{
+	char *p1 = e1->e_path, *p2 = e2->e_path;
+	int l2 = strlen(p2);
+
+	return e2->e_flags & NFSEXP_CROSSMOUNT
+	       && strncmp(p1, p2, l2) == 0
+	       && p1[l2] == '/';
+}
+
 static void nfsd_fh(FILE *f)
 {
 	/* request are:
@@ -550,13 +561,14 @@ static void nfsd_fh(FILE *f)
 				if (!client_check(exp->m_client, ai))
 					continue;
 			}
-			/* It's a match !! */
-			if (!found) {
+			if (!found || subexport(&exp->m_export, found)) {
 				found = &exp->m_export;
+				free(found_path);
 				found_path = strdup(path);
 				if (found_path == NULL)
 					goto out;
-			} else if (strcmp(found->e_path, exp->m_export.e_path)!= 0)
+			} else if (strcmp(found->e_path, exp->m_export.e_path)
+				   && !subexport(found, &exp->m_export))
 			{
 				xlog(L_WARNING, "%s and %s have same filehandle for %s, using first",
 				     found_path, path, dom);
-- 
1.7.4.1


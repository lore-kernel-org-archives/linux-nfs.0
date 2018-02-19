Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:38399 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750978AbeBSFDR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 19 Feb 2018 00:03:17 -0500
From: NeilBrown <neilb@suse.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Date: Mon, 19 Feb 2018 16:02:28 +1100
Subject: [PATCH 01/23] cred: add cred_fscmp() for comparing creds.
Cc: linux-nfs@vger.kernel.org
Message-ID: <151901654877.17421.12826958279097933802.stgit@noble>
In-Reply-To: <151901634940.17421.7637564368419392071.stgit@noble>
References: <151901634940.17421.7637564368419392071.stgit@noble>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

NFS needs to compare to credentials, to see if they can
be treated the same w.r.t. filesystem access.  Sometimes
an ordering is needed when credentials are used as a key
to an rbtree.
NFS current has its own private credential management from
before 'struct cred' existed.  To move it over to more consistent
use of 'struct cred' we need a comparison function.
This patch adds that function.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 include/linux/cred.h |    1 +
 kernel/cred.c        |   55 ++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 56 insertions(+)

diff --git a/include/linux/cred.h b/include/linux/cred.h
index 631286535d0f..6dd51e503f23 100644
--- a/include/linux/cred.h
+++ b/include/linux/cred.h
@@ -164,6 +164,7 @@ extern int change_create_files_as(struct cred *, struct inode *);
 extern int set_security_override(struct cred *, u32);
 extern int set_security_override_from_ctx(struct cred *, const char *);
 extern int set_create_files_as(struct cred *, struct inode *);
+extern int cred_fscmp(const struct cred *, const struct cred *);
 extern void __init cred_init(void);
 
 /*
diff --git a/kernel/cred.c b/kernel/cred.c
index ecf03657e71c..4ce75c6fb752 100644
--- a/kernel/cred.c
+++ b/kernel/cred.c
@@ -19,6 +19,7 @@
 #include <linux/security.h>
 #include <linux/binfmts.h>
 #include <linux/cn_proc.h>
+#include <linux/uidgid.h>
 
 #if 0
 #define kdebug(FMT, ...)						\
@@ -564,6 +565,60 @@ void revert_creds(const struct cred *old)
 }
 EXPORT_SYMBOL(revert_creds);
 
+/**
+ * cred_fscmp - Compare to credentials with respect to filesystem access.
+ * @a: The first credential
+ * @b: The second credential
+ *
+ * cred_cmp() will return zero if both credentials have the same
+ * fsuid, fsgid, and supplementary groups.  That is, if they will both
+ * provide the same access to files based on mode/uid/gid.
+ * If the credentials are different, then either -1 or 1 will
+ * be returned depending on whether @a comes before or after @b
+ * respectively in an arbitrary, but stable, ordering of credentials.
+ *
+ * Return: -1, 0, or 1 depending on comparison
+ */
+int cred_fscmp(const struct cred *a, const struct cred *b)
+{
+	struct group_info *ga, *gb;
+	int g;
+
+	if (a == b)
+		return 0;
+	if (uid_lt(a->fsuid, b->fsuid))
+		return -1;
+	if (uid_gt(a->fsuid, b->fsuid))
+		return 1;
+
+	if (gid_lt(a->fsgid, b->fsgid))
+		return -1;
+	if (gid_gt(a->fsgid, b->fsgid))
+		return 1;
+
+	ga = a->group_info;
+	gb = b->group_info;
+	if (ga == gb)
+		return 0;
+	if (ga == NULL)
+		return -1;
+	if (gb == NULL)
+		return 1;
+	if (ga->ngroups < gb->ngroups)
+		return -1;
+	if (ga->ngroups > gb->ngroups)
+		return 1;
+
+	for (g = 0; g < ga->ngroups; g++) {
+		if (gid_lt(ga->gid[g], gb->gid[g]))
+			return -1;
+		if (gid_gt(ga->gid[g], gb->gid[g]))
+			return 1;
+	}
+	return 0;
+}
+EXPORT_SYMBOL(cred_fscmp);
+
 /*
  * initialise the credentials stuff
  */



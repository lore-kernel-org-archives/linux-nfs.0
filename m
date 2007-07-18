From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: [PATCH 2/5] nfsd: return errors, not NULL, from export functions
Date: Wed, 18 Jul 2007 18:57:27 -0400
Message-ID: <278646972e4b7eaf86d648d8ee2ae879f8b6b680.1184798679.git.bfields__44535.3338298903$1184799538$gmane$org@citi.umich.edu>
References: <20070713114228.3c171a90.akpm@linux-foundation.org>
 <11847994502579-git-send-email-bfields@fieldses.org>
 <11847994502502-git-send-email-bfields@fieldses.org>
Cc: NeilBrown <neilb@suse.de>, nfs@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, andros@citi.umich.edu,
	"J. Bruce Fields" <bfields@citi.umich.edu>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S934687AbXGRW6e@vger.kernel.org>
In-Reply-To: <11847994502502-git-send-email-bfields@fieldses.org>
Message-Id: <278646972e4b7eaf86d648d8ee2ae879f8b6b680.1184798679.git.bfields@citi.umich.edu>
In-Reply-To: <2ac9f179334dc7894bb58b1c2fb62837a07fbbdf.1184798679.git.bfields@citi.umich.edu>
References: <2ac9f179334dc7894bb58b1c2fb62837a07fbbdf.1184798679.git.bfields@citi.umich.edu>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

From: J. Bruce Fields <bfields@citi.umich.edu>

I converted the various export-returning functions to return -ENOENT
instead of NULL, but missed a few cases.

This particular case could cause actual bugs in the case of a krb5
client that doesn't match any ip-based client and that is trying to
access a filesystem not exported to krb5 clients.

Signed-off-by: "J. Bruce Fields" <bfields@citi.umich.edu>
---
 fs/nfsd/export.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
index c7bbf46..6ab8de4 100644
--- a/fs/nfsd/export.c
+++ b/fs/nfsd/export.c
@@ -1265,7 +1265,7 @@ struct svc_export *
 rqst_exp_get_by_name(struct svc_rqst *rqstp, struct vfsmount *mnt,
 		struct dentry *dentry)
 {
-	struct svc_export *gssexp, *exp = NULL;
+	struct svc_export *gssexp, *exp = ERR_PTR(-ENOENT);
 
 	if (rqstp->rq_client == NULL)
 		goto gss;
@@ -1288,7 +1288,7 @@ gss:
 						&rqstp->rq_chandle);
 	if (PTR_ERR(gssexp) == -ENOENT)
 		return exp;
-	if (exp && !IS_ERR(exp))
+	if (!IS_ERR(exp))
 		exp_put(exp);
 	return gssexp;
 }
@@ -1296,7 +1296,7 @@ gss:
 struct svc_export *
 rqst_exp_find(struct svc_rqst *rqstp, int fsid_type, u32 *fsidv)
 {
-	struct svc_export *gssexp, *exp = NULL;
+	struct svc_export *gssexp, *exp = ERR_PTR(-ENOENT);
 
 	if (rqstp->rq_client == NULL)
 		goto gss;
@@ -1318,7 +1318,7 @@ gss:
 						&rqstp->rq_chandle);
 	if (PTR_ERR(gssexp) == -ENOENT)
 		return exp;
-	if (exp && !IS_ERR(exp))
+	if (!IS_ERR(exp))
 		exp_put(exp);
 	return gssexp;
 }
-- 
1.5.3.rc2

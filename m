Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pb0-f48.google.com ([209.85.160.48]:42033 "EHLO
	mail-pb0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751276AbaFJOGw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 10 Jun 2014 10:06:52 -0400
Received: by mail-pb0-f48.google.com with SMTP id rr13so6286590pbb.35
        for <linux-nfs@vger.kernel.org>; Tue, 10 Jun 2014 07:06:51 -0700 (PDT)
Message-ID: <539710F4.6060806@gmail.com>
Date: Tue, 10 Jun 2014 22:06:44 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>, kinglongmee@gmail.com
Subject: [PATCH] NFSD: Using exp_get for export getting
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Don't using cache_get besides export.h, using exp_get for export.

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfsd/export.c   | 2 +-
 fs/nfsd/export.h   | 3 ++-
 fs/nfsd/nfs4proc.c | 6 +++---
 fs/nfsd/nfsfh.c    | 3 +--
 fs/nfsd/vfs.c      | 3 +--
 5 files changed, 8 insertions(+), 9 deletions(-)

diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
index ef2d9d6..72ffd7c 100644
--- a/fs/nfsd/export.c
+++ b/fs/nfsd/export.c
@@ -1253,7 +1253,7 @@ static int e_show(struct seq_file *m, void *p)
 		return 0;
 	}
 
-	cache_get(&exp->h);
+	exp_get(exp);
 	if (cache_check(cd, &exp->h, NULL))
 		return 0;
 	exp_put(exp);
diff --git a/fs/nfsd/export.h b/fs/nfsd/export.h
index cfeea85..04dc8c1 100644
--- a/fs/nfsd/export.h
+++ b/fs/nfsd/export.h
@@ -101,9 +101,10 @@ static inline void exp_put(struct svc_export *exp)
 	cache_put(&exp->h, exp->cd);
 }
 
-static inline void exp_get(struct svc_export *exp)
+static inline struct svc_export *exp_get(struct svc_export *exp)
 {
 	cache_get(&exp->h);
+	return exp;
 }
 struct svc_export * rqst_exp_find(struct svc_rqst *, int, u32 *);
 
diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index be67340..f3f0487 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -177,7 +177,7 @@ fh_dup2(struct svc_fh *dst, struct svc_fh *src)
 	fh_put(dst);
 	dget(src->fh_dentry);
 	if (src->fh_export)
-		cache_get(&src->fh_export->h);
+		exp_get(src->fh_export);
 	*dst = *src;
 }
 
@@ -918,8 +918,8 @@ nfsd4_secinfo_no_name(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstat
 	default:
 		return nfserr_inval;
 	}
-	exp_get(cstate->current_fh.fh_export);
-	sin->sin_exp = cstate->current_fh.fh_export;
+
+	sin->sin_exp = exp_get(cstate->current_fh.fh_export);
 	fh_put(&cstate->current_fh);
 	return nfs_ok;
 }
diff --git a/fs/nfsd/nfsfh.c b/fs/nfsd/nfsfh.c
index ec83934..6f5cc76 100644
--- a/fs/nfsd/nfsfh.c
+++ b/fs/nfsd/nfsfh.c
@@ -539,8 +539,7 @@ fh_compose(struct svc_fh *fhp, struct svc_export *exp, struct dentry *dentry,
 		       dentry);
 
 	fhp->fh_dentry = dget(dentry); /* our internal copy */
-	fhp->fh_export = exp;
-	cache_get(&exp->h);
+	fhp->fh_export = exp_get(exp);
 
 	if (fhp->fh_handle.fh_version == 0xca) {
 		/* old style filehandle please */
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 7498099..df7cf61 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -189,8 +189,7 @@ nfsd_lookup_dentry(struct svc_rqst *rqstp, struct svc_fh *fhp,
 	dprintk("nfsd: nfsd_lookup(fh %s, %.*s)\n", SVCFH_fmt(fhp), len,name);
 
 	dparent = fhp->fh_dentry;
-	exp  = fhp->fh_export;
-	exp_get(exp);
+	exp = exp_get(fhp->fh_export);
 
 	/* Lookup the name, but don't follow links */
 	if (isdotent(name, len)) {
-- 
1.9.3


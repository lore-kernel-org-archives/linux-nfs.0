Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:57457 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754935Ab1DJQ3j (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 10 Apr 2011 12:29:39 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Cc: Bryan Schumaker <bjschuma@netapp.com>,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 4/5] nfsd4: make fh_verify responsibility of nfsd_lookup_dentry caller
Date: Sun, 10 Apr 2011 12:29:32 -0400
Message-Id: <1302452973-27272-4-git-send-email-bfields@redhat.com>
In-Reply-To: <20110410162536.GC26233@fieldses.org>
References: <20110410162536.GC26233@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

The secinfo caller actually won't want this.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4proc.c |    3 +++
 fs/nfsd/vfs.c      |    9 +++------
 2 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 126b8f7..8059ada 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -762,6 +762,9 @@ nfsd4_secinfo(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	__be32 err;
 
 	fh_init(&resfh, NFS4_FHSIZE);
+	err = fh_verify(rqstp, &cstate->current_fh, S_IFDIR, NFSD_MAY_EXEC);
+	if (err)
+		return err;
 	err = nfsd_lookup_dentry(rqstp, &cstate->current_fh,
 				    secinfo->si_name, secinfo->si_namelen,
 				    &exp, &dentry);
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index ac4f0b4..7d75890 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -181,16 +181,10 @@ nfsd_lookup_dentry(struct svc_rqst *rqstp, struct svc_fh *fhp,
 	struct svc_export	*exp;
 	struct dentry		*dparent;
 	struct dentry		*dentry;
-	__be32			err;
 	int			host_err;
 
 	dprintk("nfsd: nfsd_lookup(fh %s, %.*s)\n", SVCFH_fmt(fhp), len,name);
 
-	/* Obtain dentry and export. */
-	err = fh_verify(rqstp, fhp, S_IFDIR, NFSD_MAY_EXEC);
-	if (err)
-		return err;
-
 	dparent = fhp->fh_dentry;
 	exp  = fhp->fh_export;
 	exp_get(exp);
@@ -254,6 +248,9 @@ nfsd_lookup(struct svc_rqst *rqstp, struct svc_fh *fhp, const char *name,
 	struct dentry		*dentry;
 	__be32 err;
 
+	err = fh_verify(rqstp, fhp, S_IFDIR, NFSD_MAY_EXEC);
+	if (err)
+		return err;
 	err = nfsd_lookup_dentry(rqstp, fhp, name, len, &exp, &dentry);
 	if (err)
 		return err;
-- 
1.7.1


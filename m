From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 4/4] nfsd4: fix error return when pseudoroot missing
Date: Mon, 28 Sep 2009 12:22:32 -0400
Message-ID: <1254154952-13083-5-git-send-email-bfields@citi.umich.edu>
References: <1254154952-13083-1-git-send-email-bfields@citi.umich.edu>
 <1254154952-13083-2-git-send-email-bfields@citi.umich.edu>
 <1254154952-13083-3-git-send-email-bfields@citi.umich.edu>
 <1254154952-13083-4-git-send-email-bfields@citi.umich.edu>
Cc: "J. Bruce Fields" <bfields@citi.umich.edu>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:48560 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752513AbZI1QWN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 28 Sep 2009 12:22:13 -0400
In-Reply-To: <1254154952-13083-4-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We really shouldn't hit this case at all, and forthcoming kernel and
nfs-utils changes should eliminate this case; if it does happens,
consider it a bug rather than reporting an error that doesn't really
make sense for the operation (since there's no reason for a server to be
accepting v4 traffic yet have no root filehandle).

Also move some exp_pseudoroot code into a helper function while we're
here.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/nfsd/export.c  |   22 ++++++++++++++++++----
 fs/nfsd/nfsproc.c |    1 +
 2 files changed, 19 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
index c1c9e03..b73baba 100644
--- a/fs/nfsd/export.c
+++ b/fs/nfsd/export.c
@@ -1320,6 +1320,23 @@ rqst_exp_parent(struct svc_rqst *rqstp, struct path *path)
 	return exp;
 }
 
+static struct svc_export *find_fsidzero_export(struct svc_rqst *rqstp)
+{
+	struct svc_export *exp;
+	u32 fsidv[2];
+
+	mk_fsid(FSID_NUM, fsidv, 0, 0, 0, NULL);
+
+	exp = rqst_exp_find(rqstp, FSID_NUM, fsidv);
+	/*
+	 * We shouldn't have accepting an nfsv4 request at all if we
+	 * don't have a pseudoexport!:
+	 */
+	if (IS_ERR(exp) && PTR_ERR(exp) == -ENOENT)
+		exp = ERR_PTR(-ESERVERFAULT);
+	return exp;
+}
+
 /*
  * Called when we need the filehandle for the root of the pseudofs,
  * for a given NFSv4 client.   The root is defined to be the
@@ -1330,11 +1347,8 @@ exp_pseudoroot(struct svc_rqst *rqstp, struct svc_fh *fhp)
 {
 	struct svc_export *exp;
 	__be32 rv;
-	u32 fsidv[2];
-
-	mk_fsid(FSID_NUM, fsidv, 0, 0, 0, NULL);
 
-	exp = rqst_exp_find(rqstp, FSID_NUM, fsidv);
+	exp = find_fsidzero_export(rqstp);
 	if (IS_ERR(exp))
 		return nfserrno(PTR_ERR(exp));
 	rv = fh_compose(fhp, exp, exp->ex_path.dentry, NULL);
diff --git a/fs/nfsd/nfsproc.c b/fs/nfsd/nfsproc.c
index 0eb9c82..c5393d1 100644
--- a/fs/nfsd/nfsproc.c
+++ b/fs/nfsd/nfsproc.c
@@ -758,6 +758,7 @@ nfserrno (int errno)
 		{ nfserr_io, -ETXTBSY },
 		{ nfserr_notsupp, -EOPNOTSUPP },
 		{ nfserr_toosmall, -ETOOSMALL },
+		{ nfserr_serverfault, -ESERVERFAULT },
 	};
 	int	i;
 
-- 
1.6.0.4


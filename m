From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH v2 18/35] pnfsd: add helper functions for identifying DS stateids.
Date: Mon,  7 Dec 2009 11:33:46 +0200
Message-ID: <1260178426-15296-1-git-send-email-bhalevy@panasas.com>
References: <4B1CCA52.8020900@panasas.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org,
	linux-fsdevel@vger.kernel.org, Benny Halevy <bhalevy@panasas.com>,
	"David M. Richter" <richterd@citi.umich.edu>
To: " J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:36915 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S934877AbZLGJcu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 7 Dec 2009 04:32:50 -0500
In-Reply-To: <4B1CCA52.8020900@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Benny's suggestion for more clearly spelling out how a filehandle's
fh_fsid_type is overloaded to indicate that a stateid is from a DS and needs
to be validated by the MDS.

[pnfsd: define and use FSID_MAX in enum nfsd_fsid]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[pnfsd: add helper functions for identifying DS stateids.]
Signed-off-by: David M. Richter <richterd@citi.umich.edu>
[define a no-op version of pnfs_fh_is_ds for !CONFIG_PNFSD]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfsfh.c                 |    7 +++++--
 include/linux/nfsd/nfsd4_pnfs.h |   39 +++++++++++++++++++++++++++++++++++++++
 include/linux/nfsd/nfsfh.h      |    1 +
 3 files changed, 45 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfsfh.c b/fs/nfsd/nfsfh.c
index 5693f68..faa79d5 100644
--- a/fs/nfsd/nfsfh.c
+++ b/fs/nfsd/nfsfh.c
@@ -12,6 +12,7 @@
 #include <linux/exportfs.h>
 
 #include <linux/sunrpc/svcauth_gss.h>
+#include <linux/nfsd/nfsd4_pnfs.h>
 #include "nfsd.h"
 #include "vfs.h"
 #include "auth.h"
@@ -139,6 +140,7 @@ static inline __be32 check_pseudo_root(struct svc_rqst *rqstp,
 static __be32 nfsd_set_fh_dentry(struct svc_rqst *rqstp, struct svc_fh *fhp)
 {
 	struct knfsd_fh	*fh = &fhp->fh_handle;
+	int fsid_type;
 	struct fid *fid = NULL, sfid;
 	struct svc_export *exp;
 	struct dentry *dentry;
@@ -159,7 +161,8 @@ static __be32 nfsd_set_fh_dentry(struct svc_rqst *rqstp, struct svc_fh *fhp)
 			return error;
 		if (fh->fh_auth_type != 0)
 			return error;
-		len = key_len(fh->fh_fsid_type) / 4;
+		fsid_type = pnfs_fh_fsid_type(fh);
+		len = key_len(fsid_type) / 4;
 		if (len == 0)
 			return error;
 		if  (fh->fh_fsid_type == FSID_MAJOR_MINOR) {
@@ -172,7 +175,7 @@ static __be32 nfsd_set_fh_dentry(struct svc_rqst *rqstp, struct svc_fh *fhp)
 		data_left -= len;
 		if (data_left < 0)
 			return error;
-		exp = rqst_exp_find(rqstp, fh->fh_fsid_type, fh->fh_auth);
+		exp = rqst_exp_find(rqstp, fsid_type, fh->fh_auth);
 		fid = (struct fid *)(fh->fh_auth + len);
 	} else {
 		__u32 tfh[2];
diff --git a/include/linux/nfsd/nfsd4_pnfs.h b/include/linux/nfsd/nfsd4_pnfs.h
index be15b7f..b80ff01 100644
--- a/include/linux/nfsd/nfsd4_pnfs.h
+++ b/include/linux/nfsd/nfsd4_pnfs.h
@@ -36,6 +36,7 @@
 
 #include <linux/exportfs.h>
 #include <linux/exp_xdr.h>
+#include <linux/nfsd/nfsfh.h>
 
 struct nfsd4_pnfs_deviceid {
 	u64	fsid;			/* filesystem ID */
@@ -133,4 +134,42 @@ struct pnfs_export_operations {
 	int (*can_merge_layouts) (u32 layout_type);
 };
 
+#if defined(CONFIG_PNFSD)
+
+/*
+ * fh_fsid_type is overloaded to indicate whether a filehandle was one supplied
+ * to a DS by LAYOUTGET.  nfs4_preprocess_stateid_op() uses this to decide how
+ * to handle a given stateid.
+ */
+static inline int pnfs_fh_is_ds(struct knfsd_fh *fh)
+{
+	return fh->fh_fsid_type >= FSID_MAX;
+}
+
+static inline void pnfs_fh_mark_ds(struct knfsd_fh *fh)
+{
+	BUG_ON(fh->fh_version != 1);
+	BUG_ON(pnfs_fh_is_ds(fh));
+	fh->fh_fsid_type += FSID_MAX;
+}
+
+#else  /* CONFIG_PNFSD */
+
+static inline int pnfs_fh_is_ds(struct knfsd_fh *fh)
+{
+	return 0;
+}
+
+#endif /* CONFIG_PNFSD */
+
+/* allows fh_verify() to check the real fsid_type (i.e., not overloaded). */
+static inline int pnfs_fh_fsid_type(struct knfsd_fh *fh)
+{
+	int fsid_type = fh->fh_fsid_type;
+
+	if (pnfs_fh_is_ds(fh))
+		return fsid_type - FSID_MAX;
+	return fsid_type;
+}
+
 #endif /* _LINUX_NFSD_NFSD4_PNFS_H */
diff --git a/include/linux/nfsd/nfsfh.h b/include/linux/nfsd/nfsfh.h
index 49523ed..8ffa986 100644
--- a/include/linux/nfsd/nfsfh.h
+++ b/include/linux/nfsd/nfsfh.h
@@ -171,6 +171,7 @@ enum nfsd_fsid {
 	FSID_UUID8,
 	FSID_UUID16,
 	FSID_UUID16_INUM,
+	FSID_MAX
 };
 
 enum fsid_source {
-- 
1.6.5.1


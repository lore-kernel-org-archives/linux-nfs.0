Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f49.google.com ([209.85.216.49]:34984 "EHLO
	mail-qa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752597Ab3IZSk4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Sep 2013 14:40:56 -0400
Received: by mail-qa0-f49.google.com with SMTP id k15so1104567qaq.1
        for <linux-nfs@vger.kernel.org>; Thu, 26 Sep 2013 11:40:55 -0700 (PDT)
From: Benny Halevy <bhalevy@primarydata.com>
To: " J. Bruce Fields" <bfields@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH RFC v0 15/49] pnfsd: add helper functions for identifying DS filehandles
Date: Thu, 26 Sep 2013 14:40:53 -0400
Message-Id: <1380220853-13371-1-git-send-email-bhalevy@primarydata.com>
In-Reply-To: <52447EA0.7070004@primarydata.com>
References: <52447EA0.7070004@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Benny Halevy <bhalevy@panasas.com>

[pnfsd: define and use FSID_MAX in enum nfsd_fsid]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[pnfsd: add helper functions for identifying DS stateids.]
Signed-off-by: David M. Richter <richterd@citi.umich.edu>
[define a no-op version of pnfs_fh_is_ds for !CONFIG_PNFSD]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
Signed-off-by: Benny Halevy <bhalevy@primarydata.com>
---
 fs/nfsd/nfsfh.c |  7 +++++--
 fs/nfsd/nfsfh.h | 39 +++++++++++++++++++++++++++++++++++++++
 2 files changed, 44 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfsfh.c b/fs/nfsd/nfsfh.c
index 814afaa..71f9470 100644
--- a/fs/nfsd/nfsfh.c
+++ b/fs/nfsd/nfsfh.c
@@ -10,6 +10,7 @@
 #include <linux/exportfs.h>
 
 #include <linux/sunrpc/svcauth_gss.h>
+#include <linux/nfsd/nfsd4_pnfs.h>
 #include "nfsd.h"
 #include "vfs.h"
 #include "auth.h"
@@ -136,6 +137,7 @@ static inline __be32 check_pseudo_root(struct svc_rqst *rqstp,
 static __be32 nfsd_set_fh_dentry(struct svc_rqst *rqstp, struct svc_fh *fhp)
 {
 	struct knfsd_fh	*fh = &fhp->fh_handle;
+	int fsid_type;
 	struct fid *fid = NULL, sfid;
 	struct svc_export *exp;
 	struct dentry *dentry;
@@ -156,7 +158,8 @@ static __be32 nfsd_set_fh_dentry(struct svc_rqst *rqstp, struct svc_fh *fhp)
 			return error;
 		if (fh->fh_auth_type != 0)
 			return error;
-		len = key_len(fh->fh_fsid_type) / 4;
+		fsid_type = pnfs_fh_fsid_type(fh);
+		len = key_len(fsid_type) / 4;
 		if (len == 0)
 			return error;
 		if  (fh->fh_fsid_type == FSID_MAJOR_MINOR) {
@@ -169,7 +172,7 @@ static __be32 nfsd_set_fh_dentry(struct svc_rqst *rqstp, struct svc_fh *fhp)
 		data_left -= len;
 		if (data_left < 0)
 			return error;
-		exp = rqst_exp_find(rqstp, fh->fh_fsid_type, fh->fh_auth);
+		exp = rqst_exp_find(rqstp, fsid_type, fh->fh_auth);
 		fid = (struct fid *)(fh->fh_auth + len);
 	} else {
 		__u32 tfh[2];
diff --git a/fs/nfsd/nfsfh.h b/fs/nfsd/nfsfh.h
index e5e6707..2563e88 100644
--- a/fs/nfsd/nfsfh.h
+++ b/fs/nfsd/nfsfh.h
@@ -14,6 +14,7 @@ enum nfsd_fsid {
 	FSID_UUID8,
 	FSID_UUID16,
 	FSID_UUID16_INUM,
+	FSID_MAX
 };
 
 enum fsid_source {
@@ -203,4 +204,42 @@ static inline int key_len(int type)
 	}
 }
 
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
 #endif /* _LINUX_NFSD_FH_INT_H */
-- 
1.8.3.1


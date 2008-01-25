From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 010/100] NFSD: Adjust filename length argument of nfsd_lookup
Date: Fri, 25 Jan 2008 18:15:50 -0500
Message-ID: <1201303040-7779-10-git-send-email-bfields@citi.umich.edu>
References: <20080125231521.GG25141@fieldses.org>
 <1201303040-7779-1-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-2-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-3-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-4-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-5-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-6-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-7-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-8-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-9-git-send-email-bfields@citi.umich.edu>
Cc: Chuck Lever <chuck.lever@oracle.com>,
	"J. Bruce Fields" <bfields@citi.umich.edu>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:47322 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762045AbYAYXRZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jan 2008 18:17:25 -0500
In-Reply-To: <1201303040-7779-9-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Chuck Lever <chuck.lever@oracle.com>

Clean up: adjust the sign of the length argument of nfsd_lookup and
nfsd_lookup_dentry, for consistency with recent changes.  NFSD version
4 callers already pass an unsigned file name length.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Acked-By: NeilBrown <neilb@suse.de>
Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/nfsd/vfs.c             |    4 ++--
 include/linux/nfsd/nfsd.h |    4 ++--
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index d019918..755ba43 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -132,7 +132,7 @@ out:
 
 __be32
 nfsd_lookup_dentry(struct svc_rqst *rqstp, struct svc_fh *fhp,
-		   const char *name, int len,
+		   const char *name, unsigned int len,
 		   struct svc_export **exp_ret, struct dentry **dentry_ret)
 {
 	struct svc_export	*exp;
@@ -226,7 +226,7 @@ out_nfserr:
  */
 __be32
 nfsd_lookup(struct svc_rqst *rqstp, struct svc_fh *fhp, const char *name,
-					int len, struct svc_fh *resfh)
+				unsigned int len, struct svc_fh *resfh)
 {
 	struct svc_export	*exp;
 	struct dentry		*dentry;
diff --git a/include/linux/nfsd/nfsd.h b/include/linux/nfsd/nfsd.h
index 604a0d7..a51a30f 100644
--- a/include/linux/nfsd/nfsd.h
+++ b/include/linux/nfsd/nfsd.h
@@ -70,9 +70,9 @@ void		nfsd_racache_shutdown(void);
 int		nfsd_cross_mnt(struct svc_rqst *rqstp, struct dentry **dpp,
 		                struct svc_export **expp);
 __be32		nfsd_lookup(struct svc_rqst *, struct svc_fh *,
-				const char *, int, struct svc_fh *);
+				const char *, unsigned int, struct svc_fh *);
 __be32		 nfsd_lookup_dentry(struct svc_rqst *, struct svc_fh *,
-				const char *, int,
+				const char *, unsigned int,
 				struct svc_export **, struct dentry **);
 __be32		nfsd_setattr(struct svc_rqst *, struct svc_fh *,
 				struct iattr *, int, time_t);
-- 
1.5.4.rc2.60.gb2e62


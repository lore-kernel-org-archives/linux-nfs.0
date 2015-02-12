Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wg0-f48.google.com ([74.125.82.48]:64498 "EHLO
	mail-wg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751913AbbBLWJT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 12 Feb 2015 17:09:19 -0500
From: Bas Peters <baspeters93@gmail.com>
To: bfields@fieldses.org
Cc: Bas Peters <baspeters93@gmail.com>, hch@lst.de, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux@roeck-us.net,
        linux-next@vger.kernel.org
Subject: [PATCH] fs: nfsd:xdr4.h: add missing conditional group CONFIG_NFSD_V3
Date: Thu, 12 Feb 2015 23:09:13 +0100
Message-Id: <1423778953-28307-1-git-send-email-baspeters93@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch adds a missing conditional group that has been causing build
breakages due to undefined struct members being referenced when
CONFIG_NFSD_v3 is not set.

This patch applies against linux-next.

Signed-off-by: Bas Peters <baspeters93@gmail.com>
---
 fs/nfsd/xdr4.h | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
index 0bda93e..5d1597f 100644
--- a/fs/nfsd/xdr4.h
+++ b/fs/nfsd/xdr4.h
@@ -630,9 +630,11 @@ void warn_on_nonidempotent_op(struct nfsd4_op *op);
 static inline void
 set_change_info(struct nfsd4_change_info *cinfo, struct svc_fh *fhp)
 {
+	cinfo->change_supported = IS_I_VERSION(fhp->fh_dentry->d_inode);
+
+#ifdef CONFIG_NFSD_V3
 	BUG_ON(!fhp->fh_pre_saved);
 	cinfo->atomic = fhp->fh_post_saved;
-	cinfo->change_supported = IS_I_VERSION(fhp->fh_dentry->d_inode);
 
 	cinfo->before_change = fhp->fh_pre_change;
 	cinfo->after_change = fhp->fh_post_change;
@@ -640,7 +642,7 @@ set_change_info(struct nfsd4_change_info *cinfo, struct svc_fh *fhp)
 	cinfo->before_ctime_nsec = fhp->fh_pre_ctime.tv_nsec;
 	cinfo->after_ctime_sec = fhp->fh_post_attr.ctime.tv_sec;
 	cinfo->after_ctime_nsec = fhp->fh_post_attr.ctime.tv_nsec;
-
+#endif
 }
 
 int nfs4svc_encode_voidres(struct svc_rqst *, __be32 *, void *);
-- 
2.1.0


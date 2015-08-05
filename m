Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yk0-f178.google.com ([209.85.160.178]:33363 "EHLO
	mail-yk0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752471AbbHEVNy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Aug 2015 17:13:54 -0400
Received: by ykoo205 with SMTP id o205so46666636yko.0
        for <linux-nfs@vger.kernel.org>; Wed, 05 Aug 2015 14:13:54 -0700 (PDT)
From: Jeff Layton <jlayton@poochiereds.net>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 15/18] nfsd: have set_version_and_fsid_type take a knfsd_fh instead of svc_fh
Date: Wed,  5 Aug 2015 17:13:33 -0400
Message-Id: <1438809216-4846-16-git-send-email-jeff.layton@primarydata.com>
In-Reply-To: <1438809216-4846-1-git-send-email-jeff.layton@primarydata.com>
References: <1438264341-18048-1-git-send-email-jeff.layton@primarydata.com>
 <1438809216-4846-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Note however that we do still have it take a svc_fh for the ref_fh, but
that could be changed in the future if it's helpful to do so.

Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
---
 fs/nfsd/nfsfh.c | 13 ++++++++-----
 1 file changed, 8 insertions(+), 5 deletions(-)

diff --git a/fs/nfsd/nfsfh.c b/fs/nfsd/nfsfh.c
index a945500db17c..b601f291d825 100644
--- a/fs/nfsd/nfsfh.c
+++ b/fs/nfsd/nfsfh.c
@@ -454,7 +454,9 @@ static bool fsid_type_ok_for_exp(u8 fsid_type, struct svc_export *exp)
 }
 
 
-static void set_version_and_fsid_type(struct svc_fh *fhp, struct svc_export *exp, struct svc_fh *ref_fh)
+static void
+set_version_and_fsid_type(struct knfsd_fh *kfh, int maxsize,
+			  struct svc_export *exp, struct svc_fh *ref_fh)
 {
 	u8 version;
 	u8 fsid_type;
@@ -487,7 +489,7 @@ retry:
 	} else if (exp->ex_flags & NFSEXP_FSID) {
 		fsid_type = FSID_NUM;
 	} else if (exp->ex_uuid) {
-		if (fhp->fh_maxsize >= 64) {
+		if (maxsize >= 64) {
 			if (is_root_export(exp))
 				fsid_type = FSID_UUID16;
 			else
@@ -503,9 +505,9 @@ retry:
 		fsid_type = FSID_ENCODE_DEV;
 	else
 		fsid_type = FSID_DEV;
-	fhp->fh_handle.fh_version = version;
+	kfh->fh_version = version;
 	if (version)
-		fhp->fh_handle.fh_fsid_type = fsid_type;
+		kfh->fh_fsid_type = fsid_type;
 }
 
 __be32
@@ -533,7 +535,8 @@ fh_compose(struct svc_fh *fhp, struct svc_export *exp, struct dentry *dentry,
 	 * the reference filehandle (if it is in the same export)
 	 * or the export options.
 	 */
-	 set_version_and_fsid_type(fhp, exp, ref_fh);
+	 set_version_and_fsid_type(&fhp->fh_handle, fhp->fh_maxsize,
+				   exp, ref_fh);
 
 	if (ref_fh == fhp)
 		fh_put(ref_fh);
-- 
2.4.3


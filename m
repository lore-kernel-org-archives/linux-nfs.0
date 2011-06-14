Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:38125 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753956Ab1FNVgP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 14 Jun 2011 17:36:15 -0400
From: Boaz Harrosh <bharrosh@panasas.com>
To: Benny Halevy <bhalevy@panasas.com>, open-osd <osd-dev@open-osd.org>,
        NFS list <linux-nfs@vger.kernel.org>
Subject: [PATCH 04/10] SQUASHME: pnfsd-exofs: Change layout encoding to two pass
Date: Tue, 14 Jun 2011 17:36:14 -0400
Message-Id: <1308087374-13151-1-git-send-email-bharrosh@panasas.com>
In-Reply-To: <4DF7D36F.9070602@panasas.com>
References: <4DF7D36F.9070602@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

This way there is No need for dynamic allocation of the creds
array.

TODO: We can now remove the olo_comps pointer from
      struct pnfs_osd_layout neither the server nor client use
      it any more. (rename it to pnfs_osd_layout_hdr)

Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
---
 fs/exportfs/pnfs_osd_xdr_srv.c        |   16 +++++-----------
 include/linux/nfsd/pnfs_osd_xdr_srv.h |    6 +++++-
 2 files changed, 10 insertions(+), 12 deletions(-)

diff --git a/fs/exportfs/pnfs_osd_xdr_srv.c b/fs/exportfs/pnfs_osd_xdr_srv.c
index 67564f6..ec814c1 100644
--- a/fs/exportfs/pnfs_osd_xdr_srv.c
+++ b/fs/exportfs/pnfs_osd_xdr_srv.c
@@ -110,7 +110,7 @@ static inline int pnfs_osd_xdr_encode_objid(
  * 	struct pnfs_osd_opaque_cred	oc_cap;
  * };
  */
-static int pnfs_osd_xdr_encode_object_cred(
+int pnfs_osd_xdr_encode_layout_cred(
 	struct exp_xdr_stream *xdr,
 	struct pnfs_osd_object_cred *olo_comp)
 {
@@ -136,6 +136,7 @@ static int pnfs_osd_xdr_encode_object_cred(
 
 	return 0;
 }
+EXPORT_SYMBOL(pnfs_osd_xdr_encode_layout_cred);
 
 /*
  * struct pnfs_osd_layout {
@@ -145,12 +146,11 @@ static int pnfs_osd_xdr_encode_object_cred(
  * 	struct pnfs_osd_object_cred	*olo_comps;
  * };
  */
-int pnfs_osd_xdr_encode_layout(
+int pnfs_osd_xdr_encode_layout_hdr(
 	struct exp_xdr_stream *xdr,
 	struct pnfs_osd_layout *pol)
 {
 	__be32 *p;
-	u32 i;
 	int err;
 
 	err = pnfs_osd_xdr_encode_data_map(xdr, &pol->olo_map);
@@ -164,15 +164,9 @@ int pnfs_osd_xdr_encode_layout(
 	p = exp_xdr_encode_u32(p, pol->olo_comps_index);
 	p = exp_xdr_encode_u32(p, pol->olo_num_comps);
 
-	for (i = 0; i < pol->olo_num_comps; i++) {
-		err = pnfs_osd_xdr_encode_object_cred(xdr, &pol->olo_comps[i]);
-		if (err)
-			return err;
-	}
-
 	return 0;
 }
-EXPORT_SYMBOL(pnfs_osd_xdr_encode_layout);
+EXPORT_SYMBOL(pnfs_osd_xdr_encode_layout_hdr);
 
 static int _encode_string(struct exp_xdr_stream *xdr,
 			  const struct nfs4_string *str)
@@ -217,7 +211,7 @@ int pnfs_osd_xdr_encode_deviceaddr(
 	if (err)
 		return err;
 
-	err = pnfs_osd_xdr_encode_object_cred(xdr,
+	err = pnfs_osd_xdr_encode_layout_cred(xdr,
 					      &devaddr->oda_root_obj_cred);
 	if (err)
 		return err;
diff --git a/include/linux/nfsd/pnfs_osd_xdr_srv.h b/include/linux/nfsd/pnfs_osd_xdr_srv.h
index 256a7e07..e9a2187 100644
--- a/include/linux/nfsd/pnfs_osd_xdr_srv.h
+++ b/include/linux/nfsd/pnfs_osd_xdr_srv.h
@@ -17,10 +17,14 @@
 #include <linux/exp_xdr.h>
 
 /* Layout encoding */
-int pnfs_osd_xdr_encode_layout(
+int pnfs_osd_xdr_encode_layout_hdr(
 	struct exp_xdr_stream *xdr,
 	struct pnfs_osd_layout *layout);
 
+int pnfs_osd_xdr_encode_layout_cred(
+	struct exp_xdr_stream *xdr,
+	struct pnfs_osd_object_cred *cred);
+
 /* deviceaddr encoding */
 int pnfs_osd_xdr_encode_deviceaddr(
 	struct exp_xdr_stream *xdr, struct pnfs_osd_deviceaddr *devaddr);
-- 
1.7.3.4


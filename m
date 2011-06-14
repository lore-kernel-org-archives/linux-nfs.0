Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:38142 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753956Ab1FNVgW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 14 Jun 2011 17:36:22 -0400
From: Boaz Harrosh <bharrosh@panasas.com>
To: Benny Halevy <bhalevy@panasas.com>, open-osd <osd-dev@open-osd.org>,
        NFS list <linux-nfs@vger.kernel.org>
Subject: [PATCH 05/10] SQUASHME: pnfsd-exofs: osd_xdr_srv: Convert XDR API to return enum nfsstat4
Date: Tue, 14 Jun 2011 17:36:21 -0400
Message-Id: <1308087381-13179-1-git-send-email-bharrosh@panasas.com>
In-Reply-To: <4DF7D36F.9070602@panasas.com>
References: <4DF7D36F.9070602@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

* Change pnfs_osd_xdr_srv API to return nfs4 errors

Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
---
 fs/exportfs/pnfs_osd_xdr_srv.c        |   30 +++++++++++++++---------------
 include/linux/nfsd/pnfs_osd_xdr_srv.h |    6 +++---
 2 files changed, 18 insertions(+), 18 deletions(-)

diff --git a/fs/exportfs/pnfs_osd_xdr_srv.c b/fs/exportfs/pnfs_osd_xdr_srv.c
index ec814c1..4d92f1c 100644
--- a/fs/exportfs/pnfs_osd_xdr_srv.c
+++ b/fs/exportfs/pnfs_osd_xdr_srv.c
@@ -51,14 +51,14 @@
  * 	u32	odm_raid_algorithm;
  * };
  */
-static int pnfs_osd_xdr_encode_data_map(
+static enum nfsstat4 pnfs_osd_xdr_encode_data_map(
 	struct exp_xdr_stream *xdr,
 	struct pnfs_osd_data_map *data_map)
 {
 	__be32 *p = exp_xdr_reserve_qwords(xdr, 1+2+1+1+1+1);
 
 	if (!p)
-		return -E2BIG;
+		return NFS4ERR_TOOSMALL;
 
 	p = exp_xdr_encode_u32(p, data_map->odm_num_comps);
 	p = exp_xdr_encode_u64(p, data_map->odm_stripe_unit);
@@ -77,7 +77,7 @@ static int pnfs_osd_xdr_encode_data_map(
  * 	u64			oid_object_id;
  * };
  */
-static inline int pnfs_osd_xdr_encode_objid(
+static inline enum nfsstat4 pnfs_osd_xdr_encode_objid(
 	struct exp_xdr_stream *xdr,
 	struct pnfs_osd_objid *object_id)
 {
@@ -86,7 +86,7 @@ static inline int pnfs_osd_xdr_encode_objid(
 		(struct nfsd4_pnfs_deviceid *)&object_id->oid_device_id;
 
 	if (!p)
-		return -E2BIG;
+		return NFS4ERR_TOOSMALL;
 
 	p = exp_xdr_encode_u64(p, dev_id->fsid);
 	p = exp_xdr_encode_u64(p, dev_id->devid);
@@ -110,12 +110,12 @@ static inline int pnfs_osd_xdr_encode_objid(
  * 	struct pnfs_osd_opaque_cred	oc_cap;
  * };
  */
-int pnfs_osd_xdr_encode_layout_cred(
+enum nfsstat4 pnfs_osd_xdr_encode_layout_cred(
 	struct exp_xdr_stream *xdr,
 	struct pnfs_osd_object_cred *olo_comp)
 {
 	__be32 *p;
-	int err;
+	enum nfsstat4 err;
 
 	err = pnfs_osd_xdr_encode_objid(xdr, &olo_comp->oc_object_id);
 	if (err)
@@ -123,7 +123,7 @@ int pnfs_osd_xdr_encode_layout_cred(
 
 	p = exp_xdr_reserve_space(xdr, 3*4 + 4+olo_comp->oc_cap.cred_len);
 	if (!p)
-		return -E2BIG;
+		return NFS4ERR_TOOSMALL;
 
 	p = exp_xdr_encode_u32(p, olo_comp->oc_osd_version);
 
@@ -146,12 +146,12 @@ EXPORT_SYMBOL(pnfs_osd_xdr_encode_layout_cred);
  * 	struct pnfs_osd_object_cred	*olo_comps;
  * };
  */
-int pnfs_osd_xdr_encode_layout_hdr(
+enum nfsstat4 pnfs_osd_xdr_encode_layout_hdr(
 	struct exp_xdr_stream *xdr,
 	struct pnfs_osd_layout *pol)
 {
 	__be32 *p;
-	int err;
+	enum nfsstat4 err;
 
 	err = pnfs_osd_xdr_encode_data_map(xdr, &pol->olo_map);
 	if (err)
@@ -159,7 +159,7 @@ int pnfs_osd_xdr_encode_layout_hdr(
 
 	p = exp_xdr_reserve_qwords(xdr, 2);
 	if (!p)
-		return -E2BIG;
+		return NFS4ERR_TOOSMALL;
 
 	p = exp_xdr_encode_u32(p, pol->olo_comps_index);
 	p = exp_xdr_encode_u32(p, pol->olo_num_comps);
@@ -168,13 +168,13 @@ int pnfs_osd_xdr_encode_layout_hdr(
 }
 EXPORT_SYMBOL(pnfs_osd_xdr_encode_layout_hdr);
 
-static int _encode_string(struct exp_xdr_stream *xdr,
+static enum nfsstat4 _encode_string(struct exp_xdr_stream *xdr,
 			  const struct nfs4_string *str)
 {
 	__be32 *p = exp_xdr_reserve_space(xdr, 4 + str->len);
 
 	if (!p)
-		return -E2BIG;
+		return NFS4ERR_TOOSMALL;
 	exp_xdr_encode_opaque(p, str->data, str->len);
 	return 0;
 }
@@ -188,15 +188,15 @@ static int _encode_string(struct exp_xdr_stream *xdr,
  * 	struct nfs4_string		oda_osdname;
  * };
  */
-int pnfs_osd_xdr_encode_deviceaddr(
+enum nfsstat4 pnfs_osd_xdr_encode_deviceaddr(
 	struct exp_xdr_stream *xdr, struct pnfs_osd_deviceaddr *devaddr)
 {
 	__be32 *p;
-	int err;
+	enum nfsstat4 err;
 
 	p = exp_xdr_reserve_space(xdr, 4 + 4 + sizeof(devaddr->oda_lun));
 	if (!p)
-		return -E2BIG;
+		return NFS4ERR_TOOSMALL;
 
 	/* Empty oda_targetid */
 	p = exp_xdr_encode_u32(p, OBJ_TARGET_ANON);
diff --git a/include/linux/nfsd/pnfs_osd_xdr_srv.h b/include/linux/nfsd/pnfs_osd_xdr_srv.h
index e9a2187..2909fbe 100644
--- a/include/linux/nfsd/pnfs_osd_xdr_srv.h
+++ b/include/linux/nfsd/pnfs_osd_xdr_srv.h
@@ -17,16 +17,16 @@
 #include <linux/exp_xdr.h>
 
 /* Layout encoding */
-int pnfs_osd_xdr_encode_layout_hdr(
+enum nfsstat4 pnfs_osd_xdr_encode_layout_hdr(
 	struct exp_xdr_stream *xdr,
 	struct pnfs_osd_layout *layout);
 
-int pnfs_osd_xdr_encode_layout_cred(
+enum nfsstat4 pnfs_osd_xdr_encode_layout_cred(
 	struct exp_xdr_stream *xdr,
 	struct pnfs_osd_object_cred *cred);
 
 /* deviceaddr encoding */
-int pnfs_osd_xdr_encode_deviceaddr(
+enum nfsstat4 pnfs_osd_xdr_encode_deviceaddr(
 	struct exp_xdr_stream *xdr, struct pnfs_osd_deviceaddr *devaddr);
 
 /* layout_commit decoding */
-- 
1.7.3.4


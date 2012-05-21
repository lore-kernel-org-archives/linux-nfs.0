Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wi0-f178.google.com ([209.85.212.178]:63430 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751543Ab2EUPXE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 May 2012 11:23:04 -0400
Received: by wibhn6 with SMTP id hn6so2535976wib.1
        for <linux-nfs@vger.kernel.org>; Mon, 21 May 2012 08:23:04 -0700 (PDT)
From: Benny Halevy <bhalevy@tonian.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] pnfsd: provide helper for xdr encoding of deviceid
Date: Mon, 21 May 2012 18:22:54 +0300
Message-Id: <1337613774-4011-1-git-send-email-bhalevy@tonian.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Benny Halevy <bhalevy@tonian.com>
---
 fs/exportfs/nfs4filelayoutxdr.c |    3 +--
 fs/nfsd/nfs4callback.c          |    3 +--
 fs/nfsd/nfs4xdr.c               |    2 +-
 include/linux/nfsd/nfsd4_pnfs.h |    7 +++++++
 4 files changed, 10 insertions(+), 5 deletions(-)

diff --git a/fs/exportfs/nfs4filelayoutxdr.c b/fs/exportfs/nfs4filelayoutxdr.c
index f63c311..e5b9a92 100644
--- a/fs/exportfs/nfs4filelayoutxdr.c
+++ b/fs/exportfs/nfs4filelayoutxdr.c
@@ -174,8 +174,7 @@ enum nfsstat4
 	p++;
 
 	/* encode device id */
-	p = exp_xdr_encode_u64(p, flp->device_id.sbid);
-	p = exp_xdr_encode_u64(p, flp->device_id.devid);
+	p = nfsd4_encode_deviceid(p, &flp->device_id);
 
 	/* set and encode flags */
 	nfl_util = flp->lg_stripe_unit;
diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index 8734ef0..0a37f3a 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -511,8 +511,7 @@ static void encode_cb_device4args(struct xdr_stream *xdr,
 		else
 			*p++ = cpu_to_be32(20);
 		*p++ = cpu_to_be32(cbd[i].cbd_layout_type);
-		p = xdr_encode_hyper(p, cbd[i].cbd_devid.sbid);
-		xdr_encode_hyper(p, cbd[i].cbd_devid.devid);
+		p = nfsd4_encode_deviceid(p, &cbd[i].cbd_devid);
 
 		if (cbd[i].cbd_notify_type == NOTIFY_DEVICEID4_CHANGE) {
 			p = xdr_reserve_space(xdr, 4);
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index d57ccb1..ee227f7 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -3641,7 +3641,7 @@ static __be32 nfsd4_encode_bind_conn_to_session(struct nfsd4_compoundres *resp,
 
 		/* Encode device id and layout type */
 		RESERVE_SPACE(sizeof(struct nfsd4_pnfs_deviceid));
-		WRITE64((__be64)sbid);
+		WRITE64(sbid);
 		WRITE64(res.gd_devid);	/* devid minor */
 		ADJUST_ARGS();
 		(*dev_count)++;
diff --git a/include/linux/nfsd/nfsd4_pnfs.h b/include/linux/nfsd/nfsd4_pnfs.h
index d5195b6..8d3d384 100644
--- a/include/linux/nfsd/nfsd4_pnfs.h
+++ b/include/linux/nfsd/nfsd4_pnfs.h
@@ -44,6 +44,13 @@ struct nfsd4_pnfs_deviceid {
 	u64	devid;			/* filesystem-wide unique device ID */
 };
 
+static inline __be32 *nfsd4_encode_deviceid(__be32 *p,
+					const struct nfsd4_pnfs_deviceid *dp)
+{
+        p = exp_xdr_encode_u64(p, dp->sbid);
+        return exp_xdr_encode_u64(p, dp->devid);
+}
+
 struct nfsd4_pnfs_dev_iter_res {
 	u64		gd_cookie;	/* request/repsonse */
 	u64		gd_verf;	/* request/repsonse */
-- 
1.7.6.5


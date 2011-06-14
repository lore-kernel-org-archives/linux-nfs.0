Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:38181 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754044Ab1FNVg5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 14 Jun 2011 17:36:57 -0400
From: Boaz Harrosh <bharrosh@panasas.com>
To: Benny Halevy <bhalevy@panasas.com>, open-osd <osd-dev@open-osd.org>,
        NFS list <linux-nfs@vger.kernel.org>
Subject: [PATCH 09/10] SQUASHME: pnfsd-exofs: Convert XDR API to return enum nfsstat4
Date: Tue, 14 Jun 2011 17:36:56 -0400
Message-Id: <1308087416-13293-1-git-send-email-bharrosh@panasas.com>
In-Reply-To: <4DF7D36F.9070602@panasas.com>
References: <4DF7D36F.9070602@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Remove error translation from export.c, now that XDR API returns
the proper constants

Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
---
 fs/exofs/export.c |   20 +++++++++-----------
 1 files changed, 9 insertions(+), 11 deletions(-)

diff --git a/fs/exofs/export.c b/fs/exofs/export.c
index 88be441..c153ad6 100644
--- a/fs/exofs/export.c
+++ b/fs/exofs/export.c
@@ -86,7 +86,7 @@ static enum nfsstat4 exofs_layout_get(
 	struct pnfs_osd_layout layout;
 	__be32 *start;
 	bool in_recall;
-	int i, err;
+	int i;
 	enum nfsstat4 nfserr;
 
 	res->lg_seg.offset = 0;
@@ -107,11 +107,9 @@ static enum nfsstat4 exofs_layout_get(
 	layout.olo_num_comps = el->s_numdevs;
 	layout.olo_comps = creds;
 
-	err = pnfs_osd_xdr_encode_layout_hdr(xdr, &layout);
-	if (err) {
-		nfserr = NFS4ERR_TOOSMALL;
+	nfserr = pnfs_osd_xdr_encode_layout_hdr(xdr, &layout);
+	if (unlikely(nfserr))
 		goto out;
-	}
 
 	/* Encode layout components */
 	for (i = 0; i < el->s_numdevs; i++) {
@@ -133,11 +131,9 @@ static enum nfsstat4 exofs_layout_get(
 
 		cred.oc_cap.cred_len	= OSD_CAP_LEN;
 		cred.oc_cap.cred	= oi->i_cred;
-		err = pnfs_osd_xdr_encode_layout_cred(xdr, &cred);
-		if (err) {
-			nfserr = NFS4ERR_TOOSMALL;
+		nfserr = pnfs_osd_xdr_encode_layout_cred(xdr, &cred);
+		if (unlikely(nfserr))
 			goto out;
-		}
 	}
 
 	exp_xdr_encode_opaque_len(start, xdr->p);
@@ -303,13 +299,15 @@ int exofs_get_device_info(struct super_block *sb, struct exp_xdr_stream *xdr,
 	/* skip opaque size, will be filled-in later */
 	start = exp_xdr_reserve_qwords(xdr, 1);
 	if (!start) {
-		err = -E2BIG;
+		err = -ETOOSMALL;
 		goto err;
 	}
 
 	err = pnfs_osd_xdr_encode_deviceaddr(xdr, &devaddr);
-	if (err)
+	if (err) {
+		err = -ETOOSMALL;
 		goto err;
+	}
 
 	exp_xdr_encode_opaque_len(start, xdr->p);
 
-- 
1.7.3.4


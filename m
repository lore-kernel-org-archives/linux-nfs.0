Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:38171 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753956Ab1FNVgt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 14 Jun 2011 17:36:49 -0400
From: Boaz Harrosh <bharrosh@panasas.com>
To: Benny Halevy <bhalevy@panasas.com>, open-osd <osd-dev@open-osd.org>,
        NFS list <linux-nfs@vger.kernel.org>
Subject: [PATCH 08/10] SQUASHME: pnfsd-exofs: layout encoding was Changed to two pass
Date: Tue, 14 Jun 2011 17:36:48 -0400
Message-Id: <1308087408-13265-1-git-send-email-bharrosh@panasas.com>
In-Reply-To: <4DF7D36F.9070602@panasas.com>
References: <4DF7D36F.9070602@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

This way there is No need for dynamic allocation of the creds
array.

Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
---
 fs/exofs/export.c |   55 ++++++++++++++++++++++++++---------------------------
 1 files changed, 27 insertions(+), 28 deletions(-)

diff --git a/fs/exofs/export.c b/fs/exofs/export.c
index 616cf5d..14852d8 100644
--- a/fs/exofs/export.c
+++ b/fs/exofs/export.c
@@ -70,44 +70,43 @@ static enum nfsstat4 exofs_layout_get(
 		goto out;
 	}
 
-	creds = kcalloc(el->s_numdevs, sizeof(*creds), GFP_KERNEL);
-	if (!creds) {
-		nfserr = NFS4ERR_LAYOUTTRYLATER;
-		goto out;
-	}
-
 	/* Fill in a pnfs_osd_layout struct */
 	layout.olo_map = sbi->data_map;
+	layout.olo_comps_index = 0;
+	layout.olo_num_comps = el->s_numdevs;
+	layout.olo_comps = creds;
+
+	err = pnfs_osd_xdr_encode_layout_hdr(xdr, &layout);
+	if (err) {
+		nfserr = NFS4ERR_TOOSMALL;
+		goto out;
+	}
 
+	/* Encode layout components */
 	for (i = 0; i < el->s_numdevs; i++) {
-		struct pnfs_osd_object_cred *cred = &creds[i];
+		struct pnfs_osd_object_cred cred;
 		osd_id id = exofs_oi_objno(oi);
 		unsigned dev = exofs_layout_od_id(el, id, i);
 
-		set_dev_id(&cred->oc_object_id.oid_device_id, args->lg_sbid,
+		set_dev_id(&cred.oc_object_id.oid_device_id, args->lg_sbid,
 			   dev);
-		cred->oc_object_id.oid_partition_id = el->s_pid;
-		cred->oc_object_id.oid_object_id = id;
-		cred->oc_osd_version = osd_dev_is_ver1(el->s_ods[dev]) ?
+		cred.oc_object_id.oid_partition_id = el->s_pid;
+		cred.oc_object_id.oid_object_id = id;
+		cred.oc_osd_version = osd_dev_is_ver1(el->s_ods[dev]) ?
 						PNFS_OSD_VERSION_1 :
 						PNFS_OSD_VERSION_2;
-		cred->oc_cap_key_sec = PNFS_OSD_CAP_KEY_SEC_NONE;
-
-		cred->oc_cap_key.cred_len	= 0;
-		cred->oc_cap_key.cred		= NULL;
+		cred.oc_cap_key_sec = PNFS_OSD_CAP_KEY_SEC_NONE;
 
-		cred->oc_cap.cred_len	= OSD_CAP_LEN;
-		cred->oc_cap.cred	= oi->i_cred;
-	}
-
-	layout.olo_comps_index = 0;
-	layout.olo_num_comps = el->s_numdevs;
-	layout.olo_comps = creds;
+		cred.oc_cap_key.cred_len	= 0;
+		cred.oc_cap_key.cred		= NULL;
 
-	err = pnfs_osd_xdr_encode_layout(xdr, &layout);
-	if (err) {
-		nfserr = NFS4ERR_TOOSMALL; /* FIXME: Change osd_xdr error codes */
-		goto out;
+		cred.oc_cap.cred_len	= OSD_CAP_LEN;
+		cred.oc_cap.cred	= oi->i_cred;
+		err = pnfs_osd_xdr_encode_layout_cred(xdr, &cred);
+		if (err) {
+			nfserr = NFS4ERR_TOOSMALL;
+			goto out;
+		}
 	}
 
 	exp_xdr_encode_opaque_len(start, xdr->p);
-- 
1.7.3.4


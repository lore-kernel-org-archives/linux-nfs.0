Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wi0-f181.google.com ([209.85.212.181]:48228 "EHLO
	mail-wi0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756823Ab3EKCnY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 10 May 2013 22:43:24 -0400
Received: by mail-wi0-f181.google.com with SMTP id ey16so1208820wid.2
        for <linux-nfs@vger.kernel.org>; Fri, 10 May 2013 19:43:23 -0700 (PDT)
Received: from bhalevy-lt.il.tonian.com (bzq-79-180-144-28.red.bezeqint.net. [79.180.144.28])
        by mx.google.com with ESMTPSA id je7sm1166950wic.9.2013.05.10.19.43.22
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 10 May 2013 19:43:22 -0700 (PDT)
From: Benny Halevy <bhalevy@tonian.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 13/38] Revert "pnfsd: set_device_notify"
Date: Sat, 11 May 2013 05:43:18 +0300
Message-Id: <1368240198-32225-1-git-send-email-bhalevy@tonian.com>
In-Reply-To: <518B6377.3000207@tonian.com>
References: <518B6377.3000207@tonian.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This reverts commit e31921a7fa0a13119e359b8ec200fb4047c0527f.
---
 fs/nfsd/nfs4xdr.c               | 37 +++++++++++++------------------------
 include/linux/nfsd/nfsd4_pnfs.h | 10 ----------
 2 files changed, 13 insertions(+), 34 deletions(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 596a2a5..b157eae 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -3766,8 +3766,15 @@ static __be32 nfsd4_encode_bind_conn_to_session(struct nfsd4_compoundres *resp,
 
 	nfserr = sb->s_pnfs_op->get_device_info(sb, &xdr, gdev->gd_layout_type,
 						&gdev->gd_devid);
-	if (nfserr)
-		goto err;
+	if (nfserr) {
+		/* Rewind to the beginning */
+		p = p_in;
+		ADJUST_ARGS();
+		if (nfserr == -ETOOSMALL)
+			goto toosmall;
+		printk(KERN_ERR "%s: export ERROR %d\n", __func__, nfserr);
+		goto out;
+	}
 
 	/* The file system should never write 0 bytes without
 	 * returning an error
@@ -3782,21 +3789,11 @@ static __be32 nfsd4_encode_bind_conn_to_session(struct nfsd4_compoundres *resp,
 	ADJUST_ARGS();
 
 handle_notifications:
-	/* Encode supported device notifications */
+	/* Encode supported device notifications.
+	 * Note: Currently none are supported.
+	 */
 	RESERVE_SPACE(4);
-	if (sb->s_pnfs_op->set_device_notify) {
-		struct pnfs_devnotify_arg dn_args;
-
-		dn_args.dn_layout_type = gdev->gd_layout_type;
-		dn_args.dn_devid = gdev->gd_devid;
-		dn_args.dn_notify_types = gdev->gd_notify_types;
-		nfserr = sb->s_pnfs_op->set_device_notify(sb, &dn_args);
-		if (nfserr)
-			goto err;
-		WRITE32(dn_args.dn_notify_types);
-	} else {
-		WRITE32(0);
-	}
+	WRITE32(0);
 	ADJUST_ARGS();
 
 out:
@@ -3807,14 +3804,6 @@ static __be32 nfsd4_encode_bind_conn_to_session(struct nfsd4_compoundres *resp,
 	WRITE32((p_save ? (xdr.p - p_save) * 4 : 0) + type_notify_len);
 	ADJUST_ARGS();
 	goto out;
-err:
-	/* Rewind to the beginning */
-	p = p_in;
-	ADJUST_ARGS();
-	if (nfserr == -ETOOSMALL)
-		goto toosmall;
-	printk(KERN_ERR "%s: export ERROR %d\n", __func__, nfserr);
-	goto out;
 }
 
 static __be32
diff --git a/include/linux/nfsd/nfsd4_pnfs.h b/include/linux/nfsd/nfsd4_pnfs.h
index d86e1b7..a49d5f6 100644
--- a/include/linux/nfsd/nfsd4_pnfs.h
+++ b/include/linux/nfsd/nfsd4_pnfs.h
@@ -58,13 +58,6 @@ struct nfsd4_pnfs_dev_iter_res {
 	u32		gd_eof;		/* response */
 };
 
-/* Arguments for set_device_notify */
-struct pnfs_devnotify_arg {
-	struct nfsd4_pnfs_deviceid dn_devid;	/* request */
-	u32 dn_layout_type;			/* request */
-	u32 dn_notify_types;			/* request/response */
-};
-
 struct nfsd4_layout_seg {
 	u64	clientid;
 	u32	layout_type;
@@ -160,9 +153,6 @@ struct pnfs_export_operations {
 				u32 layout_type,
 				struct nfsd4_pnfs_dev_iter_res *);
 
-	int (*set_device_notify) (struct super_block *,
-				  struct pnfs_devnotify_arg *);
-
 	/* Retrieve and encode a layout for inode onto the xdr stream.
 	 * arg->minlength is the minimum number of accessible bytes required
 	 *   by the client.
-- 
1.7.11.7


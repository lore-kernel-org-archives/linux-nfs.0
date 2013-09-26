Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qe0-f52.google.com ([209.85.128.52]:41957 "EHLO
	mail-qe0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753047Ab3IZSkw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Sep 2013 14:40:52 -0400
Received: by mail-qe0-f52.google.com with SMTP id i11so1082535qej.25
        for <linux-nfs@vger.kernel.org>; Thu, 26 Sep 2013 11:40:51 -0700 (PDT)
From: Benny Halevy <bhalevy@primarydata.com>
To: " J. Bruce Fields" <bfields@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH RFC v0 14/49] pnfsd: provide helper for xdr encoding of deviceid
Date: Thu, 26 Sep 2013 14:40:48 -0400
Message-Id: <1380220848-13325-1-git-send-email-bhalevy@primarydata.com>
In-Reply-To: <52447EA0.7070004@primarydata.com>
References: <52447EA0.7070004@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Benny Halevy <bhalevy@primarydata.com>
---
 include/linux/nfsd/nfsd4_pnfs.h | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/include/linux/nfsd/nfsd4_pnfs.h b/include/linux/nfsd/nfsd4_pnfs.h
index 53a0bb7..28f9daa 100644
--- a/include/linux/nfsd/nfsd4_pnfs.h
+++ b/include/linux/nfsd/nfsd4_pnfs.h
@@ -42,6 +42,13 @@ struct nfsd4_pnfs_deviceid {
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
1.8.3.1


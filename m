Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ey0-f174.google.com ([209.85.215.174]:45461 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753679Ab1LDNuZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 4 Dec 2011 08:50:25 -0500
Received: by mail-ey0-f174.google.com with SMTP id k14so3593300eaa.19
        for <linux-nfs@vger.kernel.org>; Sun, 04 Dec 2011 05:50:24 -0800 (PST)
From: Benny Halevy <benny@tonian.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 12/13] DEBUG: pnfs: printouts
Date: Sun,  4 Dec 2011 15:50:18 +0200
Message-Id: <1323006618-13925-1-git-send-email-benny@tonian.com>
In-Reply-To: <4EDB79A9.2080109@tonian.com>
References: <4EDB79A9.2080109@tonian.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Benny Halevy <bhalevy@tonian.com>

---
 fs/nfs/nfs4xdr.c |    2 ++
 fs/nfs/pnfs.c    |    4 +++-
 2 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index e6161b2..0bda77e 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -4448,6 +4448,7 @@ static int decode_first_pnfs_layout_type(struct xdr_stream *xdr,
 
 	/* pNFS is not supported by the underlying file system */
 	if (num == 0) {
+		dprintk("%s: num=0\n", __func__);
 		*layouttype = 0;
 		return 0;
 	}
@@ -4460,6 +4461,7 @@ static int decode_first_pnfs_layout_type(struct xdr_stream *xdr,
 	if (unlikely(!p))
 		goto out_overflow;
 	*layouttype = be32_to_cpup(p);
+	dprintk("%s: layouttype=0x%x\n", __func__, *layouttype);
 	return 0;
 out_overflow:
 	print_overflow_msg(__func__, xdr);
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index baf7353..61778c9 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -97,8 +97,10 @@
 {
 	struct pnfs_layoutdriver_type *ld_type = NULL;
 
-	if (id == 0)
+	if (id == 0) {
+		dprintk("%s: layout type %u\n", __func__, id);
 		goto out_no_driver;
+	}
 	if (!(server->nfs_client->cl_exchange_flags &
 		 (EXCHGID4_FLAG_USE_NON_PNFS | EXCHGID4_FLAG_USE_PNFS_MDS))) {
 		printk(KERN_ERR "%s: id %u cl_exchange_flags 0x%x\n", __func__,
-- 
1.7.6


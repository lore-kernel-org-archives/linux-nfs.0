Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-we0-f174.google.com ([74.125.82.174]:64166 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752563Ab2EUPg2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 May 2012 11:36:28 -0400
Received: by weyu7 with SMTP id u7so3270264wey.19
        for <linux-nfs@vger.kernel.org>; Mon, 21 May 2012 08:36:27 -0700 (PDT)
From: Benny Halevy <bhalevy@tonian.com>
To: bharrosh@panasas.com
Cc: linux-nfs@vger.kernel.org, Benny Halevy <bhalevy@tonian.com>
Subject: [PATCH 2/2] pnfsd-exofs: use nfsd4_encode_deviceid
Date: Mon, 21 May 2012 18:36:22 +0300
Message-Id: <1337614582-3548-1-git-send-email-bhalevy@tonian.com>
In-Reply-To: <1337613774-4011-1-git-send-email-bhalevy@tonian.com>
References: <1337613774-4011-1-git-send-email-bhalevy@tonian.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Benny Halevy <bhalevy@tonian.com>
---
 fs/exportfs/pnfs_osd_xdr_srv.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/fs/exportfs/pnfs_osd_xdr_srv.c b/fs/exportfs/pnfs_osd_xdr_srv.c
index d0795c44..04a3681 100644
--- a/fs/exportfs/pnfs_osd_xdr_srv.c
+++ b/fs/exportfs/pnfs_osd_xdr_srv.c
@@ -88,8 +88,7 @@ static inline enum nfsstat4 pnfs_osd_xdr_encode_objid(
 	if (!p)
 		return NFS4ERR_TOOSMALL;
 
-	p = exp_xdr_encode_u64(p, dev_id->sbid);
-	p = exp_xdr_encode_u64(p, dev_id->devid);
+	p = nfsd4_encode_deviceid(p, dev_id);
 	p = exp_xdr_encode_u64(p, object_id->oid_partition_id);
 	p = exp_xdr_encode_u64(p, object_id->oid_object_id);
 
-- 
1.7.6.5


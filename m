Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:38098 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753956Ab1FNVfw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 14 Jun 2011 17:35:52 -0400
From: Boaz Harrosh <bharrosh@panasas.com>
To: Benny Halevy <bhalevy@panasas.com>, open-osd <osd-dev@open-osd.org>,
        NFS list <linux-nfs@vger.kernel.org>
Subject: [PATCH 01/10] SQUASHME: pnfsd-exofs xdr_srv: Wrong type in comments
Date: Tue, 14 Jun 2011 17:35:51 -0400
Message-Id: <1308087351-13067-1-git-send-email-bharrosh@panasas.com>
In-Reply-To: <4DF7D36F.9070602@panasas.com>
References: <4DF7D36F.9070602@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Boaz
---
 fs/exportfs/pnfs_osd_xdr_srv.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/exportfs/pnfs_osd_xdr_srv.c b/fs/exportfs/pnfs_osd_xdr_srv.c
index fc7d805..444798c 100644
--- a/fs/exportfs/pnfs_osd_xdr_srv.c
+++ b/fs/exportfs/pnfs_osd_xdr_srv.c
@@ -71,7 +71,7 @@ static int pnfs_osd_xdr_encode_data_map(
 
 /*
  * struct pnfs_osd_objid {
- * 	struct pnfs_deviceid	oid_device_id;
+ * 	struct nfs4_deviceid	oid_device_id;
  * 	u64			oid_partition_id;
  * 	u64			oid_object_id;
  * };
@@ -249,7 +249,7 @@ EXPORT_SYMBOL(pnfs_osd_xdr_decode_layoutupdate);
 
 /*
  * struct pnfs_osd_objid {
- * 	struct pnfs_deviceid	oid_device_id;
+ * 	struct nfs4_deviceid	oid_device_id;
  * 	u64			oid_partition_id;
  * 	u64			oid_object_id;
  * }; xdr size 32
-- 
1.7.3.4


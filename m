Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:46746 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754346Ab1EXPGy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 24 May 2011 11:06:54 -0400
From: Boaz Harrosh <bharrosh@panasas.com>
To: Benny Halevy <bhalevy@panasas.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        NFS list <linux-nfs@vger.kernel.org>
Subject: [PATCH 06/12] SQUASHME: pnf-obj xdr_cli: Wrong type in comments
Date: Tue, 24 May 2011 18:06:23 +0300
Message-Id: <1306249583-23333-1-git-send-email-bharrosh@panasas.com>
In-Reply-To: <4DDBC611.3050202@panasas.com>
References: <4DDBC611.3050202@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
---
 fs/nfs/objlayout/pnfs_osd_xdr_cli.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/objlayout/pnfs_osd_xdr_cli.c b/fs/nfs/objlayout/pnfs_osd_xdr_cli.c
index dd3052c..16fc758 100644
--- a/fs/nfs/objlayout/pnfs_osd_xdr_cli.c
+++ b/fs/nfs/objlayout/pnfs_osd_xdr_cli.c
@@ -47,7 +47,7 @@
 
 /*
  * struct pnfs_osd_objid {
- *	struct pnfs_deviceid	oid_device_id;
+ *	struct nfs4_deviceid	oid_device_id;
  *	u64			oid_partition_id;
  *	u64			oid_object_id;
  * }; // xdr size 32 bytes
@@ -366,7 +366,7 @@ pnfs_osd_xdr_encode_layoutupdate(struct xdr_stream *xdr,
 
 /*
  * struct pnfs_osd_objid {
- *	struct pnfs_deviceid	oid_device_id;
+ *	struct nfs4_deviceid	oid_device_id;
  *	u64			oid_partition_id;
  *	u64			oid_object_id;
  * }; // xdr size 32 bytes
-- 
1.7.2.3


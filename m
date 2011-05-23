Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:17549 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932223Ab1EWTqe (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 23 May 2011 15:46:34 -0400
Message-ID: <4DDAB984.7030901@panasas.com>
Date: Mon, 23 May 2011 22:46:12 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
To: Benny Halevy <bhalevy@panasas.com>
CC: Trond Myklebust <Trond.Myklebust@netapp.com>, linux-nfs@vger.kernel.org
Subject: [PATCH] SQUASHME: pnf-obj xdr_cli: Wrong type in comments
References: <4DDA8C3D.5080706@panasas.com> <1306168614-11427-1-git-send-email-bhalevy@panasas.com>
In-Reply-To: <1306168614-11427-1-git-send-email-bhalevy@panasas.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
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



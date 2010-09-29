Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:58547 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753420Ab0I2LM4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 29 Sep 2010 07:12:56 -0400
From: Benny Halevy <bhalevy@panasas.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 18/18] SQUASHME: pnfsd-exofs: convert to new pnfs-submit changes
Date: Wed, 29 Sep 2010 13:12:53 +0200
Message-Id: <1285758773-27381-1-git-send-email-bhalevy@panasas.com>
In-Reply-To: <4CA31DC3.8070300@panasas.com>
References: <4CA31DC3.8070300@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/exofs/export.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/exofs/export.c b/fs/exofs/export.c
index fe2c3a7..69bce46 100644
--- a/fs/exofs/export.c
+++ b/fs/exofs/export.c
@@ -32,7 +32,7 @@ static int exofs_layout_type(struct super_block *sb)
 	return LAYOUT_OSD2_OBJECTS;
 }
 
-static void set_dev_id(struct pnfs_deviceid *pnfs_devid, u64 sbid, u64 devid)
+static void set_dev_id(struct nfs4_deviceid *pnfs_devid, u64 sbid, u64 devid)
 {
 	struct nfsd4_pnfs_deviceid *dev_id =
 		(struct nfsd4_pnfs_deviceid *)pnfs_devid;
-- 
1.7.2.3


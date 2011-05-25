Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:57072 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752869Ab1EYV0t (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 25 May 2011 17:26:49 -0400
From: Benny Halevy <bhalevy@panasas.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Boaz Harrosh <bharrosh@panasas.com>, linux-nfs@vger.kernel.org
Subject: [PATCH v8 03/32] pnfs: resolve header dependency in pnfs.h
Date: Thu, 26 May 2011 00:26:46 +0300
Message-Id: <1306358806-16894-1-git-send-email-bhalevy@panasas.com>
In-Reply-To: <4DDD7392.6040505@panasas.com>
References: <4DDD7392.6040505@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Some definitions in the header file depend on nfs_fs.h so pnfs.h can't
be included independently.

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/pnfs.h |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 0c015ba..720bb9d 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -30,6 +30,7 @@
 #ifndef FS_NFS_PNFS_H
 #define FS_NFS_PNFS_H
 
+#include <linux/nfs_fs.h>
 #include <linux/nfs_page.h>
 
 enum {
-- 
1.7.3.4


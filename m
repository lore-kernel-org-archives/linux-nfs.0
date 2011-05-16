Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:34578 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750976Ab1EPQVY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 16 May 2011 12:21:24 -0400
From: Benny Halevy <bhalevy@panasas.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org, bharrosh@panasas.com
Subject: [PATCH v3 06/29] pnfs: resolve header dependency in pnfs.h
Date: Mon, 16 May 2011 09:21:20 -0700
Message-Id: <1305562880-7431-1-git-send-email-bhalevy@panasas.com>
In-Reply-To: <4DD14D8E.1070701@panasas.com>
References: <4DD14D8E.1070701@panasas.com>
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
index 02ef40c..006314e 100644
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


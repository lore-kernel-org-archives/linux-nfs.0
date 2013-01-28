Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ia0-f169.google.com ([209.85.210.169]:37282 "EHLO
	mail-ia0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753963Ab3A1Ube (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 28 Jan 2013 15:31:34 -0500
Received: by mail-ia0-f169.google.com with SMTP id j5so4964672iaf.0
        for <linux-nfs@vger.kernel.org>; Mon, 28 Jan 2013 12:31:32 -0800 (PST)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 1 1/5] NFS: Remove unneeded forward declaration
To: linux-nfs@vger.kernel.org
Cc: Chuck Lever <chuck.lever@oracle.com>
Date: Mon, 28 Jan 2013 15:31:31 -0500
Message-ID: <20130128203131.2523.51442.stgit@seurat.1015granger.net>
In-Reply-To: <20130128195843.2523.34798.stgit@seurat.1015granger.net>
References: <20130128195843.2523.34798.stgit@seurat.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I've built with NFSv4 enabled and disabled.  This forward
declaration does not seem to be required.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 include/linux/nfs_xdr.h |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 29adb12..467167402 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -14,9 +14,6 @@
 #define NFS_DEF_FILE_IO_SIZE	(4096U)
 #define NFS_MIN_FILE_IO_SIZE	(1024U)
 
-/* Forward declaration for NFS v3 */
-struct nfs4_secinfo_flavors;
-
 struct nfs4_string {
 	unsigned int len;
 	char *data;


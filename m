Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f169.google.com ([209.85.223.169]:61655 "EHLO
	mail-ie0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756418Ab3A3XmS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 30 Jan 2013 18:42:18 -0500
Received: by mail-ie0-f169.google.com with SMTP id c14so1827408ieb.14
        for <linux-nfs@vger.kernel.org>; Wed, 30 Jan 2013 15:42:17 -0800 (PST)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH v2 2/9] NFS: Remove unneeded forward declaration
To: linux-nfs@vger.kernel.org
Cc: Chuck Lever <chuck.lever@oracle.com>
Date: Wed, 30 Jan 2013 18:42:16 -0500
Message-ID: <20130130234216.47786.8964.stgit@seurat.1015granger.net>
In-Reply-To: <20130130231546.47786.6016.stgit@seurat.1015granger.net>
References: <20130130231546.47786.6016.stgit@seurat.1015granger.net>
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


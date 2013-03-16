Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f182.google.com ([209.85.223.182]:53870 "EHLO
	mail-ie0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751240Ab3CPTy1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 16 Mar 2013 15:54:27 -0400
Received: by mail-ie0-f182.google.com with SMTP id k14so5623141iea.41
        for <linux-nfs@vger.kernel.org>; Sat, 16 Mar 2013 12:54:27 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH v1 02/15] NFS: Remove unneeded forward declaration
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Chuck Lever <chuck.lever@oracle.com>
Date: Sat, 16 Mar 2013 15:54:25 -0400
Message-ID: <20130316195425.27329.28528.stgit@seurat.1015granger.net>
In-Reply-To: <20130316195044.27329.11666.stgit@seurat.1015granger.net>
References: <20130316195044.27329.11666.stgit@seurat.1015granger.net>
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
index 4b993d3..94b0406 100644
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


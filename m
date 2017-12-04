Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:43593 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752524AbdLDTNc (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 4 Dec 2017 14:13:32 -0500
Subject: [PATCH v1 1/4] nfs: Define NFS_RDMA_PORT
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 04 Dec 2017 14:13:30 -0500
Message-ID: <20171204191330.18629.77069.stgit@manet.1015granger.net>
In-Reply-To: <20171204190904.18629.70341.stgit@manet.1015granger.net>
References: <20171204190904.18629.70341.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The NFS/RDMA port assignment is specified in Section 9 of RFC 8267.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 include/uapi/linux/nfs.h |    1 +
 1 file changed, 1 insertion(+)

diff --git a/include/uapi/linux/nfs.h b/include/uapi/linux/nfs.h
index 057d22a..946cb62 100644
--- a/include/uapi/linux/nfs.h
+++ b/include/uapi/linux/nfs.h
@@ -12,6 +12,7 @@
 
 #define NFS_PROGRAM	100003
 #define NFS_PORT	2049
+#define NFS_RDMA_PORT	20049
 #define NFS_MAXDATA	8192
 #define NFS_MAXPATHLEN	1024
 #define NFS_MAXNAMLEN	255


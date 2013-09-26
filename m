Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qe0-f41.google.com ([209.85.128.41]:54417 "EHLO
	mail-qe0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752808Ab3IZSkB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Sep 2013 14:40:01 -0400
Received: by mail-qe0-f41.google.com with SMTP id 1so1114675qee.14
        for <linux-nfs@vger.kernel.org>; Thu, 26 Sep 2013 11:40:01 -0700 (PDT)
From: Benny Halevy <bhalevy@primarydata.com>
To: " J. Bruce Fields" <bfields@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH RFC v0 02/49] pnfsd: define NFSDDBG_PNFS
Date: Thu, 26 Sep 2013 14:39:58 -0400
Message-Id: <1380220798-12766-1-git-send-email-bhalevy@primarydata.com>
In-Reply-To: <52447EA0.7070004@primarydata.com>
References: <52447EA0.7070004@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Benny Halevy <bhalevy@panasas.com>

[extraced from pnfsd: Initial pNFS server implementation.]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
Signed-off-by: Benny Halevy <bhalevy@primarydata.com>
---
 include/uapi/linux/nfsd/debug.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/include/uapi/linux/nfsd/debug.h b/include/uapi/linux/nfsd/debug.h
index a6f453c..168f3a3 100644
--- a/include/uapi/linux/nfsd/debug.h
+++ b/include/uapi/linux/nfsd/debug.h
@@ -32,6 +32,7 @@
 #define NFSDDBG_REPCACHE	0x0080
 #define NFSDDBG_XDR		0x0100
 #define NFSDDBG_LOCKD		0x0200
+#define NFSDDBG_PNFS		0x0400
 #define NFSDDBG_ALL		0x7FFF
 #define NFSDDBG_NOCHANGE	0xFFFF
 
-- 
1.8.3.1


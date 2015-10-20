Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:32897 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751666AbbJTLT2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Oct 2015 07:19:28 -0400
Received: by pabrc13 with SMTP id rc13so19042872pab.0
        for <linux-nfs@vger.kernel.org>; Tue, 20 Oct 2015 04:19:27 -0700 (PDT)
From: Peng Tao <tao.peng@primarydata.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Peng Tao <tao.peng@primarydata.com>
Subject: [PATCH] nfs: add missing linux/types.h
Date: Wed, 21 Oct 2015 03:18:16 +0800
Message-Id: <1445368696-10315-1-git-send-email-tao.peng@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

After merging the nfs tree, today's linux-next build (powerpc allyesconfig
produced this warning:

./usr/include/linux/nfs.h:40: found __[us]{8,16,32,64} type without #include <linux/types.h>

Reported-by: Stephen Rothwell <sfr@canb.auug.org.au>
Signed-off-by: Peng Tao <tao.peng@primarydata.com>
---
 include/uapi/linux/nfs.h | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/include/uapi/linux/nfs.h b/include/uapi/linux/nfs.h
index c6b86cc..654bae3 100644
--- a/include/uapi/linux/nfs.h
+++ b/include/uapi/linux/nfs.h
@@ -7,6 +7,8 @@
 #ifndef _UAPI_LINUX_NFS_H
 #define _UAPI_LINUX_NFS_H
 
+#include <linux/types.h>
+
 #define NFS_PROGRAM	100003
 #define NFS_PORT	2049
 #define NFS_MAXDATA	8192
-- 
1.8.3.1


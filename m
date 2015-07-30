Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pd0-f175.google.com ([209.85.192.175]:33234 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751301AbbG3Nny (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 30 Jul 2015 09:43:54 -0400
Received: by pdbnt7 with SMTP id nt7so24946687pdb.0
        for <linux-nfs@vger.kernel.org>; Thu, 30 Jul 2015 06:43:54 -0700 (PDT)
Message-ID: <55BA2A0C.1010303@gmail.com>
Date: Thu, 30 Jul 2015 21:43:40 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: Trond Myklebust <trond.myklebust@primarydata.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        kinglongmee@gmail.com
Subject: [PATCH 5/7 v2] NFS: Update NFS4_BITMAP_SIZE
References: <55BA290B.2020704@gmail.com>
In-Reply-To: <55BA290B.2020704@gmail.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

v4.1/v4.2 have define attributes at word2, nfs client also support
security label now.

v2, new one.

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 include/uapi/linux/nfs4.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/uapi/linux/nfs4.h b/include/uapi/linux/nfs4.h
index 2119c7c..2b871e0 100644
--- a/include/uapi/linux/nfs4.h
+++ b/include/uapi/linux/nfs4.h
@@ -15,7 +15,7 @@
 
 #include <linux/types.h>
 
-#define NFS4_BITMAP_SIZE	2
+#define NFS4_BITMAP_SIZE	3
 #define NFS4_VERIFIER_SIZE	8
 #define NFS4_STATEID_SEQID_SIZE 4
 #define NFS4_STATEID_OTHER_SIZE 12
-- 
2.4.3


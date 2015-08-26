Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:35881 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756143AbbHZNMZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 26 Aug 2015 09:12:25 -0400
Received: by pacgr6 with SMTP id gr6so8817196pac.3
        for <linux-nfs@vger.kernel.org>; Wed, 26 Aug 2015 06:12:25 -0700 (PDT)
Subject: [PATCH 3/5 v3] NFS: Update NFS4_BITMAP_SIZE
To: Trond Myklebust <trond.myklebust@primarydata.com>
References: <55DDBA9E.1040008@gmail.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        kinglongmee@gmail.com
From: Kinglong Mee <kinglongmee@gmail.com>
Message-ID: <55DDBB2F.7010100@gmail.com>
Date: Wed, 26 Aug 2015 21:12:15 +0800
MIME-Version: 1.0
In-Reply-To: <55DDBA9E.1040008@gmail.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

v4.1/v4.2 have define attributes at word2, nfs client also support
security label now.

v3, same as v2.

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


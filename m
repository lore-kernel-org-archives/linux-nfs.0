Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:63974 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751707Ab3KDUvX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 4 Nov 2013 15:51:23 -0500
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Linux NFS <linux-nfs@vger.kernel.org>
CC: J Bruce Fields <bfields@fieldses.org>, Steve Dickson <steved@redhat.com>,
        Jeff Layton <jlayton@redhat.com>,
        David Quigley <dpquigl@davequigley.com>
Subject: [PATCH 1/5] NFSv4.2: Fix a mismatch between Linux labeled NFS and the NFSv4.2 spec
Date: Mon, 4 Nov 2013 15:51:08 -0500
Message-ID: <1383598272-17737-1-git-send-email-Trond.Myklebust@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In the spec, the security label attribute id is '80', which means that
it should be bit number 80-64 == 16 in the 3rd word of the bitmap.

Fixes: 4488cc96c581: NFS: Add NFSv4.2 protocol constants
Cc: J. Bruce Fields <bfields@fieldses.org>
Cc: Steve Dickson <steved@redhat.com>
Cc: stable@vger.kernel.org # 3.11+
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 include/linux/nfs4.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
index c56fa8fedce9..bfe6c379a24e 100644
--- a/include/linux/nfs4.h
+++ b/include/linux/nfs4.h
@@ -395,7 +395,7 @@ enum lock_type4 {
 #define FATTR4_WORD1_FS_LAYOUT_TYPES    (1UL << 30)
 #define FATTR4_WORD2_LAYOUT_BLKSIZE     (1UL << 1)
 #define FATTR4_WORD2_MDSTHRESHOLD       (1UL << 4)
-#define FATTR4_WORD2_SECURITY_LABEL     (1UL << 17)
+#define FATTR4_WORD2_SECURITY_LABEL     (1UL << 16)
 
 /* MDS threshold bitmap bits */
 #define THRESHOLD_RD                    (1UL << 0)
-- 
1.8.3.1


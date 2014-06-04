Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:40031 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751362AbaFDVe5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 4 Jun 2014 17:34:57 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 4/4] nfs4: remove unused CHANGE_SECURITY_LABEL
Date: Wed,  4 Jun 2014 17:34:55 -0400
Message-Id: <1401917695-8309-5-git-send-email-bfields@redhat.com>
In-Reply-To: <1401917695-8309-1-git-send-email-bfields@redhat.com>
References: <1401917695-8309-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

This constant has the wrong value.  And we don't use it.  And it's been
removed from the 4.2 spec anyway.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfs/nfs4proc.c    |    2 +-
 include/linux/nfs4.h |    2 --
 2 files changed, 1 insertion(+), 3 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 397be39..7f55fed 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2750,7 +2750,7 @@ static void nfs4_close_context(struct nfs_open_context *ctx, int is_sync)
 
 #define FATTR4_WORD1_NFS40_MASK (2*FATTR4_WORD1_MOUNTED_ON_FILEID - 1UL)
 #define FATTR4_WORD2_NFS41_MASK (2*FATTR4_WORD2_SUPPATTR_EXCLCREAT - 1UL)
-#define FATTR4_WORD2_NFS42_MASK (2*FATTR4_WORD2_CHANGE_SECURITY_LABEL - 1UL)
+#define FATTR4_WORD2_NFS42_MASK (2*FATTR4_WORD2_SECURITY_LABEL - 1UL)
 
 static int _nfs4_server_capabilities(struct nfs_server *server, struct nfs_fh *fhandle)
 {
diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
index 12c2cb9..a1e3064 100644
--- a/include/linux/nfs4.h
+++ b/include/linux/nfs4.h
@@ -399,8 +399,6 @@ enum lock_type4 {
 #define FATTR4_WORD2_LAYOUT_BLKSIZE     (1UL << 1)
 #define FATTR4_WORD2_MDSTHRESHOLD       (1UL << 4)
 #define FATTR4_WORD2_SECURITY_LABEL     (1UL << 16)
-#define FATTR4_WORD2_CHANGE_SECURITY_LABEL \
-					(1UL << 17)
 
 /* MDS threshold bitmap bits */
 #define THRESHOLD_RD                    (1UL << 0)
-- 
1.7.9.5


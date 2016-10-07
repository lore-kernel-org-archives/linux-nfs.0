Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:33198 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752557AbcJGTB3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 7 Oct 2016 15:01:29 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 1/2] nfsd: only WARN once on unmapped errors
Date: Fri,  7 Oct 2016 15:01:26 -0400
Message-Id: <1475866887-26734-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

No need to spam the logs here.

The only drawback is losing information if we ever encounter two
different unmapped errors, but in practice we've rarely see even one.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfsproc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfsd/nfsproc.c b/fs/nfsd/nfsproc.c
index e9214768cde9..a56ee10204d9 100644
--- a/fs/nfsd/nfsproc.c
+++ b/fs/nfsd/nfsproc.c
@@ -798,7 +798,7 @@ nfserrno (int errno)
 		if (nfs_errtbl[i].syserr == errno)
 			return nfs_errtbl[i].nfserr;
 	}
-	WARN(1, "nfsd: non-standard errno: %d\n", errno);
+	WARN_ONCE(1, "nfsd: non-standard errno: %d\n", errno);
 	return nfserr_io;
 }
 
-- 
2.7.4


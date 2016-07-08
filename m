Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from linuxhacker.ru ([217.76.32.60]:49104 "EHLO fiona.linuxhacker.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753543AbcGHCDo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 7 Jul 2016 22:03:44 -0400
From: Oleg Drokin <green@linuxhacker.ru>
To: Jeff Layton <jlayton@poochiereds.net>,
        "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        Oleg Drokin <green@linuxhacker.ru>
Subject: [PATCH] nfsd: Correct a comment for NFSD_MAY_ defines location
Date: Thu,  7 Jul 2016 21:49:38 -0400
Message-Id: <1467942578-3081513-1-git-send-email-green@linuxhacker.ru>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Those are now defined in fs/nfsd/vfs.h

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 fs/nfsd/nfsfh.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfsd/nfsfh.c b/fs/nfsd/nfsfh.c
index a891944..7e49dcb 100644
--- a/fs/nfsd/nfsfh.c
+++ b/fs/nfsd/nfsfh.c
@@ -298,7 +298,7 @@ out:
  * that it expects something not of the given type.
  *
  * @access is formed from the NFSD_MAY_* constants defined in
- * include/linux/nfsd/nfsd.h.
+ * fs/nfsd/vfs.h.
  */
 __be32
 fh_verify(struct svc_rqst *rqstp, struct svc_fh *fhp, umode_t type, int access)
-- 
2.7.4


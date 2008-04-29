From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: [PATCH] nfsd: remove unnecessary atomic ops
Date: Mon, 28 Apr 2008 23:13:25 -0400
Message-ID: <20080429031325.GA2841@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:50432 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752749AbYD2DN0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 28 Apr 2008 23:13:26 -0400
Received: from bfields by fieldses.org with local (Exim 4.69)
	(envelope-from <bfields@fieldses.org>)
	id 1JqgHV-0000ye-Ip
	for linux-nfs@vger.kernel.org; Mon, 28 Apr 2008 23:13:25 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: J. Bruce Fields <bfields@citi.umich.edu>

These bit operations don't need to be atomic.  They're all done under a
single big mutex anyway.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/nfsd/nfs4state.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

I'm queuing this up for 2.6.26.

--b.

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 8799b87..5c97d47 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1579,8 +1579,8 @@ nfs4_upgrade_open(struct svc_rqst *rqstp, struct svc_fh *cur_fh, struct nfs4_sta
 	}
 	/* remember the open */
 	filp->f_mode |= open->op_share_access;
-	set_bit(open->op_share_access, &stp->st_access_bmap);
-	set_bit(open->op_share_deny, &stp->st_deny_bmap);
+	__set_bit(open->op_share_access, &stp->st_access_bmap);
+	__set_bit(open->op_share_deny, &stp->st_deny_bmap);
 
 	return nfs_ok;
 }
-- 
1.5.5.rc1


Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:41411 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751197Ab2E3Sgb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 30 May 2012 14:36:31 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 1/5] nfsd4: fix exchange_id to return confirm flag
Date: Wed, 30 May 2012 14:36:24 -0400
Message-Id: <1338402988-17356-2-git-send-email-bfields@redhat.com>
In-Reply-To: <1338402988-17356-1-git-send-email-bfields@redhat.com>
References: <1338402988-17356-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Otherwise nfsd4_set_ex_flags writes over the return flags.

Reported-by: Bryan Schumaker <bjschuma@netapp.com>
Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index be1fc97..d53ad72 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1617,7 +1617,7 @@ nfsd4_exchange_id(struct svc_rqst *rqstp,
 			goto expire_client;
 		}
 		if (verfs_match) { /* case 2 */
-			exid->flags |= EXCHGID4_FLAG_CONFIRMED_R;
+			conf->cl_exchange_flags |= EXCHGID4_FLAG_CONFIRMED_R;
 			new = conf;
 			goto out_copy;
 		}
-- 
1.7.10.2


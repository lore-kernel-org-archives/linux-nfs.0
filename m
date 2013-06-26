Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:35130 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752556Ab3FZTVc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 26 Jun 2013 15:21:32 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 5/7] nfsd4: delegation-based open reclaims should bypass permissions
Date: Wed, 26 Jun 2013 15:21:25 -0400
Message-Id: <1372274488-4752-6-git-send-email-bfields@redhat.com>
In-Reply-To: <1372274488-4752-1-git-send-email-bfields@redhat.com>
References: <1372274488-4752-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

We saw a v4.0 client's create fail as follows:

	- open create succeeds and gets a read delegation
	- client attempts to set mode on new file, gets DELAY while
	  server recalls delegation.
	- client attempts a CLAIM_DELEGATE_CUR open using the
	  delegation, gets error because of new file mode.

This probably can't happen on a recent kernel since we're no longer
giving out delegations on create opens.  Nevertheless, it's a
bug--reclaim opens should bypass permission checks.

Reported-by: Steve Dickson <steved@redhat.com>
Reported-by: Trond Myklebust <Trond.Myklebust@netapp.com>
Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4proc.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 1a1ff24..a7cee86 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -296,7 +296,8 @@ do_open_lookup(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate, stru
 
 	nfsd4_set_open_owner_reply_cache(cstate, open, resfh);
 	accmode = NFSD_MAY_NOP;
-	if (open->op_created)
+	if (open->op_created ||
+			open->op_claim_type == NFS4_OPEN_CLAIM_DELEGATE_CUR)
 		accmode |= NFSD_MAY_OWNER_OVERRIDE;
 	status = do_open_permission(rqstp, resfh, open, accmode);
 	set_change_info(&open->op_cinfo, current_fh);
-- 
1.8.1.4


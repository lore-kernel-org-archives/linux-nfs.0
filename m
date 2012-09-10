Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:40394 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753067Ab2IJOyo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 10 Sep 2012 10:54:44 -0400
Date: Mon, 10 Sep 2012 10:54:43 -0400
To: linux-nfs@vger.kernel.org
Cc: cbay@excellency.fr
Subject: [PATCH] nfsd4: fix nfs4 stateid leak
Message-ID: <20120910145443.GD30136@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Processes that open and close multiple files may end up setting this
oo_last_closed_stid without freeing what was previously pointed to.
This can result in a major leak, visible for example by watching the
nfsd4_stateids line of /proc/slabinfo.

Reported-by: Cyril B. <cbay@excellency.fr>
Tested-by: Cyril B. <cbay@excellency.fr>
Cc: stable@vger.kernel.org
Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c |    1 +
 1 file changed, 1 insertion(+)

Queuing up for 3.7 and -stable.--b.

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 5f1a91a..6686e74 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -3766,6 +3766,7 @@ nfsd4_close(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	memcpy(&close->cl_stateid, &stp->st_stid.sc_stateid, sizeof(stateid_t));
 
 	nfsd4_close_open_stateid(stp);
+	release_last_closed_stateid(oo);
 	oo->oo_last_closed_stid = stp;
 
 	if (list_empty(&oo->oo_owner.so_stateids)) {
-- 
1.7.9.5


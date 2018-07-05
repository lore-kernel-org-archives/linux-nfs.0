Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:54968 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753131AbeGEJsR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 5 Jul 2018 05:48:17 -0400
From: Jeff Layton <jlayton@kernel.org>
To: trond.myklebust@hammerspace.com, anna.schumaker@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] nfs: initiate returning delegation when reclaiming one that's been recalled
Date: Thu,  5 Jul 2018 05:48:14 -0400
Message-Id: <20180705094814.4940-1-jlayton@kernel.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When reclaiming a delegation via CLAIM_PREVIOUS open, the server can
indicate that the delegation has been recalled since it was issued by
setting the "recalled" flag in the delegation.

Ensure that we respect the flag by initiating a delegation return when
it is set.

Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 fs/nfs/nfs4proc.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 6dd146885da9..bf454debd99a 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1773,6 +1773,10 @@ nfs4_opendata_check_deleg(struct nfs4_opendata *data, struct nfs4_state *state)
 				data->o_res.delegation_type,
 				&data->o_res.delegation,
 				data->o_res.pagemod_limit);
+
+	if (data->o_res.do_recall)
+		nfs_async_inode_return_delegation(state->inode,
+						  &data->o_res.delegation);
 }
 
 /*
-- 
2.17.1


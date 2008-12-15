From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 2/6] nfsd: dprint each op status in nfsd4_proc_compound
Date: Mon, 15 Dec 2008 19:40:49 +0200
Message-ID: <1229362849-9727-1-git-send-email-bhalevy@panasas.com>
References: <49469601.7020101@panasas.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org,
	Benny Halevy <bhalevy@panasas.com>
To: " J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from DSL212-235-53-3.bb.netvision.net.il ([212.235.53.3]:53660 "EHLO
	bh-buildlin1.bhalevy.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754933AbYLORlF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 15 Dec 2008 12:41:05 -0500
In-Reply-To: <49469601.7020101@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4proc.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 669461e..9fa60a3 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -946,6 +946,11 @@ encode_op:
 			nfsd4_encode_operation(resp, op);
 			status = op->status;
 		}
+
+		dprintk("nfsv4 compound op %p opcnt %d #%d: %d: status %d\n",
+			args->ops, args->opcnt, resp->opcnt, op->opnum,
+			be32_to_cpu(status));
+
 		if (cstate->replay_owner) {
 			nfs4_put_stateowner(cstate->replay_owner);
 			cstate->replay_owner = NULL;
-- 
1.6.0.2


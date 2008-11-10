From: Benny Halevy <bhalevy@panasas.com>
Subject: [RFC 02/51] nfsd: dprint each op status in nfsd4_proc_compound
Date: Mon, 10 Nov 2008 22:41:16 +0200
Message-ID: <1226349676-10167-1-git-send-email-bhalevy@panasas.com>
References: <491895A0.3040809@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: " J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from DSL212-235-53-3.bb.netvision.net.il ([212.235.53.3]:60253 "EHLO
	bh-buildlin1.bhalevy.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750865AbYKJUl2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Nov 2008 15:41:28 -0500
In-Reply-To: <491895A0.3040809@panasas.com>
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


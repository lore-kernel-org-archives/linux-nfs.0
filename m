From: Benny Halevy <bhalevy@panasas.com>
Subject: [RFC 15/51] FIXME: nfsd41: free up slot unless operation is dropped
Date: Mon, 10 Nov 2008 22:45:46 +0200
Message-ID: <1226349946-10659-1-git-send-email-bhalevy@panasas.com>
References: <491895A0.3040809@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: " J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from DSL212-235-53-3.bb.netvision.net.il ([212.235.53.3]:57232 "EHLO
	bh-buildlin1.bhalevy.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754499AbYKJUp6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Nov 2008 15:45:58 -0500
In-Reply-To: <491895A0.3040809@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Marc Eshel <eshel@almaden.ibm.com>

Mark slot is NFS4_SLOT_AVAILABLE before exiting nfsd4_proc_compound
unless op->status == nfserr_dropit

FIXME: bhalevy: verify slot gets freed eventually in the dropit case.

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4proc.c |    9 ++++++++-
 1 files changed, 8 insertions(+), 1 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index bfebeaa..876f285 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -979,8 +979,15 @@ out_free:
 #if defined(CONFIG_NFSD_V4_1)
 	if (current_ses) {
 		struct nfs41_slot *cs_slot = current_ses->cs_slot;
-		if (cs_slot)
+		if (cs_slot) {
+			if (op && op->status != nfserr_dropit) {
+				dprintk("%s: SET SLOT STATE TO AVAILABLE\n",
+					__func__);
+				nfs41_set_slot_state(cs_slot,
+						     NFS4_SLOT_AVAILABLE);
+			}
 			nfs41_put_session(cs_slot->sl_session);
+		}
 		kfree(current_ses);
 	}
 #endif /* CONFIG_NFSD_V4_1 */
-- 
1.6.0.2


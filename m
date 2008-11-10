From: Benny Halevy <bhalevy@panasas.com>
Subject: [RFC 09/51] nfsd41: destroy_session when client is expired
Date: Mon, 10 Nov 2008 22:43:41 +0200
Message-ID: <1226349821-10431-1-git-send-email-bhalevy@panasas.com>
References: <491895A0.3040809@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: " J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from DSL212-235-53-3.bb.netvision.net.il ([212.235.53.3]:57203 "EHLO
	bh-buildlin1.bhalevy.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754087AbYKJUny (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Nov 2008 15:43:54 -0500
In-Reply-To: <491895A0.3040809@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Marc Eshel <eshel@almaden.ibm.com>

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4state.c |   10 ++++++++++
 1 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 7406826..bf4d2c2 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -414,6 +414,9 @@ expire_client(struct nfs4_client *clp)
 	struct nfs4_stateowner *sop;
 	struct nfs4_delegation *dp;
 	struct list_head reaplist;
+#if defined(CONFIG_NFSD_V4_1)
+	struct nfs41_session  *ses;
+#endif /* CONFIG_NFSD_V4_1 */
 
 	dprintk("NFSD: expire_client cl_count %d\n",
 	                    atomic_read(&clp->cl_count));
@@ -440,6 +443,13 @@ expire_client(struct nfs4_client *clp)
 		sop = list_entry(clp->cl_openowners.next, struct nfs4_stateowner, so_perclient);
 		release_stateowner(sop);
 	}
+#if defined(CONFIG_NFSD_V4_1)
+	while (!list_empty(&clp->cl_sessions)) {
+		ses = list_entry(clp->cl_sessions.next, struct nfs41_session,
+				 se_perclnt);
+		destroy_session(ses);
+	}
+#endif /* CONFIG_NFSD_V4_1 */
 	put_nfs4_client(clp);
 }
 
-- 
1.6.0.2


From: Benny Halevy <bhalevy@panasas.com>
Subject: [RFC 24/51] nfsd41: print exchange flags when purging client
Date: Mon, 10 Nov 2008 22:48:53 +0200
Message-ID: <1226350133-11000-1-git-send-email-bhalevy@panasas.com>
References: <491895A0.3040809@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: " J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from DSL212-235-53-3.bb.netvision.net.il ([212.235.53.3]:44771 "EHLO
	bh-buildlin1.bhalevy.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751005AbYKJUtF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Nov 2008 15:49:05 -0500
In-Reply-To: <491895A0.3040809@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Dean Hildebrand <seattleplus@gmail.com>

Signed-off-by: Dean Hildebrand <dhildeb@us.ibm.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4state.c |    8 +++++++-
 1 files changed, 7 insertions(+), 1 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 76b2870..cbbb733 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2114,8 +2114,14 @@ nfs4_laundromat(void)
 				clientid_val = t;
 			break;
 		}
-		dprintk("NFSD: purging unused client (clientid %08x)\n",
+#if defined(CONFIG_NFSD_V4_1)
+		dprintk("NFSD: purging unused client"
+			"(clientid %08x cl_exchange_flags %x)\n",
+			clp->cl_clientid.cl_id, clp->cl_exchange_flags);
+#else
+		dprintk("NFSD: purging unused client(clientid %08x)\n",
 			clp->cl_clientid.cl_id);
+#endif /* CONFIG_NFSD_V4_1 */
 		nfsd4_remove_clid_dir(clp);
 		expire_client(clp);
 	}
-- 
1.6.0.2


From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH v2 10/47] nfsd41: release_session when client is expired
Date: Sat, 28 Mar 2009 11:31:41 +0300
Message-ID: <1238229101-10224-1-git-send-email-bhalevy@panasas.com>
References: <49CDDFC2.4070402@panasas.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: " J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:15804 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754917AbZC1IcR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 28 Mar 2009 04:32:17 -0400
In-Reply-To: <49CDDFC2.4070402@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Marc Eshel <eshel@almaden.ibm.com>

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[add CONFIG_NFSD_V4_1 to fix v4.0 regression bug]
Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4state.c |    8 ++++++++
 1 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index b71ec72..df9d42e 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -515,6 +515,14 @@ expire_client(struct nfs4_client *clp)
 		sop = list_entry(clp->cl_openowners.next, struct nfs4_stateowner, so_perclient);
 		release_openowner(sop);
 	}
+#ifdef CONFIG_NFSD_V4_1
+	while (!list_empty(&clp->cl_sessions)) {
+		struct nfsd4_session  *ses;
+		ses = list_entry(clp->cl_sessions.next, struct nfsd4_session,
+				 se_perclnt);
+		release_session(ses);
+	}
+#endif /* CONFIG_NFSD_V4_1 */
 	put_nfs4_client(clp);
 }
 
-- 
1.6.2.1


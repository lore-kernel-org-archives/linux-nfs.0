From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH v3 06/35] nfsd41: release_session when client is expired
Date: Fri,  3 Apr 2009 08:27:49 +0300
Message-ID: <1238736469-17264-1-git-send-email-bhalevy@panasas.com>
References: <49D599EA.6060705@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: " J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:28605 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753659AbZDCF1y (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 3 Apr 2009 01:27:54 -0400
In-Reply-To: <49D599EA.6060705@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Marc Eshel <eshel@almaden.ibm.com>

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[add CONFIG_NFSD_V4_1 to fix v4.0 regression bug]
Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4state.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index b261199..f23385b 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -511,6 +511,12 @@ expire_client(struct nfs4_client *clp)
 		sop = list_entry(clp->cl_openowners.next, struct nfs4_stateowner, so_perclient);
 		release_openowner(sop);
 	}
+	while (!list_empty(&clp->cl_sessions)) {
+		struct nfsd4_session  *ses;
+		ses = list_entry(clp->cl_sessions.next, struct nfsd4_session,
+				 se_perclnt);
+		release_session(ses);
+	}
 	put_nfs4_client(clp);
 }
 
-- 
1.6.2.1


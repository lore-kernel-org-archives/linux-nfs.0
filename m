From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 3/3] nfs41: pass state recovery error back to caller
Date: Tue, 30 Jun 2009 20:06:30 +0300
Message-ID: <1246381590-4010-1-git-send-email-bhalevy@panasas.com>
References: <4A4A4564.3000708@panasas.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org,
	Benny Halevy <bhalevy@panasas.com>,
	Andy Adamson <andros@netapp.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ip67-152-220-66.z220-152-67.customer.algx.net ([67.152.220.66]:21657
	"EHLO daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752303AbZF3RG3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 30 Jun 2009 13:06:29 -0400
In-Reply-To: <4A4A4564.3000708@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Currently the error returned from create_session to the state manager
is recorded in cl_cons_state via nfs_mark_client_ready
but it is ignored by nfs4_check_client_ready and mis-translated to
-EPROTONOSUPPORT if the client has a session.

Fixes https://bugzilla.linux-nfs.org/show_bug.cgi?id=178

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
Cc: Andy Adamson <andros@netapp.com>
---
 fs/nfs/client.c |    9 ++-------
 1 files changed, 2 insertions(+), 7 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 157a1d9..b3f8307 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -536,16 +536,11 @@ void nfs_mark_client_ready(struct nfs_client *clp, int state)
 /*
  * With sessions, the client is not marked ready until after a
  * successful EXCHANGE_ID and CREATE_SESSION.
- *
- * Map errors cl_cons_state errors to EPROTONOSUPPORT to indicate
- * other versions of NFS can be tried.
  */
 int nfs4_check_client_ready(struct nfs_client *clp)
 {
-	if (!nfs4_has_session(clp))
-		return 0;
-	if (clp->cl_cons_state < NFS_CS_READY)
-		return -EPROTONOSUPPORT;
+	if (clp->cl_cons_state < 0)
+		return clp->cl_cons_state;
 	return 0;
 }
 
-- 
1.6.3.3


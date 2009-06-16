From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 12/44] nfsd41: set the session maximum response size cached
Date: Tue, 16 Jun 2009 04:19:46 +0300
Message-ID: <1245115186-7196-1-git-send-email-bhalevy@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: bfields@citi.umich.edu
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ip67-152-220-66.z220-152-67.customer.algx.net ([67.152.220.66]:2441
	"EHLO daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754463AbZFPBTq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 15 Jun 2009 21:19:46 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

We won't cache the SEQUENCE operation because we can encode it from the session
slot values.

Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[nfsd41: move channel attributes from nfsd4_session to a nfsd4_channel_attr struct]
Signed-off-by: Alexandros Batsakis <Alexandros.Batsakis@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4state.c |   12 ++++++++----
 1 files changed, 8 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 6427f8b..a6a7968 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -446,6 +446,12 @@ static int set_forechannel_maxreqs(struct nfsd4_channel_attrs *fchan)
 	}
 }
 
+/* rpc header + encoded OP_SEQUENCE reply + NFSD_SLOT_CACHE_SIZE in bytes */
+#define NFSD_MAX_RESPONSE_CACHED  ((RPC_MAX_HEADER_WITH_AUTH + \
+				  2 + /* OP_SEQUENCE header */ \
+				  XDR_QUADLEN(NFS4_MAX_SESSIONID_LEN) + 5 + \
+				  XDR_QUADLEN(NFSD_SLOT_CACHE_SIZE)) << 2)
+
 /*
  * fchan holds the client values on input, and the server values on output
  */
@@ -467,9 +473,7 @@ static int init_forechannel_attrs(struct svc_rqst *rqstp,
 		fchan->maxresp_sz = maxcount;
 	session_fchan->maxresp_sz = fchan->maxresp_sz;
 
-	/* Set the max response cached size our default which is
-	 * a multiple of PAGE_SIZE and small */
-	session_fchan->maxresp_cached = NFSD_PAGES_PER_SLOT * PAGE_SIZE;
+	session_fchan->maxresp_cached = NFSD_MAX_RESPONSE_CACHED;
 	fchan->maxresp_cached = session_fchan->maxresp_cached;
 
 	/* Use the client's maxops if possible */
@@ -587,7 +591,7 @@ free_session(struct kref *kref)
 		nfsd4_release_respages(e->ce_respages, e->ce_resused);
 	}
 	spin_lock(&nfsd_drc_lock);
-	nfsd_drc_mem_used -= ses->se_fnumslots * NFSD_SLOT_CACHE_SIZE;
+	nfsd_drc_mem_used -= ses->se_fchannel.maxreqs * NFSD_SLOT_CACHE_SIZE;
 	spin_unlock(&nfsd_drc_lock);
 	kfree(ses);
 }
-- 
1.6.3


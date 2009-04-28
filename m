From: andros@netapp.com
Subject: [PATCH 11/31] nfsd41: set the session maximum response size cached
Date: Tue, 28 Apr 2009 12:59:45 -0400
Message-ID: <1240938005-23778-11-git-send-email-andros@netapp.com>
References: <1240938005-23778-1-git-send-email-andros@netapp.com>
 <1240938005-23778-2-git-send-email-andros@netapp.com>
 <1240938005-23778-3-git-send-email-andros@netapp.com>
 <1240938005-23778-4-git-send-email-andros@netapp.com>
 <1240938005-23778-5-git-send-email-andros@netapp.com>
 <1240938005-23778-6-git-send-email-andros@netapp.com>
 <1240938005-23778-7-git-send-email-andros@netapp.com>
 <1240938005-23778-8-git-send-email-andros@netapp.com>
 <1240938005-23778-9-git-send-email-andros@netapp.com>
 <1240938005-23778-10-git-send-email-andros@netapp.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org,
	Andy Adamson <andros@netapp.com>
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:7762 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760498AbZD1RBJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 28 Apr 2009 13:01:09 -0400
In-Reply-To: <1240938005-23778-10-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

We won't cache the SEQUENCE operation because we can encode it from the session
slot values.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfsd/nfs4state.c |   10 +++++++---
 1 files changed, 7 insertions(+), 3 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index a9e722e..187e1da 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -448,6 +448,12 @@ static int set_forechannel_maxreqs(struct nfsd4_channel_attrs *fchan)
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
@@ -469,9 +475,7 @@ static int init_forechannel_attrs(struct svc_rqst *rqstp,
 		fchan->maxresp_sz = maxcount;
 	session_fchan->maxresp_sz = fchan->maxresp_sz;
 
-	/* Set the max response cached size our default which is
-	 * a multiple of PAGE_SIZE and small */
-	session_fchan->maxresp_cached = NFSD_PAGES_PER_SLOT * PAGE_SIZE;
+	session_fchan->maxresp_cached = NFSD_MAX_RESPONSE_CACHED;
 	fchan->maxresp_cached = session_fchan->maxresp_cached;
 
 	/* Use the client's maxops if possible */
-- 
1.5.4.3


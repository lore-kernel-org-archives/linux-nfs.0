From: andros@netapp.com
Subject: [PATCH 2/2] nfsd41: add RPC header size to fore channel negotiation
Date: Fri, 11 Sep 2009 18:52:55 -0400
Message-ID: <1252709575-3426-3-git-send-email-andros@netapp.com>
References: <1252709575-3426-1-git-send-email-andros@netapp.com>
 <1252709575-3426-2-git-send-email-andros@netapp.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org,
	Andy Adamson <andros@netapp.com>
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:46768 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754560AbZIKWxU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 11 Sep 2009 18:53:20 -0400
In-Reply-To: <1252709575-3426-2-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Both the max request and the max response size include the RPC header with
credential (request only)  and verifier as well as the payload.

The RPCSEC_GSS credential and verifier are the largest. Kerberos is the only
supported GSS security mechansim, so the Kerberos GSS credential and verifier
sizes are used.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfsd/nfs4state.c |   29 +++++++++++++++++++++++++----
 1 files changed, 25 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 5ecb42c..e4d8f94 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -428,6 +428,27 @@ gen_sessionid(struct nfsd4_session *ses)
 #define NFSD_MIN_HDR_SEQ_SZ  (20 + 12 + 44)
 
 /*
+ * The protocol defines ca_maxrequestsize as the XDR encoded size of the
+ * request including the RPC headers (including security flavor credentials
+ * and verifiers) but excludes any RPC transport framing headers.
+ * So we need to advertize a ca_maxrequestsize value that is the number of
+ * bytes of the maximum payload we support, plus some additional bytes to cover
+ * the maximum RPC header size. The RPCSEC_GSS security flavor has the
+ * largest credential and verifier, so we add 24 bytes for the RPC call header
+ * (xid through proceedure), 32 bytes of GSS credential, and 48 bytes of
+ * Kerberos GSS verifier.
+ */
+#define NFSD_MAX_CALL_HDR_SZ (24 + 32 + 48)
+
+/* The protocol defines ca_maxresponsesize as also including the RPC headers
+ * just as in ca_maxrequestsize. Once again, we use the maximum supported
+ * payload plus the largest RPC reply header which uses the RPCSEC_GSS
+ * security flavor. We add 12 bytes of RPC reply header (xid through 
+ * reply state) and 48 bytes of GSS Kerberos verifier.
+ */
+#define NFSD_MAX_REPLY_HDR_SZ (12 + 48)
+
+/*
  * Give the client the number of ca_maxresponsesize_cached slots it
  * requests, of size bounded by NFSD_SLOT_CACHE_SIZE,
  * NFSD_MAX_MEM_PER_SESSION, and nfsd_drc_max_mem. Do not allow more
@@ -488,12 +509,12 @@ static int init_forechannel_attrs(struct svc_rqst *rqstp,
 	/* headerpadsz set to zero in encode routine */
 
 	/* Use the client's max request and max response size if possible */
-	if (fchan->maxreq_sz > maxcount)
-		fchan->maxreq_sz = maxcount;
+	if (fchan->maxreq_sz > maxcount + NFSD_MAX_CALL_HDR_SZ)
+		fchan->maxreq_sz = maxcount + NFSD_MAX_CALL_HDR_SZ;
 	session_fchan->maxreq_sz = fchan->maxreq_sz;
 
-	if (fchan->maxresp_sz > maxcount)
-		fchan->maxresp_sz = maxcount;
+	if (fchan->maxresp_sz > maxcount + NFSD_MAX_REPLY_HDR_SZ)
+		fchan->maxresp_sz = maxcount + NFSD_MAX_REPLY_HDR_SZ;
 	session_fchan->maxresp_sz = fchan->maxresp_sz;
 
 	/* Use the client's maxops if possible */
-- 
1.6.2.5


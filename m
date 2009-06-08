From: andros@netapp.com
Subject: [PATCH 10/30] nfsd41: set the session maximum response size cached
Date: Mon,  8 Jun 2009 14:20:51 -0400
Message-ID: <1244485271-7461-11-git-send-email-andros@netapp.com>
References: <>
 <1244485271-7461-1-git-send-email-andros@netapp.com>
 <1244485271-7461-2-git-send-email-andros@netapp.com>
 <1244485271-7461-3-git-send-email-andros@netapp.com>
 <1244485271-7461-4-git-send-email-andros@netapp.com>
 <1244485271-7461-5-git-send-email-andros@netapp.com>
 <1244485271-7461-6-git-send-email-andros@netapp.com>
 <1244485271-7461-7-git-send-email-andros@netapp.com>
 <1244485271-7461-8-git-send-email-andros@netapp.com>
 <1244485271-7461-9-git-send-email-andros@netapp.com>
 <1244485271-7461-10-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:39968 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752806AbZFHSVX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 8 Jun 2009 14:21:23 -0400
In-Reply-To: <1244485271-7461-10-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

We don't cache the SEQUENCE operation because we can encode it from the session
slot values, so it is not included in NFSD_SLOT_CACHE_SIZE.

Fix the nfsd4_check_drc_limit() comment - the cache is no longer page based.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfsd/nfs4state.c |   10 +++++++---
 fs/nfsd/nfs4xdr.c   |    2 --
 2 files changed, 7 insertions(+), 5 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index db56a8a..cdc2a5e 100644
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
 	session->se_fmaxresp_sz = fchan->maxresp_sz;
 
-	/* Set the max response cached size our default which is
-	 * a multiple of PAGE_SIZE and small */
-	session->se_fmaxresp_cached = NFSD_PAGES_PER_SLOT * PAGE_SIZE;
+	session->se_fmaxresp_cached = NFSD_MAX_RESPONSE_CACHED;
 	fchan->maxresp_cached = session->se_fmaxresp_cached;
 
 	/* Use the client's maxops if possible */
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index b73549d..7e6b139 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -3176,8 +3176,6 @@ static nfsd4_enc nfsd4_enc_ops[] = {
  *
  * Compare this length to the session se_fmaxresp_cached.
  *
- * Our se_fmaxresp_cached will always be a multiple of PAGE_SIZE, and so
- * will be at least a page and will therefore hold the xdr_buf head.
  */
 static int nfsd4_check_drc_limit(struct nfsd4_compoundres *resp)
 {
-- 
1.5.4.3


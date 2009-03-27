From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 27/47] nfsd41: destroy_session operation
Date: Fri, 27 Mar 2009 06:16:59 +0300
Message-ID: <1238123819-7781-1-git-send-email-bhalevy@panasas.com>
References: <49CC40E5.2080506@panasas.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org,
	Benny Halevy <bhalevy@panasas.com>
To: " J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:24339 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756036AbZC0DRE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Mar 2009 23:17:04 -0400
In-Reply-To: <49CC40E5.2080506@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Implement the destory_session operation confoming to
http://tools.ietf.org/html/draft-ietf-nfsv4-minorversion1-26

[use sessionid_lock spin lock]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4state.c       |   29 ++++++++++++++++++++++++++++-
 fs/nfsd/nfs4xdr.c         |    7 +++++--
 include/linux/nfsd/xdr4.h |    2 +-
 3 files changed, 34 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index f42cda9..9c93f96 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1439,7 +1439,34 @@ nfsd4_destroy_session(struct svc_rqst *r,
 		      struct nfsd4_compound_state *cstate,
 		      struct nfsd4_destroy_session *sessionid)
 {
-	return -1;	/* stub */
+	struct nfsd4_session *ses;
+	u32 status = nfserr_badsession;
+
+	/* Notes:
+	 * - The confirmed nfs4_client->cl_sessionid holds destroyed sessinid
+	 * - Should we return nfserr_back_chan_busy if waiting for
+	 *   callbacks on to-be-destroyed session?
+	 * - Do we need to clear any callback info from previous session?
+	 */
+
+	dump_sessionid(__func__, &sessionid->sessionid);
+	spin_lock(&sessionid_lock);
+	ses = find_in_sessionid_hashtbl(&sessionid->sessionid);
+	if (!ses) {
+		spin_unlock(&sessionid_lock);
+		goto out;
+	}
+
+	unhash_session(ses);
+	spin_unlock(&sessionid_lock);
+
+	/* wait for callbacks */
+	shutdown_callback_client(ses->se_client);
+	nfsd4_put_session(ses);
+	status = nfs_ok;
+out:
+	dprintk("%s returns %d\n", __func__, ntohl(status));
+	return status;
 }
 
 __be32
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index a8bb04a..5720aab 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -1208,7 +1208,11 @@ static __be32
 nfsd4_decode_destroy_session(struct nfsd4_compoundargs *argp,
 			     struct nfsd4_destroy_session *destroy_session)
 {
-	return nfserr_opnotsupp;	/* stub */
+	DECODE_HEAD;
+	READ_BUF(NFS4_MAX_SESSIONID_LEN);
+	COPYMEM(destroy_session->sessionid.data, NFS4_MAX_SESSIONID_LEN);
+
+	DECODE_TAIL;
 }
 
 static __be32
@@ -2980,7 +2984,6 @@ static __be32
 nfsd4_encode_destroy_session(struct nfsd4_compoundres *resp, int nfserr,
 			     struct nfsd4_destroy_session *destroy_session)
 {
-	/* stub */
 	return nfserr;
 }
 
diff --git a/include/linux/nfsd/xdr4.h b/include/linux/nfsd/xdr4.h
index 641e5cd..37a7c51 100644
--- a/include/linux/nfsd/xdr4.h
+++ b/include/linux/nfsd/xdr4.h
@@ -396,7 +396,7 @@ struct nfsd4_sequence {
 };
 
 struct nfsd4_destroy_session {
-	int	foo;	/* stub */
+	struct nfs4_sessionid	sessionid;
 };
 #endif /* CONFIG_NFSD_V4_1 */
 
-- 
1.6.2.1


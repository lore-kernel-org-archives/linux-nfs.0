From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH v3 21/35] nfsd41: destroy_session operation
Date: Fri,  3 Apr 2009 08:28:38 +0300
Message-ID: <1238736518-17735-1-git-send-email-bhalevy@panasas.com>
References: <49D599EA.6060705@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: " J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:10490 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755977AbZDCF2o (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 3 Apr 2009 01:28:44 -0400
In-Reply-To: <49D599EA.6060705@panasas.com>
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
index 04a395f..9192e5b 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1422,7 +1422,34 @@ nfsd4_destroy_session(struct svc_rqst *r,
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
index 64bc215..c6a726d 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -1207,7 +1207,11 @@ static __be32
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
@@ -2971,7 +2975,6 @@ static __be32
 nfsd4_encode_destroy_session(struct nfsd4_compoundres *resp, int nfserr,
 			     struct nfsd4_destroy_session *destroy_session)
 {
-	/* stub */
 	return nfserr;
 }
 
diff --git a/include/linux/nfsd/xdr4.h b/include/linux/nfsd/xdr4.h
index 4861888..a0a2e83 100644
--- a/include/linux/nfsd/xdr4.h
+++ b/include/linux/nfsd/xdr4.h
@@ -395,7 +395,7 @@ struct nfsd4_sequence {
 };
 
 struct nfsd4_destroy_session {
-	int	foo;	/* stub */
+	struct nfs4_sessionid	sessionid;
 };
 
 struct nfsd4_op {
-- 
1.6.2.1


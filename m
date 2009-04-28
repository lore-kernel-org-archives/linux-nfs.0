From: andros@netapp.com
Subject: [PATCH 04/31] nfsd41: separate clientid slot from session slot
Date: Tue, 28 Apr 2009 12:59:38 -0400
Message-ID: <1240938005-23778-4-git-send-email-andros@netapp.com>
References: <1240938005-23778-1-git-send-email-andros@netapp.com>
 <1240938005-23778-2-git-send-email-andros@netapp.com>
 <1240938005-23778-3-git-send-email-andros@netapp.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org,
	Andy Adamson <andros@netapp.com>
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:50930 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760498AbZD1RBD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 28 Apr 2009 13:01:03 -0400
In-Reply-To: <1240938005-23778-3-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

The nfs41 single slot clientid cache holds an encoded create session response
which has a maximum size of 88 bytes. The slot does not need the inuse,
cachethis or other fields that the multiple slot session cache uses.

Declare a new structure with a static buffer to struct nfs4_client to cache
the encoded create session response.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfsd/nfs4state.c        |   28 ++++++++++++++++------------
 include/linux/nfsd/state.h |   16 +++++++++++++++-
 2 files changed, 31 insertions(+), 13 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index e6dbf05..fee6bf0 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -652,8 +652,6 @@ free_client(struct nfs4_client *clp)
 	shutdown_callback_client(clp);
 	if (clp->cl_cb_xprt)
 		svc_xprt_put(clp->cl_cb_xprt);
-	nfsd4_release_respages(clp->cl_slot.sl_cache_entry.ce_respages,
-			     clp->cl_slot.sl_cache_entry.ce_resused);
 	if (clp->cl_cred.cr_group_info)
 		put_group_info(clp->cl_cred.cr_group_info);
 	kfree(clp->cl_principal);
@@ -729,6 +727,18 @@ static struct nfs4_client *create_client(struct xdr_netobj name, char *recdir)
 	return clp;
 }
 
+static struct nfs4_client *create_client_session(struct xdr_netobj name,
+						  char *recdir)
+{
+	struct nfs4_client *clp;
+
+	clp = create_client(name, recdir);
+	if (clp)
+		/* the slot sl_seqid is 0 */
+		clp->cl_slot.sl_datalen = CS_MAX_ENC_SZ;
+	return clp;
+}
+
 static void copy_verf(struct nfs4_client *target, nfs4_verifier *source)
 {
 	memcpy(target->cl_verifier.data, source->data,
@@ -1277,7 +1287,7 @@ nfsd4_exchange_id(struct svc_rqst *rqstp,
 
 out_new:
 	/* Normal case */
-	new = create_client(exid->clname, dname);
+	new = create_client_session(exid->clname, dname);
 	if (new == NULL) {
 		status = nfserr_resource;
 		goto out;
@@ -1294,7 +1304,6 @@ out_copy:
 	exid->clientid.cl_boot = new->cl_clientid.cl_boot;
 	exid->clientid.cl_id = new->cl_clientid.cl_id;
 
-	new->cl_slot.sl_seqid = 0;
 	exid->seqid = 1;
 	nfsd4_set_ex_flags(new, exid);
 
@@ -1342,7 +1351,7 @@ nfsd4_create_session(struct svc_rqst *rqstp,
 {
 	u32 ip_addr = svc_addr_in(rqstp)->sin_addr.s_addr;
 	struct nfs4_client *conf, *unconf;
-	struct nfsd4_slot *slot = NULL;
+	struct nfsd4_clid_slot *slot = NULL;
 	int status = 0;
 
 	nfs4_lock_state();
@@ -1351,8 +1360,7 @@ nfsd4_create_session(struct svc_rqst *rqstp,
 
 	if (conf) {
 		slot = &conf->cl_slot;
-		status = check_slot_seqid(cr_ses->seqid, slot->sl_seqid,
-					  slot->sl_inuse);
+		status = check_slot_seqid(cr_ses->seqid, slot->sl_seqid, 0);
 		if (status == nfserr_replay_cache) {
 			dprintk("Got a create_session replay! seqid= %d\n",
 				slot->sl_seqid);
@@ -1372,8 +1380,7 @@ nfsd4_create_session(struct svc_rqst *rqstp,
 		}
 
 		slot = &unconf->cl_slot;
-		status = check_slot_seqid(cr_ses->seqid, slot->sl_seqid,
-					  slot->sl_inuse);
+		status = check_slot_seqid(cr_ses->seqid, slot->sl_seqid, 0);
 		if (status) {
 			/* an unconfirmed replay returns misordered */
 			status = nfserr_seq_misordered;
@@ -1412,9 +1419,6 @@ nfsd4_create_session(struct svc_rqst *rqstp,
 	       NFS4_MAX_SESSIONID_LEN);
 	cr_ses->seqid = slot->sl_seqid;
 
-	slot->sl_inuse = true;
-	/* Ensure a page is used for the cache */
-	slot->sl_cache_entry.ce_cachethis = 1;
 out:
 	nfs4_unlock_state();
 	dprintk("%s returns %d\n", __func__, ntohl(status));
diff --git a/include/linux/nfsd/state.h b/include/linux/nfsd/state.h
index 14da8f6..bc34876 100644
--- a/include/linux/nfsd/state.h
+++ b/include/linux/nfsd/state.h
@@ -128,6 +128,20 @@ struct nfsd4_slot {
 	struct nfsd4_cache_entry	sl_cache_entry;
 };
 
+/*
+ * maximum encoded size of create session response
+ * 16 - sessionid, 8 - sequence # and flags,
+ * 32 - fore channel attrs, 32 - back channel attrs
+ */
+#define CS_MAX_ENC_SZ  88
+
+struct nfsd4_clid_slot {
+	u32		sl_seqid;
+	__be32		sl_status;
+	u32		sl_datalen;
+	char		sl_data[CS_MAX_ENC_SZ];
+};
+
 struct nfsd4_channel_attrs {
 	u32		headerpadsz;
 	u32		maxreq_sz;
@@ -205,7 +219,7 @@ struct nfs4_client {
 
 	/* for nfs41 */
 	struct list_head	cl_sessions;
-	struct nfsd4_slot	cl_slot;	/* create_session slot */
+	struct nfsd4_clid_slot	cl_slot;	/* create_session slot */
 	u32			cl_exchange_flags;
 	struct nfs4_sessionid	cl_sessionid;
 
-- 
1.5.4.3


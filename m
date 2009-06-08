From: andros@netapp.com
Subject: [PATCH 03/30] nfsd41: declare clientid create session slot structure
Date: Mon,  8 Jun 2009 14:20:44 -0400
Message-ID: <1244485271-7461-4-git-send-email-andros@netapp.com>
References: <>
 <1244485271-7461-1-git-send-email-andros@netapp.com>
 <1244485271-7461-2-git-send-email-andros@netapp.com>
 <1244485271-7461-3-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:10001 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752638AbZFHSVS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 8 Jun 2009 14:21:18 -0400
In-Reply-To: <1244485271-7461-3-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

The nfs41 single slot clientid cache holds the results of create session
processing in the create session xdr struct.  The slot does not need the inuse,
cachethis or other fields that the multiple slot session cache uses.

The cl_slot field of struct nfs4_client will be removed in a following patch.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 include/linux/nfsd/state.h |   31 +++++++++++++++++++++++++++++++
 include/linux/nfsd/xdr4.h  |   23 -----------------------
 2 files changed, 31 insertions(+), 23 deletions(-)

diff --git a/include/linux/nfsd/state.h b/include/linux/nfsd/state.h
index 4d61c87..901590e 100644
--- a/include/linux/nfsd/state.h
+++ b/include/linux/nfsd/state.h
@@ -122,6 +122,36 @@ struct nfsd4_slot {
 	struct nfsd4_cache_entry	sl_cache_entry;
 };
 
+struct nfsd4_channel_attrs {
+	u32	headerpadsz;
+	u32	maxreq_sz;
+	u32	maxresp_sz;
+	u32	maxresp_cached;
+	u32	maxops;
+	u32	maxreqs;
+	u32	nr_rdma_attrs;
+	u32	rdma_attrs;
+};
+
+struct nfsd4_create_session {
+	clientid_t			clientid;
+	struct nfs4_sessionid		sessionid;
+	u32				seqid;
+	u32				flags;
+	struct nfsd4_channel_attrs	fore_channel;
+	struct nfsd4_channel_attrs	back_channel;
+	u32				callback_prog;
+	u32				uid;
+	u32				gid;
+};
+
+/* The single slot clientid cache structure */
+struct nfsd4_clid_slot {
+	u32				sl_seqid;
+	__be32				sl_status;
+	struct nfsd4_create_session	sl_cr_ses;
+};
+
 struct nfsd4_session {
 	struct kref		se_ref;
 	struct list_head	se_hash;	/* hash by sessionid */
@@ -192,6 +222,7 @@ struct nfs4_client {
 	/* for nfs41 */
 	struct list_head	cl_sessions;
 	struct nfsd4_slot	cl_slot;	/* create_session slot */
+	struct nfsd4_clid_slot	cl_cs_slot;	/* create_session slot */
 	u32			cl_exchange_flags;
 	struct nfs4_sessionid	cl_sessionid;
 };
diff --git a/include/linux/nfsd/xdr4.h b/include/linux/nfsd/xdr4.h
index f80d601..6e24dbb 100644
--- a/include/linux/nfsd/xdr4.h
+++ b/include/linux/nfsd/xdr4.h
@@ -363,29 +363,6 @@ struct nfsd4_exchange_id {
 	int		spa_how;
 };
 
-struct nfsd4_channel_attrs {
-	u32		headerpadsz;
-	u32		maxreq_sz;
-	u32		maxresp_sz;
-	u32		maxresp_cached;
-	u32		maxops;
-	u32		maxreqs;
-	u32		nr_rdma_attrs;
-	u32		rdma_attrs;
-};
-
-struct nfsd4_create_session {
-	clientid_t		clientid;
-	struct nfs4_sessionid	sessionid;
-	u32			seqid;
-	u32			flags;
-	struct nfsd4_channel_attrs fore_channel;
-	struct nfsd4_channel_attrs back_channel;
-	u32			callback_prog;
-	u32			uid;
-	u32			gid;
-};
-
 struct nfsd4_sequence {
 	struct nfs4_sessionid	sessionid;		/* request/response */
 	u32			seqid;			/* request/response */
-- 
1.5.4.3


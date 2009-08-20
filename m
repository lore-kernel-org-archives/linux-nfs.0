From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH RFC 05/10] nfsd41: Backchannel: Add sequence arguments to callback RPC arguments
Date: Thu, 20 Aug 2009 03:34:35 +0300
Message-ID: <1250728475-28610-1-git-send-email-bhalevy@panasas.com>
References: <4A8C9992.2000505@panasas.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org,
	Ricardo Labiaga <Ricardo.Labiaga@netapp.com>,
	Benny Halevy <bhalevy@panasas.com>
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ip67-152-220-67.z220-152-67.customer.algx.net ([67.152.220.67]:15755
	"EHLO daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753491AbZHTAs0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 19 Aug 2009 20:48:26 -0400
In-Reply-To: <4A8C9992.2000505@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>

Follow the model we use in the client. Make the sequence arguments
part of the regular RPC arguments.  None of the callbacks that are
soon to be implemented expect results that need to be passed back
to the caller, so we don't define a separate RPC results structure.
For session validation, the cb_sequence decoding will use a pointer
to the sequence arguments that are part of the RPC argument.

Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
[define struct nfsd4_cb_sequence here]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4callback.c     |    5 +++++
 include/linux/nfsd/state.h |    9 +++++++++
 2 files changed, 14 insertions(+), 0 deletions(-)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index a39548e..a301a14 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -92,6 +92,11 @@ enum nfs_cb_opnum4 {
 					cb_sequence_dec_sz +            \
 					op_dec_sz)
 
+struct nfs4_rpc_args {
+	void				*args_op;
+	struct nfsd4_cb_sequence	args_seq;
+};
+
 /*
 * Generic encode routines from fs/nfs/nfs4xdr.c
 */
diff --git a/include/linux/nfsd/state.h b/include/linux/nfsd/state.h
index bccda62..50c515f 100644
--- a/include/linux/nfsd/state.h
+++ b/include/linux/nfsd/state.h
@@ -60,6 +60,12 @@ typedef struct {
 #define si_stateownerid   si_opaque.so_stateownerid
 #define si_fileid         si_opaque.so_fileid
 
+struct nfsd4_cb_sequence {
+	/* args/res */
+	u32			cbs_minorversion;
+	struct nfs4_client	*cbs_clp;
+};
+
 struct nfs4_delegation {
 	struct list_head	dl_perfile;
 	struct list_head	dl_perclnt;
@@ -205,6 +211,9 @@ struct nfs4_client {
 	struct nfsd4_clid_slot	cl_cs_slot;	/* create_session slot */
 	u32			cl_exchange_flags;
 	struct nfs4_sessionid	cl_sessionid;
+
+	/* for nfs41 callbacks */
+	struct svc_xprt		*cl_cb_xprt;	/* 4.1 callback transport */
 };
 
 /* struct nfs4_client_reset
-- 
1.6.4


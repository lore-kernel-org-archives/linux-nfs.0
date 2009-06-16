From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 39/44] nfsd41: Backchannel: Add sequence arguments to callback RPC arguments
Date: Tue, 16 Jun 2009 04:21:05 +0300
Message-ID: <1245115265-8089-1-git-send-email-bhalevy@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: bfields@citi.umich.edu
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ip67-152-220-66.z220-152-67.customer.algx.net ([67.152.220.66]:2782
	"EHLO daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1757646AbZFPBVE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 15 Jun 2009 21:21:04 -0400
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
index f75750e..a661ae4 100644
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
index f02e53c..299e44d 100644
--- a/include/linux/nfsd/state.h
+++ b/include/linux/nfsd/state.h
@@ -61,6 +61,12 @@ typedef struct {
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
@@ -206,6 +212,9 @@ struct nfs4_client {
 	struct nfsd4_clid_slot	cl_slot;	/* create_session slot */
 	u32			cl_exchange_flags;
 	struct nfs4_sessionid	cl_sessionid;
+
+	/* for nfs41 callbacks */
+	struct svc_xprt		*cl_cb_xprt;	/* 4.1 callback transport */
 };
 
 /* struct nfs4_client_reset
-- 
1.6.3


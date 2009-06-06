From: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
Subject: [RFC 06/11] nfsd41: Backchannel: Add sequence arguments to callback RPC arguments
Date: Fri,  5 Jun 2009 19:50:01 -0700
Message-ID: <1244256606-12905-6-git-send-email-Ricardo.Labiaga@netapp.com>
References: <273FE88A07F5D445824060902F7003440612BB9D@SACMVEXC1-PRD.hq.netapp.com>
 <1244256606-12905-1-git-send-email-Ricardo.Labiaga@netapp.com>
 <1244256606-12905-2-git-send-email-Ricardo.Labiaga@netapp.com>
 <1244256606-12905-3-git-send-email-Ricardo.Labiaga@netapp.com>
 <1244256606-12905-4-git-send-email-Ricardo.Labiaga@netapp.com>
 <1244256606-12905-5-git-send-email-Ricardo.Labiaga@netapp.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org,
	Ricardo Labiaga <Ricardo.Labiaga@netapp.com>,
	Benny Halevy <bhalevy@panasas.com>
To: bfields@fieldses.org, trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:18948 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753355AbZFFCw4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 5 Jun 2009 22:52:56 -0400
In-Reply-To: <1244256606-12905-5-git-send-email-Ricardo.Labiaga@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

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
index 212a75b..931aaa6 100644
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
@@ -188,6 +194,9 @@ struct nfs4_client {
 	struct nfsd4_slot	cl_slot;	/* create_session slot */
 	u32			cl_exchange_flags;
 	struct nfs4_sessionid	cl_sessionid;
+
+	/* for nfs41 callbacks */
+	struct svc_xprt		*cl_cb_xprt;	/* 4.1 callback transport */
 };
 
 /* struct nfs4_client_reset
-- 
1.5.4.3


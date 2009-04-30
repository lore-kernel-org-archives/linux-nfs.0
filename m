From: Benny Halevy <bhalevy@panasas.com>
Subject: [RFC 06/10] nfsd41: Backchannel: Add sequence arguments to callback RPC arguments
Date: Fri,  1 May 2009 02:06:21 +0300
Message-ID: <1241132781-32558-1-git-send-email-bhalevy@panasas.com>
References: <49FA2D86.8060402@panasas.com>
Cc: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>, pnfs@linux-nfs.org,
	linux-nfs@vger.kernel.org, Benny Halevy <bhalevy@panasas.com>
To: " J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:2538 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758513AbZD3XG3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 30 Apr 2009 19:06:29 -0400
In-Reply-To: <49FA2D86.8060402@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>

Follow the model we use in the client. Make the sequence arguments
part of the regular RPC arguments.  The results point to them.  Adjust
references to the sequence arguments.

Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
[define struct nfsd4_cb_sequence here]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4callback.c     |    9 +++++++++
 include/linux/nfsd/state.h |    5 +++++
 2 files changed, 14 insertions(+), 0 deletions(-)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index 6f1ca49..14535b2 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -92,6 +92,15 @@ enum nfs_cb_opnum4 {
 					cb_sequence_dec_sz +            \
 					op_dec_sz)
 
+struct nfs4_rpc_args {
+	void				*args_op;
+	struct nfsd4_cb_sequence	args_seq;
+};
+
+struct nfs4_rpc_res {
+	struct nfsd4_cb_sequence	*res_seq;
+};
+
 /*
 * Generic encode routines from fs/nfs/nfs4xdr.c
 */
diff --git a/include/linux/nfsd/state.h b/include/linux/nfsd/state.h
index 6bdf0d5..aeb9c40 100644
--- a/include/linux/nfsd/state.h
+++ b/include/linux/nfsd/state.h
@@ -61,6 +61,11 @@ typedef struct {
 #define si_stateownerid   si_opaque.so_stateownerid
 #define si_fileid         si_opaque.so_fileid
 
+struct nfsd4_cb_sequence {
+	/* args/res */
+	u32			cbs_minorversion;
+	struct nfs4_client	*cbs_clp;
+};
 
 struct nfs4_cb_recall {
 	u32			cbr_ident;
-- 
1.6.2.1


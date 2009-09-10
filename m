From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH v2 06/12] nfsd41: Backchannel: Add sequence arguments to callback RPC arguments
Date: Thu, 10 Sep 2009 12:26:12 +0300
Message-ID: <1252574772-30211-1-git-send-email-bhalevy@panasas.com>
References: <4AA8C597.8080809@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org,
	Ricardo Labiaga <Ricardo.Labiaga@netapp.com>,
	Benny Halevy <bhalevy@panasas.com>
To: " J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from dip-colo-pa.panasas.com ([67.152.220.67]:53553 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755315AbZIJJZn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Sep 2009 05:25:43 -0400
In-Reply-To: <4AA8C597.8080809@panasas.com>
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
 include/linux/nfsd/state.h |    6 ++++++
 2 files changed, 11 insertions(+), 0 deletions(-)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index 3e3e15b..ff59a61 100644
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
index 243277b..f69ea48 100644
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
-- 
1.6.4


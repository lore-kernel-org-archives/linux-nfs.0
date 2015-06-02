Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qc0-f175.google.com ([209.85.216.175]:35131 "EHLO
	mail-qc0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751891AbbFBK7d (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 2 Jun 2015 06:59:33 -0400
Received: by qczw4 with SMTP id w4so33424269qcz.2
        for <linux-nfs@vger.kernel.org>; Tue, 02 Jun 2015 03:59:33 -0700 (PDT)
Message-ID: <556D8C8D.50205@gmail.com>
Date: Tue, 02 Jun 2015 18:59:25 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
CC: Christoph Hellwig <hch@infradead.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        kinglongmee@gmail.com
Subject: [PATCH 2/2] nfsd: Update callback sequnce id only CB_SEQUENCE success
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When testing pnfs layout, nfsd got error NFS4ERR_SEQ_MISORDERED.
It is caused by nfs return NFS4ERR_DELAY before validate_seqid(),
don't update the sequnce id, but nfsd updates the sequnce id !!!

According to RFC5661 20.9.3,
" If CB_SEQUENCE returns an error, then the state of the slot
(sequence ID, cached reply) MUST NOT change. "

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfsd/nfs4callback.c | 14 ++++++++++++--
 fs/nfsd/state.h        |  1 +
 2 files changed, 13 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index 8b1ac8d..a492018 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -455,6 +455,7 @@ static int decode_cb_sequence4res(struct xdr_stream *xdr,
 	if (unlikely(status || cb->cb_status))
 		return status;
 
+	cb->cb_update_seq_nr = true;
 	return decode_cb_sequence4resok(xdr, cb);
 }
 
@@ -875,6 +876,7 @@ static void nfsd4_cb_prepare(struct rpc_task *task, void *calldata)
 	u32 minorversion = clp->cl_minorversion;
 
 	cb->cb_minorversion = minorversion;
+	cb->cb_update_seq_nr = false;
 	cb->cb_status = 0;
 	if (minorversion) {
 		if (!nfsd41_cb_get_slot(clp, task))
@@ -892,9 +894,16 @@ static void nfsd4_cb_done(struct rpc_task *task, void *calldata)
 		clp->cl_minorversion);
 
 	if (clp->cl_minorversion) {
-		/* No need for lock, access serialized in nfsd4_cb_prepare */
-		if (!task->tk_status)
+		/*
+		 * No need for lock, access serialized in nfsd4_cb_prepare
+		 *
+		 * RFC5661 20.9.3
+		 * If CB_SEQUENCE returns an error, then the state of the slot
+		 * (sequence ID, cached reply) MUST NOT change.
+		 */
+		if (cb->cb_update_seq_nr)
 			++clp->cl_cb_session->se_cb_seq_nr;
+
 		clear_bit(0, &clp->cl_cb_slot_busy);
 		rpc_wake_up_next(&clp->cl_cb_waitq);
 		dprintk("%s: freed slot, new seqid=%d\n", __func__,
@@ -1091,6 +1100,7 @@ void nfsd4_init_cb(struct nfsd4_callback *cb, struct nfs4_client *clp,
 	cb->cb_ops = ops;
 	INIT_WORK(&cb->cb_work, nfsd4_run_cb_work);
 	cb->cb_status = 0;
+	cb->cb_update_seq_nr = false;
 	cb->cb_need_restart = false;
 }
 
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index dbc4f85..4ed7c2a 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -68,6 +68,7 @@ struct nfsd4_callback {
 	struct nfsd4_callback_ops *cb_ops;
 	struct work_struct cb_work;
 	int cb_status;
+	bool cb_update_seq_nr;
 	bool cb_need_restart;
 };
 
-- 
2.4.2


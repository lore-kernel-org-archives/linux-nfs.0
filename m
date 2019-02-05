Return-Path: <SRS0=v/uS=QM=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 09515C282DC
	for <linux-nfs@archiver.kernel.org>; Tue,  5 Feb 2019 10:01:46 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id B007A2145D
	for <linux-nfs@archiver.kernel.org>; Tue,  5 Feb 2019 10:01:45 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725954AbfBEKBo (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 5 Feb 2019 05:01:44 -0500
Received: from mx3.molgen.mpg.de ([141.14.17.11]:60403 "EHLO mx1.molgen.mpg.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1728059AbfBEKBn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 5 Feb 2019 05:01:43 -0500
Received: from theinternet.molgen.mpg.de (theinternet.molgen.mpg.de [141.14.31.7])
        by mx.molgen.mpg.de (Postfix) with ESMTP id 36FFF201353436;
        Tue,  5 Feb 2019 11:01:41 +0100 (CET)
From:   Donald Buczek <buczek@molgen.mpg.de>
To:     stable@vger.kernel.org
Cc:     linux-nfs@vger.kernel.org, bfields@fieldses.org
Subject: [PATCH 4.14 1/2] nfsd4: fix cached replies to solo SEQUENCE compounds
Date:   Tue,  5 Feb 2019 11:01:40 +0100
Message-Id: <20190205100141.25304-2-buczek@molgen.mpg.de>
X-Mailer: git-send-email 2.20.0
In-Reply-To: <20190205100141.25304-1-buczek@molgen.mpg.de>
References: <20190205100141.25304-1-buczek@molgen.mpg.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: "J. Bruce Fields" <bfields@redhat.com>

commit 085def3ade52f2ffe3e31f42e98c27dcc222dd37 upstream.

Currently our handling of 4.1+ requests without "cachethis" set is
confusing and not quite correct.

Suppose a client sends a compound consisting of only a single SEQUENCE
op, and it matches the seqid in a session slot (so it's a retry), but
the previous request with that seqid did not have "cachethis" set.

The obvious thing to do might be to return NFS4ERR_RETRY_UNCACHED_REP,
but the protocol only allows that to be returned on the op following the
SEQUENCE, and there is no such op in this case.

The protocol permits us to cache replies even if the client didn't ask
us to.  And it's easy to do so in the case of solo SEQUENCE compounds.

So, when we get a solo SEQUENCE, we can either return the previously
cached reply or NFSERR_SEQ_FALSE_RETRY if we notice it differs in some
way from the original call.

Currently, we're returning a corrupt reply in the case a solo SEQUENCE
matches a previous compound with more ops.  This actually matters
because the Linux client recently started doing this as a way to recover
from lost replies to idempotent operations in the case the process doing
the original reply was killed: in that case it's difficult to keep the
original arguments around to do a real retry, and the client no longer
cares what the result is anyway, but it would like to make sure that the
slot's sequence id has been incremented, and the solo SEQUENCE assures
that: if the server never got the original reply, it will increment the
sequence id.  If it did get the original reply, it won't increment, and
nothing else that about the reply really matters much.  But we can at
least attempt to return valid xdr!

Tested-by: Olga Kornievskaia <aglo@umich.edu>
Signed-off-by: J. Bruce Fields <bfields@redhat.com>
Signed-off-by: Donald Buczek <buczek@molgen.mpg.de>
---
 fs/nfsd/nfs4state.c | 20 +++++++++++++++-----
 fs/nfsd/state.h     |  1 +
 fs/nfsd/xdr4.h      | 13 +++++++++++--
 3 files changed, 27 insertions(+), 7 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 3cef6bfa09d4..177be048c17f 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2331,14 +2331,16 @@ nfsd4_store_cache_entry(struct nfsd4_compoundres *resp)
 
 	dprintk("--> %s slot %p\n", __func__, slot);
 
+	slot->sl_flags |= NFSD4_SLOT_INITIALIZED;
 	slot->sl_opcnt = resp->opcnt;
 	slot->sl_status = resp->cstate.status;
 
-	slot->sl_flags |= NFSD4_SLOT_INITIALIZED;
-	if (nfsd4_not_cached(resp)) {
-		slot->sl_datalen = 0;
+	if (!nfsd4_cache_this(resp)) {
+		slot->sl_flags &= ~NFSD4_SLOT_CACHED;
 		return;
 	}
+	slot->sl_flags |= NFSD4_SLOT_CACHED;
+
 	base = resp->cstate.data_offset;
 	slot->sl_datalen = buf->len - base;
 	if (read_bytes_from_xdr_buf(buf, base, slot->sl_data, slot->sl_datalen))
@@ -2365,8 +2367,16 @@ nfsd4_enc_sequence_replay(struct nfsd4_compoundargs *args,
 	op = &args->ops[resp->opcnt - 1];
 	nfsd4_encode_operation(resp, op);
 
-	/* Return nfserr_retry_uncached_rep in next operation. */
-	if (args->opcnt > 1 && !(slot->sl_flags & NFSD4_SLOT_CACHETHIS)) {
+	if (slot->sl_flags & NFSD4_SLOT_CACHED)
+		return op->status;
+	if (args->opcnt == 1) {
+		/*
+		 * The original operation wasn't a solo sequence--we
+		 * always cache those--so this retry must not match the
+		 * original:
+		 */
+		op->status = nfserr_seq_false_retry;
+	} else {
 		op = &args->ops[resp->opcnt++];
 		op->status = nfserr_retry_uncached_rep;
 		nfsd4_encode_operation(resp, op);
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 005c911b34ac..2488b7df1b35 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -174,6 +174,7 @@ struct nfsd4_slot {
 #define NFSD4_SLOT_INUSE	(1 << 0)
 #define NFSD4_SLOT_CACHETHIS	(1 << 1)
 #define NFSD4_SLOT_INITIALIZED	(1 << 2)
+#define NFSD4_SLOT_CACHED	(1 << 3)
 	u8	sl_flags;
 	char	sl_data[];
 };
diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
index aa4375eac475..f47c392cbd57 100644
--- a/fs/nfsd/xdr4.h
+++ b/fs/nfsd/xdr4.h
@@ -651,9 +651,18 @@ static inline bool nfsd4_is_solo_sequence(struct nfsd4_compoundres *resp)
 	return resp->opcnt == 1 && args->ops[0].opnum == OP_SEQUENCE;
 }
 
-static inline bool nfsd4_not_cached(struct nfsd4_compoundres *resp)
+/*
+ * The session reply cache only needs to cache replies that the client
+ * actually asked us to.  But it's almost free for us to cache compounds
+ * consisting of only a SEQUENCE op, so we may as well cache those too.
+ * Also, the protocol doesn't give us a convenient response in the case
+ * of a replay of a solo SEQUENCE op that wasn't cached
+ * (RETRY_UNCACHED_REP can only be returned in the second op of a
+ * compound).
+ */
+static inline bool nfsd4_cache_this(struct nfsd4_compoundres *resp)
 {
-	return !(resp->cstate.slot->sl_flags & NFSD4_SLOT_CACHETHIS)
+	return (resp->cstate.slot->sl_flags & NFSD4_SLOT_CACHETHIS)
 		|| nfsd4_is_solo_sequence(resp);
 }
 
-- 
2.20.0


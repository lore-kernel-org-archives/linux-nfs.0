Return-Path: <SRS0=v/uS=QM=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9F1EAC4151A
	for <linux-nfs@archiver.kernel.org>; Tue,  5 Feb 2019 10:01:44 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 77E322175B
	for <linux-nfs@archiver.kernel.org>; Tue,  5 Feb 2019 10:01:44 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728207AbfBEKBn (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 5 Feb 2019 05:01:43 -0500
Received: from mx3.molgen.mpg.de ([141.14.17.11]:50751 "EHLO mx1.molgen.mpg.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1727099AbfBEKBn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 5 Feb 2019 05:01:43 -0500
Received: from theinternet.molgen.mpg.de (theinternet.molgen.mpg.de [141.14.31.7])
        by mx.molgen.mpg.de (Postfix) with ESMTP id 426D0201353437;
        Tue,  5 Feb 2019 11:01:41 +0100 (CET)
From:   Donald Buczek <buczek@molgen.mpg.de>
To:     stable@vger.kernel.org
Cc:     linux-nfs@vger.kernel.org, bfields@fieldses.org
Subject: [PATCH 4.14 2/2] nfsd4: catch some false session retries
Date:   Tue,  5 Feb 2019 11:01:41 +0100
Message-Id: <20190205100141.25304-3-buczek@molgen.mpg.de>
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

commit 53da6a53e1d414e05759fa59b7032ee08f4e22d7 upstream.

The spec allows us to return NFS4ERR_SEQ_FALSE_RETRY if we notice that
the client is making a call that matches a previous (slot, seqid) pair
but that *isn't* actually a replay, because some detail of the call
doesn't actually match the previous one.

Catching every such case is difficult, but we may as well catch a few
easy ones.  This also handles the case described in the previous patch,
in a different way.

The spec does however require us to catch the case where the difference
is in the rpc credentials.  This prevents somebody from snooping another
user's replies by fabricating retries.

(But the practical value of the attack is limited by the fact that the
replies with the most sensitive data are READ replies, which are not
normally cached.)

Tested-by: Olga Kornievskaia <aglo@umich.edu>
Signed-off-by: J. Bruce Fields <bfields@redhat.com>
Signed-off-by: Donald Buczek <buczek@molgen.mpg.de>
---
 fs/nfsd/nfs4state.c | 37 ++++++++++++++++++++++++++++++++++++-
 fs/nfsd/state.h     |  1 +
 2 files changed, 37 insertions(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 177be048c17f..94128643ec1a 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1472,8 +1472,10 @@ free_session_slots(struct nfsd4_session *ses)
 {
 	int i;
 
-	for (i = 0; i < ses->se_fchannel.maxreqs; i++)
+	for (i = 0; i < ses->se_fchannel.maxreqs; i++) {
+		free_svc_cred(&ses->se_slots[i]->sl_cred);
 		kfree(ses->se_slots[i]);
+	}
 }
 
 /*
@@ -2334,6 +2336,8 @@ nfsd4_store_cache_entry(struct nfsd4_compoundres *resp)
 	slot->sl_flags |= NFSD4_SLOT_INITIALIZED;
 	slot->sl_opcnt = resp->opcnt;
 	slot->sl_status = resp->cstate.status;
+	free_svc_cred(&slot->sl_cred);
+	copy_cred(&slot->sl_cred, &resp->rqstp->rq_cred);
 
 	if (!nfsd4_cache_this(resp)) {
 		slot->sl_flags &= ~NFSD4_SLOT_CACHED;
@@ -3040,6 +3044,34 @@ static bool nfsd4_request_too_big(struct svc_rqst *rqstp,
 	return xb->len > session->se_fchannel.maxreq_sz;
 }
 
+static bool replay_matches_cache(struct svc_rqst *rqstp,
+		 struct nfsd4_sequence *seq, struct nfsd4_slot *slot)
+{
+	struct nfsd4_compoundargs *argp = rqstp->rq_argp;
+
+	if ((bool)(slot->sl_flags & NFSD4_SLOT_CACHETHIS) !=
+	    (bool)seq->cachethis)
+		return false;
+	/*
+	 * If there's an error than the reply can have fewer ops than
+	 * the call.  But if we cached a reply with *more* ops than the
+	 * call you're sending us now, then this new call is clearly not
+	 * really a replay of the old one:
+	 */
+	if (slot->sl_opcnt < argp->opcnt)
+		return false;
+	/* This is the only check explicitly called by spec: */
+	if (!same_creds(&rqstp->rq_cred, &slot->sl_cred))
+		return false;
+	/*
+	 * There may be more comparisons we could actually do, but the
+	 * spec doesn't require us to catch every case where the calls
+	 * don't match (that would require caching the call as well as
+	 * the reply), so we don't bother.
+	 */
+	return true;
+}
+
 __be32
 nfsd4_sequence(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		union nfsd4_op_u *u)
@@ -3099,6 +3131,9 @@ nfsd4_sequence(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		status = nfserr_seq_misordered;
 		if (!(slot->sl_flags & NFSD4_SLOT_INITIALIZED))
 			goto out_put_session;
+		status = nfserr_seq_false_retry;
+		if (!replay_matches_cache(rqstp, seq, slot))
+			goto out_put_session;
 		cstate->slot = slot;
 		cstate->session = session;
 		cstate->clp = clp;
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 2488b7df1b35..86aa92d200e1 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -169,6 +169,7 @@ static inline struct nfs4_delegation *delegstateid(struct nfs4_stid *s)
 struct nfsd4_slot {
 	u32	sl_seqid;
 	__be32	sl_status;
+	struct svc_cred sl_cred;
 	u32	sl_datalen;
 	u16	sl_opcnt;
 #define NFSD4_SLOT_INUSE	(1 << 0)
-- 
2.20.0


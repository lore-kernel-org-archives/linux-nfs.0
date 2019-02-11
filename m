Return-Path: <SRS0=ULVj=QS=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_MUTT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5068CC282D7
	for <linux-nfs@archiver.kernel.org>; Mon, 11 Feb 2019 15:59:34 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 11E2B218D8
	for <linux-nfs@archiver.kernel.org>; Mon, 11 Feb 2019 15:59:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="eatvlweN"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1731430AbfBKP7c (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 11 Feb 2019 10:59:32 -0500
Received: from mail-ed1-f67.google.com ([209.85.208.67]:40780 "EHLO
        mail-ed1-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1730873AbfBKP7c (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 11 Feb 2019 10:59:32 -0500
Received: by mail-ed1-f67.google.com with SMTP id 10so3091309eds.7;
        Mon, 11 Feb 2019 07:59:29 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=sZr5/503F3oduux+Pr5Cf1BMLLGx47tISd3qc011ISw=;
        b=eatvlweNtrCwxL/cg8dUDqb17t2NJ2vK50gubHj5EdQR+uj4G80U3SkeNcFs6P51te
         dZwwBwdn6xHqrU2bv9gXs586OnLwgRgocfujkqPeW+uDEuSj5sT37UHRuBu6bz0JcfbS
         S2jqWQnF+Hn70MasParfH9m2Ra6Iau8ImtKkS1kTCqfk2Cr3pP20grU8OgyjLID16QvT
         17CZASGjNQfZk1+H4Pl6apsmbkWCuZ73TJhBoGn+6aGDi4JLrCZVfZFqXBS88+gVu8CZ
         5o3QwOMykwQq3q/QfB9jk6zqqjxHvn4JUaELX1zYKTh694joT7g7mWsUc06EQHPLb9O3
         n4wg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:date:from:to:cc:subject:message-id
         :references:mime-version:content-disposition:in-reply-to:user-agent;
        bh=sZr5/503F3oduux+Pr5Cf1BMLLGx47tISd3qc011ISw=;
        b=aPdPEWivewftRWL/L+vAHAQm8apnGSBTCW9KI2kIQvgCVX5n4UomO/8t9a5iBiR/OK
         uNh5XB4+mhvjbHBQcBunGfVRtgno8F/joALNBzcto2KZahErn4+u8JHUDBziSquGCp9D
         cTpfvTqCtTgwqEeTIHaZtscJs7P44etq0qsWvVaJjbr67wcsxK5pg1hu3oBbKJQ2bnDE
         vE75ru+NlRNCzEhUnR0xTGz1/VTE5Ut7aR0XxSmdiPsSEXxP4iXtZw5EtWwSytRk1NMU
         fU1Cwe0n+RMqQnJnZyWXE2uqQ4k0ZcTnghq8oyOl360X025scPmintqXVbmGzbeew4PR
         kbzw==
X-Gm-Message-State: AHQUAuYy46l9wG28EPfDEOYB2SKw6J5T986/HTozfKVASEwbw5+qdt6f
        RtY37biKjLd4Xc7lLyWsdIfzF8mWGwY=
X-Google-Smtp-Source: AHgI3IbSMPxEJUzxgjfLoy+k1NeurTKxnb2n9HVFy6txy625m0eB3B6NUjDx3ZP7wK6maK3vbZov3g==
X-Received: by 2002:a50:9624:: with SMTP id y33mr28814720eda.206.1549900768594;
        Mon, 11 Feb 2019 07:59:28 -0800 (PST)
Received: from eldamar (80-218-24-251.dclient.hispeed.ch. [80.218.24.251])
        by smtp.gmail.com with ESMTPSA id m13sm3187291edd.2.2019.02.11.07.59.27
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 11 Feb 2019 07:59:27 -0800 (PST)
Date:   Mon, 11 Feb 2019 16:59:26 +0100
From:   Salvatore Bonaccorso <carnil@debian.org>
To:     Greg KH <greg@kroah.com>
Cc:     Donald Buczek <buczek@molgen.mpg.de>, stable@vger.kernel.org,
        linux-nfs@vger.kernel.org, bfields@fieldses.org
Subject: Re: [PATCH 4.14 0/2] Two nfsd4 fixes for 4.14 longterm
Message-ID: <20190211155926.GA19955@eldamar.local>
References: <20190205100141.25304-1-buczek@molgen.mpg.de>
 <20190205115948.azdwswkyetbop56r@lorien.valinor.li>
 <7a263d82-27e7-077f-3a51-78180785a41f@molgen.mpg.de>
 <20190211133441.GA17709@kroah.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="k+w/mQv8wyuph6w0"
Content-Disposition: inline
In-Reply-To: <20190211133441.GA17709@kroah.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org


--k+w/mQv8wyuph6w0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Mon, Feb 11, 2019 at 02:34:41PM +0100, Greg KH wrote:
> On Tue, Feb 05, 2019 at 03:59:04PM +0100, Donald Buczek wrote:
> > On 02/05/19 12:59, Salvatore Bonaccorso wrote:
> > 
> > > Are you planning to submit the same as well for 4.9 LTS? The two
> > > commits apply on top of 4.9.154 with line number updated.
> > 
> > No, I'm not, because I didn't do any testing with 4.9.
> > 
> > Additionally, I'm unsure about the right procedure for trivial backports
> > to multiple trees: Individual patch sets, which apply perfectly, a single
> > patch sets and Greg resolves that for the other trees or maybe no patch
> > set at all and just a "please cherry-pick .... from upstream" mail.
> 
> The first patch in this series applies to 4.9.y, but the second does
> not.
> 
> I'll be glad to take a backported, and tested, series, if someone still
> cares about NFS for 4.9.y.  But unless you really care about that tree,
> I would not worry about it.

Hmm, both apply on top of 4.9.155, still but with line numbers
adjusted (I'm attaching the respective rebased patches). Actually my
question on the respective backports was originally triggered due to
https://bugs-devel.debian.org/898060

The problem actually is on the 'tested' part, as Donald did no
testing/reproducing with 4.9 itself.

Regards,
Salvatore

--k+w/mQv8wyuph6w0
Content-Type: text/x-diff; charset=us-ascii
Content-Disposition: attachment; filename="0001-nfsd4-fix-cached-replies-to-solo-SEQUENCE-compounds.patch"

From d54d2762cfa2b01fee19e4641f3f242bebd0aded Mon Sep 17 00:00:00 2001
From: "J. Bruce Fields" <bfields@redhat.com>
Date: Wed, 18 Oct 2017 16:17:18 -0400
Subject: [PATCH 1/2] nfsd4: fix cached replies to solo SEQUENCE compounds

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
---
 fs/nfsd/nfs4state.c | 20 +++++++++++++++-----
 fs/nfsd/state.h     |  1 +
 fs/nfsd/xdr4.h      | 13 +++++++++++--
 3 files changed, 27 insertions(+), 7 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 12d780718b48..88168ce0e882 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2344,14 +2344,16 @@ nfsd4_store_cache_entry(struct nfsd4_compoundres *resp)
 
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
@@ -2378,8 +2380,16 @@ nfsd4_enc_sequence_replay(struct nfsd4_compoundargs *args,
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
index 8fda4abdf3b1..448e74e32344 100644
--- a/fs/nfsd/xdr4.h
+++ b/fs/nfsd/xdr4.h
@@ -645,9 +645,18 @@ static inline bool nfsd4_is_solo_sequence(struct nfsd4_compoundres *resp)
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
2.20.1


--k+w/mQv8wyuph6w0
Content-Type: text/x-diff; charset=us-ascii
Content-Disposition: attachment; filename="0002-nfsd4-catch-some-false-session-retries.patch"

From 59d8d507a097666ed2237984ae3548f6383fab7e Mon Sep 17 00:00:00 2001
From: "J. Bruce Fields" <bfields@redhat.com>
Date: Tue, 17 Oct 2017 20:38:49 -0400
Subject: [PATCH 2/2] nfsd4: catch some false session retries

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
---
 fs/nfsd/nfs4state.c | 37 ++++++++++++++++++++++++++++++++++++-
 fs/nfsd/state.h     |  1 +
 2 files changed, 37 insertions(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 88168ce0e882..3656f87d11e3 100644
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
@@ -2347,6 +2349,8 @@ nfsd4_store_cache_entry(struct nfsd4_compoundres *resp)
 	slot->sl_flags |= NFSD4_SLOT_INITIALIZED;
 	slot->sl_opcnt = resp->opcnt;
 	slot->sl_status = resp->cstate.status;
+	free_svc_cred(&slot->sl_cred);
+	copy_cred(&slot->sl_cred, &resp->rqstp->rq_cred);
 
 	if (!nfsd4_cache_this(resp)) {
 		slot->sl_flags &= ~NFSD4_SLOT_CACHED;
@@ -3049,6 +3053,34 @@ static bool nfsd4_request_too_big(struct svc_rqst *rqstp,
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
 nfsd4_sequence(struct svc_rqst *rqstp,
 	       struct nfsd4_compound_state *cstate,
@@ -3108,6 +3140,9 @@ nfsd4_sequence(struct svc_rqst *rqstp,
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
2.20.1


--k+w/mQv8wyuph6w0--

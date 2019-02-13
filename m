Return-Path: <SRS0=saDi=QU=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_NEOMUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 874E5C282CE
	for <linux-nfs@archiver.kernel.org>; Wed, 13 Feb 2019 06:50:03 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 58695222C7
	for <linux-nfs@archiver.kernel.org>; Wed, 13 Feb 2019 06:50:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="sYfwoi1Y"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2387417AbfBMGuC (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 13 Feb 2019 01:50:02 -0500
Received: from mail-wm1-f66.google.com ([209.85.128.66]:39591 "EHLO
        mail-wm1-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726411AbfBMGuC (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 13 Feb 2019 01:50:02 -0500
Received: by mail-wm1-f66.google.com with SMTP id f16so1112185wmh.4;
        Tue, 12 Feb 2019 22:49:59 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=Jw7TqIKiCLf6wQmCJGM88zE9nZCScsYTKo7LAitmKJM=;
        b=sYfwoi1YBWYubH8YrbSrleKhUYWelWySoofde8DiC5SkTax2hX2j09laahD3imaCS2
         9Wf1eokqLCncUhrIUZvGwvJCNVtC2FrhEeKlpu4J72TEJ/cWX7B9zQq9HW3BcyybQe0n
         KTU+/VWPCeK8mYW74a7dkwQJIu/91NlSSwTNchF84FM9XUE5sw9/st95DYxN488AJaeh
         kU7zUKB2r5horlqYOgcgmYPotHfcsCEVMG6b4yGjoo7mfWC4CoWX5usWpoR8ySsxuQDz
         akUNqmoOtDycpZECt4juBafOw2vj1a90cgidUZ76akrnQq6mFmS4ygGn7snuVAX9iccw
         IvPA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:date:from:to:cc:subject:message-id
         :references:mime-version:content-disposition:in-reply-to:user-agent;
        bh=Jw7TqIKiCLf6wQmCJGM88zE9nZCScsYTKo7LAitmKJM=;
        b=hKgauhZ3C2YMNrmu6KNoDEuIkqzP5htfN/0RIY3uqzpNv79fMdSlyZV8I0eXtIK1TW
         fmGBr1gzidfLAD0RkpO+Y3EpyawtkGnI6Ho8vy3XS2YePxMI6quKC1x3VPr5o5iGJgck
         ZQI2roNxf7iKvFgGS7rtH0Eyi/g61ekvRk6/7J4tEIOxUmRBzfrkJjfvXqYWb7vn+/4a
         J++PODitHhX1d/IxkS36BOeszZ0KpWVHm3H9F3NYVIR1ZKLEroWwqoWRCBne9fNu1iek
         n9x5iueussPltj7XQVJbFvmMZH/RMNidPTnTgYnT7Y02YuhCE+a7Ga3GernDmNeyg7A0
         6Ffw==
X-Gm-Message-State: AHQUAubzersQmQ5ii8Fp3BdMQ6iBPiI2KG+MdnRIeCk5KaQLrCP+kB+a
        4dIf3xlvxn9ma7mpnqRGz+IjzuTNOPM=
X-Google-Smtp-Source: AHgI3IZSd5KnO16Hk8xH1S3tBvhK4GRjPW5F+BVl+4mZUFoeY01ZKdxE0j9RFyFmPd6fEVz9P/TBFw==
X-Received: by 2002:a1c:7304:: with SMTP id d4mr1823337wmb.136.1550040599036;
        Tue, 12 Feb 2019 22:49:59 -0800 (PST)
Received: from lorien (lorien.valinor.li. [2a01:4f8:192:61d5::2])
        by smtp.gmail.com with ESMTPSA id z3sm9931330wmi.32.2019.02.12.22.49.57
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 12 Feb 2019 22:49:57 -0800 (PST)
Date:   Wed, 13 Feb 2019 07:49:56 +0100
From:   Salvatore Bonaccorso <carnil@debian.org>
To:     Greg KH <greg@kroah.com>
Cc:     Donald Buczek <buczek@molgen.mpg.de>, stable@vger.kernel.org,
        linux-nfs@vger.kernel.org, bfields@fieldses.org
Subject: Re: [PATCH 4.14 0/2] Two nfsd4 fixes for 4.14 longterm
Message-ID: <20190213064956.i57glcw5qql6t6qr@lorien.valinor.li>
References: <20190205100141.25304-1-buczek@molgen.mpg.de>
 <20190205115948.azdwswkyetbop56r@lorien.valinor.li>
 <7a263d82-27e7-077f-3a51-78180785a41f@molgen.mpg.de>
 <20190211133441.GA17709@kroah.com>
 <20190211155926.GA19955@eldamar.local>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="6tptyn4c3azyw4id"
Content-Disposition: inline
In-Reply-To: <20190211155926.GA19955@eldamar.local>
User-Agent: NeoMutt/20170113 (1.7.2)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org


--6tptyn4c3azyw4id
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Mon, Feb 11, 2019 at 04:59:26PM +0100, Salvatore Bonaccorso wrote:
> On Mon, Feb 11, 2019 at 02:34:41PM +0100, Greg KH wrote:
> > On Tue, Feb 05, 2019 at 03:59:04PM +0100, Donald Buczek wrote:
> > > On 02/05/19 12:59, Salvatore Bonaccorso wrote:
> > > 
> > > > Are you planning to submit the same as well for 4.9 LTS? The two
> > > > commits apply on top of 4.9.154 with line number updated.
> > > 
> > > No, I'm not, because I didn't do any testing with 4.9.
> > > 
> > > Additionally, I'm unsure about the right procedure for trivial backports
> > > to multiple trees: Individual patch sets, which apply perfectly, a single
> > > patch sets and Greg resolves that for the other trees or maybe no patch
> > > set at all and just a "please cherry-pick .... from upstream" mail.
> > 
> > The first patch in this series applies to 4.9.y, but the second does
> > not.
> > 
> > I'll be glad to take a backported, and tested, series, if someone still
> > cares about NFS for 4.9.y.  But unless you really care about that tree,
> > I would not worry about it.
> 
> Hmm, both apply on top of 4.9.155, still but with line numbers
> adjusted (I'm attaching the respective rebased patches). Actually my
> question on the respective backports was originally triggered due to
> https://bugs-devel.debian.org/898060
> 
> The problem actually is on the 'tested' part, as Donald did no
> testing/reproducing with 4.9 itself.

Attached rebased to apply on top of 4.9.156.

Regards,
Salvatore

--6tptyn4c3azyw4id
Content-Type: text/x-diff; charset=us-ascii
Content-Disposition: attachment; filename="0001-nfsd4-fix-cached-replies-to-solo-SEQUENCE-compounds.patch"

From 435d215dcdf1aba9529cc402f68c913e43676445 Mon Sep 17 00:00:00 2001
From: "J. Bruce Fields" <bfields@redhat.com>
Date: Wed, 18 Oct 2017 16:17:18 -0400
Subject: nfsd4: fix cached replies to solo SEQUENCE compounds

[ Upstream commit 085def3ade52f2ffe3e31f42e98c27dcc222dd37 ]

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
2.11.0


--6tptyn4c3azyw4id
Content-Type: text/x-diff; charset=us-ascii
Content-Disposition: attachment; filename="0002-nfsd4-catch-some-false-session-retries.patch"

From 1b2a30bd22b61432678763e1b4106692d7d514ba Mon Sep 17 00:00:00 2001
From: "J. Bruce Fields" <bfields@redhat.com>
Date: Tue, 17 Oct 2017 20:38:49 -0400
Subject: nfsd4: catch some false session retries

[ Upstream commit 53da6a53e1d414e05759fa59b7032ee08f4e22d7 ]

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
2.11.0


--6tptyn4c3azyw4id--

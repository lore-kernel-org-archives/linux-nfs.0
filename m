Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795021319;
	b=TqSJSXzDmosIRsC0ebcHd10MWE6ie4jhfBqMc9H4hVwPbgXCC7VVxRvaMog5kqcU3U5O
	 tDxoFzlb6zwasmBzo5lUV4e7ucjjjay9M77m/NJTbPe6Ei0+NwaECtwJndOxy7YBlU6Lz
	 xiKJv3KhSiJLIuewGETCZfvmhYrIHWQ/e1Scsj7xsAwgNp1KtEVjRLUFRFRQJlEyqyYBn
	 f+GyKb5jTKoX+fVJXxqwvZMicdzf8RXLg7Z4eovk9r08Rlxlo3Az3x64X2xvkuWrvwLiv
	 uQ2/pJseTIQ+J9BSwuWhTZgxC6yzLLGDBr7LqhKsGZdjdEhJX4Iws4dUYHMUaDEg8lQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795021319;
	h=Received:DKIM-Signature:Received:Received:X-ME-Sender:
	 X-ME-Proxy-Cause:X-ME-Proxy:Feedback-ID:Received:X-Mailer:
	 MIME-Version:X-ThreadId:Date:From:To:Cc:Message-Id:In-Reply-To:
	 References:Subject:Content-Type:Content-Transfer-Encoding;
	bh=RF7QX6h9cEM3dm/nBAflY+qZcrRok+wmEcNGJnmN+4Y=;
	b=oPH9G/0AId+nPy+nLITn2OMfgdcrnzuf1QOadg192IKOe1Nf6mTKDKvX2YBPTsG11qAR
	 ZnMpBmpV/IpxbYT4DemaD3LOjPu8x+HNFn81NHApUz8OaIry6XaKYJQfKUHgofkC3/EuA
	 k9qmnBLfVosu4DJtkov3hd7I6/RYxDTDUhItkxe20ol6gF21WEJT45ZxJJPAFecz1DK6y
	 CauXG8Cd4X3LpUZfQSIhRphkLpgdPV02ue6SaVc6fJ0wVwDFszxxsYrVyExTnNL1Q1RCb
	 7Rl5E9AqDKxMQ2lATB9p2sA45s2ZxVV0RSFrALSc3/0Y4LyvPE4W1spt0iLzeSgkfZA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=BKl4sRqu;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0513A606A31C
	for <linux-nfs@vger.kernel.org>; Wed, 18 Nov 2026 17:01:58 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=BKl4sRqu
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 6E8171F000C6;
	Wed, 18 Nov 2026 17:01:58 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1795021318;
	bh=RF7QX6h9cEM3dm/nBAflY+qZcrRok+wmEcNGJnmN+4Y=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=BKl4sRqujEemAy9iSm5Teu1Yee649OwEQXyDvl0MshoiDdYoGzPp4CYiPovlwzFQ8
	 Et4xXZCIN7lE3HRB6FMa+JiAcADVCr1QMvr2s+C4NEvVTdLole0s3gn95HHqlO8dxo
	 4umxo65R1yAbxCxMP7qwv4bxmcivoa2NqNXGXFcxARxWqLGlbgPxmCB8xkpFI1Mw5K
	 TSrYtISN/mJ3aSnw5RisPvofEFuP4xtf70jCuiIYsSw4+Kd1vuMiJ//oKiSQwiX9mr
	 bFiPVbQoQz2zh1PPAqbzxrk5VHWWKylAlBV9A+GavBrm+i+lR5dIlDDeaq2IfM6Fhr
	 uE8fFG4Df868g==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id A94D7F4006D;
	Wed, 18 Nov 2026 12:01:57 -0500 (EST)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Wed, 18 Nov 2026 12:01:57 -0500
X-ME-Sender: <xms:Bdr9ao-R7v9rr4CueHyDGC6F0nFRDINUdTe0qXz9uVdO3J5dXhXaXg>
    <xme:Bdr9arhHvVwSd3vWroHF2zARasRtHP6d2AmKSmP0j7Do_5Y3uhJI_AEcJNDRQy7S9
    u_yuJXXryeeyqKzINp_aEmCPoThHWPjOdoLqm0uND3DxXgxFDhb9v9i>
X-ME-Proxy-Cause: dmFkZTEoTjgii3XS4BBKybyYC/qOwmkqo5BDr4HMM6ZdHJ3zYc+q+e9Dngxfztaa8GnGke
    O1AOjNlxgC1Dm2FC96KyHtCM5566I81iePro+LyF8go6YvQMuLF3gqPQDJputb0isB6fsP
    yXblNo6RXgeL03juC9ep+dLwEyPUxZcOMZhsUXwoimHux6J7HYx1bYrb/c9S1iNcYM5eRW
    nDjl0D6Qn+w8z57+sd7N268jw9eUoxgRupq90zB8XGwY1/aFZ4kJ+/C7fOPjnOYUp6UTxG
    sURYvKggbIHtTxRkRYSbDh6q1kiXnF3rfrbu0wyv9CcR11XlR4zIxDS+fGuzgvRz81s5eb
    G8FyWYMrCuZciFGJ516ltG1jKWEics2Mdt9udWy5KPay49Xf8tQxQkPg9ucpv+OJMAi/2f
    TcKmqLh9qu/5VwQqdTVSlkdlQA/zegOqb9ycpu1RTbRmGVDYDjTezZ5JIK0OUvmwLuRQYo
    PHMCeL5u+BAV1k1art7evPTIXSawTBsQrjzXF7IuzPqdTNFOEdWZh80stBCA6G+JMf805r
    SZA79DC6BETIS7CLtIAlrswXrUtywVXH0OSCz6m/z1d1ofYBhbfXZp3FjRAUErZC13VXLF
    mdgzHKG4IwK51EaAJ1DB9GO9+I8fzMLGaVICVSQH7KsS74HdqWx+yXd9TOyQ
X-ME-Proxy: <xmx:Bdr9agVr3vTyDm5oPfSfBONPh7clgkigtZ9eBewVT9FZjNtU2dp5ow>
    <xmx:Bdr9alR9JaS9wm_0-a4xY3F_AnHcnvixWdugRklS5lEDJW6SL_wCkg>
    <xmx:Bdr9aimptDvMQTcdUfhzmAFjjE3BmVCrX6xoOof8QhqJR_P7BemMxQ>
    <xmx:Bdr9aj48AI6naorzlOtNyG84q6jlR7QM2A37rzNJgezAkmiPMwhjtQ>
    <xmx:Bdr9agi2O23cd_cakINWuDSTbLqii1nwALncoIuiZP9zuVrxQoHDSDmK>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 8CDC5780076; Wed, 18 Nov 2026 12:01:57 -0500 (EST)
X-Mailer: MessagingEngine.com Webmail Interface
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
X-ThreadId: AI3BvNtEmVlk
Date: Wed, 18 Nov 2026 12:01:37 -0500
From: "Chuck Lever" <cel@kernel.org>
To: "Kari Pulli" <kari@smasint.com>
Cc: linux-nfs@vger.kernel.org, "Jeff Layton" <jlayton@kernel.org>,
 NeilBrown <neil@brown.name>, "Olga Kornievskaia" <okorniev@redhat.com>,
 "Trond Myklebust" <trondmy@kernel.org>, "Anna Schumaker" <anna@kernel.org>
Message-Id: <9a186457-b96d-4f63-8b99-ae8fe6c34998@slotpi15m67>
In-Reply-To: 
 <CAPJN3b=1qd=5E7BVTCG6UtR7=BqUenM6j7zTuDHCEno5oj77hQ@mail.gmail.com>
References: 
 <CAPJN3b=1qd=5E7BVTCG6UtR7=BqUenM6j7zTuDHCEno5oj77hQ@mail.gmail.com>
Subject: Re: nfsd: session stuck in permanent NFS4ERR_SEQ_MISORDERED after the slot
 shrinker runs (7.0, with f5d22e372f4a and 1cff14b7fc7f)
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Tue, Nov 17, 2026, at 7:58 PM, Kari Pulli wrote:
> My guess is
> that the shrink never completes, because the client never meets the
> conditions in nfsd4_sequence() for freeing slots above
> se_target_maxslots, possibly because of the INUSE deferral, but I have
> not proven that.

NFSD and the Linux NFS client handle slot table shrinking separately.
It's possible the protocol permits races where the two sides become
misaligned about their slot table state.

The wedge is permanent because of how the client retries. After
NFS4ERR_SEQ_MISORDERED on a fresh slot, nfs41_sequence_process()
keeps seqid 1 and retries after a delay, still holding the slot.
While the client holds slots 264-269, every SEQUENCE carries an
sa_highest_slotid of at least 269. nfsd4_sequence() therefore never
sees seq->maxslots at or below the target, and never frees. The
retry loop matches the ~15 second queue time you measured, and
explains why only a new session recovers.

I don't yet understand how the client gets back up to slot numbers
above NFSD's target after dropping them. nconnect might have a role
in this.

The patch below adds a tracepoint, nfsd_slot_shrink, just before the
free decision in nfsd4_sequence(). It fires only while a shrink is
pending. The trace should show which one prevents the free. It
applies to v7.0 with f5d22e372f4a.

If you can run it with the drop_caches loop you suggested, please
capture:

  On the server:
    trace-cmd record -e nfsd:nfsd_slot_shrink \
        -e nfsd:nfsd_slot_seqid_sequence

  On one client:
    trace-cmd record -e nfs4:nfs4_sequence_done

Leave nfsd_slot_seqid_sequence unfiltered this time, and sample
/proc/fs/nfsd/clients/*/info every few seconds instead of every two
minutes. The client trace records each reply's highest_slotid and
target as the client applies them, which should settle the open
question above. The traces carry client addresses, so feel free to
send them to me off-list.


--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -4469,6 +4469,14 @@
 	if (status)
 		goto out_put_session;

+	if (trace_nfsd_slot_shrink_enabled() &&
+	    session->se_target_maxslots < session->se_fchannel.maxreqs) {
+		bool inuse = nfsd4_slots_inuse(session,
+					       session->se_target_maxslots);
+
+		trace_nfsd_slot_shrink(clp, seq, slot, session, inuse);
+	}
+
 	if (session->se_target_maxslots < session->se_fchannel.maxreqs &&
 	    slot->sl_generation == session->se_slot_gen &&
 	    seq->maxslots <= session->se_target_maxslots &&
--- a/fs/nfsd/trace.h
+++ b/fs/nfsd/trace.h
@@ -903,6 +903,47 @@
 	)
 );

+TRACE_EVENT(nfsd_slot_shrink,
+	TP_PROTO(
+		const struct nfs4_client *clp,
+		const struct nfsd4_sequence *seq,
+		const struct nfsd4_slot *slot,
+		const struct nfsd4_session *session,
+		bool inuse
+	),
+	TP_ARGS(clp, seq, slot, session, inuse),
+	TP_STRUCT__entry(
+		__field(u32, cl_boot)
+		__field(u32, cl_id)
+		__field(u32, slot_index)
+		__field(u32, seqid)
+		__field(u32, maxslots)
+		__field(u32, target)
+		__field(u32, maxreqs)
+		__field(u16, slot_gen)
+		__field(u16, session_gen)
+		__field(bool, inuse)
+	),
+	TP_fast_assign(
+		__entry->cl_boot = clp->cl_clientid.cl_boot;
+		__entry->cl_id = clp->cl_clientid.cl_id;
+		__entry->slot_index = seq->slotid;
+		__entry->seqid = seq->seqid;
+		__entry->maxslots = seq->maxslots;
+		__entry->target = session->se_target_maxslots;
+		__entry->maxreqs = session->se_fchannel.maxreqs;
+		__entry->slot_gen = slot->sl_generation;
+		__entry->session_gen = session->se_slot_gen;
+		__entry->inuse = inuse;
+	),
+	TP_printk("client %08x:%08x idx=%u seqid=%u maxslots=%u target=%u maxreqs=%u gen=%u/%u inuse=%d",
+		__entry->cl_boot, __entry->cl_id, __entry->slot_index,
+		__entry->seqid, __entry->maxslots, __entry->target,
+		__entry->maxreqs, __entry->slot_gen, __entry->session_gen,
+		__entry->inuse
+	)
+);
+
 DECLARE_EVENT_CLASS(nfsd_clientid_class,
 	TP_PROTO(const clientid_t *clid),
 	TP_ARGS(clid),

You can send the trace capture to cel@kernel.org directly to avoid
spamming the list.


-- 
Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)

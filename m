Received: from mail-yx1-f41.google.com (mail-yx1-f41.google.com [74.125.224.41])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E454742C513
	for <linux-nfs@vger.kernel.org>; Mon, 24 Aug 2026 17:37:16 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=74.125.224.41
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787593048; cv=none; b=RyOB+D1E//1FEDxQzYTH7v2K99/tcDTgBOLijGppS2W8lyH7rGJL1ExryW/69A3DAAzVEPJGT2B3a8UCtQeA+P61g/Pix9OcCRZFpYc2/s2IhKcwE5NSHm4DhXtt7aSbIcA3CYjffUZDn94/YUjfRwO93bc1AZf1ktWQavAawVs=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787593048; c=relaxed/simple;
	bh=y1LwkuJrKqmPKjA1nv1GBZdrDvHyK67PxeM6dHPhccQ=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=tO1DREOBpPf/U/1Zr3paiZ66No3i5gEO0tPOeEbsupno4ZcvLp3HMlrP2FQYlyJwoDaFm4m23z6vnJ9KHSHq6cP1cQlmbjVGiJsn9gaUdTZ+G547IQG+GH8NoXjfhTMWB99ykhRv9vLC0WLODWQo6JZKW0mzi9YjXLu1Gsvoxow=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=truenas.com; spf=pass smtp.mailfrom=truenas.com; dkim=pass (2048-bit key) header.d=truenas.com header.i=@truenas.com header.b=f7VWl28X; arc=none smtp.client-ip=74.125.224.41
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=truenas.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=truenas.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=truenas.com header.i=@truenas.com header.b="f7VWl28X"
Received: by mail-yx1-f41.google.com with SMTP id 956f58d0204a3-66d06b5f023so1937456d50.2
        for <linux-nfs@vger.kernel.org>; Mon, 24 Aug 2026 10:37:15 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=truenas.com; s=google; t=1787593033; x=1788197833; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=0ZPzoehwqsp1tcTgBFI/7UAjsP2nS8LuPRehc3KxXBQ=;
        b=f7VWl28Xb3QUv3lb0+xUOeDBSpEg7Q2USsx6esWyX3y6ydyeb5u65vuqYlJCM0nIAr
         1xQZv9mKQOpkxtjjMcqI+JZ3wfT7Pla2uanZ+F+Y0vuHOakontizBPhWaRlIYUQ4ZHjs
         3lo8L8lcCi1c5b1+HCMC3uoPnn6yb9QGSigKEWIRZ2DaHm6oPV+vZF/S1aAhFFSxfTNW
         NMoGEOucPskrJSCsPH7VFk+jWN1/suuP6EK/Y8f0BRCVeOQkBBm/RnKlmf2xAzomN3Zf
         gZYwBSgTeyO5RVIZWw+yLCYF7IGQmBpye7rPsDCtMa4ToNo39kfQvpPxtVUOhYe4m3Ox
         M+oQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1787593033; x=1788197833;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=0ZPzoehwqsp1tcTgBFI/7UAjsP2nS8LuPRehc3KxXBQ=;
        b=dujDe1b7syKOCnHaybpliILK2Xg7gdsbguxloKlHumRmC8p2HPDzaicYlW5x/+MTmo
         seWs9w/mVn4PSqy0ODpqbzr0u05jNlPJD8RUwCzNRAQyZkgjO75tbNvux1E7AyLv6pCD
         RP+N+8KIgazyiNiX/52ElcmUUbvWkagQj1jvQvYmODTER0W7Mdxbi6LtMQEA8H5DbCIO
         FnQGEszeZMfSHNPzaihvWl/ackXD/cdVerLjfLv1Hdkh2IRQkwN/gJjoqtZRijcQbPCu
         CGnUqwzsGYVdOfLywfTVYWgkAtrJYlsiwhNJFA/lE+QgE8NfvyQrTUZftdcnqCLVLw6T
         bBtg==
X-Gm-Message-State: AFuF++kcbMFvtf/1v9XYAAVv+bK7eKbvjffC+eUPjPqgdpY27UCIwWIa
	q9TUNS1EtgXtr2WXSMrmB8j6C/XShZIbTRUIuDR9OOn9ZErEPDyQEMCoE66C8MWXwQ==
X-Gm-Gg: AR+sD11P//vqsVPqUNmuuYp4KMf3MbwVnfxdxq2Gx8+CkIDxxM4L/D2ukzTPTbTG8+z
	yPRU0QgFez0eqK9MwN57Z0qCOShBWAzJYN/PoqEF+9F8plgF1dIeqoNLr3cFuJFLF9RckNLJ7GG
	XFgGLaF7xcpf2njF2gl5fJyyjAZf+YkoEXq3jeNAg+/sfl5Wb14MrZX0I8uHFZ7F4h5hOLTQKsB
	OM8i7OG5LiHnUEUIL0iyXuHXoYVv7GNoQx+hD9UxVlevjHzid+drmdIkjCLRhxvaRAODoKzJD1h
	dQs9RM58V1np2oQhmxuUdp0u/gkNmbJoKoiGEOMeF9Cu7w1UcfWMpy1qlPfgT+jf5YVv+jz7T3E
	OuRevxjyh2SI4GX8131n1GW+fBguSlmYG4+qTSIpfSyB05MiE2+HMW8iv5ZWNkBKBL5ULHM+CqV
	6f1qA90BxL6ow/tFtDnXOFn3HHfN8t9E2gUkG4eclLNcvNs/jBDBlX0oWgNfzm
X-Received: by 2002:a05:690e:1309:b0:66d:7b7:e36c with SMTP id 956f58d0204a3-66d07b7ea83mr2773799d50.48.1787593033079;
        Mon, 24 Aug 2026 10:37:13 -0700 (PDT)
Received: from hamza-PC ([124.29.197.38])
        by smtp.gmail.com with ESMTPSA id 956f58d0204a3-66cf4a2c204sm4214957d50.16.2026.08.24.10.37.09
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 24 Aug 2026 10:37:12 -0700 (PDT)
From: Ameer Hamza <ameer.hamza@truenas.com>
To: cel@kernel.org,
	jlayton@kernel.org,
	neil@brown.name,
	okorniev@redhat.com,
	Dai.Ngo@oracle.com,
	tom@talpey.com
Cc: linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	alexander.motin@truenas.com,
	caleb.stjohn@truenas.com,
	ameer.hamza@truenas.com
Subject: [PATCH] nfsd: don't modify a session slot when replaying its cached reply
Date: Mon, 24 Aug 2026 22:36:41 +0500
Message-ID: <20260824173641.3274260-1-ameer.hamza@truenas.com>
X-Mailer: git-send-email 2.53.0
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

nfsd4_sequence() claims a session slot by setting NFSD4_SLOT_INUSE
under nn->client_lock. A reply served from the slot's reply cache does
not claim it, and that distinction lived only in cstate->status, which
nfsd4_sequence() set to nfserr_replay_cache. Commit cc028a10a48c
("NFSD: Hoist status code encoding into XDR encoder functions") moved
nfsd4_proc_compound()'s cstate->status assignment below the out:
label, and the replay path's goto out was the one path that relied on
skipping it. The test in nfsd4_sequence_done() therefore no longer
identifies a replay, and every replay now stores its reply and clears
NFSD4_SLOT_INUSE as though it owned the slot.

NFSD4_SLOT_INUSE is the interlock: check_slot_seqid() rejects every
sequence id for a slot that is in use, before replay_matches_cache()
runs. A replay never sets it, so two replays can be in flight on the
same slot at once. One can read slot->sl_cred under nn->client_lock
while the other's completion frees and rebuilds it from the XDR
encoder without that lock. Two completions can also collide with each
other and release the same group_info twice. free_svc_cred() leaves
cr_uid, cr_gid and cr_flavor intact, so the reader passes every
earlier test in same_creds() and dereferences a NULL cr_group_info.
From a 6.12.91 production server:

  BUG: kernel NULL pointer dereference, address: 0000000000000004
  CPU: 63 UID: 0 PID: 39015 Comm: nfsd
  RIP: 0010:same_creds+0x38/0xa0 [nfsd]
  RDX: 0000000000000000
  Call Trace:
   nfsd4_sequence+0x6a8/0x910 [nfsd]
   nfsd4_proc_compound+0x345/0x670 [nfsd]
   nfsd_dispatch+0x100/0x220 [nfsd]
   svc_process_common+0x311/0x700 [sunrpc]
   svc_process+0x131/0x1c0 [sunrpc]
   svc_recv+0x7ef/0x9c0 [sunrpc]
   nfsd+0xa3/0x100 [nfsd]
  Kernel panic - not syncing: Fatal exception

Since v6.14 a live session's slot table can shrink, and the unowned
store becomes a use-after-free write. nfsd4_sequence() defers the
shrink while a slot is in use, but it tests NFSD4_SLOT_INUSE, which a
replay does not set, so free_session_slots() can kfree() the slot the
replay still holds in cstate->slot.

Record the claim in cstate->slot_owned when nfsd4_sequence() accepts a
request and test that in nfsd4_sequence_done(), so only the request
that claimed the slot updates its cached reply and clears
NFSD4_SLOT_INUSE. svc_generic_init_request() zeroes the compound
response before each request, so the flag starts clear.

Fixes: cc028a10a48c ("NFSD: Hoist status code encoding into XDR encoder functions")
Assisted-by: Claude:claude-opus-5
Signed-off-by: Ameer Hamza <ameer.hamza@truenas.com>
---
Reproduced on an unmodified tree with a client that pipelines two
copies of a cached request before reading either reply.

 fs/nfsd/nfs4state.c | 7 ++++++-
 fs/nfsd/xdr4.h      | 1 +
 2 files changed, 7 insertions(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 2c1b8b2cbbb5b..a4a75a512e9f0 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -5170,6 +5170,7 @@ nfsd4_sequence(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		slot->sl_flags &= ~NFSD4_SLOT_CACHETHIS;
 
 	cstate->slot = slot;
+	cstate->slot_owned = true;
 	cstate->session = session;
 	cstate->clp = clp;
 
@@ -5244,7 +5245,11 @@ nfsd4_sequence_done(struct nfsd4_compoundres *resp)
 	struct nfsd4_compound_state *cs = &resp->cstate;
 
 	if (nfsd4_has_session(cs)) {
-		if (cs->status != nfserr_replay_cache) {
+		/*
+		 * Only the request that claimed the slot may update its
+		 * cached reply and clear NFSD4_SLOT_INUSE.
+		 */
+		if (cs->slot_owned) {
 			nfsd4_store_cache_entry(resp);
 			cs->slot->sl_flags &= ~NFSD4_SLOT_INUSE;
 		}
diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
index b841bc462dac8..5b7edf1893e0a 100644
--- a/fs/nfsd/xdr4.h
+++ b/fs/nfsd/xdr4.h
@@ -62,6 +62,7 @@ struct nfsd4_compound_state {
 	struct nfsd4_slot	*slot;
 	int			data_offset;
 	bool                    spo_must_allowed;
+	bool			slot_owned;
 	size_t			iovlen;
 	u32			minorversion;
 	__be32			status;

base-commit: 46ff234c7129c7c10ed493413d4f60d0cf4dd1f1
-- 
2.53.0


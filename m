Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793581849;
	b=Ck1zBc4bp1dqBm9NLyZnExi9jUOSZUTYCSZWV2C2p3x2VHBEIdC3111R8BqY7+Z/8BgD
	 upgLQ69qyV1kSmwFjNaTgNKEtRLSjXIzNYTBkAskvYyRqw+AjeDuuOEoEFW7gpXDxqtAw
	 /+mri2Vbz+MwVUeuu0SJn5K1TuH7PplmYkYLUMq0cO3RLL0cyL/pp8UlsZNWz4G10hYbE
	 LMs8BIDgdq2EMuJGaq4tlSXxyFwXiZ4YD5ZkRZeFQ1icxFdQ5S3xCqYsOYImSzsustY34
	 Zp0dxmy5jw3MZ+pHLc3zxYSXjRyGTpl2jQtVr1yeMgBirPuk/1oG/jMDkXwvRPYGBcw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793581849;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 MIME-Version:Content-Transfer-Encoding;
	bh=YYTrIGxUOSOb88OnIFx0hwwl3v23j5XFNga48Rjoaig=;
	b=Yue+LD5bf+tklDJpAYy4dqkIjofzghza5xAF9ukth454AguBHYCBWzn7bsrAWaoaNG2t
	 4TvWj5HoOn0TKFT8sTZKlKkAGw2ej+LH/yQUSuEObKvogkNDBe/7rdgcxodzsota0xOUT
	 R4uINkLDWHr9Y8ed1n6/XXWqYGvUey5TzRPajV/nD+Cs48hBTUkeeYquTFlhAedP3GFU6
	 sCkpZh/2rZCH1k/mlUxGrQ8RAOxCdVG/qX6AOvFWwyT+8qabwNLGJMAFg6FwsUmqMBjG7
	 ZLe6urMHWHEHYcsxLk9fws5CMgzwahAowCEkezFXIl+KcjqCqfeYH2Eg8/x7DZJVziw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=Kl3c6X45;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C95B5606A324
	for <linux-nfs@vger.kernel.org>; Mon,  2 Nov 2026 01:10:48 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=Kl3c6X45
Received: by smtp.kernel.org (Postfix) with ESMTPSA id EFD741F000C1;
	Mon,  2 Nov 2026 01:10:47 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793581848;
	bh=YYTrIGxUOSOb88OnIFx0hwwl3v23j5XFNga48Rjoaig=;
	h=From:To:Cc:Subject:Date;
	b=Kl3c6X45XfZIFpX5gPSdh2/oYXtRWZ79ge0NMf0Y2nentxO3Z5t44URegMvp7qwve
	 bKdmYs9R6vRIPoUk38hRie+FD1x10vdPtWrGlH+JNRjHDMtYO648NsbYgW4quoS1Kp
	 7hzkCUUWHRgROujzdsvxo1j9lXMFYsR+n5D7bdWZzmgiCNjmNLPWYVfgfFuURr//ZA
	 EWIdrQnFX9/Il6YgkCOgsqpLRZul+mpqDlBaE3n/mg27uzSdPCMZxTgngil002RJJi
	 TcZ5lredOVxScxWu6eHmHKtmhrX/3djoi3REd5SpkKXBGnKDwPb6fDP9Avp+95DUiB
	 N+qwVuHyJnyNw==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neilb@ownmail.net>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH v2] NFSD: Do not regrow a slot in the SEQUENCE that retired it
Date: Sun,  1 Nov 2026 20:10:47 -0500
Message-ID: <20261102011047.2659441-1-cel@kernel.org>
X-Mailer: git-send-email 2.54.0
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

When a SEQUENCE acknowledges a smaller slot table, free_session_slots()
retires the slots above the target. If that SEQUENCE is on the new top
slot, the growth test later in the same nfsd4_sequence() call finds the
table at its target and allocates back the slot the call just freed.

A client fills in sa_highest_slotid from the slots in use when it
builds a request, so a request it sends afterward on a higher slot can
reach NFSD first. When the reply to that request is lost, the
acknowledging SEQUENCE retires and rebuilds the slot inside one
request, and the client's retransmit never sees NFS4ERR_BADSLOT. A
retransmit of the slot's first request passes the seqid 1 rule for a
rebuilt slot and executes a second time. A CREATE replayed this way
returns NFS4ERR_EXIST, reproduced with pynfs against a two-slot session
and one write to drop_caches. A retransmit of a later request matches
the retained seqid on the uninitialized rebuilt slot and gets
NFS4ERR_SEQ_MISORDERED, which the Linux client retries every 15 seconds
without limit.

Skip the growth block in a call that retired slots. A retransmit that
arrives while the slot is retired now gets NFS4ERR_BADSLOT, which the
Linux client handles as a session reset. The next request on the top
live slot still grows the table on demand, so a copy delayed past that
request meets a rebuilt slot as before.

Fixes: fc8738c68d0b ("nfsd: add support for freeing unused session-DRC slots")
Signed-off-by: Chuck Lever <cel@kernel.org>
---
Changes in v2:
- Explain the request in flight on the retired slot (per Neil's review)
- Rewrite the comment on the growth test (per Neil's review)
- Link to v1: https://lore.kernel.org/r/20261101154742.1950822-1-cel@kernel.org

 fs/nfsd/nfs4state.c | 14 ++++++++++++--
 1 file changed, 12 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index cafdf80f32de..8b7483278f50 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -5230,6 +5230,7 @@ nfsd4_sequence(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	struct nfs4_client *clp;
 	struct nfsd4_slot *slot;
 	struct nfsd4_conn *conn;
+	bool retired = false;
 	__be32 status;
 	int buflen;
 	u32 maxlen, respsize;
@@ -5301,9 +5302,11 @@ nfsd4_sequence(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	    slot->sl_generation == session->se_slot_gen &&
 	    seq->maxslots <= session->se_target_maxslots &&
 	    seq->slotid < session->se_target_maxslots &&
-	    !nfsd4_slots_inuse(session, session->se_target_maxslots))
+	    !nfsd4_slots_inuse(session, session->se_target_maxslots)) {
 		/* Client acknowledged our reduce maxreqs */
 		free_session_slots(session, session->se_target_maxslots);
+		retired = true;
+	}
 
 	buflen = (seq->cachethis) ?
 			session->se_fchannel.maxresp_cached :
@@ -5360,8 +5363,15 @@ nfsd4_sequence(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	 * configured maximum, not the running thread count, so a
 	 * client resuming from idle can grow back before the pool
 	 * scales up.
+	 *
+	 * Do not grow the table in the call that retired slots.  A
+	 * rebuilt slot has no cached reply, so a retransmit on it
+	 * is executed again or fails with SEQ_MISORDERED.  Left
+	 * retired, the slot returns BADSLOT, which the client
+	 * recovers from.
 	 */
-	if (seq->slotid == session->se_fchannel.maxreqs - 1 &&
+	if (!retired &&
+	    seq->slotid == session->se_fchannel.maxreqs - 1 &&
 	    session->se_target_maxslots >= session->se_fchannel.maxreqs) {
 		int s = session->se_fchannel.maxreqs;
 		int ceiling = min_t(int, NFSD_MAX_SLOTS_PER_SESSION,
-- 
2.54.0


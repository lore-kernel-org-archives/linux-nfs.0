Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793548064;
	b=hUpT5n4ztoHwAE59O+DYUyx6RtQuGC0RDSTzMoz96wWfptTGUomEtm53spIWLV5NBrGt
	 o2t3ekpOaXWv3EqUkAYWhc+n9BTaW5u0MIChWgLKPoHuLIGwax8yS93bRgU4XkBLSSsaD
	 MoSAZCJX9Gmmio2u48BjmYwHxeIkexcjz7M9v1IpAo9KbwG5R5eqBsq0uUG1LkTTSzvai
	 NCrlmPbgEjcsvctFOkaOMXDJicGt9rC8LrLMBIzAaF3vfji6G0sNBI/9MPCJ5FOSkS979
	 Wxi5Fng7jg6sXqakDE7wLgV2BtAym+yV4GclZUmBRrxx3EQd5I2dyaKiIJbHiPOC8lA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793548064;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 MIME-Version:Content-Transfer-Encoding;
	bh=oOOojLPEwvCB7b31jiIC2frhwu/xoVj/htWhH3gLpgw=;
	b=So5JmDgTBW1csQSWbgiMKxqgMvzFn0tz18ZD1lE3PurfOgzTP4PJJpD/2cHqkoFlnKKe
	 2MSh/9ta6FNshYIqoTdePVfMdniXyrKFs30DVtOCWBEcNnp7RK8DaX6l/IjQsStzPasMk
	 wCz0x0izNGeOmf69Rd83j/nJmgdai20m83NiTaG7i4ocbS+o07Pv3ZpPP+y4w7Lc64ccM
	 nPBFouEhSLv2QpSXX3VkMBY8DZkhXBlq17Mb43XsA+ngCcdtXOlj9U2fy3wPEVl7lxgAt
	 lqMLwKpq1AfnF+0Dcs/74Sye8Gwf80RX+0kFyeAQ9FBaWfePqTDW/3+BX1tkPCcl3yA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b="DS/+sAO2";
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BB230606A327
	for <linux-nfs@vger.kernel.org>; Sun,  1 Nov 2026 15:47:43 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=DS/+sAO2
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 13E8E1F000C1;
	Sun,  1 Nov 2026 15:47:43 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793548063;
	bh=oOOojLPEwvCB7b31jiIC2frhwu/xoVj/htWhH3gLpgw=;
	h=From:To:Cc:Subject:Date;
	b=DS/+sAO2EHsr30Jn3NzziRnE362ElRGNKTCdHxtU7s77Gieaa0P65bDtiWyPF6+BP
	 ij8UkEjqrFJWDK8OYGeQoeTISS1U+KKm2ytun9xqsxPuVhtZJUK4zShaBjDNnBgBd8
	 zUyoLDxOgr/DoESBWUDhK+20XFAWGCaEuMgor/OOmWWOZl90J9qFN/0Nxu1h+/cGs2
	 D+nVhKFueVGlnvWLPXD28AnEVQ+7o/IOHpqSTbZeIhVWEd4IBO1pGy8474oKRbOw8K
	 dkm6joP64TIcd9s8QJju04PPl9WhDvLlhT0atV3p0FNOVrdfTy6+zshz35dxzfrFOn
	 E1jbivo1DRKSw==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neilb@ownmail.net>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH v1] NFSD: Do not regrow a slot in the SEQUENCE that retired it
Date: Sun,  1 Nov 2026 10:47:42 -0500
Message-ID: <20261101154742.1950822-1-cel@kernel.org>
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

The slot is retired and rebuilt inside one request, so a client with a
request outstanding on it never sees NFS4ERR_BADSLOT. A copy of the
slot's first request passes the seqid 1 rule for a rebuilt slot and
executes a second time. A CREATE replayed this way returns
NFS4ERR_EXIST, reproduced with pynfs against a two-slot session and one
write to drop_caches. A retransmit of a request whose reply was lost
matches the retained seqid on the uninitialized rebuilt slot and gets
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
 fs/nfsd/nfs4state.c | 13 +++++++++++--
 1 file changed, 11 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index cafdf80f32de..1b8fe62cc756 100644
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
@@ -5360,8 +5363,14 @@ nfsd4_sequence(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	 * configured maximum, not the running thread count, so a
 	 * client resuming from idle can grow back before the pool
 	 * scales up.
+	 *
+	 * A slot rebuilt in the call that retired it carries
+	 * no cached reply for its outstanding request, so a
+	 * retransmit of that request is executed again or fails
+	 * with SEQ_MISORDERED instead of BADSLOT.
 	 */
-	if (seq->slotid == session->se_fchannel.maxreqs - 1 &&
+	if (!retired &&
+	    seq->slotid == session->se_fchannel.maxreqs - 1 &&
 	    session->se_target_maxslots >= session->se_fchannel.maxreqs) {
 		int s = session->se_fchannel.maxreqs;
 		int ceiling = min_t(int, NFSD_MAX_SLOTS_PER_SESSION,
-- 
2.54.0


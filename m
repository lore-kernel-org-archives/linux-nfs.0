Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793281281;
	b=yDxckye49hL1yvioiBLjGp+njA9xRmvb8CJ01txTWgrNQOv49vKNi0vCiNytZKq0nLsF
	 /YfGWJXdp88Cs0h+WPW8CTcqV9QFqhXi0Eer7iirot9kmZo0j7X4JEa0dhP6Bl1rLrVRP
	 JS+2EqUtYVZxuTELf4rO1sf8EwQ/AlIPRq0Zec0sDI0BKq2kW1CHqmGGzKQYzymfkRZqJ
	 PpMNizJErPtjLstzS1kRrIc8ugNDTREfZKlC9ia935jvYBCQju9edt2TXTBQtMKbdowUG
	 FXdkkTZq6pIO8grL0BPxnDugeN8Cu2jKLT9LS5/rp06Gv3pLzJ8SSXQ6w10ZWXifO0A==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793281281;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=g+Tit1C6cHHCvh64ed+uoqzBX77S1bWWY8LiX81dQMM=;
	b=3cpR4QVUZ7khNQIrMC1XZmj/r0c/6LHA3VpIY6RNA2E070hIyCZ4WBLAHbZdfr6LpQ3P
	 ATzVhIYXufRxHvppRlJefYttjT7kJufue7ZXmi235yMwM41esnBs4gwHTKgKevEBDh7i6
	 ivH0wV5yNdiTDJNGvAOTw6tH6zIbAQMhOGpBl2qzoiebh4ka76tFUc0XWVoQVMEEqCv+G
	 a44t0HWtT65hoY33/uEiRuludec2DlRTjSaeT+xCdogZVYm3qSHKrjOfJFuWk0R556lkM
	 AmYcQdLvHDDK6NNmqLZYQ6YPaA9KZm+ck34jXVnZ6E1W65q0GFE+VXevW6+aLQ4hwzQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=ndJK4geB;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B1D37606A31F
	for <linux-nfs@vger.kernel.org>; Thu, 29 Oct 2026 13:41:20 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=ndJK4geB
Received: by smtp.kernel.org (Postfix) with ESMTPSA id C34A01F031EA;
	Thu, 29 Oct 2026 13:41:19 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793281280;
	bh=g+Tit1C6cHHCvh64ed+uoqzBX77S1bWWY8LiX81dQMM=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=ndJK4geBuoQqb1UrjCf7fjHzmoVjLecoDL1kZWAtvH+pNFvH0dSUSD1L4VvxZYNms
	 XX0jXqvTIyguKcmrIE/I6J0nb64lNrr1eaZfbQ5q3unVZHgGsON+neFYliKpGkVLiN
	 zvDudRSXsSsuxsBxsRCGEwXezSd+Wsfyw5lzhDGucQkhxCnN+Q8ZxGuxsPifJN+64W
	 seH5+G7Xtkv+v4thE3s5/sVzvwodEYheY5iEti1NIZUJHVwMkglBM48oNr9LRyAfkU
	 Jz9I3/BrjYrxL3PPeE1y6rIRPGULwGLGqmJxcKTLiAlV84NVwABLRgmhtSsGq3lfcT
	 itqaMKu4wmDnA==
From: Chuck Lever <cel@kernel.org>
Date: Thu, 29 Oct 2026 09:41:04 -0400
Subject: [PATCH 06/10] NFSD: Stop disclosing the conflicting lock holder in
 a lock denial
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20261029-random-stateids-v1-6-8648878fec8c@kernel.org>
References: <20261029-random-stateids-v1-0-8648878fec8c@kernel.org>
In-Reply-To: <20261029-random-stateids-v1-0-8648878fec8c@kernel.org>
To: Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org
X-Mailer: b4 0.17-dev-9c833
X-Developer-Signature: v=1; a=openpgp-sha256; l=5044; i=cel@kernel.org;
 h=from:subject:message-id; bh=wG1RELbHmrvQ3wPajpXiESYS/cvYLgu9p+BdjXoVfwI=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBq40z39H0iphv5cuMG6+Ctz0ZDV1Aave8p2JFw6
 6aEkylKkoiJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCauNM9wAKCRAzarMzb2Z/
 l1BhEAC8fRIqJ2pnX2sw+USdwsnMT2VR/xhnEjPYwG8IaQjgS+Bw7IHXm7SjbhV7Hg3ruRRY1m2
 AS9sFmwCR+E2cZ/2cFfnWJfBF+xpcqZtqBHjFG/RlD78X85rDAZoXXnOhUWFUFTb4ls4fQDwuw7
 ypttwot9bTC5NTx+6VpsiF++kEHAIJXGSnUPkB8CTf22PjhidBLjL9pTDz4C2cjFUweuyKcjmle
 pi0zXDnnUqIoPEnqu7p0Zbyk+uQ2laU8uF9Kv2L0p4GYbLYlGO5RqXwU+XlCOz6xXRKV8g3skSk
 bCA6e9OEwNbp7DF8DFFFz7oEVeNKH3mO91ULKogU75VCngApEf80Mhii32D0RiCV3ELYxWPebWD
 4MH+t4Pj0Y5OXBzBx2FK0gNAsmZ4cQjPNSmHNeJT5mYifEHjHRL0PmU+6/VUWks58THxmYlNeS+
 onPL/jd3/4GlIPebUdqpvOpDhClORri4y+Oajk1pTbhdn3zWy57M072SuGKKRmoJ0QQmGXp7sVd
 nEFqGApfAE4MrKN44J0uUCGeKp3fLYzjA2YYDNzo8UAKjn8YW2Aoi+dy8bDXWgIxr/n+mbrTWgh
 WXYJQkKAQaSwGwDOznQsLaCPwz6QhPhnJHh1HLMjZXyReylPzUeJ40AMSmkfIn/xdjg6sBrYojf
 WauX9C4AUiuYNSQ==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

nfs4_set_lock_denied() copies the conflicting lock holder's
cl_clientid into ld_clientid, and nfsd4_encode_lock4denied() puts
that clientid on the wire in every LOCK and LOCKT denial. One LOCKT
against a file where another client holds a conflicting byte-range
lock hands the requester that holder's full clientid. NFSv4.0
resolves a presented stateid against the client named inside the
stateid rather than the caller, so a disclosed clientid lets an
attacker skip the clientid search that a random cl_id is meant to
force.

RFC 7530 Sections 16.10 and 16.11 return the conflicting lock's owner
but do not require the holder's real clientid. RFC 8881 Section
18.10.3 does: a server returning NFS4ERR_DENIED MUST set the clientid
of the denied owner. This change departs from that requirement on
purpose. The nevermind branch already returns a zero clientid and an
empty owner when a non-NFSv4 owner holds the conflict, so every
client already copes with that reply, and the Linux NFS client
discards the denied owner.

Route every denial through the nevermind behavior. ld_owner.data is
then always NULL, so remove nfsd4_lock_release() and
nfsd4_lockt_release() and their op_release entries.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/nfs4proc.c  |  2 --
 fs/nfsd/nfs4state.c | 42 +++++++++---------------------------------
 fs/nfsd/xdr4.h      |  2 --
 3 files changed, 9 insertions(+), 37 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index a50f9dcb3a31..d1527e7f23bc 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -3923,7 +3923,6 @@ static const struct nfsd4_operation nfsd4_ops[] = {
 	},
 	[OP_LOCK] = {
 		.op_func = nfsd4_lock,
-		.op_release = nfsd4_lock_release,
 		.op_flags = OP_MODIFIES_SOMETHING |
 				OP_NONTRIVIAL_ERROR_ENCODE,
 		.op_name = "OP_LOCK",
@@ -3932,7 +3931,6 @@ static const struct nfsd4_operation nfsd4_ops[] = {
 	},
 	[OP_LOCKT] = {
 		.op_func = nfsd4_lockt,
-		.op_release = nfsd4_lockt_release,
 		.op_flags = OP_NONTRIVIAL_ERROR_ENCODE,
 		.op_name = "OP_LOCKT",
 		.op_rsize_bop = nfsd4_lock_rsize,
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 3c8ad25bfc89..eda976e826cc 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -9339,23 +9339,15 @@ static const struct lock_manager_operations nfsd_posix_mng_ops  = {
 static inline void
 nfs4_set_lock_denied(struct file_lock *fl, struct nfsd4_lock_denied *deny)
 {
-	struct nfs4_lockowner *lo;
-
-	if (fl->fl_lmops == &nfsd_posix_mng_ops) {
-		lo = (struct nfs4_lockowner *) fl->c.flc_owner;
-		xdr_netobj_dup(&deny->ld_owner, &lo->lo_owner.so_owner,
-						GFP_KERNEL);
-		if (!deny->ld_owner.data)
-			/* We just don't care that much */
-			goto nevermind;
-		deny->ld_clientid = lo->lo_owner.so_client->cl_clientid;
-	} else {
-nevermind:
-		deny->ld_owner.len = 0;
-		deny->ld_owner.data = NULL;
-		deny->ld_clientid.cl_boot = 0;
-		deny->ld_clientid.cl_id = 0;
-	}
+	/*
+	 * RFC 8881 Section 18.10.3 requires the conflicting holder's
+	 * clientid here, but returning it discloses that clientid to any
+	 * client that can provoke a denial.
+	 */
+	deny->ld_owner.len = 0;
+	deny->ld_owner.data = NULL;
+	deny->ld_clientid.cl_boot = 0;
+	deny->ld_clientid.cl_id = 0;
 	deny->ld_start = fl->fl_start;
 	deny->ld_length = NFS4_MAX_UINT64;
 	if (fl->fl_end != NFS4_MAX_UINT64)
@@ -9842,14 +9834,6 @@ nfsd4_lock(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	return status;
 }
 
-void nfsd4_lock_release(union nfsd4_op_u *u)
-{
-	struct nfsd4_lock *lock = &u->lock;
-	struct nfsd4_lock_denied *deny = &lock->lk_denied;
-
-	kfree(deny->ld_owner.data);
-}
-
 /*
  * The NFSv4 spec allows a client to do a LOCKT without holding an OPEN,
  * so we do a temporary open here just to get an open file to pass to
@@ -9955,14 +9939,6 @@ nfsd4_lockt(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	return status;
 }
 
-void nfsd4_lockt_release(union nfsd4_op_u *u)
-{
-	struct nfsd4_lockt *lockt = &u->lockt;
-	struct nfsd4_lock_denied *deny = &lockt->lt_denied;
-
-	kfree(deny->ld_owner.data);
-}
-
 __be32
 nfsd4_locku(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	    union nfsd4_op_u *u)
diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
index ec198993429e..ecab2249e9bd 100644
--- a/fs/nfsd/xdr4.h
+++ b/fs/nfsd/xdr4.h
@@ -900,10 +900,8 @@ extern __be32 nfsd4_open_downgrade(struct svc_rqst *rqstp,
 		struct nfsd4_compound_state *, union nfsd4_op_u *u);
 extern __be32 nfsd4_lock(struct svc_rqst *rqstp, struct nfsd4_compound_state *,
 		union nfsd4_op_u *u);
-extern void nfsd4_lock_release(union nfsd4_op_u *u);
 extern __be32 nfsd4_lockt(struct svc_rqst *rqstp, struct nfsd4_compound_state *,
 		union nfsd4_op_u *u);
-extern void nfsd4_lockt_release(union nfsd4_op_u *u);
 extern __be32 nfsd4_locku(struct svc_rqst *rqstp, struct nfsd4_compound_state *,
 		union nfsd4_op_u *u);
 extern __be32

-- 
2.56.0


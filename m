Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794332668;
	b=xvQFChZFGOLHI10cfLjbnAIuYBm5yFv6PxYkNKQM9Sn0be8f5Cwe4KjLR+AaQ6wa3/Pn
	 d32lq22Rc0j5A3bjL2ogGFxdEiMMCcS5B6C2bKGLhE3S3IMPJOzkD4rFjjl9UedKdg0ry
	 /5q80zkS10B8vpIeTPh7m8/HySaKfHRHqQCWgNLXcJnOUCGekGacBMuNHD/v761jfl/wx
	 pvTs+u7Mo//zIs5DwsGced11pRQwIUqg4yxo9Jrz9x9cAmcajnvO5xQRXSSsw4x5C/f5h
	 vO7Cqvks4+HYYouKoSjzrX27GbMnjDpLkteA/aace7SRc0/EYN2/+81UKJX932pfiBQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794332668;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=Om2dxLvbUp2xXSm5y0VvpifaYRvNb6qDmRaytnm1M3E=;
	b=CdKzX84Ml2sXt26deOtvVugqJaJZltvL1fIFSSRNG76dncGBvb1KbcwJ/+RzSijCCUwi
	 o0F5cmv8LCp3bKxxcsb9Q2qGiA3gEd+M+KPoFIQn+hyAjZBZYXqdXoszxYY0SzT7+RxOD
	 MNS7bl/PltriRse/QJ4lhjKHig/YMqASbUXiqj+M754Tvc7tUM/I0SB2GUKcrpxA0voS9
	 +RV+bLS/UXhYE6qXCanQlhi/3fT3oCtO+nz8JaLIm4FOvDnc5fJGZbdDhS2jDr2PRPggl
	 TAGonpUy8rGuKecjO5tbF7eBSzMdzRGOtSsN6SWPo2F2OtPOBvUxm2ACmt+cglQcm2A==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=QJeltQIA;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4E0B3606A332
	for <linux-nfs@vger.kernel.org>; Tue, 10 Nov 2026 17:44:28 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=QJeltQIA
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 55D461F008A2;
	Tue, 10 Nov 2026 17:44:27 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794332668;
	bh=Om2dxLvbUp2xXSm5y0VvpifaYRvNb6qDmRaytnm1M3E=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=QJeltQIARxzxcHbVl375rfjJjh2Gcz/JsdivO7Z5O5fUgvW0qN3znqpgJiVhdr2gm
	 MM0UybpUzJKeGHi9J5prfm6+rfKu9ADtBQMZ7Id6pPFlPf83opS9sUAa63Xr0ilWTh
	 Is4eyi76UGyWAdABTWj6s8pvbGnF7ssahhT9UGYZYV51yfzY1G+kpiBbMYRJNPbxlx
	 KOASQigWzO8MJRtWNGyjz5jM4O00gSMx1lZiJ2lsBQOGEhEIgg1pqP9GNsOl6OOfZ4
	 IBbWv3LEvxim8ctPZcH3MVBBdy5sCz03VIFiDMeU8bZTVXd4RXdgoPM7iwr58eD9kQ
	 GU+YelW3xg5fA==
From: Chuck Lever <cel@kernel.org>
Date: Tue, 10 Nov 2026 12:44:13 -0500
Subject: [PATCH v2 06/10] NFSD: Stop disclosing the conflicting lock holder
 in a lock denial
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
Message-Id: <20261110-random-stateids-v2-6-57e0996eb2a2@kernel.org>
References: <20261110-random-stateids-v2-0-57e0996eb2a2@kernel.org>
In-Reply-To: <20261110-random-stateids-v2-0-57e0996eb2a2@kernel.org>
To: Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org
X-Mailer: b4 0.17-dev-9c833
X-Developer-Signature: v=1; a=openpgp-sha256; l=5091; i=cel@kernel.org;
 h=from:subject:message-id; bh=H6k5w/zLbo3eLX4UWyf+2iZg/DbeGkG3Ygi9YeSV0a0=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBq81f0/t4WIoR4cUym1ZayWdLeUbt1DwEmw/fnk
 5FPyIqQ2pOJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCavNX9AAKCRAzarMzb2Z/
 l8eYD/4zm1dym+T2Y2AT8qz+76HrfWNu68Xcp759solFt68aoTmO9KyPf4Ha9SIAQOkibJhJTHa
 2xtaiBjgjILeurCodSjZcJtC/J731Bcw1y1heVe+11CPNrUhdk++6p7ot4yrQ+MPc1Ax6mEjBkh
 TALGMPHyrfqgKRxP1p0LsuRVbjlr9uTWRUWINIpkaQnRrlgr5udHVaQDdOAZe6uQuaEIqj4HG5K
 4SA1Emr01q2BPPllgTeHp7MwIJpNa44ukcSgU1q9IO7c14A28uzZcHILNmCRoyjpUOmj120m4MZ
 DdUcCql/jyQb7jEVDylksqTMMB0TfUBFrWK5j72TSGaDsQFgIlkZm4PupHQz4VvcRgs1vLbGikq
 UWZ5UfFhQSCxqOUbN8xdE3GL2R0BA9DgaZK9Z4qIXUEJaEB1MO0eNzGNmyv48Jsk74YjmOtCXn0
 wqPd7krDWefGminiti8XBLgQKAhw0AypUzNzO+AC3gP6sXaPVpN20YVkoAl3k57g5GQQxHCrX9d
 7EBgLRJoWdLzQrShLlnZubXvFKfqoTKyXFygy31CLODMsv4sQXrQNbPV3etWtqp36SuoOi4foCc
 rfruqEthEV1jrnzY3ejBHuQjV4sQ6I4Xcs4qQNgZS51n8PJC8Xj3erD46o+0ath3vGdEboct/BE
 qiociZ7CqlPcVMw==
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

Reviewed-by: Jeff Layton <jlayton@kernel.org>
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/nfs4proc.c  |  2 --
 fs/nfsd/nfs4state.c | 42 +++++++++---------------------------------
 fs/nfsd/xdr4.h      |  2 --
 3 files changed, 9 insertions(+), 37 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 93452ce68da1..ca7d7303545c 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -4019,7 +4019,6 @@ static const struct nfsd4_operation nfsd4_ops[] = {
 	},
 	[OP_LOCK] = {
 		.op_func = nfsd4_lock,
-		.op_release = nfsd4_lock_release,
 		.op_flags = OP_MODIFIES_SOMETHING |
 				OP_NONTRIVIAL_ERROR_ENCODE,
 		.op_name = "OP_LOCK",
@@ -4028,7 +4027,6 @@ static const struct nfsd4_operation nfsd4_ops[] = {
 	},
 	[OP_LOCKT] = {
 		.op_func = nfsd4_lockt,
-		.op_release = nfsd4_lockt_release,
 		.op_flags = OP_NONTRIVIAL_ERROR_ENCODE,
 		.op_name = "OP_LOCKT",
 		.op_rsize_bop = nfsd4_lock_rsize,
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 81f82837dc73..adf834f1a0af 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -9349,23 +9349,15 @@ static const struct lock_manager_operations nfsd_posix_mng_ops  = {
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
@@ -9852,14 +9844,6 @@ nfsd4_lock(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
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
@@ -9965,14 +9949,6 @@ nfsd4_lockt(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
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
index 61afbabc1773..20a7cbcf64e6 100644
--- a/fs/nfsd/xdr4.h
+++ b/fs/nfsd/xdr4.h
@@ -901,10 +901,8 @@ extern __be32 nfsd4_open_downgrade(struct svc_rqst *rqstp,
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


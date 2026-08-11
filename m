Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 315703BB9FD
	for <linux-nfs@vger.kernel.org>; Tue, 11 Aug 2026 19:52:17 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786477938; cv=none; b=STQGJ2FomqpV8hYPtkDAUK3yOYXo6sH8nYPV2foKeTek9hojftuzMG7DktC686gOee6QcTK3BDYjsvk3QzRG+Apmxk+8y7jF8z/ec5ynojSIEa0qkM/KkzQ1JfW+qDLA/kQYv4URCP2XCfpMDj+DJGXgd/QVfSXoILw+cq1pmsE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786477938; c=relaxed/simple;
	bh=FIggDbicM/VY1oJv2w+zaXSgiawE8lcg2RPuxs54tj8=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=jxHihV6I3msud2weQ1kJVUaAYUGgoZIzVxUanqxIzSqfPjR0JCo79GCkxfFmKYdP4MB/PYk3TA18GFKSGYbNxWrXUbPBjO0sDmiNiuDLW6vSQwLf+ezTEXaiFdJRqLOeAmy2jOP5ZiwN1q/05mv154mj3Dc82NKIyjCQSR2PV74=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=WyKhcTa3; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="WyKhcTa3"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 842D31F00A3D;
	Tue, 11 Aug 2026 19:52:16 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1786477937;
	bh=mLxsDeilH7yrbnG5Fdh2CAlqJFlLh5WsDr4WR+yCT4k=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=WyKhcTa37EJwkUJc8Z15tOAcPYDxV6qsSspUEkCgO1k4MYUM8seMsSqbbwg5yKR1T
	 LGmPWK2lHrX5QM4VNI984XXw3P+5/QxHYqlMcwbnLmcQYpDo+K8QDPD8ad7Nnu7J23
	 8Qn8MnCeWzFtUHvc9slXzugVtj3ft83nZx7xMOdYZJwKP6OBoZtMzHdx3IwOvn1EY4
	 7+Tai4UZt5Dv1Mu53EmL6QYx0gtXYkcnaZcs5QtHxiK95yecd8hZfnLOG5RfiJHl2m
	 6PAa4DQzfj1dB0A7MEGfzyvRVFLQyqhXmi8ubz8dnVmaDjrGHwrUC+GeED2krmuiiC
	 gPalHqhMb/7yQ==
From: Chuck Lever <cel@kernel.org>
Date: Tue, 11 Aug 2026 15:52:05 -0400
Subject: [PATCH 4/4] NFSD: Send a meaningful CB_RECALL_ANY keep count
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260811-recall-any-keep-count-v1-4-de9ca00493b7@kernel.org>
References: <20260811-recall-any-keep-count-v1-0-de9ca00493b7@kernel.org>
In-Reply-To: <20260811-recall-any-keep-count-v1-0-de9ca00493b7@kernel.org>
To: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org, Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=3488; i=cel@kernel.org;
 h=from:subject:message-id; bh=FIggDbicM/VY1oJv2w+zaXSgiawE8lcg2RPuxs54tj8=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqe31tEHF41PrCAnS7y1dSFk+aFlTd6qxOdB8xC
 YJDCx9lxWOJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCant9bQAKCRAzarMzb2Z/
 lzxPD/45h7A/Fnrrar6UDyhS7dPc1fFYHeDddK8yY3wuWW04IJ1BoRcu6P/u2Kwc4DwZVbC8rZ9
 GP32XIHtZ9U2tk8nM4hy+n7Cmc614eaQloDCt1HWwJnv+B3OnPlV8YqRoQWOOjuORdPEy3YGJ+R
 kp2YdHHpzRmE8xHhYiOqMcoPHhXZk9AriBQFHBX3CQHkFSDWim7gbOGFGDMWEUvV7A2bj50iRJm
 3tFxpKmhoA6WtrCaFyx8BEPU+V8lwAmkV5cAhLx3NxoKirvY/aIUTTWxwTt3TXrhwzRcM9zcrvB
 imHqaKmU07MJr8x6e67xzEMG9ZPZd1/e3x7Usp62i4roYKeN6UrTuv4jw5IQ6wrL0W2qKZBCIQ0
 UPywfyQzW1jo7X5YheSDeg6Bv1ELcL0KJRyU/AOCxGQYdcVa6pztbrh1kGYCyhg+tm4JDOHh2vp
 110ZJ98pq2CGDY8AoX49WZwPO26Gun8DGlpXrBXo0i7nCIVvi47iKwijJGjZKHa6p0ARm9fW99O
 43DnDUgULxTqxGQKYjUxcaDzfYCJEiC/feluNUBmvT1l3u9i1NPj8QgNBgvCuTm2dx2JvWfnTVO
 JbJCvahSZ4adNC1lAhZOlUrltV/mY5YKwNTxbOJWXBJbXIYNobriP4DAlNRmHnWooBo341qjHeK
 n2r/l2VMboeDjfQ==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

deleg_reaper() sets craa_objects_to_keep to zero on every
CB_RECALL_ANY. Per RFC 8881 Section 20.6.3, that asks the client to
retain no read or write delegation at all, whether or not the
delegation backs an open file.

The field names a count the client may keep. The client picks which
objects to return, because the server cannot read lack of recent
use as lack of usefulness. Zero leaves nothing to choose among. A
client that complies returns the delegations backing its open files
and reopens each one with CLAIM_DELEGATE_CUR, so NFSD trades a
delegation for an open stateid and recovers nothing. A client that
reads the zero as "unspecified" does nothing instead, and
nfsd4_cb_recall_any_done() inspects only the reply status, so NFSD
cannot tell the two apart.

Derive the keep count from cl_deleg_count and ask each client for a
single delegation. A larger request reaches delegations an
application still has open, and both callers re-arm while their
condition lasts. Skip a client holding one delegation rather than
send the zero again. That gate subsumes the list_empty() test above
it, and it belongs above the NFSD4_CALLBACK_RUNNING test_and_set. A
continue below that point latches the bit with no callback in
flight to clear it.

The Linux client ignores craa_objs_to_keep and returns unused
delegations from the type mask alone, so the count changes nothing
for it. The gate does. The reaper goes quiet for a client walked
down to one delegation.

Fixes: 44df6f439a17 ("NFSD: add delegation reaper to react to low memory condition")
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/nfs4state.c | 20 +++++++++++++++++---
 1 file changed, 17 insertions(+), 3 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 3017a93261ff..e825ecb2ddfc 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -7944,6 +7944,7 @@ deleg_reaper(struct nfsd_net *nn)
 {
 	struct list_head *pos, *next;
 	struct nfs4_client *clp;
+	unsigned int count;
 
 	spin_lock(&nn->client_lock);
 	list_for_each_safe(pos, next, &nn->client_lru) {
@@ -7953,21 +7954,34 @@ deleg_reaper(struct nfsd_net *nn)
 			continue;
 		if (clp->cl_state != NFSD4_ACTIVE)
 			continue;
-		if (list_empty(&clp->cl_delegations))
-			continue;
 		if (atomic_read(&clp->cl_delegs_in_recall))
 			continue;
 		if (ktime_get_boottime_seconds() - clp->cl_ra_time < 5)
 			continue;
 		if (clp->cl_cb_state != NFSD4_CB_UP)
 			continue;
+		/*
+		 * This read races with hash_delegation_locked() and
+		 * unhash_delegation_locked() on other CPUs. A stale
+		 * value only defers this client to the next
+		 * laundromat pass.
+		 */
+		count = data_race(READ_ONCE(clp->cl_deleg_count));
+		if (count < 2)
+			continue;
 		if (test_and_set_bit(NFSD4_CALLBACK_RUNNING, &clp->cl_ra->ra_cb.cb_flags))
 			continue;
 
 		/* release in nfsd4_cb_recall_any_release */
 		kref_get(&clp->cl_nfsdfs.cl_ref);
 		clp->cl_ra_time = ktime_get_boottime_seconds();
-		clp->cl_ra->ra_keep = 0;
+		/*
+		 * Ask for one delegation at a time. A larger request
+		 * reaches delegations backing files that applications
+		 * still have open. Returning one of those trades a DELEG
+		 * stateid for an OPEN stateid and frees nothing.
+		 */
+		clp->cl_ra->ra_keep = count - 1;
 		clp->cl_ra->ra_bmval[0] = BIT(RCA4_TYPE_MASK_RDATA_DLG) |
 						BIT(RCA4_TYPE_MASK_WDATA_DLG) |
 						BIT(RCA4_TYPE_MASK_DIR_DLG);

-- 
2.54.0


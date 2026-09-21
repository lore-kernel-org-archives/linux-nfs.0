Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 40E6649DBBD
	for <linux-nfs@vger.kernel.org>; Mon, 21 Sep 2026 13:22:43 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789996965; cv=none; b=EmPkRMN7Sss82FoWh/O8teKUGYVJv2saV86crbAs99rEiCUuzq5Kua2fA7k6d9305bAECttqgYo+eC/D7aVbPNhAQxOkEpba44TD4geaVDm08dgh75kOl5CR4rPmCxQO1zg6heIW25HbyEIrlgfUFvlJ84VtWRV76erR1HbC6os=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789996965; c=relaxed/simple;
	bh=sGBpBXVbYpdHdEVOlXBGsHoczIu5Oa/AFXM4NK5XI4o=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=WFsAJC0gFkWZN4OzcDVaU3MnTD502v4lgx1xIOQuY1TlYoD/rNOvriPUMNHDZM+/WRSrkDPvDAAi7odi0t68FETNXEOngoAMXXpJHpiYJaGFlmaiYTEmN69qo9jq28NTNwLWYiR9DIhlP3dlA96m5LqEdWahW11CydtcgyH12IA=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=SfE6SaOG; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="SfE6SaOG"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 2824B1F00898;
	Mon, 21 Sep 2026 13:22:43 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789996963;
	bh=u6uURAZ1ABR0Qt3MCiHfp+LwiXQBN9sHeCWmTNhP2zU=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=SfE6SaOG9Yji0u2vqenVvJdpt+VcJqgtZsHTb3dqVREhgTrLZGdIPca5W4Sz24Q6P
	 SpvN438gJ6XpbyPmI0WVyTaeGDA0F5rRBz+3q2waglPP1ZU6bvHXXmvLzKaC3SPjFy
	 VsnqZhTbC7OBoml2cfyBp0RQXRpx0gflrWvaJl84fMt6lRpaWu/XydNOIif158AGh9
	 0/uYxEUixY9p2YEMCff0pyK8Ul3pPzO+78efmwFLseAgo82kH/Q5eisd+9oBBDwp/H
	 jvBLvHMhe8JA6I7KXmqNEptLrqL2WHbUZbKzHEX2aEZPKM0Wb8f/TSSpqyB7DOef3W
	 Ip+7As4NFq9Cg==
From: Chuck Lever <cel@kernel.org>
Date: Mon, 21 Sep 2026 09:22:31 -0400
Subject: [PATCH v6 05/12] NFSD: Prepare bucket pruning for additional
 eviction reasons
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260921-duplicate-reply-cache-v6-5-db5e13fd9944@kernel.org>
References: <20260921-duplicate-reply-cache-v6-0-db5e13fd9944@kernel.org>
In-Reply-To: <20260921-duplicate-reply-cache-v6-0-db5e13fd9944@kernel.org>
To: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: Rick Macklem <rmacklem@uoguelph.ca>, linux-nfs@vger.kernel.org, 
 Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=1339; i=cel@kernel.org;
 h=from:subject:message-id; bh=sGBpBXVbYpdHdEVOlXBGsHoczIu5Oa/AFXM4NK5XI4o=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqsS+dtRwYq0iQH/qDuqyVOcNpy4DhKw1NQrEBt
 B7Lsq4sqdKJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCarEvnQAKCRAzarMzb2Z/
 l0T5D/9IgshIhMJ5pxvVblw92DFs/1OPzypQ+C/jl67VQTb9UwDZmISjEbOinWIKacrX8O4EjDY
 Mbz95H6AxDJf09jzpKcYaVxrZBP/x9U4DzgI2yFcXTGQK5R42CCtXW2W9qMra+qTNyQX4B6cx84
 o51WV5OMWYngKaAzxjLyigEteNTl3ovvUU0iGMIUPkz9zBsIdPrAPlHbodrEq5JY1KknWWU/C+n
 SJ7mGX9liGA6kgKV8VpIH/uRjt8qDeY7cHh5hyFlTFh9RUNC68YOsvf2QqOOjryGBzeR0no57Nv
 764cfCUiiyII+AMY6ar/eG8zWexqZN/9cTWx+sD7SKnQvKuhqdxXLgy3SB9OTaK4zOdYH1FhWnh
 t6Kla64eFcCnIBj4PnAmSFUmn1fzyE8ntXER65m8IVgdLb3YN5AJRFw5cD7EfmEIQGn/mg7oZsX
 pISGSnNTLsXb1yGVAQGWoLfW9U7LXyw/i6R8AJceTogYsXhUKVnSIwxda0lTBUBOlc6ZohNjzl7
 lbVynAvDjb+HHwB50CeOM9d8e8N3v8MpCGTPTprYfJAqYMIyupsgeotbbvHYSTbHCm4PfrGjxQH
 l/vB/aD01gnEsKyYjTz3MeYcHYMSLwN/FTD3riUVfH+9XxsgmWkTQ6p3N1rIlucG8yL+3futbF8
 2RWpLMoIQxNTmLQ==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

nfsd_prune_bucket_locked() combines its two eviction reasons,
memory pressure and RC_EXPIRE, in a single test and stops the walk
at the first entry the test does not evict. A reason that needs
its own handling, a tracepoint per reason or a test that must run
ahead of the stop, has nowhere to go.

Test each reason on its own and jump to a shared eviction label.
The walk still stops at the first entry no reason applies to.

Assisted-by: LLM
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/nfscache.c | 9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/fs/nfsd/nfscache.c b/fs/nfsd/nfscache.c
index 4207c2e694db..27c369b1f11b 100644
--- a/fs/nfsd/nfscache.c
+++ b/fs/nfsd/nfscache.c
@@ -274,10 +274,13 @@ nfsd_prune_bucket_locked(struct nfsd_net *nn, struct nfsd_drc_bucket *b,
 
 	/* The bucket LRU is ordered oldest-first. */
 	list_for_each_entry_safe(rp, tmp, &b->lru_head, c_lru) {
-		if (atomic_read(&nn->num_drc_entries) <= nn->max_drc_entries &&
-		    time_before(expiry, rp->c_timestamp))
-			break;
+		if (atomic_read(&nn->num_drc_entries) > nn->max_drc_entries)
+			goto evict;
+		if (time_before_eq(rp->c_timestamp, expiry))
+			goto evict;
+		break;
 
+evict:
 		nfsd_cacherep_unlink_locked(nn, b, rp);
 		list_add(&rp->c_lru, dispose);
 

-- 
2.55.0


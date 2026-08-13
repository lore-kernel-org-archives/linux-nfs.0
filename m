Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id ED7624156FD
	for <linux-nfs@vger.kernel.org>; Thu, 13 Aug 2026 18:40:51 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786646453; cv=none; b=JO5XYRi5XO0U0E+Z16u69iyvDyfvdz27lGc0H5oAp43KwqgS+tM1/R9DSk9z6+rMUvFLEQP/0KZrFa1cFn8KtG7wTSD/fOmE4R19zoy17KFTP9eZCaZP12yzBFegLpMDCq2xGyuQjusK0I7PSSegFkEwYF91uOIJcjf9bjJb9nM=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786646453; c=relaxed/simple;
	bh=sPSahgmRUEVCHeZ5hnXRLkKaHeG17HKqUV5CNGSLrQM=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=kURe4ZLXz/0wRy7O/knLW7jOBraTjWY2Jj/gOPvrUdRaLDoXgp2g936D06lMgCMv5LWIwobypIsXZoU8rC+dYvktIfV25+2vWUwy9xOY8Hx4N9PFl7wQEfFh8bDDWNXokRpkcE4A6fCNhgsCQ3J4K842NW1gQF8xtbVoSfpKjps=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=HHoGs3SF; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="HHoGs3SF"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 1398E1F0155E;
	Thu, 13 Aug 2026 18:40:51 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1786646451;
	bh=MS80YBLZuztBsSDR2MkHm37dqkkouA3ehU5zJf/Rlgk=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=HHoGs3SFk+knSsoi8vU80p7E+ZT5c0SprTBcyukDkvT51Nv0fcmVxICmEbOo+jZt+
	 M61qyvARMV9C5tlGKGSa/ufUQpcZlfYG/oQX3hXt92g6cHFW41juoHUIKFXVJInswW
	 m+LK1MELyq+2X7kbZPAsdmxzhvPMJaAEgtRWiei1819YZh83gzykEtSQhXahkv+a98
	 RQ/HVlsDK2PZ5CQ3sScfun3AeLmti+XqJEZkG1gvX1iduLABY4c8CBL3TixbcKbACp
	 L/qqtx2wEbqn2RWpm/wUFIYgInB3rLMwQkM7ey8pVQkiW6HRBRXjO2xDaF8EO1xK/1
	 K8IsDoigoUgYg==
From: Chuck Lever <cel@kernel.org>
Date: Thu, 13 Aug 2026 14:40:31 -0400
Subject: [PATCH v3 2/8] NFSD: Count the delegations held by each client
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260813-recall-any-keep-count-v3-2-a96d243c0b13@kernel.org>
References: <20260813-recall-any-keep-count-v3-0-a96d243c0b13@kernel.org>
In-Reply-To: <20260813-recall-any-keep-count-v3-0-a96d243c0b13@kernel.org>
To: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org, Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=2423; i=cel@kernel.org;
 h=from:subject:message-id; bh=sPSahgmRUEVCHeZ5hnXRLkKaHeG17HKqUV5CNGSLrQM=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqfg+wTCBo3FfG7hF4BXussJ7rHf5ixPeyRIKz1
 odsPJTU/MyJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCan4PsAAKCRAzarMzb2Z/
 lxNlEACJ7MxM1vVOzHZmO22kgR9JV/zpKjxWrQJcLFmEV4Eo2Wh1KHDC74rIULN9LrYfsyQBqyA
 +ZoUQ/HuOORFi++jLz7Kc7ZUECmo/Cyn+jGRcgnFNZXgD5un/jFT2wI3jlgjvJxTnagWCXYz7ob
 vAksFuGewBpErMQTe8KLq3W7LMR0pvZmvGhHGOrxDq8C2dX6EY6dGy4w7yRUbbBYj3PAJFWiHt2
 Qyvc2TpL8JJOzcuou11tV+PLVsF3jIzkmlKxbK7KmDaf4rv2cAxB92vCK38lwmVBM6FmkKCimFW
 3b/kQPJ86CVYvkJunyz7gdCstSPxZpGGMmLrP7XNe8tKxmeRBdo66PbaHFwhRNeKTvrE5luRPNL
 GwUnsMwzQZcb8WSEbIfDGjmFCOMfggu8K6FDZ2QtOJv1lle9+pwCxxj8taWs3SD98WopIcTRK2t
 NHTkDcBTbb91gQ7ihU5OGsq6ZqXDWQQoH5g+unN3B6QksniOVCNwsipCRS6aqM2oKDMLkzifeBR
 B9HqtCaCAACTNqdS5QHggQfCB+D7kGFVcB9wWMsssaF0TV2wCqVNvSAbQZCl2k5UzL7nZfQ54fP
 7Hg4mRrzaZvFdnXHv0k2hj4pd+fXWn5ybdbQYRiFu47QBuxQRmfot8HaJZ2HDDQ+3RzKV2mm6ps
 ajetxUOYoFVs34A==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

struct nfs4_client records the delegations it holds on cl_delegations
but keeps no count of them. deleg_reaper() walks nn->client_lru under
nn->client_lock, but cl_delegations is serialized by nn->deleg_lock,
which nests outside nn->client_lock. A caller there cannot take
nn->deleg_lock to count the list. The cost tells against the walk as
well: an O(n) count per client, on a pass that already visits every
client.

Add cl_deleg_count, maintained at the two sites that mutate
cl_delegations. Both hold nn->deleg_lock, so the counter is already
serialized against itself and needs no atomic of its own. The decrement
sits below the delegation_hashed() test, next to the list_del_init it
pairs with, so it runs only when the delegation really leaves the list.

A reader that holds only nn->client_lock is not synchronized against
either update site, so it can see a count that does not match the
list. Such a reader marks the access with data_race() and may not
depend on the value for correctness.

No functional change.

Signed-off-by: Chuck Lever <cel@kernel.org>
Reviewed-by: Jeff Layton <jlayton@kernel.org>
---
 fs/nfsd/nfs4state.c | 2 ++
 fs/nfsd/state.h     | 2 ++
 2 files changed, 4 insertions(+)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 09b1aa2914bc..2ddc77ac7312 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1521,6 +1521,7 @@ hash_delegation_locked(struct nfs4_delegation *dp, struct nfs4_file *fp)
 	dp->dl_stid.sc_type = SC_TYPE_DELEG;
 	list_add(&dp->dl_perfile, &fp->fi_delegations);
 	list_add(&dp->dl_perclnt, &clp->cl_delegations);
+	clp->cl_deleg_count++;
 	return 0;
 }
 
@@ -1552,6 +1553,7 @@ unhash_delegation_locked(struct nfs4_delegation *dp, unsigned short statusmask)
 	++dp->dl_time;
 	spin_lock(&fp->fi_lock);
 	list_del_init(&dp->dl_perclnt);
+	dp->dl_stid.sc_client->cl_deleg_count--;
 	list_del_init(&dp->dl_recall_lru);
 	list_del_init(&dp->dl_perfile);
 	spin_unlock(&fp->fi_lock);
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index ff1c9fa731aa..10beeb851cf6 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -632,6 +632,8 @@ struct nfs4_client {
 
 	unsigned int		cl_state;
 	atomic_t		cl_delegs_in_recall;
+	/* Length of cl_delegations, updated under nn->deleg_lock */
+	unsigned int		cl_deleg_count;
 
 	struct nfsd4_cb_recall_any	*cl_ra;
 	time64_t		cl_ra_time;

-- 
2.54.0


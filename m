Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0AFC6483BD6
	for <linux-nfs@vger.kernel.org>; Thu, 13 Aug 2026 18:40:54 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786646455; cv=none; b=O7lwFAQntx7TZKbQeidrxvFcGTTCj7QpBVmqgIM6+LMRhMQO8ERNF241daSpxG83ZcOub+vYS2BO//ox12j85SzAfsbhnmVOxAhxN3azA0h3SuypqA5Gdv4LYPA/l8j+9ahznUa5BYWTJNutG6DJ9N/DDQZu3EDo7H4chPDs45A=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786646455; c=relaxed/simple;
	bh=QzwVxHPhLHari5sUO3sYFbbftTNAcslZhoj30ZyNzY8=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=gMl6J1xWm7X5hbyF6VI9R+yB1k/G3RadLQ+gYaZaEQpUR5ydHonRQ0RaGyPapEGcPpBbdCpU0hmbxtmJDRi99jQ7RJBIsAFKUlVMl04gz+XVsATxAAlZOp127nftqelDsbW8U5ehnVOLDrJ+TK4r6JSkuCg4cEzFcygzy5zvp6Y=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=hfIS71lt; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="hfIS71lt"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 61BCB1F00ACA;
	Thu, 13 Aug 2026 18:40:53 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1786646453;
	bh=XcntQQsmx3oDDnx4GFlRaCQJUsXTjtyy10tqruCl1Sk=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=hfIS71ltfO101fYCWf5yl4Zc0KMJFpyLQlV3OlqxHWs/BEAcxQXtOrFhR956KSS/x
	 nciuEJpPXPcc81WKoEPvw8IzNlWj41Hl794SkF8kJg4ROQUV0eJ3iVjYR6URoW97vz
	 r8eOhV7lAddxV8w1hYqccu+Xy1ST6QzzLXZhVIzIYpNR11kWcv9sVFoEz49tK+hD/q
	 hJBY7jnafKV+pAh7oDd3aQXhJC2Y0BYbnn1VXJ7OSmKYnOAPzPhKh/q+EMc7QWFEM5
	 cbGgD97pXioUQbabibspGR0hS2SK3UImXmJo2P4hHkPVHIgM1nBT9iYvCbrgUURzSg
	 t/p4FDa7lLvTw==
From: Chuck Lever <cel@kernel.org>
Date: Thu, 13 Aug 2026 14:40:34 -0400
Subject: [PATCH v3 5/8] NFSD: Count delegations per network namespace
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260813-recall-any-keep-count-v3-5-a96d243c0b13@kernel.org>
References: <20260813-recall-any-keep-count-v3-0-a96d243c0b13@kernel.org>
In-Reply-To: <20260813-recall-any-keep-count-v3-0-a96d243c0b13@kernel.org>
To: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org, Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=3291; i=cel@kernel.org;
 h=from:subject:message-id; bh=QzwVxHPhLHari5sUO3sYFbbftTNAcslZhoj30ZyNzY8=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqfg+xmkJR14TOUtOkU3J6127XZKDkSu1J0j3nT
 g0B97I55WuJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCan4PsQAKCRAzarMzb2Z/
 ly+RD/4pkTcxKGuhZ1Dn93Z5MLvn/kR4fAmYk0wBEE7XU5IjAKvSvGHzK40vK8faPWDjxVx2EEs
 th5pywU9gxGEtRvSEqCRJRLpwzB2Wzo8rYS0/zv/BAu3fnB4Zs8f3fTZ7ne9opWg2GvnjxySp4y
 gHqlE4nrILx9nwsIc36jq//L0ZTV0xYa2q5NqkObSYyOS5SfKP8808Z/89pS9YKG0kUINnG+KTl
 A0Ul9oLQcPzYZnfRXttGinbUOtOH80wDacX1bsOyZts9Rtk3NvZcD0WnrZrHb64fYnEgiGzlHkX
 NwubNfK6AprPTfFV7mdHrXjXOjS+II8P0n5pH4v7d9HB6GO77AmCArOdOFua1pnlhwkbwafUA2h
 DhCGNJkQo/cLssg9El0l6Xvpih6ZCt8JfpITinDJJ1vbfEgL7freaIclml/L+YRP/wQIRXNJey6
 85Y3mMP3NX5Ksv59DcoNCXMSpGP1sftN7cySSNwrP8xb5qtNohnxBMZen0fhqeD9DwKzMnBwsVA
 PGquoSdC5H2HXM6jWdssZ5gEfpjQzUnKDQC5YRjswHEJgle/ky7ZB2I04VAri3U1wVx5OH0CVD4
 /zHmugKiZv4LgwC/Bjeu8adSq+IKnmQumeAsjaxyMJu6hq9F3RI3LltPm4KIdtVtcUIBuwbTru5
 hXremS9BmDIOBqw==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

The state shrinker is allocated per network namespace, but
nfsd4_state_shrinker_count() reports num_delegations, which counts
the delegations held by the whole host. Every namespace therefore
reports every delegation on the server. Reclaim sees the
population multiplied by the number of namespaces running NFSD. A
namespace holding no delegations of its own still reports a
nonzero count and queues its reaper, which then finds nothing to
recall.

Count the delegations in each namespace and report that instead.
num_delegations stays for the admission check in
__alloc_init_deleg() and the ceiling check in nfs4_laundromat().
Both compare against max_delegations, which is sized from host
memory and so remains a host-wide limit.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/netns.h     | 2 ++
 fs/nfsd/nfs4state.c | 7 ++++++-
 2 files changed, 8 insertions(+), 1 deletion(-)

diff --git a/fs/nfsd/netns.h b/fs/nfsd/netns.h
index 71eebfea020d..bb62d19430bc 100644
--- a/fs/nfsd/netns.h
+++ b/fs/nfsd/netns.h
@@ -238,6 +238,8 @@ struct nfsd_net {
 	int			nfs4_max_clients;
 
 	atomic_t		nfsd_courtesy_clients;
+	/* per-namespace; num_delegations in nfs4state.c is host-wide */
+	atomic_long_t		nfsd_delegations;
 	struct shrinker		*nfsd_client_shrinker;
 	struct work_struct	nfsd_shrinker_work;
 
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 7d8d7df9953b..f818e8a60099 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1161,6 +1161,7 @@ static struct nfs4_ol_stateid * nfs4_alloc_open_stateid(struct nfs4_client *clp)
  */
 static void nfs4_free_deleg(struct nfs4_stid *stid)
 {
+	struct nfsd_net *nn = net_generic(stid->sc_client->net, nfsd_net_id);
 	struct nfs4_delegation *dp = delegstateid(stid);
 
 	WARN_ON_ONCE(!list_empty(&stid->sc_cp_list));
@@ -1171,6 +1172,7 @@ static void nfs4_free_deleg(struct nfs4_stid *stid)
 	nfsd41_cb_destroy_referring_call_list(&dp->dl_recall);
 	kmem_cache_free(deleg_slab, stid);
 	atomic_long_dec(&num_delegations);
+	atomic_long_dec(&nn->nfsd_delegations);
 }
 
 /*
@@ -1255,6 +1257,7 @@ __alloc_init_deleg(struct nfs4_client *clp, struct nfs4_file *fp,
 		   struct nfs4_clnt_odstate *odstate, u32 dl_type,
 		   void (*sc_free)(struct nfs4_stid *))
 {
+	struct nfsd_net *nn = net_generic(clp->net, nfsd_net_id);
 	struct nfs4_delegation *dp;
 	struct nfs4_stid *stid;
 	long n;
@@ -1263,6 +1266,7 @@ __alloc_init_deleg(struct nfs4_client *clp, struct nfs4_file *fp,
 		return NULL;
 
 	n = atomic_long_inc_return(&num_delegations);
+	atomic_long_inc(&nn->nfsd_delegations);
 	if (n < 0 || n > max_delegations)
 		goto out_dec;
 
@@ -1295,6 +1299,7 @@ __alloc_init_deleg(struct nfs4_client *clp, struct nfs4_file *fp,
 	return dp;
 out_dec:
 	atomic_long_dec(&num_delegations);
+	atomic_long_dec(&nn->nfsd_delegations);
 	return NULL;
 }
 
@@ -5566,7 +5571,7 @@ nfsd4_state_shrinker_count(struct shrinker *shrink, struct shrink_control *sc)
 
 	count = atomic_read(&nn->nfsd_courtesy_clients);
 	if (!count)
-		count = atomic_long_read(&num_delegations);
+		count = atomic_long_read(&nn->nfsd_delegations);
 	if (count)
 		queue_work(laundry_wq, &nn->nfsd_shrinker_work);
 	return (unsigned long)count;

-- 
2.54.0


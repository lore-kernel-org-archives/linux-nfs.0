Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3644D41D626
	for <linux-nfs@vger.kernel.org>; Sat, 15 Aug 2026 16:39:03 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786811944; cv=none; b=P7GEQqkA7Oik3Sh7jr684NHI42yU0GZwx+Vp7e+JpktQvVflvu6m735/0deniGZHJI+d3gj6A28/iJWtOPXXYJLt5sloY2gOHdi1Y+Nxye+HYoh+OTCAlWi9CfbgOwlcyopayyHo+fCtwZjShmY/EU/jSY9yLn0OgqO+PwkIOoA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786811944; c=relaxed/simple;
	bh=6gxEda1bs/KRoQALu90aDCby3CKqfUsNFvbZ25kwX4w=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=M5c1pMqO5UzltHyqz7tIETTvd0b8Fe/YwsNE440jAX+FQG13NKRaR9masRh4QEAV/gyxfhP7Lx47NWmzZ0VdQRdpzixUWQNsMqTTdXjz5kC/SxOXAvXGygqDC7OvGcSsA4wGwIyRXsSBQzhn8abEP3kt8NwvSKUMyuabIWcFCy4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=EgaOfmDH; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="EgaOfmDH"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 5ED9D1F000E9;
	Sat, 15 Aug 2026 16:39:02 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1786811942;
	bh=RahMs4vn3aH/kioWRL7QEaIjgwqJei0EssjGjceUJno=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=EgaOfmDHiP10Oe33IQKPdMgiFfvZYUC+W8WgWw6LE+oVUGTz7Ugmrd+ffzh1uR4Fd
	 f0TWx64+VBxlb8cQnDJyqF36ggnoCHIi0qdhksXGb+0jIv4ChPHnE1+mWgYFzgE3dG
	 wluAykvJ9AjaUiLYAWJ6zuR9k5j5qZE+Gg0WruZgC0gtEmI3dRxaT5kF+AEJL6n2YE
	 LL6E3b1t2ypgp6+YJEOloedPUdfk+jSx26M2jbRVL8XOaDKKQhV0ShLSwsrWv2ALUP
	 C1lesmpjO2Afe+Mg7af4LZezLL4vQnp3nOeBpvBwqnAjwdo1x8JR6kfdVyXkrijJGf
	 HuyA19kSiD9yA==
From: Chuck Lever <cel@kernel.org>
Date: Sat, 15 Aug 2026 12:38:53 -0400
Subject: [PATCH v4 5/8] NFSD: Count delegations per network namespace
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260815-recall-any-keep-count-v4-5-bfb5b83d6cb1@kernel.org>
References: <20260815-recall-any-keep-count-v4-0-bfb5b83d6cb1@kernel.org>
In-Reply-To: <20260815-recall-any-keep-count-v4-0-bfb5b83d6cb1@kernel.org>
To: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org, Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=3338; i=cel@kernel.org;
 h=from:subject:message-id; bh=6gxEda1bs/KRoQALu90aDCby3CKqfUsNFvbZ25kwX4w=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqgJYhukaGTpNDaFNFlyBk/QlpKkQTUwyhV3wiy
 /fO07c0W3eJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCaoCWIQAKCRAzarMzb2Z/
 ly7sD/wLYLl2Gt40gzBNTyrUXbOYqzA7BW9gh/d0J4OoliwYerGKyktJffjYo9P159rU5YTO/JE
 J11cM/bSxmaVY0QvLQrwdE+97Zir79gh/Ld9qPv/3qZPDvTEbs4lg++9/0tQ64nETCMR9iUWY5l
 KWRNWgu/EyKJVqwCvlZi5xXT35XAPVGZr5XZF7FQ2Juq748gO9crHvH3KfWLN3KDR1TUxmYxatG
 pIuBRgDN28l4limGa5aZxW6L+q1hOJRtKGMCZcyG5oHETSbaf4nOsGBTEUpLwQlcY4B1CQl8y3y
 g8DweUUvCdVkIWrN2eOU7srGU4QliucKihrbHl7FWCTa3SkR2C/G7gpxdgAVSQxZW3NdA8z7Yop
 ljVzkoUW+L+mWkil5R8oZd2OO7Iuh/JNO7vaU2rDaWyuccKoW9RxX2EqXJT0RWrVSGdxotqi0rH
 +lRWqV3a5u/AKr4izOit2MHh4iUQVCwMbhunbgk/3bI3x7bhFc1hOJolM4svGQzDnW5Ih2Ue2TL
 02QLmxpPPixGo4qpCEjm6fxVqhIQyA32/25K4PK34fTqKhDtH+SzPay834JV2x59hU1oxuFUf/t
 6VUs7EBJx3FjaFuNJu32nP86uTRU9LM04gjYAKR0g1m8NoXx6A2elwNHrDTsZv+yXX3beOql7WS
 1rvOCLurutzsxPw==
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
Reviewed-by: Jeff Layton <jlayton@kernel.org>
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
index 5c2dd6657fac..2c169bfabfbe 100644
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
 
@@ -5564,7 +5569,7 @@ nfsd4_state_shrinker_count(struct shrinker *shrink, struct shrink_control *sc)
 
 	count = atomic_read(&nn->nfsd_courtesy_clients);
 	if (!count)
-		count = atomic_long_read(&num_delegations);
+		count = atomic_long_read(&nn->nfsd_delegations);
 	if (count)
 		queue_work(laundry_wq, &nn->nfsd_shrinker_work);
 	return (unsigned long)count;

-- 
2.54.0


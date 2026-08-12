Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8E0C846EC8B
	for <linux-nfs@vger.kernel.org>; Wed, 12 Aug 2026 15:00:18 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786546824; cv=none; b=JX0jXJy3Ze1XXVbuWlOlhiP3WuyAscMArj528WlKvP2/PLqndsJt2i6s+/NaGrVHwPgxIi1h3syabesJy5CfBT+IPzJj5MMig6MSLNvuIcvne4C1w/eAtoaQAEOCiqitzH3un6T29s3qb7zx+ScI4vHYosSvc+hKQZYpNxyMyE8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786546824; c=relaxed/simple;
	bh=0in4Ax2goUIi92RZ669bQFXmx2GvATN4Ol6lL/N4kGo=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=Q19t2R/k0CYyMgjYEarOQP/QXV6vDV2nYhXsZ6rXepgizu+aZXZkelmqr89WVtg2tSzL7WaXfOY4l9ltyzxVUsMGTdfvs38kiVDw1+hz5nJhPyQZaSlmwJJeIiR9taxfD3cQp+9+QkQ80zP9jtuTCRdqxHI9joprzWJEqZ8MMTg=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=hET/+OUv; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="hET/+OUv"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 790361F00A3D;
	Wed, 12 Aug 2026 15:00:13 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1786546814;
	bh=dQL60BagKfwY8iFoqFTVXgGICu2R2/Wt0ZneckGnFTQ=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=hET/+OUvJkoW6VAiVFBnvc4o80thpKoVLvYz2DGZCyQmn1iyXGJYdlJrfaRkOJoz2
	 VOBgH7RNzhypQuVAc0e6tMc/eMwtR85lCt4Iehyo+xGRcRy8/xILYJLCWtl/OXT3p1
	 3VRVw+Irg/bG01IeBNuYrtmaqJFn6iwsSA0PhHEbPfZygWgSV6om+ItnqwIJ4xmXIc
	 F7rIiR/1+0QMYpztNIQl3Z8YAV2bo0O9qOzxGVAgq7DuIAuaXFhQ/KkQbNCfL+acjk
	 U4Z2UUQIxdWDR8mtwtgb8LjJSh5Uzhppv+SG0wHfSEJEpiRyDMQjfUKYMR2XTFle/F
	 8/3mWPuGikuHw==
From: Chuck Lever <cel@kernel.org>
Date: Wed, 12 Aug 2026 10:59:56 -0400
Subject: [PATCH v2 2/4] NFSD: Count the delegations held by each client
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260812-recall-any-keep-count-v2-2-a82f4ca23812@kernel.org>
References: <20260812-recall-any-keep-count-v2-0-a82f4ca23812@kernel.org>
In-Reply-To: <20260812-recall-any-keep-count-v2-0-a82f4ca23812@kernel.org>
To: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org, Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=2376; i=cel@kernel.org;
 h=from:subject:message-id; bh=0in4Ax2goUIi92RZ669bQFXmx2GvATN4Ol6lL/N4kGo=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqfIp7inxB5OeBk2t7IvqM4y3VPrOVeYnYAlx95
 2/7t14hWyGJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCanyKewAKCRAzarMzb2Z/
 l++eD/0SVybaybibbi3cgf4Katcvr+SOkWbLZoOsrD2j3bal4kQtcYS1KXsrf4A7vWSJY6mWok/
 Uftc4avjLebfumgVE0dwWq508CalIvHOvcvhoVH6AZaTb5ZXfbqz1X3aW0nQvz4mfx/gzO7Ar4T
 fMgkS+wAsWTGpsfSRG1xGV6XcRhXUl7+q4SeqgjBo2VqNAZEw2+u3zBFdhmB9co5ewkOLDg9kI4
 1QHgkdsw24EAJiWytXxduLhW3Co97wCIwAyNpup3BZmLeeBh+YG6iVYG6ynSql/PDBypHFGw0WH
 RizWN7RB5UdPpFUDrLNirimdFNjR3vvUEne2PalFD0z5IVYKYFk5gA1yHDA6yo0BXMUstiVVHPc
 kmU6Ob/gDh5gdbiRRUe6hmALtIs0H13eGR3imAia11YMb6x0VvIkYId7VaOItcp035w0d1B+5zK
 GLAo1w5Gmi/8wSh9SlNOig6/B3+oDCLwPERdvvZ3gyP1kQZlcb4hYAmq57kRhHQn3FAewF0SOG9
 FcmpgHboe+dRKdvSDKxlh+B6jjP9oJHDN64DDUKR74yf6240yBJVB3uYD2VB2BfUSU12AY3QY4U
 49VwazZzc1EN27zt22Hv8/PWOzgMf9MgMK/vHbideEKd9n1rlT+xJgx6PIVswZmoC8OCP8Uh7KJ
 lGHYtNO9YFHpNaQ==
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


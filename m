Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A32993769F2
	for <linux-nfs@vger.kernel.org>; Sat, 13 Jun 2026 22:16:48 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1781389009; cv=none; b=hJyAcNifGADMFsIVtWnDmV9bLqYGs5FDmMFW54YPogDGdPGfodq17HB+4NUMX4yL1NzY3TnDfHgCE82HiOHL4OQzcsM+GznP0pvcJyXJz1Q9IgdFtNYN8/uj6PDZIP0oiHA4cNtjYeJJM4V0NpB5kXrWLDNHvPyxOzoqIh3fbzU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1781389009; c=relaxed/simple;
	bh=TNyUjRoSv/WB+fBvH9+aXEnKhdsX9PC+L6XcpseztYE=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=iWMtZoy+f0uVfFdS51SQvZ7vJzXmK3d8lO2l/hWjk23JGSEg4GqNBeeIh4crM8GBEQ0UvAXH9a4uQX1M5EbTrYglTs4EHA+b/dkU4BnhkxJgHQ39OpVYTgju5QP8aqLqzjDPvxBS+Z9pqUg3Fu4kPvPuJNtIVrO3JseknHHJ448=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=de4BGmD1; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="de4BGmD1"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id DE6E01F00A3A;
	Sat, 13 Jun 2026 22:16:47 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1781389008;
	bh=HuxTa6XYuMd01q7NxaHJMsgg3vOhSdFIU/6yhhjNQoY=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=de4BGmD1ecwRU6geoiAm7FY+L0MQvIHda1iWPaNGES5wQdNRV2zIF9pEOHBaESRhK
	 7lgK50shTI2jJPC66mPbI708PpJPrUB3GIVKLjr0S45FOrgVFh2Uv6v5BWl0Y//2mR
	 vXQO155W6YfsU98gvuc4986HqzRZlvvcShyFCe0WSph28VCw5hDJWd5CZT0lNHJsYd
	 CBndFUlecsqHAIKQB1nwNI9Tn/uiyVI8JCk2zA5korRhickm8Tm4ykIF30KM83QKV8
	 alh5NoyN37Zo97ENOuVMskexIh++kMhlsGu/UpvdDSsbCibfg0coMVJvKUDABXAXyK
	 5JY1mihr6JVFQ==
From: Chuck Lever <cel@kernel.org>
Date: Sat, 13 Jun 2026 18:16:34 -0400
Subject: [PATCH 3/3] NFSD: Annotate caller preconditions for the
 state-table walkers
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260613-unlock-filesystem-uaf-v1-3-462b9bec8c84@kernel.org>
References: <20260613-unlock-filesystem-uaf-v1-0-462b9bec8c84@kernel.org>
In-Reply-To: <20260613-unlock-filesystem-uaf-v1-0-462b9bec8c84@kernel.org>
To: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: Musaab Khan <musaab.khan@protonmail.com>, linux-nfs@vger.kernel.org, 
 Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.16-dev
X-Developer-Signature: v=1; a=openpgp-sha256; l=3503; i=cel@kernel.org;
 h=from:subject:message-id; bh=TNyUjRoSv/WB+fBvH9+aXEnKhdsX9PC+L6XcpseztYE=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqLdbNh8iyZdDq9nRR/qMx1kh7cf7g7Y3XogKXH
 g2eOLP+h/+JAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCai3WzQAKCRAzarMzb2Z/
 l4T+EACzJU5XDleoqnKK7t39wD/GuukJBtcuXst8GTNWA4pdUYp60DaLSrCZVg8bjl3wkraX0YA
 VPkr8byrHi1iuOcaKdd3cZ6/VkrX+DJZAu01MBQRa9y8v6d706SAkQXUTt6Ou5mfiWjG/U1LnxL
 9v9oimQlU/1ZpoAMn3BJaNFBaLJe4ina1mwBmycV46jFogxHroOqU9D9BIEm7vY9+B63+aiN8vm
 evKK0/xKcYZqB8XZ/kjTLVQtxR/yfrhIEEAKd1YhIpsFyUciqiNb4yj5tbnr0HMfRdhU34+v1hj
 ufTfkVIF4ajqzzV+j6FTrl6SeWy6FTDaL+CM8I0IYS7U3WVGrA7ymhmlo2ICex2tE2C1mUNU1Ft
 Dezsk1EXh6IIjsegbmUjKinTKkSVcxND14WZiYnhZXJD8N0NMwFxfctzNWp1d8h6QuObe/N5KHs
 CQxH6eX4C+01pU0Hfa4/UeeW/U3Xpgz1KUQefiqKDzgEglj++hmbjGRWKejrzzJwnAK3HoI89Qp
 L0JfbfSU+vTK38jaLpU7YhdoOU04zL8yebNiEQwYUyvue01lf9xhfn5piSS4/CSw+pb0KKGaKXr
 ktlVUK2pAuTsa3XpU2aK7ZMsjUKkGwHGT/k/GqpbqkIj71VwG4NYjzNfYw4HSflAS0fAec2zVuv
 ZxsAKUFc1Dh/XQA==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

The state-table walkers now assert nfsd_mutex with
lockdep_assert_held() and document the nfsd_mutex / nn->nfsd_serv
precondition in a Context: kdoc section, so the next caller added to
this path cannot silently reintroduce the same use-after-free.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/nfs4proc.c  |  6 ++++++
 fs/nfsd/nfs4state.c | 16 +++++++++++++++-
 2 files changed, 21 insertions(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index eb8a2a16839f..3e4de45aa360 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1587,6 +1587,11 @@ static bool nfsd4_copy_on_sb(const struct nfsd4_copy *copy,
  * nfsd4_cancel_copy_by_sb - cancel async copy operations on @sb
  * @net: net namespace containing the copy operations
  * @sb: targeted superblock
+ *
+ * Context: Caller must hold nfsd_mutex with nn->nfsd_serv confirmed
+ *          non-NULL.  nfs4_state_destroy_net() frees conf_id_hashtbl
+ *          at server shutdown without clearing the pointer, so a
+ *          walk without these guarantees iterates freed slab memory.
  */
 void nfsd4_cancel_copy_by_sb(struct net *net, struct super_block *sb)
 {
@@ -1596,6 +1601,7 @@ void nfsd4_cancel_copy_by_sb(struct net *net, struct super_block *sb)
 	unsigned int idhashval;
 	LIST_HEAD(to_cancel);
 
+	lockdep_assert_held(&nfsd_mutex);
 	spin_lock(&nn->client_lock);
 	for (idhashval = 0; idhashval < CLIENT_HASH_SIZE; idhashval++) {
 		struct list_head *head = &nn->conf_id_hashtbl[idhashval];
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index bef0ec9be459..2a6a0c9ef65f 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1873,14 +1873,21 @@ static void revoke_one_stid(struct nfsd_net *nn, struct nfs4_client *clp,
  * being released.  Thus nfsd will no longer prevent the filesystem from being
  * unmounted.
  *
- * The clients which own the states will subsequently being notified that the
+ * The clients which own the states will subsequently be notified that the
  * states have been "admin-revoked".
+ *
+ * Context: Caller must hold nfsd_mutex with nn->nfsd_serv confirmed
+ *          non-NULL.  nfs4_state_destroy_net() frees conf_id_hashtbl
+ *          at server shutdown without clearing the pointer, so a
+ *          walk without these guarantees iterates freed slab memory.
  */
 void nfsd4_revoke_states(struct nfsd_net *nn, struct super_block *sb)
 {
 	unsigned int idhashval;
 	unsigned int sc_types;
 
+	lockdep_assert_held(&nfsd_mutex);
+
 	sc_types = SC_TYPE_OPEN | SC_TYPE_LOCK | SC_TYPE_DELEG | SC_TYPE_LAYOUT;
 
 	spin_lock(&nn->client_lock);
@@ -1946,12 +1953,19 @@ static struct nfs4_stid *find_one_export_stid(struct nfs4_client *clp,
  *
  * Userspace (exportfs -u) sends this after removing the last client
  * for a path, enabling the underlying filesystem to be unmounted.
+ *
+ * Context: Caller must hold nfsd_mutex with nn->nfsd_serv confirmed
+ *          non-NULL.  nfs4_state_destroy_net() frees conf_id_hashtbl
+ *          at server shutdown without clearing the pointer, so a
+ *          walk without these guarantees iterates freed slab memory.
  */
 void nfsd4_revoke_export_states(struct nfsd_net *nn, const struct path *path)
 {
 	unsigned int idhashval;
 	unsigned int sc_types;
 
+	lockdep_assert_held(&nfsd_mutex);
+
 	sc_types = SC_TYPE_OPEN | SC_TYPE_LOCK | SC_TYPE_DELEG | SC_TYPE_LAYOUT;
 
 	spin_lock(&nn->client_lock);

-- 
2.54.0


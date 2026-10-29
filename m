Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793281276;
	b=PxGD7eWw2IkSa+IVrDwszu7TteT6QMDshorVAeN2TUlfJnI21Iu2dXcpoQQ78lC7ayNy
	 KgMPHjKdBrswFUwWFeVY8bAKxMo92pzlkc1rhloxYWXRlxt3p5QcxoGg8M9kMIUPEgbP4
	 KMqDnW22gxR3bK9Tni6xbj/AyoonHRrG1MFSN3ipt3ZvlvzE0aJeiPsk5Mk0YlLe+0Gmt
	 eveL6/3/F5VRxZfbKy1vBtWj+0Oep3ZIH/McAD+VTFz3aFpmBcWE34ox2INPQY5YRIBol
	 1VXykaq/l7guvoZJpcO4DfurAtZR0VogUQwT+3bODabG6A1hLfoKqHifiZOOspDwx1Q==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793281276;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=XL1lAn3vAWFPf9PcA4BhixZyHFuj0H7Sum8FCmZEJho=;
	b=shdG8O5Xf0FoVDUWadm+uzLEWRubAiF56YxSFYu+OjWoHGMXPAUb3V5o3bI90dlxkARK
	 vqV3HpuwL9KAx7urqFTFbVhFreeOJdcikCSbg3sSykJki2ZCVOjjq/5Ls5+flH1oWzKG7
	 av7Yac8b2YarWDqMoxLCCDC2dZDNi7kcGqNJB0e2/Kz8OC4kEdT/zM2glvE+xj/zQDGWv
	 fWs6HJakXQQewBLKTf1toRkXGy1Igvl1NncQwlPz3lXvrmF0zXay72MMr1J6JEyHYWZ11
	 mcHvKNjn2R14Tc8srj0dOzK+s4gLlTEWeF+qUpOIq9lSgYeE5b1SRuEELN1hFNTdiGw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=LSBByxn1;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id DC34C606A320
	for <linux-nfs@vger.kernel.org>; Thu, 29 Oct 2026 13:41:15 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=LSBByxn1
Received: by smtp.kernel.org (Postfix) with ESMTPSA id BE6FB1F01828;
	Thu, 29 Oct 2026 13:41:14 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793281275;
	bh=XL1lAn3vAWFPf9PcA4BhixZyHFuj0H7Sum8FCmZEJho=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=LSBByxn1Vv+s/d1wPshlFEVU83vtU6lQuHbnlCUfbIX6RjUdXoMp9YdBDDvbqKbbu
	 2SxXXJ7R8nlj9+ahGRy3Pz9mPYgsgV79UYdqcQembTzIiDAujGT5FkAiJ4syqwNhgH
	 OZUTSoWOder3xE7wg3zFmp+7EvUYjpqFusu9z8bdqI9nHASH7dK0M/opbVHRQLcnps
	 RXd5qgJXwxU/XQoxFpg/BmbA7zbODmRdjG2ZHPDvpV6Cvg6Qsopj4rr14UgTJI9bvr
	 +BEZ6blYtu2LsXGxDK4Mbjqg4DSlBWs7hTRIXLTJgKFfOc0YFIXc8KAZxJeQVgIyi+
	 7SQxvcXaS2VIw==
From: Chuck Lever <cel@kernel.org>
Date: Thu, 29 Oct 2026 09:40:59 -0400
Subject: [PATCH 01/10] NFSD: Serialize forced client expiry with state
 shutdown
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
Message-Id: <20261029-random-stateids-v1-1-8648878fec8c@kernel.org>
References: <20261029-random-stateids-v1-0-8648878fec8c@kernel.org>
In-Reply-To: <20261029-random-stateids-v1-0-8648878fec8c@kernel.org>
To: Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org
X-Mailer: b4 0.17-dev-9c833
X-Developer-Signature: v=1; a=openpgp-sha256; l=3384; i=cel@kernel.org;
 h=from:subject:message-id; bh=AoXRbHOPXctx6FkvJy29LZdVPetMCHoGs7nnYuv0ZaM=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBq40z38DMSkCBWi9mgP+ovU/JOT9fLmDnXEyzoq
 7OBWiqrFwCJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCauNM9wAKCRAzarMzb2Z/
 l6OYD/9L/fZtevHWG3jJVzi4w0FjWOBXQW0mwIgvxXPFnRadcXl1G3ubYWIBmFJ/6kh85705qls
 6vXi5WO3TLDoY9cdPK4sKEiKxLZyLLpUqZJIqNJ0DjAu6aLxN8FuoL7tT9MFkFOeHzml2fsjcUu
 avTaG8wOf0pkH52vR5dm0MZPhQ15b2sfYPZXrCdPREY5RMa9pDI4uQmFUd7hz07k2ASDSR4GDLn
 ukksfScxSQDn7SKM1uTGOCf3CtWXdv4gFhGg1rnXs7dnXNq0TonKEuFt4HhWO8G6x7evUki0//A
 ow74voYQob+mn6eCx4MIJwPhFaiexItntdZl/Ledy1fYgsUqwqC2ZlQVuPXuc4oBpI1EI85KEMo
 A32r/xDE9RlsE6OFoJw0B0wcBsDB/lrHcHPIzesn1LoKA7P3jibDhknSDwbkBA254WZMRhE5/4x
 mkb4B18VtdWxrnD5W+n1sGY0t0QJNGTTdNycDHqXSFRU8BDbMeB6NnL3ykZlReUxJXIxq5MieSK
 rgep0jSZWYJBAOtLlPhUhNvom8aOHI7AvFzD6vPuKw/iOVzE29VbGBi/E2UE75g9q7jEzogaXli
 m/0Y8DMGIUev5e1STbPabjY82f6NxZOYl2c7r+NI2BbuX5fZC6Ela4alV8k9BQO9vn0VMTRedCl
 Q1RnpK9NiRSCalw==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

client_ctl_write() pins the client only through the nfsdfs kref and
calls force_expire_client() without nn->nfsd_mutex.
nfs4_state_shutdown_net() walks the client hash tables with only that
mutex held. A write of "expire" that races with the shutdown unhashes
its client under client_lock, so the walk never sees that client. The
write's expire_client() then runs __destroy_client() after the
shutdown has freed the hash tables, disabled the laundromat, freed
nn->client_tracking_ops, and destroyed the nfsd_file and nfs4_file
caches that the destroy puts references into.

Take nn->nfsd_mutex in force_expire_client() around the unhash and
the destroy, once cl_rpc_users has drained, and proceed only while
NFSD_NET_UP is set, as nfsd4_revoke_states() already requires of its
callers. Under the mutex the shutdown either has not started, so the
forced expiry completes before the walk, or has finished, so the
write fails with ENXIO. The two waits stay outside the mutex, which
the netlink export handlers also take.

Fixes: 89c905beccbb ("nfsd: allow forced expiration of NFSv4 clients")
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/nfs4state.c | 26 ++++++++++++++++++++------
 1 file changed, 20 insertions(+), 6 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index f2b52ba901cb..a613a9f6c330 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -3595,7 +3595,7 @@ static const struct file_operations client_states_fops = {
  * so the caller has a guarantee that the client's locks are gone by
  * the time the write returns:
  */
-static void force_expire_client(struct nfs4_client *clp)
+static bool force_expire_client(struct nfs4_client *clp)
 {
 	struct nfsd_net *nn = net_generic(clp->net, nfsd_net_id);
 	bool already_expired;
@@ -3608,27 +3608,40 @@ static void force_expire_client(struct nfs4_client *clp)
 	 * this client or is seen by this wait_event().
 	 */
 	spin_lock(&nn->client_lock);
+	if (list_empty(&clp->cl_lru) && clp->cl_time) {
+		spin_unlock(&nn->client_lock);
+		return false;
+	}
 	clp->cl_time = 0;
 	spin_unlock(&nn->client_lock);
 
 	wait_event(expiry_wq, atomic_read(&clp->cl_rpc_users) == 0);
+
+	mutex_lock(&nn->nfsd_mutex);
+	if (!test_bit(NFSD_NET_UP, &nn->flags)) {
+		mutex_unlock(&nn->nfsd_mutex);
+		return false;
+	}
 	spin_lock(&nn->client_lock);
 	already_expired = list_empty(&clp->cl_lru);
 	if (!already_expired)
 		unhash_client_locked(clp);
 	spin_unlock(&nn->client_lock);
-
 	if (!already_expired)
 		expire_client(clp);
-	else
+	mutex_unlock(&nn->nfsd_mutex);
+
+	if (already_expired)
 		wait_event(expiry_wq, clp->cl_nfsd_dentry == NULL);
+	return true;
 }
 
 static ssize_t client_ctl_write(struct file *file, const char __user *buf,
 				   size_t size, loff_t *pos)
 {
-	char *data;
 	struct nfs4_client *clp;
+	ssize_t ret = -ENXIO;
+	char *data;
 
 	data = simple_transaction_get(file, buf, size);
 	if (IS_ERR(data))
@@ -3638,9 +3651,10 @@ static ssize_t client_ctl_write(struct file *file, const char __user *buf,
 	clp = get_nfsdfs_clp(file_inode(file));
 	if (!clp)
 		return -ENXIO;
-	force_expire_client(clp);
+	if (force_expire_client(clp))
+		ret = 7;
 	nfsd4_put_client(clp);
-	return 7;
+	return ret;
 }
 
 static const struct file_operations client_ctl_fops = {

-- 
2.56.0


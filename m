Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794332663;
	b=lIFh7gUTXnxXSudhCWjpogbQ/ONfwIrI7PJNQ1fjf9BlHaVbhDiAkQpcLh06tBWcuTC4
	 DTnBQJUCREzjSLUgO3ujO2a4Pstk+s+6o/j1SNvrlhyFtaVmiqBZjuP0QYS5orEL0IKuP
	 dyl16gXNbi65iFMxjCy/3KZY7E1i3mG/w3HqVKnZi9vlKVY5z+dI3Xa9ga1iEXvMobA7V
	 x5ugmXTXszA5W3ClqvFPTm++0wEB1Li7Lp38nbJEMA53UprW6mKBxgxkgo/mQGIU3wk4O
	 SBdbPBwNZnJrf/2TFfYiE+suQaR6pfGYmtpuatvtYrhOwxSstcQAZzpT1+P6XyOCKDA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794332663;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=TXGlOEZPkPJIMZc6iYy3WLukJr+SkA0RKjA4UkNB0fw=;
	b=lQrMhCwnSLKmTwTCrEx6HAgRxVa9o+JZ6TUcfhqwj+H5AykheDVxnKDo44eDLstrDVuE
	 QkjV32o+C/qSwSal0m2Z5wo5cu4ZuRYX3rH04IzlDfhPI0bo/Nf8+suAnERw4W+pdZ7rX
	 NUYWE9/rGAo1PJtGoxygOnvKivEbUBHCA+qTT+SyhtAOEm3K9L8ePV9iVK2Yn8M+Vuc+G
	 LPVsN1RfjxcHerLj5zQBXfvtk6u9/NUdTBpOR10l1ZtUiS5E+plISJuICwB9XptU6YzKC
	 OGeL06vdEcuLckadStj5CmSHOirLCnHOhdHbNP/+81EE6iWUOHVbeHYBy3d1meEvkAQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b="cP9SsL0/";
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 401AF60A2603
	for <linux-nfs@vger.kernel.org>; Tue, 10 Nov 2026 17:44:23 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=cP9SsL0/
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 378911F008A1;
	Tue, 10 Nov 2026 17:44:22 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794332663;
	bh=TXGlOEZPkPJIMZc6iYy3WLukJr+SkA0RKjA4UkNB0fw=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=cP9SsL0/nPOMv3AfQQyAiBtlCyX1jG6nGhxFAZrE2Ot7u9AlRVVW52WXECBoTV1By
	 twgYy0yidNgA4jOp/Cav6SH0IS6nRBylgjizlV7+R9IIEnQSaQiHaMHSpkDHwWJbBr
	 qH4cPnbozL/w9/vu79cPlIn8oY5P1hVO7OfKjpI5KNMVZrMN6ukUP2e1mtTmTlRG6c
	 oGASPMp4ZNoRd4p+DtmQRsKZp6cuhvdV42Vv7TtbqbxzSU8f2JWLHkEGorzQAgp1xz
	 eukP+HRhN/eAYjcYwcMbGbPvRORa/KWEuWAdC3Lyq50SWASCxcWTnK/mxonVfsCpoS
	 gvabuWKl4hxUA==
From: Chuck Lever <cel@kernel.org>
Date: Tue, 10 Nov 2026 12:44:08 -0500
Subject: [PATCH v2 01/10] NFSD: Serialize forced client expiry with state
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
Message-Id: <20261110-random-stateids-v2-1-57e0996eb2a2@kernel.org>
References: <20261110-random-stateids-v2-0-57e0996eb2a2@kernel.org>
In-Reply-To: <20261110-random-stateids-v2-0-57e0996eb2a2@kernel.org>
To: Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org
X-Mailer: b4 0.17-dev-9c833
X-Developer-Signature: v=1; a=openpgp-sha256; l=3431; i=cel@kernel.org;
 h=from:subject:message-id; bh=ludfOzc09zrX/Xez6tt8yQ0aVOhyoOH2y315xy6K4oA=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBq81f015JF0ILzLErIushtYd6XlwP+ZosXHyT2B
 H3TKBh5hTOJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCavNX9AAKCRAzarMzb2Z/
 lzHND/9orqDGm1tSspBUEx8THtlnsLvsFvIff9nHczCGkdfyXwZjTL8kIr56ieWzLqdDQ2HP24s
 DEkAynPz9C30HlyF5CRymSzv05TE9WveJlALyfZcWRsIGrIb5eVGO4pVdt975JHmsAzkKbkpcqk
 zN3sYL+1Dv98LTybfwVy24O13vlwoWEQnm4LRCCW9UnIAAyjtX59dZVsOLnhEHDNcknoK9Ud51g
 ey23B4ne1O1Dytjvk13bkRtAyDsgTU16BnOsQn/UnQ/fy1bY99qYFpTxP8IKyrMJa4VR5d0FVdr
 jobAFmaqNUdrhtVANFGCxMZw0MJ4AqgEgHDRsc+YzkA6pF0TPhREkguU2BqWTFMkwkH5wGQqbF1
 5xRIwVLjlPRg3ITFlOBcUb6N8xSwCdboYBFRNL+4H6T/S8m95QApQXj++KsQVS6y0WPKQBWAtW7
 510jUt4Hc5s2zqiNUNVRj79zmrPZjPyjS1YXwOJ8yPd6rIzRRA9yED6rAYQ8Fm+iEJ5vSqmoZYy
 U43fpfzszFVHukyp404WNzSRXlJWpsQLF+xr0KD8PbFks4XumBTg258I/M/WNF8eYcZQU8YMss4
 EPLezsk56BcxiJYiqYBRMlcSRp6rKqC9FkQuGrG427ezGFMy1q0DB2HKFkm7BOaWP/caQGX6WuO
 ddBDwpLKSlY4Izg==
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
Reviewed-by: Jeff Layton <jlayton@kernel.org>
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/nfs4state.c | 26 ++++++++++++++++++++------
 1 file changed, 20 insertions(+), 6 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index f62801b42f8b..d3ce40420fd0 100644
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


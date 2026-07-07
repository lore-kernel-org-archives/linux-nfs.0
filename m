Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D91133148D9
	for <linux-nfs@vger.kernel.org>; Tue,  7 Jul 2026 19:31:44 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1783452705; cv=none; b=YRPMai5d2/jKmT1JKwDKglkXJK46eQwmRwO1tao85yfIUvyCMoq1hKRdLAXzwa+4edCC3tdMpEVuQPxigKJ8JhIBqTQFqOuQq9OYtvbuwD0CZbH3p68VZGzYAkJvlviUF7MB18VSHgV5xqoJvzYPtX4IzwRPrRH2RBBNr8eaiOw=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1783452705; c=relaxed/simple;
	bh=g00rAC1Ng8s0ZfTIS3tOFLDXXZ/A4//EF06iPJvatd0=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=uGkMvuFk/+7HS83WSXqXcXvMeLXDPlUFKV7XRlnGzbU28ncAhK1lIEOlXumfMZQv1qB/afV9RpxMRwG/8K5cdtlYv67dJcUbukPdYY4s06ywysw5FsYu5hOQx7uzO2jgCYtGxz7GiKdFjaTyi7uu1Zdm9oz9VzfkPNH63/D+n30=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=aYm3lPQH; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="aYm3lPQH"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 416751F00A3A;
	Tue,  7 Jul 2026 19:31:44 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1783452704;
	bh=hWdtR3m2Wpf37AoHQ0Uma2/MaUspOcIjEf4PJ/Evoo4=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=aYm3lPQHhqzsy1NDoS9pvomlLDkUIO6WxxwTm70l7eSGUUz1VsKLdGLnOfQt965zt
	 5R4vlt0BFg+Kxc+DcyrcvMw92WmWU0ebS6yv6QVdRgcJEPls6J6x/9zx+Ak5bz3wsm
	 0jNJ7pw6va82UH/AZGlqH/EL8dV71WnPVwxqBWnDkbxOh1PhzBdnnygmgqF4brMeDo
	 LgsTpxkGKFPhP9P8ll8rk6i5D9muqHmunTr98lackNGhc1iIVmZrRmXzskjhYZPlIt
	 IA+GhhMz121YKTD4u7BV8NV8X0xSquS/pOkf4O0NctpD9mnEyvH61b/gYPB9DpqUO3
	 Xou7DXLK20K5Q==
From: Chuck Lever <cel@kernel.org>
Date: Tue, 07 Jul 2026 15:31:25 -0400
Subject: [PATCH v3 5/9] NFSD: Prevent client use-after-free during NFSv4.0
 revoked-state cleanup
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260707-cel-v3-5-7c0cc16fd54f@kernel.org>
References: <20260707-cel-v3-0-7c0cc16fd54f@kernel.org>
In-Reply-To: <20260707-cel-v3-0-7c0cc16fd54f@kernel.org>
To: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org, Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.16-dev
X-Developer-Signature: v=1; a=openpgp-sha256; l=1898; i=cel@kernel.org;
 h=from:subject:message-id; bh=g00rAC1Ng8s0ZfTIS3tOFLDXXZ/A4//EF06iPJvatd0=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqTVQbzegYYbcVmYF2al9x+96zaqyhGmkid078o
 2UnGwAJmhiJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCak1UGwAKCRAzarMzb2Z/
 l1aJD/41DPuLpHzHiBlV8hbl2qgVq9agL7j7EOE6WomOUGDo9rAalLs7q1SoG69k+p1smy5sdq8
 pIdXtX8plKqCVvYcBnBorj5iET1D/UFahlx903s/Anr0DmiPkz2o/SAhsuAjnZwpwd0/jMIrEjX
 6GLwhSUM5RtphSX1ag7M5nhIRkZQzucfUbiWySsN6USIyRRHlpmqmwKexz3FlGGGdDmKA5sZZ/i
 rGZ+njQUAxRxS8DBrfyi5FA0+KCFCjhkCH/LY/QOWTRiorHhR9eEznr8Pq8qBBLJkwSQRLhqvYD
 PixSsKLuVfmrX48vfdNKPukKBu7U9wPOJISD0G7vR6AT53ZBPnUq0gdRN+vYjxFZgws0wodJqso
 3Z+kCJCl0SwOzUfXxPCvOeeMxXWV3uq8IdF0Bq/UmRRxo3fnFRN0/w36AWtpwADH80LVRjFHWH8
 YDw25GLEfDikJqC3EdQEdzG3a15aSH0dtZIAK9dDJD41+8uPv8m17alUkUUYZcDqhObpm7tvme1
 d3OUG5i0F9Q4c5fqz18NRWQspNOGCr5Sduc/ffsNwixXcPPlmlvEv/5SfWlAd4kgcC+bsi85wOA
 +Qw343/ZhIf59nrA7xu+KhGXM0waW5NhiigsloLZbP09iQo7QibbsLVUugWAYMpAh9+hRvc0Znq
 tLrMMulHJ1ZLxcQ==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

nfs40_clean_admin_revoked() takes a stateid reference under
clp->cl_lock, drops nn->client_lock, and calls
nfsd4_drop_revoked_stid(), which dereferences the stateid's client
through s->sc_client->cl_lock.  The stateid reference does not pin the
client, so a teardown racing the dropped lock can free the client
while nfsd4_drop_revoked_stid() is still using it.

This cleanup runs from the laundromat, so a periodic sweep can race
force_expire_client() driven by a write to the clients/<id>/ctl file.

Skip a client that is already expiring and otherwise pin it with
cl_rpc_users under client_lock before dropping the lock, matching
nfsd4_revoke_states().

Fixes: d688d8585e6b ("nfsd: allow admin-revoked NFSv4.0 state to be freed.")
Reviewed-by: NeilBrown <neil@brown.name>
Reviewed-by: Jeff Layton <jlayton@kernel.org>
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/nfs4state.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 9de535a2a4bb..445a0f40d5ff 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -7452,16 +7452,22 @@ static void nfs40_clean_admin_revoked(struct nfsd_net *nn,
 
 		if (atomic_read(&clp->cl_admin_revoked) == 0)
 			continue;
+		if (is_client_expired(clp))
+			continue;
 
 		spin_lock(&clp->cl_lock);
 		idr_for_each_entry_ul(&clp->cl_stateids, stid, tmp, id)
 			if (stid->sc_status & SC_STATUS_ADMIN_REVOKED) {
 				refcount_inc(&stid->sc_count);
+				atomic_inc(&clp->cl_rpc_users);
 				spin_unlock(&nn->client_lock);
 				/* this function drops ->cl_lock */
 				nfsd4_drop_revoked_stid(stid);
 				nfs4_put_stid(stid);
 				spin_lock(&nn->client_lock);
+				if (atomic_dec_and_test(&clp->cl_rpc_users) &&
+				    is_client_expired(clp))
+					wake_up_all(&expiry_wq);
 				goto retry;
 			}
 		spin_unlock(&clp->cl_lock);

-- 
2.54.0


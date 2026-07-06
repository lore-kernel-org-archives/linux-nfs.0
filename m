Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A716532E141
	for <linux-nfs@vger.kernel.org>; Mon,  6 Jul 2026 01:26:03 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1783301164; cv=none; b=QNz9pxi+uhmGhmav0Lty3rPptN7WE1P1z498OfHmAW3QjZy4SA1NTwTVdkEknHX9lGb4eIfizxOtHwu52Uia80Zff1D3QHiAE36gL80iHuEyK8WtjndoiWEeT96CKdosAJE6CuHQNnIrd5rvy2P24LTPQ2UayfJjrbUrclBYjtM=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1783301164; c=relaxed/simple;
	bh=S6wUjw2zseX4CbNIMYlM+UTi26VOrwCo8oUJDZjDx6o=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=idfVq+2XPinaOJ1+29BC0TPNQpa9kUo5LKQVQgiZUP3CEuK7Me8X4szyEaaW/gXPHNLgas/vweNpsDNyiNtdKgiDWIzQjFZgcCTeB8eXhcTC0JZmWbcKMC9LaTXVEpXbRB/7raC9ggP3si55lB06gvooaJcTVgV5LBxyEbGMh50=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=XwgOCeYc; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="XwgOCeYc"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 076A11F00A3D;
	Mon,  6 Jul 2026 01:26:02 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1783301163;
	bh=mKhIxeOdQKummKFyx+6Q09UuLDEWGrwI6WXxNbZ6X78=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=XwgOCeYcwz2PK7l/RpzUSZviWsnkQe39L/qLDU6WYEu3DdablSyGY3ySMaXL5Wts9
	 mzboZ+v+h9WqDmLHBDHsbgQ/1fj6KdIg9shPPc0Uo7wK2j3gI9NvdInm0TtO9UXr1i
	 8xPqQTaky+pfeUWKoTI6EBPk/RIJV0C/HijB/nxpDlq9LWZVLg3me16vyo9U0Rv4RU
	 jDyqBxD6/S08pDlZ5n2bPwmpi+63j4fi1dVm8+M9ocT0rBJK0nq1v4gVQ7Noqehc/4
	 KpKdH1kM5ebBHtYMKSbPvdhRAFULiqANxHrPsPQ/H/PdDMVoJdFQB1IaKCBsAC77d9
	 jOyhsvg5UPjBg==
From: Chuck Lever <cel@kernel.org>
Date: Sun, 05 Jul 2026 21:25:42 -0400
Subject: [PATCH v2 6/6] NFSD: Consolidate the revocation-path client unpin
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260705-cel-v2-6-d88c3b68e8bc@kernel.org>
References: <20260705-cel-v2-0-d88c3b68e8bc@kernel.org>
In-Reply-To: <20260705-cel-v2-0-d88c3b68e8bc@kernel.org>
To: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org, Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.16-dev
X-Developer-Signature: v=1; a=openpgp-sha256; l=4787; i=cel@kernel.org;
 h=from:subject:message-id; bh=S6wUjw2zseX4CbNIMYlM+UTi26VOrwCo8oUJDZjDx6o=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqSwQmV9pOQ9G6aOwYRSt5RrjseJ2VkVURTM8IL
 Oss2arURFKJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCaksEJgAKCRAzarMzb2Z/
 l//RD/9RWIrdV3O+pFDKFt4+Cnka9I+R+EanP69kgadC8bdDDhZNOK3OnELA1On8ssnb5ZDeOIx
 3cF6OvB1J6gB+YMMhW2kZX3OSWsPBObGoUAKpx45uyUNi1U3+3+7LMq2XAjA7BxABOwXqO/a8Ok
 JvL5M93uFwe8GtYSqVJlYYy2t5jXW0zXZdWV2y9+y9TQnopc0t0SByZs9E67FpN685kaM/0EUGE
 lmwsWyFw6AKs25c83m16M9KKuLuRpvwMe0NX6KtaynoWdOpJIoztz2h+tOnKNJw9DEztIPPungp
 HLhWB7TwbFVBXab68ALyLiJWaaEi65QO+qEOj6GAwiaqGt5UTBvaAikkn1AgjqkVIggOxcrKi2/
 G2QS3hFNcHCh1ODfXR2/aQ7eqS3v04sFd6kYB2mpugxMsjcKU0ZFsORMRP8Y1ZymYDChOrWaQuc
 rQG6AanjiM6jg4xPbPIYChoFZcA6vePUOdjkyH3ZgcSRi1B+hXuCjls3bJZbAzRCfrVFrNfNiqn
 5WvPEq8vcMsy7gWh8D4yRHY71PG0AFphsPVuFW17nttRrEh4O8gfGUu06LlxpZsw6ohh+Ifc11z
 h7DfS0zKij+FhQrqPdi3phQfp+Yv7NGO22EkopFUe8pPGWkjZtdK7CPVHtw5hk3iB62QojmNynI
 GUq9kpurnm1qLXg==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

The client use-after-free fixes in the state-revocation paths left
four open-coded copies of one idiom: drop a cl_rpc_users pin without
renewing the client's lease, waking force_expire_client() when the
last pin drops on a client it is tearing down.  The accompanying "do
not renew" rationale was documented at only one of the four sites.

put_client_renew_locked() and put_client_renew() already carry the
same pin-drop logic, but they renew a non-expired client's lease and
so would resurrect the client whose state is being revoked.  Factor
the common pin-drop into __put_client_locked(), parameterized by
whether to renew.  The renew helpers pass true; the new
put_client_no_renew_locked() and put_client_no_renew() pass false and
carry the revocation paths, which must not revive the client they are
tearing down.  No change in behavior.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/nfs4state.c | 69 +++++++++++++++++++++++++++++++----------------------
 1 file changed, 41 insertions(+), 28 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index e80d4f97f020..53d123ae7965 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -206,18 +206,28 @@ renew_client_locked(struct nfs4_client *clp)
 	clp->cl_state = NFSD4_ACTIVE;
 }
 
+/*
+ * Finish a cl_rpc_users unpin with the client_lock held. A
+ * revocation walk clears @renew so the client whose state it is
+ * revoking is not revived; every other caller renews the lease of
+ * a still-active client.
+ */
+static void __put_client_locked(struct nfs4_client *clp, bool renew)
+{
+	if (is_client_expired(clp))
+		wake_up_all(&expiry_wq);
+	else if (renew)
+		renew_client_locked(clp);
+}
+
 static void put_client_renew_locked(struct nfs4_client *clp)
 {
 	struct nfsd_net *nn = net_generic(clp->net, nfsd_net_id);
 
 	lockdep_assert_held(&nn->client_lock);
 
-	if (!atomic_dec_and_test(&clp->cl_rpc_users))
-		return;
-	if (!is_client_expired(clp))
-		renew_client_locked(clp);
-	else
-		wake_up_all(&expiry_wq);
+	if (atomic_dec_and_test(&clp->cl_rpc_users))
+		__put_client_locked(clp, true);
 }
 
 static void put_client_renew(struct nfs4_client *clp)
@@ -226,10 +236,27 @@ static void put_client_renew(struct nfs4_client *clp)
 
 	if (!atomic_dec_and_lock(&clp->cl_rpc_users, &nn->client_lock))
 		return;
-	if (!is_client_expired(clp))
-		renew_client_locked(clp);
-	else
-		wake_up_all(&expiry_wq);
+	__put_client_locked(clp, true);
+	spin_unlock(&nn->client_lock);
+}
+
+static void put_client_no_renew_locked(struct nfs4_client *clp)
+{
+	struct nfsd_net *nn = net_generic(clp->net, nfsd_net_id);
+
+	lockdep_assert_held(&nn->client_lock);
+
+	if (atomic_dec_and_test(&clp->cl_rpc_users))
+		__put_client_locked(clp, false);
+}
+
+static void put_client_no_renew(struct nfs4_client *clp)
+{
+	struct nfsd_net *nn = net_generic(clp->net, nfsd_net_id);
+
+	if (!atomic_dec_and_lock(&clp->cl_rpc_users, &nn->client_lock))
+		return;
+	__put_client_locked(clp, false);
 	spin_unlock(&nn->client_lock);
 }
 
@@ -1990,9 +2017,7 @@ void nfsd4_revoke_states(struct nfsd_net *nn, struct super_block *sb)
 					 */
 					nn->nfs40_last_revoke =
 						ktime_get_boottime_seconds();
-				if (atomic_dec_and_test(&clp->cl_rpc_users) &&
-				    is_client_expired(clp))
-					wake_up_all(&expiry_wq);
+				put_client_no_renew_locked(clp);
 				goto retry;
 			}
 		}
@@ -2070,9 +2095,7 @@ void nfsd4_revoke_export_states(struct nfsd_net *nn, const struct path *path)
 				if (clp->cl_minorversion == 0)
 					nn->nfs40_last_revoke =
 						ktime_get_boottime_seconds();
-				if (atomic_dec_and_test(&clp->cl_rpc_users) &&
-				    is_client_expired(clp))
-					wake_up_all(&expiry_wq);
+				put_client_no_renew_locked(clp);
 				goto retry;
 			}
 		}
@@ -7460,9 +7483,7 @@ static void nfs40_clean_admin_revoked(struct nfsd_net *nn,
 				nfsd4_drop_revoked_stid(stid);
 				nfs4_put_stid(stid);
 				spin_lock(&nn->client_lock);
-				if (atomic_dec_and_test(&clp->cl_rpc_users) &&
-				    is_client_expired(clp))
-					wake_up_all(&expiry_wq);
+				put_client_no_renew_locked(clp);
 				goto retry;
 			}
 		spin_unlock(&clp->cl_lock);
@@ -7535,15 +7556,7 @@ nfs4_laundromat(struct nfsd_net *nn)
 		clp = dp->dl_stid.sc_client;
 		list_del_init(&dp->dl_recall_lru);
 		revoke_delegation(dp);
-		/*
-		 * Unpin without renewing: put_client_renew() would
-		 * renew the reaped client's lease.
-		 */
-		if (atomic_dec_and_lock(&clp->cl_rpc_users, &nn->client_lock)) {
-			if (is_client_expired(clp))
-				wake_up_all(&expiry_wq);
-			spin_unlock(&nn->client_lock);
-		}
+		put_client_no_renew(clp);
 	}
 
 	spin_lock(&nn->client_lock);

-- 
2.54.0


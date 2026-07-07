Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9D9522D8391
	for <linux-nfs@vger.kernel.org>; Tue,  7 Jul 2026 19:31:45 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1783452706; cv=none; b=lcrSCeE7ledXn25V12dzoAvi/Sh7ED9yP40onG2JEgrAU+ahn6EONSbSnWX0wYkrOJnL9di9ndUZXZ2RslxIYrxGvOshciEi5R2vm2B4IKGQ0CbWFfO47iZyhqgQyKWXHFAy/O7p2vl3pfjnsUhwC3gvnYCxQY1HuaW+pV8zdHw=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1783452706; c=relaxed/simple;
	bh=OHNPpDUoxlvLmA9oMH2uu2wD8kPh8i83NI9I0DaLpU4=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=FDy+GFdcpSAqMcylSAufTNH/PhGrNsCerDS+ncnAeIxvBG2QYkB3uiPKb/+dpGbW1LXsN7BUxjCFR3yHiUnav9uFjta3RR6gKhF2SW2wYDMy26WO/iwqJH4CycqFGzNFZ09uYsl1cKFuZyXQIuJtJ34X3ETU/OlHYRKB1hMzzsw=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=V12vhnlU; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="V12vhnlU"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 064BD1F00A3D;
	Tue,  7 Jul 2026 19:31:44 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1783452705;
	bh=jXKIF1/8Z0bAqwPLu4AeFYwhGaz8CukTAjbXK6rzrJw=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=V12vhnlUqCd4Npx+A7E+Xs1W+tJI+Po3hKOL/jHN+Mz/N0fx1tq/XNGlGqdiL3EDC
	 6uW7iSFpK5RnwaGvS1+PedI0N0ZuRtXvHj2qi9llw0YO2xI8I7TL+j8KHkK90/5OIS
	 8zzKj1L3XjFtKri8C2XK+ebPefGPTYVpMtH5dkzUFsXDsiP4lOsJ6r3p6XzYENjNkS
	 OOemHSvnFU5PJs9hWAzb3qyzBzLN3xloCFZl+aWj2hs1hlRg8ER53Ao2+MiH3IzcbR
	 lnAzyivkqygOFC60eeTBEkGgqYvhsC+E854aj49S6Ouz5/1hFhGXomBTsYaPgeLwdk
	 7RcdzO6qtmEkQ==
From: Chuck Lever <cel@kernel.org>
Date: Tue, 07 Jul 2026 15:31:26 -0400
Subject: [PATCH v3 6/9] NFSD: Consolidate the revocation-path client unpin
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260707-cel-v3-6-7c0cc16fd54f@kernel.org>
References: <20260707-cel-v3-0-7c0cc16fd54f@kernel.org>
In-Reply-To: <20260707-cel-v3-0-7c0cc16fd54f@kernel.org>
To: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org, Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.16-dev
X-Developer-Signature: v=1; a=openpgp-sha256; l=4876; i=cel@kernel.org;
 h=from:subject:message-id; bh=OHNPpDUoxlvLmA9oMH2uu2wD8kPh8i83NI9I0DaLpU4=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqTVQb9vnf8T8HiwA7aCludVqGoQ+ZLwIuyKTae
 NuXWipeNlmJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCak1UGwAKCRAzarMzb2Z/
 lzjTD/9Nh/3JG7TWprEM/6+Bh1R6NRUNi9/cFT7Ff2Wm8LmGWgLSG5CFKvDLLRNHISN4kK1DGXt
 erUBSwiACCbRmlLCcz4TrZGSMdX10NxIhtNkeUNHmwF52ZKiC0Oc6FStwLDutUbKqBU80c0eh0x
 Ae0lYdeQJERRR5FiTdgjaHm0MlhJb6jiwoiiYda2GsUFuCn3mzpqeh2cYqYsstIvYEWUMI1StQ+
 f68/VeWOQPOxcaNqzNwPyrvmMcryp0oETVCQfmsh5sw2dyDGy96dKqkwp1RoyRT25ZrmtX1SDNt
 fj53f2TvTDgChb+QJ8Wg+XmsPZy4Ct4UMtdbt+GuB5wqwt3n3f8lkg+O6MlaDR+oqCSi2BjmnJA
 ImQUwwZVHvkupJQ6Iukax0TWuf1FHvWJwy29m9Xy46m9NxJNQRnQ9c294Q3FWM0rCv8cXOxC4iE
 IVkq52CQxvtrVL/7kNz/vWNu2RVmP+AQkbU+zQSIcx9YpvWtzSIPjXgCM1PU+06NZcMwc1Su9E4
 9gPtVXPi4TmNB86Ku+3UdbBtWq3vSQfg02wIKvLZi2Kc5lFqaSbC+Sif9mZWyUgrXubfvfq3mcM
 KYzKaqgWGePsdxIeBwCxLyOFjmOUwc7FotabcDs3p1jcopi76ijl5DtD55BQyTGeDS3YneGC4yn
 aluc/Qniwg+juvA==
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

Reviewed-by: NeilBrown <neil@brown.name>
Reviewed-by: Jeff Layton <jlayton@kernel.org>
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/nfs4state.c | 69 +++++++++++++++++++++++++++++++----------------------
 1 file changed, 41 insertions(+), 28 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 445a0f40d5ff..142ba7d80539 100644
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
@@ -7465,9 +7488,7 @@ static void nfs40_clean_admin_revoked(struct nfsd_net *nn,
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
@@ -7540,15 +7561,7 @@ nfs4_laundromat(struct nfsd_net *nn)
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


Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id EC79D4195AF
	for <linux-nfs@vger.kernel.org>; Thu,  9 Jul 2026 17:40:41 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1783618843; cv=none; b=MJNGcYedAYXtUE67ZrvC+B2mLpa1sQbhGs/m3JpSDWV5JFPVDwogQmEod7VJ7iAW/hl7/A4qu6PAfCd8jjTMI7aaO3NNWIbP7MwgV0DvjoE1Bdx4gyfJb01IahY+3IqQg2JrAyoBIJJrHuMM5UwShJQdxAI9DmBVBJnEkiumTTQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1783618843; c=relaxed/simple;
	bh=TdjDz0QPIisYg2PRMpA6G2KXuaNaSDOKOQSW4HZKINQ=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=k1Mapr/luS0KkY0JQoT14nU+yhALr49HKRgorWPdvx8VX/E+heZS1qSw/2WMkBC4zogJjjn0EX9T5YNtYZXb/w28DyIFQTJQRX7z3qrKYOpfYE9QNi7mhs5C6XyB1rULnx9AN933aTIJ+r/9QjEGndVVEmnaRq4VSsscWX9eBhs=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=NIuW0SA2; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="NIuW0SA2"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 561A31F00A3E;
	Thu,  9 Jul 2026 17:40:41 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1783618841;
	bh=q2/sBPW2xQmXWLCmo8oxZcbQDGqZmXMQvI1RUCljaq4=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=NIuW0SA2aLpFAVvKA5nzDsMerZxomyI9gue1Wtpun8glfjYSTGvZWvz5hcgsGm/g7
	 A12r/d92Rj9IpAnSBVp7RE6ebSh5I6QdFFDTY3rPStk+Os7qmTjKR1Yh68Aessvhvi
	 iAU+j5voLYAA0d+pZJ0Z8wVKpn9XHJS3V9QIzzkgwpVObzQbg9HJT6ecc1DwB6muJi
	 a0uWySvoUxSl4W5SysI+xJ41UxeMDqLIg3YXUiQzjs4h6PVH19CIq0lnI1xldMrFjX
	 NIHfluBHluSedob0O+ZDlbI+nRvxY2s64Ad9SWwsXR1LGGlTjYFfeZ/3iKuO6MJKK0
	 uNE5XqnHXlKPQ==
From: Chuck Lever <cel@kernel.org>
Date: Thu, 09 Jul 2026 13:40:27 -0400
Subject: [PATCH v4 4/9] NFSD: Prevent client use-after-free during export
 state revocation
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260709-cel-v4-4-1d519d9be0cb@kernel.org>
References: <20260709-cel-v4-0-1d519d9be0cb@kernel.org>
In-Reply-To: <20260709-cel-v4-0-1d519d9be0cb@kernel.org>
To: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org, Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.16-dev
X-Developer-Signature: v=1; a=openpgp-sha256; l=2102; i=cel@kernel.org;
 h=from:subject:message-id; bh=TdjDz0QPIisYg2PRMpA6G2KXuaNaSDOKOQSW4HZKINQ=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqT90V+LLeH3RzgI+Y5grsaGBPyZcpsqNKm/iV7
 pkG0NEfh92JAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCak/dFQAKCRAzarMzb2Z/
 l/seEACAaPf7Wy5QCV7O+jnOETqURdhILCGemlN5UDSAdhF2jHt5rlt+bDS3naeqa/uAi/dEV6t
 WRQuYuGgdgtuVz3BGIZnWEUmvhY+1hgwRyeytDDuQ5Me+6wf7H1iIy3VLWATiswP474buR6Rl6B
 iC9zsVeZMUZc2XXc22Pqz6G6bL4Tyeh5AJwX0mL+/GoEqZQEn0EKHqbwmsuBZwkjov4Fo9sAY+6
 JEZUOwMRTwaethD8uXI12p/34q8yOWzZWHf+0s6XOjnD8lOHDKz4qGtSkwZUy8fzvuyLLG4LPZ7
 zErpul/sC0VBjPzXoMwmy5v3VNELuSDTJJwLpjRuyHr4S0ozHEVj5A3Uba1IXoP9yiNjvc/c4ud
 T+UFFHWDNVfVrIP5wNg3OSPz4DJRIEJH6VOH76E1vqRxADvwnpz6qgr0h9YUZ7TFJdC+1eHcx8s
 wAa5XiY1lWwrP/Yiz+YVmVbdYeyCGuk2voIWTiVpXxG8rlAJfA4hONseNzW2FAc8UzO1mHHeBY3
 ycR9qKWGz8iqbYOn+IAMKUoLljXQNqz6WeMCs2ITOJ0dK28qm9ZAAwiAu3zbADhGlj2Oxc+Deq1
 o1ZNBVupeRVhmmmoBO27+nYLRjweJmgxvNkwRt8X0LXRImXWWzHstkHjWPC9n0IiM/kZIaXbwRC
 cyV6TRNAoT9KSpA==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

nfsd4_revoke_export_states() has the same use-after-free as
nfsd4_revoke_states(): it drops nn->client_lock across
revoke_one_stid() and the following read of clp->cl_minorversion, but
the stateid reference it holds does not pin the client.  A teardown
racing the dropped lock can free the client while revoke_one_stid()
still dereferences it.

exportfs -u drives this path through NFSD_CMD_UNLOCK_EXPORT, so an
administrator removing an export can race a client expiry.

Skip a client that is already expiring and otherwise pin it with
cl_rpc_users under client_lock before dropping the lock, matching
nfsd4_revoke_states().

Fixes: 2eac189bb059 ("NFSD: Add NFSD_CMD_UNLOCK_EXPORT netlink command")
Reviewed-by: NeilBrown <neil@brown.name>
Reviewed-by: Jeff Layton <jlayton@kernel.org>
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/nfs4state.c | 13 ++++++++++---
 1 file changed, 10 insertions(+), 3 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 565fa2ff5ba5..9de535a2a4bb 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2055,10 +2055,14 @@ void nfsd4_revoke_export_states(struct nfsd_net *nn, const struct path *path)
 		struct nfs4_client *clp;
 	retry:
 		list_for_each_entry(clp, head, cl_idhash) {
-			struct nfs4_stid *stid = find_one_export_stid(
-							clp, path,
-							sc_types);
+			struct nfs4_stid *stid;
+
+			/* Skip or pin clp as in nfsd4_revoke_states(). */
+			if (is_client_expired(clp))
+				continue;
+			stid = find_one_export_stid(clp, path, sc_types);
 			if (stid) {
+				atomic_inc(&clp->cl_rpc_users);
 				spin_unlock(&nn->client_lock);
 				revoke_one_stid(nn, clp, stid);
 				nfs4_put_stid(stid);
@@ -2066,6 +2070,9 @@ void nfsd4_revoke_export_states(struct nfsd_net *nn, const struct path *path)
 				if (clp->cl_minorversion == 0)
 					nn->nfs40_last_revoke =
 						ktime_get_boottime_seconds();
+				if (atomic_dec_and_test(&clp->cl_rpc_users) &&
+				    is_client_expired(clp))
+					wake_up_all(&expiry_wq);
 				goto retry;
 			}
 		}

-- 
2.54.0


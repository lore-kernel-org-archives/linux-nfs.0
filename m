Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 1E70C33F582
	for <linux-nfs@vger.kernel.org>; Tue,  7 Jul 2026 19:31:44 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1783452705; cv=none; b=mH26ePWzNJqWH/7+/th9kmWO0W1owNV2sSIiRlky+UAfZFGyVjKXx3ZyKTrvn0eiR7FLKdeNdOCcgRvXM5rbABiw8CQ/V3ARNDI4QEvJhjIncPI+z80Xj0M6sFAtjY884lAKRZcuIsd/IXPkamPhJUNa4q8NF+/7dAuxY1cascA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1783452705; c=relaxed/simple;
	bh=TdjDz0QPIisYg2PRMpA6G2KXuaNaSDOKOQSW4HZKINQ=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=U36457u0YLEDtBjzOdNrtQUdQYDaMBVPE35pe/QywPokM4Jyp/Vh/6dwhIzsAf1o0mg+1RYega5Jv++8hpNrNqXTBob0oW8sR8qmX4JpyUVkZY8QZSrPM6HJllrYW7U3whPYawxrG79h0d07JGL6W+csTsjNw8p31c5vz5gC2CY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=AY935ZKO; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="AY935ZKO"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 7B5FD1F000E9;
	Tue,  7 Jul 2026 19:31:43 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1783452704;
	bh=q2/sBPW2xQmXWLCmo8oxZcbQDGqZmXMQvI1RUCljaq4=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=AY935ZKOz1RJVR95eici3w17QTu2jBjGHSMtfTLP20WWGCiEp8c9mVMXTMejaxLLj
	 QxYEd6NPG4AZ5n/9csDuOAn9CEZfeBiX+uTbQgsiEQYeJwkrmLQM5sgAUZOoVazROs
	 agR+X4XDsaIwjlcy0mtuc28JVZh0vKbJ8VykWUC9S5xK60tVfWo9RQ/OutEMYSxHc4
	 iAOk+iCstjGHXwn83o/yxPebDgFLjwWIBzj5yOuyLc1jGcOVEFVjOaNgbB2My2KuKv
	 fIc7lwP6P6eOMto4nHgWX5kaFjpz1Ni1yTRDxPWiA7Sm4ud5wOeZZRQ0uUf7xS9335
	 V1aYg0ONzqnJA==
From: Chuck Lever <cel@kernel.org>
Date: Tue, 07 Jul 2026 15:31:24 -0400
Subject: [PATCH v3 4/9] NFSD: Prevent client use-after-free during export
 state revocation
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260707-cel-v3-4-7c0cc16fd54f@kernel.org>
References: <20260707-cel-v3-0-7c0cc16fd54f@kernel.org>
In-Reply-To: <20260707-cel-v3-0-7c0cc16fd54f@kernel.org>
To: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org, Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.16-dev
X-Developer-Signature: v=1; a=openpgp-sha256; l=2102; i=cel@kernel.org;
 h=from:subject:message-id; bh=TdjDz0QPIisYg2PRMpA6G2KXuaNaSDOKOQSW4HZKINQ=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqTVQbw6+oFXJhi2V1JUMcfh+dZiHGt7Tq8cVwV
 FFmVLHSfQuJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCak1UGwAKCRAzarMzb2Z/
 l2cnEADBxI4BHjFtke79l0eQWLYmSvI1SgGc+N03m2uPubiQ+4k8ftGn2A+DEzKiagqtDdf8hav
 qttPJ9hdjIgVKmYUmjwtUNQ1zBPje4f/OcKPMcrFbCxJYiz7SqJLu1JNa+A84gqIdAh7wjuJh/Z
 YFB9f/pVUaxq+RvZENXPIFiSclCWP+WO8pT0Dhgcmr9eXCDA6208jzB9tb4m4lue2UfLf4waYjO
 +gp/By4XnAMhyhW8zBGiq7jdqvvALBM7XhRSdY+T98wa3EvnF0DcRj2ZhfIjnBY8lZxH8Cotk/U
 f7CsKDvCsThnbDSY4p+7kkihxqC2mGrneWXPd/NxbTor4VYa0a2glQ7c/8SmoHkSOvuFdqvCsbf
 BhmoDpLI3YqZKw8wi+2GI75vPVGqYcyHW1cy2Lif32EN4DPJezWfF9SBrW7Z8cnAB/KDsrhsgAv
 cGJRk7z+xR7PQKPZXHNN+DRbs3LK5JlyHDpbbcUhoJN3tuDcgYfIjO+TuaakneWH2wW3688wASN
 QLLxQUSHN1TD5/ysKFUDnZmxoOjgUpgqGnNdFrS7wa6xOFFs+AzveIpfjcUFI3BccKlkIkimo+c
 cUHkZpjHy1pNC0uYmaDoq5PXdBeU52RY0KsCpmfxfo3b3aeHLR2iamoIgJ0bA6TtyQX4NuV7t0d
 LLwsYcb2HtNZdgA==
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


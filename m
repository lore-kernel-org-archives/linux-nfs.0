Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795549767;
	b=Byz6biMcS4nxT36RtjKnE0OVnFlGwwIHZ9QxgbybQxoN3okA0ghsod379CkYXtQgF090
	 2CWxWcM6BGQlb18Vn3pxfLiR6dydP7qtjim6mYlS6c/a++1L6Y9K+/Jambkbd4fZpVM6U
	 B2TAE/opKDzO9biHx8oOhR4oKE3DLga0mY/TfSC9DGp1PibhZd0byzhLQGa8p55aDvT/j
	 NX931BtEkzUHh3Yim7Cm6hhkkVVJSJVD1trlv4ZpXTLaJ9dmXmaDvFyrCkQ4keI6/UdFA
	 BqC8Apg1Kj8QJPV/jbTozabYuHO0vZpE4ZRO7/zpHsTDCD0RRrC7VibdgA0xUPAUsGw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795549767;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=dMpsdJJ0U8+zai0zMK56GvghsOgJVoXzaoxUj7ZE/RA=;
	b=rpWqok90nd138t9q+6ERNj7uyf9A3TQ6C8pxCC8GuYHTJdVnFW1QQqJT7zMqVn4E236N
	 MLRPOyWn7JOjsdZbDH6Ga+5lBYafcfysol2QH+bEhu695/unGZR/1V+vrlp+IBYtx7TdX
	 dQveasvsSPg6GeUvu6yC1T5p87k4HYyQD9AIvWiebxYhyoIrmVMb9XVMcDHe6oka0wLqw
	 12yfUVOvwE80I/9M2yy9BPkp2Czm06uSi0MpIIBnI7kGO4n4sLwRqbQ4rLkigjeJwvMca
	 CkdKQesu70wAPFc46vmyGm2IG6LyeAO2vY+LUNAOcHaxpPQ9owACNkj1NNDMv50vcNQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=VOkpdFkO;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 94C44606A69F;
	Tue, 24 Nov 2026 19:49:27 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=VOkpdFkO
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 696331F000D8;
	Tue, 24 Nov 2026 19:49:26 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1795549767;
	bh=dMpsdJJ0U8+zai0zMK56GvghsOgJVoXzaoxUj7ZE/RA=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=VOkpdFkOxDg9fwIOg5rcofH9D6tetSfHMC/vY+9B0dG5WpnK/nWiRkV1ntL6gICVR
	 J++UVqpWCWghdBKvO5ToHk4pS44rW0RBjYDkvgty06VxBib1O9gvP+t7uupolqOLe2
	 aGuQ1HQMktXR7YL2PJOkhPqrcLdbzKMIqUtN2w5Vd7JgCbCVrY3hxD8gsIBnnilzli
	 bTRVq+ks+lKo1iZ/TfNNA+D9DAPmtIEj0dW7HcI+kfpnL64RISgPTGQxbUqhtf2qW0
	 19fgygpKYsk89Hf9pG6TG8Eq/PSaoMl622nL0soARfJKuPb57XHUWsnPg8nksTWBAz
	 qUS0B0v5CVkDQ==
From: Jeff Layton <jlayton@kernel.org>
Date: Tue, 24 Nov 2026 14:48:49 -0500
Subject: [PATCH v3 10/12] nfsd: check fi_had_conflict under deleg_lock
 before hashing a delegation
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
Message-Id: <20261124-delegts-fixes-v3-10-6fe4ba705aef@kernel.org>
References: <20261124-delegts-fixes-v3-0-6fe4ba705aef@kernel.org>
In-Reply-To: <20261124-delegts-fixes-v3-0-6fe4ba705aef@kernel.org>
To: Chuck Lever <cel@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>, Christian Brauner <brauner@kernel.org>
Cc: =?utf-8?q?Aur=C3=A9lien_Couderc?= <aurelien.couderc2002@gmail.com>, 
 linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, 
 Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=2002; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=XSlKBI+6fPgWFwqVFVy0OhxcOeY8hsL/7ntbFwt9cKU=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBrBeo3292xwqIerz9nTeqvNXacfBLkWjoZ0kRrq
 Ulxpgr/YamJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCawXqNwAKCRAADmhBGVaC
 FcnuD/9U73gzbgOsOM2Bq+X7FULMvPFrkydHZeAhg1D2ds04yRA9XrojTgebCfoN393f3Pmu+dI
 BvMqVknAhcYEppi/dcciE2PS+P4MpeIu8e4cZbKK+ZuUls6GG9VbXHOg02liBbS1MhpYT2BG04U
 h+ppQREWRPpk876nJVJVkqEBqRGKlot0DUsJU37Qd30x5y3MovihCqSFnKW1KhxTMvfU3lIewBt
 M6cHz09Wpe4eufAJW994nd8/MoPEaV19f1HYtRbThjHB57CDT5ZN7RRr2J6+aZrIPHunQx6Wjs/
 eaarKyRDd6ux2OzRme7k8qSKRFytJYw1NqS5+HMkHuI5sZfZBlI4uNtJQRhYozKRyKZbGoCrXFo
 dnzhkZXqSD/0FPaBPDHjNlpR6QFSjCD/EPIBTN1OVia+Y1dej7hWbv9pDLaqXMW9YYmDH4klDbp
 28MGUepRcVht+9wKHN8VYQDniooESSjaDEYThhW+0K8VhX9Hys40Lw5MS/y6i2p7HBNvMWedXEc
 oDgtxCe3AYRbfEMYGMWeUOcYWWu6i2Aq77MZfYcMVjgGGzSKzIV3fJt+km6WI0NTRHhobrRrb2p
 vAf1K8EohEAswGXQrGGsYF/C23PUATQHUTrsz+032ycXNyQ+DCATqqXitL7MfjFLSLEDDGI57st
 dqsMidgKEmQ3SzA==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

nfs4_set_delegation() checks fi_had_conflict without a lock, then takes
deleg_lock and hashes the delegation. A lease break in between sets
fi_had_conflict and queues the recall. The recall's prepare callback,
nfsd4_cb_recall_prepare(), takes deleg_lock and puts the delegation on
del_recall_lru only if the delegation is hashed. If the prepare runs
before the hash, NFSD grants a delegation that is already recalled but
not on del_recall_lru. The laundromat then never revokes the delegation
if the client does not return it.

Check fi_had_conflict again under deleg_lock. The break sets
fi_had_conflict before queueing the recall. A prepare that ran before
the hash therefore left fi_had_conflict set, and a prepare that runs
after the hash finds the delegation hashed.

Before 5ea9a7c5fe41, nfs4_set_delegation() made the final check under
fi_lock, which nfsd_break_deleg_cb() also took.

Fixes: 5ea9a7c5fe41 ("nfsd: don't take fi_lock in nfsd_break_deleg_cb()")
Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 fs/nfsd/nfs4state.c | 12 +++++++++++-
 1 file changed, 11 insertions(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index db096859dce2..3491b2b86a3e 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -7437,7 +7437,17 @@ nfs4_set_delegation(struct nfsd4_open *open,
 	spin_lock(&nn->deleg_lock);
 	spin_lock(&clp->cl_lock);
 	spin_lock(&fp->fi_lock);
-	status = hash_delegation_locked(dp, fp);
+	/*
+	 * Check again under deleg_lock. A break after the unlocked check
+	 * has queued a recall whose prepare takes deleg_lock. The prepare
+	 * doesn't queue an unhashed delegation for revocation, so the
+	 * laundromat would never revoke a delegation granted after the
+	 * break.
+	 */
+	if (fp->fi_had_conflict)
+		status = -EAGAIN;
+	else
+		status = hash_delegation_locked(dp, fp);
 	if (status == -EEXIST) {
 		held = nfs4_delegation_exists(clp, fp);
 		*held_type = held->dl_type;

-- 
2.56.1


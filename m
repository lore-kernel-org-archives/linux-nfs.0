Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795192827;
	b=Co/5/6SAfs3hyLdLNCrfAzIIDyXPnTkHyc+xuHFHxJUztqh7bYRUQU39jc3jiJjOnV0f
	 ckyeazzzYJudLSPlhhDoM0aOd3rIHuIom3/dX3bd6Yc85J4IBtlhyAum1xlsLlZw0y/Pi
	 JPaX0rwTU3rYQi5mYrJonoWs4tczgFD/7OFRSJWljeR+OYXbsPvWUZiuLn+D2a8F1kpfu
	 cp0p+oeSY1S+RQpXXgLytrSsz74SZaPqQyy3/g5NCiAUovQawP07k8qK2IeiSHfL7jZOT
	 lK/DrbUa9vkHac0OrEyC3x8/3eBhkmnOCMeMa0ByEDCKFFxB0lC+8Pd0Cwm733hYKmQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795192827;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=9YipLPBUod4kH94EKvybruTM5l0JRP56pmn/95/Aq5s=;
	b=zHrxwTQbW5SISHxbIAbJZSkxqEHCHiWZyZhpvp7GYN8jnuu+H6LThTsxOW9FyMqVPcFO
	 82fM17O1NThn892OSoL36tQQ2ZIzx6iaRrFdFA//u6/j6of6LqRNhwHnA3fxhAS/TILbd
	 ifRG5DcNVYGJhiY0inV5NP+GJgLn2rZvkcewWxgGlPOeZ8LrIYiAsw5Y0WSsv0Y+PhD9F
	 hUHtETj7QyzA2U4ZuQXFg2igWL+SwmqX2BGFc3rrqmd21eF2e0LlvL4TanzbKMf+n1cKv
	 Liaue3v3D3f5ngDYhBEtRiTXr6JNTK2LOzT+VmFb5j2V6a85PGZ/VK96nOSxOJB5oSg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=dak8wCXx;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7261060A6F50;
	Fri, 20 Nov 2026 16:40:27 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=dak8wCXx
Received: by smtp.kernel.org (Postfix) with ESMTPSA id AE13A1F000D0;
	Fri, 20 Nov 2026 16:40:26 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1795192827;
	bh=9YipLPBUod4kH94EKvybruTM5l0JRP56pmn/95/Aq5s=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=dak8wCXxKo/EVYF4UWm9rOqPry/RbeHz2g6AHl9Ml3Qw5gasWewiulYVy9zk5a0s0
	 BDhZ19xWqdRNVCtX5yLOLqNNfzeYXYtaMP27ONiJclwtGT9ly9vUQVUtj6R3g25huE
	 MrrWgbOyXH+49mnnvZcL7V5HFq2ZKRaIMx7kVlONntccils1mhfr1l6hs0PyzHmZ7G
	 BzCNttmMTVZjz/HMkX2h2vMT8buwTrQH13S6dMGYW6b6OI8lZSISVV/O6gIuHgZUb9
	 Wyg1ijgFzJbfokK+0YODWoFbfw4VRLzLRbrcS6NakGVrmIN0+Hi0DYW/fLAYXEStzE
	 ebNbUNXazOeog==
From: Jeff Layton <jlayton@kernel.org>
Date: Fri, 20 Nov 2026 08:40:16 -0800
Subject: [PATCH 10/11] nfsd: check fi_had_conflict under deleg_lock before
 hashing a delegation
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
Message-Id: <20261120-delegts-fixes-v1-10-c89b37d2d462@kernel.org>
References: <20261120-delegts-fixes-v1-0-c89b37d2d462@kernel.org>
In-Reply-To: <20261120-delegts-fixes-v1-0-c89b37d2d462@kernel.org>
To: Chuck Lever <cel@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>, Christian Brauner <brauner@kernel.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, 
 Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=1924; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=m585Qghi4R+IE2R9qBbhiXt8kRhIa14vMmnc7mcl0bA=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBrAHfyP5Q2Y9NA4d/LcPEJVVBbYLsTGlDtJt5Wa
 Z8/t+By0g2JAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCawB38gAKCRAADmhBGVaC
 FYXnD/98DLK+wKgbUnpTxvAN7Ct20Cm/GDEUY8158fUqMxgJ5jsKV9dVtbxtpxVOEI1oxXkNh0i
 g0F00Bc84y9bvYEhd31yRv5DxEffilf9rozpgkQvV5bubNclC6x20nfWyoi/P7Apl5S6hT+ar96
 Fg36RZ7oNP6jVFktl/nt+2dIYsxqxjTEWopHuzW7D02tC7mRS9KPdURYOSo3jdCVDnFmPMFXjGy
 2TB3O8PYezw8MIEg0jJ9+uj4/KwjtfbgdhPtO1n9IK1zUuB/ETr1XorBxgQHbBm5Qi1vGqJZ/6a
 tw7RFxwGRpaBo4rjUQHdXEMCakBfDk+KEYA+sjUon5un30fHzpnuWO+94sa5waxi3s1Bak2fqs+
 EoyJCyhOfBDYHkOObRXMBbtMvB1WFbPukyP1wXJb2i/SCKErrlXpJqtfcRht61w3zPMTSxJZOoO
 aLSq6Ns0LuMC/TBd2SgfBaa4n/09k8pHahdJns2O0EUtxBZhuHHboXtzQeZEXjxlZRP+3pU1VgX
 gnM0gsyYJOiX71rVeK1ztGdfCWS6DRs33/fbiwQuwf6TXmlJFTgqHDyhCmrFo6JWk2DULCWYgEh
 0Dc70C7Rdp0EhhbHoZ76eVGUcLjXElAXD9e09WOrZzLbMAIr+2rTxuKVBhwJe0Pqjrrz5N7w4Gp
 pyDIhCIxJ91sKhA==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

nfs4_set_delegation() checks fi_had_conflict without a lock, then takes
deleg_lock and hashes the delegation. A lease break in between sets
fi_had_conflict and queues the recall, whose prepare,
nfsd4_cb_recall_prepare(), takes deleg_lock and queues the delegation
on del_recall_lru only if it is hashed. If the prepare runs before the
hash, the delegation is granted already recalled, and is never put on
del_recall_lru, so the laundromat never revokes it if the client
doesn't return it.

Check fi_had_conflict again under deleg_lock. The break sets it before
queueing the recall, so a prepare that ran before the hash leaves it
set, and one that runs after finds the delegation hashed.

Before 5ea9a7c5fe41, the final check was made under fi_lock, which
nfsd_break_deleg_cb() also took.

Fixes: 5ea9a7c5fe41 ("nfsd: don't take fi_lock in nfsd_break_deleg_cb()")
Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 fs/nfsd/nfs4state.c | 12 +++++++++++-
 1 file changed, 11 insertions(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index fc01ff50c8b2..ea940d8759b0 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -7427,7 +7427,17 @@ nfs4_set_delegation(struct nfsd4_open *open,
 	spin_lock(&nn->deleg_lock);
 	spin_lock(&clp->cl_lock);
 	spin_lock(&fp->fi_lock);
-	status = hash_delegation_locked(dp, fp);
+	/*
+	 * Check again under deleg_lock. A break after the check above has
+	 * queued a recall whose prepare takes deleg_lock, and that prepare
+	 * doesn't queue an unhashed delegation for revocation. Granting
+	 * the delegation then would leave a recalled delegation that the
+	 * laundromat never revokes.
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


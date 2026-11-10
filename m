Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794332669;
	b=O8hCy0Nhr7Ap0yq2fZ2MI6sevwNZtvzygVnGTk7qdEPPTKsAFWRl1rqxGwqVeUqVPQ9B
	 BPyv0+w6TcjQwBW6f6O49GI7iHrjAUI+PycWi4mHYG9u798zWRgxxFm3ikO4Dat8nCQTH
	 Syt0mbHhEQ4eZy84zxPUgX7eWAvZLybq8sYi+K5n3BUA8ouLICrgiHU4J4k1iapwO2Lyn
	 Qtr62se+kIfzLOWFTu2iN16zA31u382D8ARJ7O1IIj4e6N4v/IGufg5s7IPaEF+i3w7CX
	 souLVPgK18yyNcmyuuxZACBwfBgBZ+4iUnnPafqvuK+z8r0Vwc+0Y1hBtzL3D51D/sg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794332669;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=pAnl6Qws4TDtxucerYEyl4j25a4HthG6cmxc2ayS3OU=;
	b=Eeg75hc1jaO1gNBU2q/WS2TLRE+ePU+5eIir7Ltr6bm/GzsmIc/+krj6O4aFGI9mJUkG
	 QWFAxBNegMsVFo6ipjdr7CJsoSA5pvde540RRV+PotriBnIyPOyXHhoqcTVGdCeUaSSYv
	 AJv6BpqybZ+xQpbd+oF+QjkbkZuaqPCVnx8NUo3EK00m8Z/OuUh8/MA190KB7NIGvmd9l
	 Zh67CEXsa5PfX4XYhVIBk/5gpgFmHPE4sJoTnHxtjP9x8Uz1173FJcAthPS+S22nb+pC8
	 CVDeCSTSsRSyxdY0qfoPyZ7qxDcth48Yemz0Qt3oouL+ybMqzCTfZj/dc6LI6Xykxsg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=jirF968H;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 09030606A338
	for <linux-nfs@vger.kernel.org>; Tue, 10 Nov 2026 17:44:29 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=jirF968H
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 34A0D1F008BE;
	Tue, 10 Nov 2026 17:44:28 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794332668;
	bh=pAnl6Qws4TDtxucerYEyl4j25a4HthG6cmxc2ayS3OU=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=jirF968Hukl5SMwkJwCWj8CPskrExTLYzNtqPpYVhrFAQ66SGLaAvA+kgSgYLfZdK
	 369SoXbbVR5cy5heHuty/TAApQbtTzEbLvTITI1FST2bCLPttSHdw5WYZKYV0qd0Lq
	 iyJOX+XOwpW90QW3Wv1rwLemUJYx0zHgBuyOqtZwjfA7XsF4MlSjd/QuVtnmHOuk2M
	 h2L5KfHARVmL5iIn7EwfKBm1pcS9YMUFkdXMovHBbitmgV9idlRKj3z5T7gdZFHNKE
	 9tPn5Mgh4FaumnQ0+M6wbW0AsAf6sdrQO28FeyT9N67DxoMnxlmDXBmKDfMZy0V5Qm
	 0+kTf/ESgUigg==
From: Chuck Lever <cel@kernel.org>
Date: Tue, 10 Nov 2026 12:44:14 -0500
Subject: [PATCH v2 07/10] NFSD: Destroy the COPY_NOTIFY stateid IDR at
 netns teardown
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
Message-Id: <20261110-random-stateids-v2-7-57e0996eb2a2@kernel.org>
References: <20261110-random-stateids-v2-0-57e0996eb2a2@kernel.org>
In-Reply-To: <20261110-random-stateids-v2-0-57e0996eb2a2@kernel.org>
To: Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org
X-Mailer: b4 0.17-dev-9c833
X-Developer-Signature: v=1; a=openpgp-sha256; l=2289; i=cel@kernel.org;
 h=from:subject:message-id; bh=alYD1SuOXkv87fFWsc5ncli1lHUcEgQtTdyTTo5x9uM=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBq81f0CK9b4u+rZmF73YXMkLiK1vgThvOBh1MJs
 eWZBWpYBk6JAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCavNX9AAKCRAzarMzb2Z/
 l1GYD/9nS6XdXhLYBDHyUexupPHvQBmEJSYlMcqMCAyFjlxV9xKssenHYwqNQF1oR2hRdUfsoOp
 gJblNSapVLhF6jMlanYJiR/2miSfVGzvYPq+fsYSgIEXqsaRsQ69fnKt4ygx5rhcaUrR32oRI+H
 QrTg2hTiAtAJB8wvJTEtFWv2xaSwGeUZAS6p2Qw3QDHlW5/rg90Yb5vqlfYX+Ej1vxEIk/JgwP3
 QZsQzgq3Ct4B9xcqxik10gAz+nbIO2MhHUuOBDhsPMqxp+NCVr/RwZPshjn4a84X+D4ENYONrba
 ru3ahn0BUwXfIxcPhiOANOzc3MdAHd2aJkQ2bx+iIBw+7fcuoWdi3uhbrdMFlOpg1Th19Lpg5/G
 VbQDBcYnE9LPFdC1VaUHi68xVs1UY+RgNA7cacCOwoPO7poSXXLwewjENa3QBCTYKAnhcqHNHSo
 tDBCla6eqipYyVXon8U4xnd2xC374i2iycTMf2Sg/bkmf8vB7G9++zRtrd8E6qcCbG6Uc6KjTic
 mecn3OAEv5yIlYy2y8D7yDSJnXdmWKrUUhV2PnW/uztJe3GSYN2Z9uGpZJODZADF2EMSTYe/sxZ
 bfRWNjV+f1+3XX0UG+zUCaSN7Y/hTrK22JuiPo3azUEPlNo+R5Yr06PlTikLrueByZht7jYgAM4
 oj10VqRakq0EW4w==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

nfs4_state_destroy_net() frees a netns's client hash tables but never
drains or destroys nn->s2s_cp_stateids. The IDR empties only as the
walked clients' stids reach their final put, and
nfs4_state_create_net() runs idr_init() on it again at the next start.

A parent stid can outlive the client walk:
nfsd4_deleg_getattr_conflict() holds a delegation reference across its
callback wait from any netns that exports the same inode. The re-init
orphans that stid's COPY_NOTIFY entries, and a later idr_remove() by
so_id on the fresh IDR can remove an unrelated entry. The IDR's radix
nodes leak as well.

After the client walk, revoke every surviving entry and destroy the
IDR under s2s_cp_lock. The late put then finds an empty sc_cp_list and
never touches the IDR. A survivor draws no warning: a late delegation
release is legitimate.

This patch depends on "NFSD: Serialize forced client expiry with
state shutdown", which keeps a forced expire_client() from running
after the walk.

Reviewed-by: Jeff Layton <jlayton@kernel.org>
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/nfs4state.c | 15 +++++++++++++++
 1 file changed, 15 insertions(+)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index adf834f1a0af..960a1eda2249 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -10379,6 +10379,7 @@ static void
 nfs4_state_destroy_net(struct net *net)
 {
 	int i;
+	copy_stateid_t *cps_t;
 	struct nfs4_client *clp = NULL;
 	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
 
@@ -10398,6 +10399,20 @@ nfs4_state_destroy_net(struct net *net)
 		}
 	}
 
+	/*
+	 * A parent stid can outlive the client walk above. Revoking its
+	 * COPY_NOTIFY entries under s2s_cp_lock empties its sc_cp_list before
+	 * the stid's final put, so the put never reaches an IDR destroyed here
+	 * or reinitialized by the next start.
+	 */
+	spin_lock(&nn->s2s_cp_lock);
+	idr_for_each_entry(&nn->s2s_cp_stateids, cps_t, i)
+		revoke_cpntf_state_locked(nn, container_of(cps_t,
+							   struct nfs4_cpntf_state,
+							   cp_stateid));
+	idr_destroy(&nn->s2s_cp_stateids);
+	spin_unlock(&nn->s2s_cp_lock);
+
 	kfree(nn->sessionid_hashtbl);
 	kfree(nn->unconf_id_hashtbl);
 	kfree(nn->conf_id_hashtbl);

-- 
2.56.0


Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793281277;
	b=1KduSc7He3Ags706kMvIkJIeszQ/ugWR2STarAvW6skP+kgsUxuQI/nGxjoKXRhLCS/q
	 rVHrJHU5TvtAGCVpuXYU31FaFkHyxlEqPT4x0tXgpExhcHs02sM7dbuICF3ySxgl3y4CT
	 /z1otm80NGURTxAXqRiAmNcK3Uhbq5lXRPqqUwaMAchPV5mATTk7C1sQbGq+3N73dQmWn
	 LayzFklerL+sFLv3iCzLVcSPuQUxaG2imNMi/aNS8Pi2vPNJn+i/1mYWurlnW83KUXZKI
	 w3isjHb4JcQzs3xVM0NoL79kTlXn0xTvanal1uipxWmMl101DtH4JSao/2aGtP4oi6Q==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793281277;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=EoH2a37imCA+Eao1URNOrSQLLPu7rXRjNBQWBXElPb8=;
	b=hCEkzTieELFGI7TBeQaK8MljH2QANTcudA10ggZrnJlsZ3DIMb45M6jyRy/b3DnvKFaS
	 sqLw7Ivkm5W+M3NJ2zwnCLyWKjVDbZqOsJCBHJZVOrzvZLou4DArEVGJiHsM/TgSamN3i
	 ZedOWne492DbkVr9xINXKsFJ1nAZc0c+nHmPRlvPp+wIicY4EOh+4jnyeEyEalrCMaqPU
	 9GGeGEBFIjell2TcDjQOac6IuLdnAenDmd8xAS876ZghExUT1rKxMK4qVD5zE853RNdap
	 2/Muo6x0/be6LGzhFBOzcUDej+01PlSE6okTAA1VKuZ3XJlfP+5q9nXJp1EiJro+c6w==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=kdBx9RcY;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8C082606A31F
	for <linux-nfs@vger.kernel.org>; Thu, 29 Oct 2026 13:41:17 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=kdBx9RcY
Received: by smtp.kernel.org (Postfix) with ESMTPSA id BB73E1F031E4;
	Thu, 29 Oct 2026 13:41:16 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793281277;
	bh=EoH2a37imCA+Eao1URNOrSQLLPu7rXRjNBQWBXElPb8=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=kdBx9RcYym2j6FdDTJy//3HJ7xmiQ9XGAMWlaLhaGc2+c6za7uLR/9KpFEF7dMlrt
	 xuFp46VRtZ0bAyZq8Di/RgwRIHWwBsJHN0f9FfbMakMMccDVoV1h/HgX5rxar51nCY
	 D9SmRvPf8oOszTqvDc1JXp5hIA4lsMoqMluH0Xt2fPAnk3Lr3IUHbBOBsIU6CWqbvq
	 u6Xdj1y5Pg+NL/e2JIaJNh1RiHxZhUmScmGBdBuwws8ahfDbkIIk18mz732heCZj+x
	 xjGjdj01DmPFgiUWtN5YLqdsUaRjhRNlZ/DuXNoQ2wzs0FOSkNdB9RKtiLxHaH3NHy
	 4qsWGj9Ej8i/g==
From: Chuck Lever <cel@kernel.org>
Date: Thu, 29 Oct 2026 09:41:01 -0400
Subject: [PATCH 03/10] NFSD: Make nn->boot_time strictly increase across
 state starts
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
Message-Id: <20261029-random-stateids-v1-3-8648878fec8c@kernel.org>
References: <20261029-random-stateids-v1-0-8648878fec8c@kernel.org>
In-Reply-To: <20261029-random-stateids-v1-0-8648878fec8c@kernel.org>
To: Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org
X-Mailer: b4 0.17-dev-9c833
X-Developer-Signature: v=1; a=openpgp-sha256; l=1689; i=cel@kernel.org;
 h=from:subject:message-id; bh=AAeai+b6gr6727RAaFLxVMTacuuxXfR/lwWPdwAvU4g=;
 b=owEBbAKT/ZANAwAKATNqszNvZn+XAcsmYgBq40z3pcC8gYss2xEj1/Dapsx5vkCmMmKcU+FMA
 q0Rtto7P1iJAjIEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCauNM9wAKCRAzarMzb2Z/
 l0HhD/iRM87KpB6QBPErHYPJPGwYNlAQQwQwsePMBvYsJ7PLIFztnIURnKtl+tjQ0ix+Afyf1Zs
 gDf0Jw1r2wm0idZyGNXJp352aerl4bwKCfnCnXcZWAIBHjE3ZGFDI+mO+5cVQ75k1ozLkeBAkEA
 dppDYByoV9HDY4PWm2IHJU1ypZK8C5PXYwABrbsdwnOYiTiORv3QCWKf9Yi5BsckupmC1V2TcEv
 dEesngSKKg2Cac6ElcABqNJtuNKl7zq4KfIQpdMJ5jw/jFnAvz2Y53QWxXCah8uno0YIq8ueL3x
 rlO8vf5Pq6ewejFjBEkE8TM3Bwk4MszI+Q/lfz95F8hda7JWX4X7e0bC9geJ/kfUrcbBHp6TnJT
 GvwncdsmwA6LNJyzmvHd99vEPC0d71VLElDJIWrcz1tmQXyZHRKGWRuybdsM9fB0hsEH+ul8ipc
 U/WXqfb/xnTeSn08/PD4r50UxYOxX5+XRhFnbvNNQC0C95dbk9bSM96fvWRV+3e2asC079ELBDM
 yxZ5XI+Xchn0shiZzgNdkiZU2ptqHYEd0FjkRC1dsGg6D92KyPo77hUbxlKP6NJ6wq02sA5ASHX
 zkZKdacZD/HByLQyGysSJcuqZflsg7E/eVTUKUDoAvQcvBnwRe1sue0y93nVnXjrE+QWYvAKyQR
 MgGF7NnZ1+U4r
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

STALE_CLIENTID() tells a clientid issued by a previous NFSD instance
from a current one by its cl_boot word, (u32)nn->boot_time sampled at
each state start. nfs4_state_create_net() sets nn->boot_time to
ktime_get_real_seconds(), so two starts within one wall-clock second
record the same cl_boot. NFSD then rejects a pre-restart clientid on
an NFSv4.0 RENEW as EXPIRED instead of STALE_CLIENTID. The NFS client
treats the restart as a lease expiry and does not reclaim.

nn->boot_time persists across starts within a netns. When a fresh
reading is not greater than the stored value, use the stored value
plus one.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/nfs4state.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index f0e4fe5be21a..5f9c3f2f13e7 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -10212,6 +10212,7 @@ set_max_delegations(void)
 static int nfs4_state_create_net(struct net *net)
 {
 	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
+	time64_t previous_boot;
 	int i;
 
 	nn->conf_id_hashtbl = kmalloc_objs(struct list_head, CLIENT_HASH_SIZE);
@@ -10233,7 +10234,10 @@ static int nfs4_state_create_net(struct net *net)
 		INIT_LIST_HEAD(&nn->sessionid_hashtbl[i]);
 	nn->conf_name_tree = RB_ROOT;
 	nn->unconf_name_tree = RB_ROOT;
+	previous_boot = nn->boot_time;
 	nn->boot_time = ktime_get_real_seconds();
+	if (nn->boot_time <= previous_boot)
+		nn->boot_time = previous_boot + 1;
 	nn->boot_time_bt = ktime_get_boottime_seconds();
 	clear_bit(NFSD_NET_GRACE_ENDED, &nn->flags);
 	clear_bit(NFSD_NET_GRACE_END_FORCED, &nn->flags);

-- 
2.56.0


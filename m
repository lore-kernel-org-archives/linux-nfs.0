Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794332665;
	b=07puuVgBhIIJk6k9ty4dDYvlOGu7ADoC1Hu5RFPJNXkh35CdM/kWEsildEQ62lwJsPSK
	 /Ftznc2+RdzZbbwXcu6dkyX7J/T0zzd6yDUatk9ASH1Yj+Rr1HQrCPSy5Oa6KV+kHtPoZ
	 AuMxXcygX4U0wX0hTUiLBQFCfb2+n/OZ+O9YW5UVXcNwCIvfyM4oR4WTbeanXeq5rbg8m
	 QjHXSwhnKipKaisnbRHimxAAu7i8G79bwPxlUR3I3c48HwSD6TNiH5hOX7X0DLLpsec9j
	 K1VADd2PwvOXFeQLOnaMWheGxEJdlq5N4KBBNyQX53bNxLc86o/QxBYMYmIMk0lOMKQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794332665;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=DB4EQRalsgnxWrWfkaASL4xiJT0TqAjPVBpWOCMeVYQ=;
	b=LoxjdVIpceoskA+llnRUk0yAJNAjse7Ib6qwLMpARmPVijxOpzHceiMYFROxADiF3f+u
	 3dHdah/QpiZklu8wV6jgXzaCFnJa+YuzEwhd5V65ooD0ININdZfOJheadurU7zJYeQ3bu
	 5eoq+MQJSv5ObRsVTVvloa8CzD25+wIqVx1IOSpIJG+xc1/+2SdmrJgD28X+wnvCeNYn6
	 EapiYe1e3/4dpa6uw6XLkw49GjelpBK9HYWkeyPFB0EnGayQdoCKAiNykQIH1kOftjZIQ
	 H3iFoFcihLUoHekqpaMJP2zS3imVS7FMCFbF4NjCo5IcbfpndEBB0zSY3RdM5lx4kyQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=nk6Y50+V;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6EF49606A321
	for <linux-nfs@vger.kernel.org>; Tue, 10 Nov 2026 17:44:25 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=nk6Y50+V
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 5D9C41F008A7;
	Tue, 10 Nov 2026 17:44:24 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794332665;
	bh=DB4EQRalsgnxWrWfkaASL4xiJT0TqAjPVBpWOCMeVYQ=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=nk6Y50+VkR8ZK0KeOrK/5YlcdFweVut6+gbxVmQcIL3ErSpHzZaPa/KgPFaQC4OYe
	 YuQxCxdVAAzBee+eAt1WdjsO8/mNs3lolwKIeucJV5SDGzj2FCbIemkLbVQtGBryR+
	 1grE1o6Xwpe7UgFAqVMgWvQqnAv9hkfpJaEQXn494+eAdg5pnQdxW/nClL7soFXx/L
	 mkZgktR1AqKMnjv5ILji56gV5OcsB7LS0OQDRZkr1lSVVv/UjBWyDeXgc+ihUBopt2
	 9ZKWTFo4GyMxofY3NA1QslH2xo98Yc6tKjKWLLOkxxpWFszVt4KOBB17SmqUyBJFus
	 PYEPAr5KLahSA==
From: Chuck Lever <cel@kernel.org>
Date: Tue, 10 Nov 2026 12:44:10 -0500
Subject: [PATCH v2 03/10] NFSD: Make nn->boot_time strictly increase across
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
Message-Id: <20261110-random-stateids-v2-3-57e0996eb2a2@kernel.org>
References: <20261110-random-stateids-v2-0-57e0996eb2a2@kernel.org>
In-Reply-To: <20261110-random-stateids-v2-0-57e0996eb2a2@kernel.org>
To: Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org
X-Mailer: b4 0.17-dev-9c833
X-Developer-Signature: v=1; a=openpgp-sha256; l=1736; i=cel@kernel.org;
 h=from:subject:message-id; bh=cafDef9/64k7S3PiwZtUOHDGgRcE/9AMKVaQc5ZjQxU=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBq81f0BnbFdu4n5n2SJyRMStHP7n37EIZU7S1jI
 stOW4Oh1meJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCavNX9AAKCRAzarMzb2Z/
 l9rEEAClrjhQKMk6Cidu22Iq6ahzdyQ4HXzZywqCC1GRxVYHTCSsm0we6EelbJ3ZPZ+HbZ0BDkP
 WSHmGJbaXiXdpsWXOPLtFsIt3YPMCuJ2CCFCliw9jNJyg8gvAX+ePeV47LLc1Wh9q8Xj928EDzq
 4D148hEtSB/w+nb6YIPeNep6bhGlWnMs5SDI5FkkTzKrnigTtCb9ylNEpUXAiTkdD2hvfeOiciD
 0pAFcRYoJZOkOjjR18eX2wDDveYhjH2vLoskUQdnI1DVCKhoHSocB1XvSWKr3OQgNi5+wVAdPF2
 wk6JNQLm4fCAiHmjICqufW8eZ0skTxoE1mCZ/q5QuyZx1Sv0HJSDk91XjNho/PqIT+8B6tohQdO
 LYlWVHtcYSA7sUZIYOf9flth10uXjngoULH0U1+wpE2E1zYt/c3KK60P6CUB3uNkSg86iTNcSSo
 U66WNePobqHjhLaWCL+OYJZmvJoYEhJgYIGE8S15QjQ4xYJuDTDPYughQnugPzO5S6RsqweVuQR
 nzsMXEIblzH2fhDuYao+Z0qM8lSxFdMrWc0eJL8mjYEXV5u9v9l5FDaGW/GDsZmV/BVU1FjI9rW
 Iw7aNY1whCQWo1lzRFkMPCTV1Vt/hArArxoJ6x11sTmP4iX+4OKFnkzEetPGXgLnzSl+HPWt1rJ
 mY8rYHuQPFdRfHQ==
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

Reviewed-by: Jeff Layton <jlayton@kernel.org>
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/nfs4state.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 010155cc6f97..56d2944c91e7 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -10222,6 +10222,7 @@ set_max_delegations(void)
 static int nfs4_state_create_net(struct net *net)
 {
 	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
+	time64_t previous_boot;
 	int i;
 
 	nn->conf_id_hashtbl = kmalloc_objs(struct list_head, CLIENT_HASH_SIZE);
@@ -10243,7 +10244,10 @@ static int nfs4_state_create_net(struct net *net)
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


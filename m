Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=37.230.196.243
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792662061;
	b=ja9ID9VRtD1SAbqranInSAAXQoNxcMYH8lxBiHJSNgLQEp0cOAuQMLE7uRHgmZwFiYSM
	 afThurnCYzBpY6H+M+yKerxdBc8tRG5cE9S5SQXdg7D/TCDxCZ2dmJwsf1D/lWJLhHeCx
	 Rq7KMFM2kVf/u5mSLlsq9Sce2TpwCpnACNGZTgAJeFk2q2+acKN9gIUThJF/ZYl4gkdU4
	 HG/BASt5BFzBgZA6CBq7reul1tq59UwdVg+jlinrnsdO2p5x6nNpRQG9mQKR5HZSThKKk
	 X40oDiU7F7jkCOvzB48R0mhO/uBc1nCEqgEpZuOKt7Eh9OKK9EMp/oXsnNCJ/0ryBxQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792662061;
	h=DMARC-Filter:DKIM-Signature:Received:Received:Received:From:To:Cc:
	 Subject:Date:Message-ID:X-Mailer:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:X-KSMG-AntiPhishing:X-KSMG-AntiSpam-Auth:
	 X-KSMG-AntiSpam-Envelope-From:X-KSMG-AntiSpam-Info:
	 X-KSMG-AntiSpam-Interceptor-Info:X-KSMG-AntiSpam-Lua-Profiles:
	 X-KSMG-AntiSpam-Method:X-KSMG-AntiSpam-Rate:X-KSMG-AntiSpam-Status:
	 X-KSMG-AntiSpam-Version:X-KSMG-AntiVirus:X-KSMG-AntiVirus-Status:
	 X-KSMG-LinksScanning:X-KSMG-Message-Action:X-KSMG-Rule-ID;
	bh=VkX6/hxg6tGP+Na+8+f6fQRtPVGU63YxkS54Fjitld0=;
	b=NvoVgFzbarkgi+Yp0ZUnWDhTSZ54EdFcgHor5sTnZgHMX+E6P0fOnIFC9rLEWrC823Rl
	 I0B58XSHQA7ufJd4J7X0SitBf+Vbsz2Cm8vNdjMXN+6bfT6pVbW9tEGMGCcjpZglPmEpj
	 GucmCVpmOwEjvz95d6JnkPE84dh5TLnLSY+XyyASosN76+nQIDFNh4fljMBrgjIXACXad
	 l1DPuFrrRk43mhmchaayMY0/iZREZTR/jJV+Q7p1YJCatIoPxX35npEatTBxTJtJefZXy
	 pNHKXHZPJGLazU/Zu/LTpu+vhOyAkKcC9fykLwA+mEuqBMC5AH0H2YMI3t75qCssHYg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=astralinux.ru;
	spf=pass smtp.mailfrom=astralinux.ru;
	dkim=pass header.d=astralinux.ru header.i=@astralinux.ru header.a=rsa-sha256 header.s=mail header.b=m2QDR8rV;
	arc=none smtp.remote-ip=37.230.196.243
Received: from mail-gw01.astralinux.ru (mail-gw01.astralinux.ru [37.230.196.243])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6E544606A31A;
	Thu, 22 Oct 2026 09:40:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 6E544606A31A
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=astralinux.ru
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=astralinux.ru
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=astralinux.ru header.i=@astralinux.ru header.a=rsa-sha256 header.s=mail header.b=m2QDR8rV
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=astralinux.ru;
	s=mail; t=1792662043;
	bh=eLxqJqOnXKPl8NOR565h9c6QuRkURN7KkC0Ml4xZeEk=;
	h=From:To:Cc:Subject:Date:From;
	b=m2QDR8rVQ4Siq3hgKZli95eyy4GL2idh5Oi38kf5zEGo50bBe3QAHUfPeLIBIwiU4
	 7y5hiSZH3IUz+t0neF31idwxCypZTMYLwMBa6JlOEhHiNJRNWcdRZPf0BHzlyuQhBH
	 5xbVz7A58Z2fXg7b204K0tFUAP/YF98jzs/FJAaxc8vL2Q1FqsD3saKxJmIo/tjh+A
	 XRjoFx7rNDfYG0HOaVZEeOpdN7WBUdL2RQmAn0hWJR3TyHJHQz+aaz2AKXmbKKHnyP
	 s9eap+l6JTwdxeyhgZx7x7G7LYYk3BnTfuASws64HsrOfseELfyLipbe2Xnzc6qF7n
	 0BBrIeRgId0+A==
Received: from gca-sc-a-srv-ksmg01.astralinux.ru (localhost [127.0.0.1])
	by mail-gw01.astralinux.ru (Postfix) with ESMTP id 5359825867;
	Thu, 22 Oct 2026 12:40:43 +0300 (MSK)
Received: from new-mail.astralinux.ru (unknown [10.205.207.6])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (P-256) server-digest SHA256)
	(No client certificate requested)
	by mail-gw01.astralinux.ru (Postfix) with ESMTPS;
	Thu, 22 Oct 2026 12:40:41 +0300 (MSK)
Received: from DESKTOP-D46TNHI (unknown [10.198.49.111])
	by new-mail.astralinux.ru (Postfix) with ESMTPA id 4j9Lk12Nt3zNlm;
	Thu, 22 Oct 2026 12:40:41 +0300 (MSK)
From: Mikhail Dmitrichenko <mdmitrichenko@astralinux.ru>
To: stable@vger.kernel.org,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Mikhail Dmitrichenko <mdmitrichenko@astralinux.ru>,
	Sasha Levin <sashal@kernel.org>,
	=?UTF-8?q?J=C3=A9r=C3=A9my=20Jean?= <Jeremy.Jean@oss.cyber.gouv.fr>,
	Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	lvc-project@linuxtesting.org,
	Trond Myklebust <trond.myklebust@hammerspace.com>
Subject: [PATCH 5.10/5.15] NFSv4.1: zero referring call lists before decoding
Date: Thu, 22 Oct 2026 12:37:39 +0300
Message-ID: <20261022093742.1216-1-mdmitrichenko@astralinux.ru>
X-Mailer: git-send-email 2.54.0.windows.1
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-KSMG-AntiPhishing: NotDetected
X-KSMG-AntiSpam-Auth: dkim=none
X-KSMG-AntiSpam-Envelope-From: mdmitrichenko@astralinux.ru
X-KSMG-AntiSpam-Info: LuaCore: 131 0.3.131 f330ffd1b9dcd8f1d29707120f19686573775fe7, {Tracking_from_domain_doesnt_match_to}, astralinux.ru:7.1.1;new-mail.astralinux.ru:7.1.1;127.0.0.199:7.1.2;d41d8cd98f00b204e9800998ecf8427e.com:7.1.1, FromAlignment: s
X-KSMG-AntiSpam-Interceptor-Info: scan successful
X-KSMG-AntiSpam-Lua-Profiles: 206889 [Oct 22 2026]
X-KSMG-AntiSpam-Method: none
X-KSMG-AntiSpam-Rate: 0
X-KSMG-AntiSpam-Status: not_detected
X-KSMG-AntiSpam-Version: 6.1.1.27
X-KSMG-AntiVirus: Kaspersky Secure Mail Gateway, version 2.1.0.7854, bases: 2026/10/22 03:54:00 #28723736
X-KSMG-AntiVirus-Status: NotDetected, skipped
X-KSMG-LinksScanning: NotDetected
X-KSMG-Message-Action: skipped
X-KSMG-Rule-ID: 1

From: Jérémy Jean <Jeremy.Jean@oss.cyber.gouv.fr>

commit 8fa4804fe62ca4155a2d8fc2789d630376cbf2fc upstream.

decode_cb_sequence_args() allocates csa_rclists with kmalloc_objs(), so
each referring_call_list starts uninitialized. decode_rc_list() assigns
rcl_refcalls only when rcl_nrefcalls is nonzero. A valid list with zero
referring calls therefore leaves the pointer uninitialized, and
nfs4_callback_sequence() later passes stale slab contents to kfree().

Allocate csa_rclists with kzalloc_objs() so every rcl_refcalls member is
NULL from the beginning, including valid empty referring call lists.

Fixes: 4aece6a19cf7 ("nfs41: cb_sequence xdr implementation")
Assisted-by: Codex:gpt-5
Signed-off-by: Jérémy Jean <Jeremy.Jean@oss.cyber.gouv.fr>
Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
[ mdmitrichenko: kzalloc_objs() does not exist in 5.10 and 5.15, so
  replace the kmalloc_array() call with kcalloc() instead. ]
Signed-off-by: Mikhail Dmitrichenko <mdmitrichenko@astralinux.ru>
---
Backport fix for CVE-2026-90104
 fs/nfs/callback_xdr.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/callback_xdr.c b/fs/nfs/callback_xdr.c
index c8f5a0555ad2..cc9a19467b88 100644
--- a/fs/nfs/callback_xdr.c
+++ b/fs/nfs/callback_xdr.c
@@ -419,9 +419,9 @@ static __be32 decode_cb_sequence_args(struct svc_rqst *rqstp,
 	args->csa_nrclists = ntohl(*p++);
 	args->csa_rclists = NULL;
 	if (args->csa_nrclists) {
-		args->csa_rclists = kmalloc_array(args->csa_nrclists,
-						  sizeof(*args->csa_rclists),
-						  GFP_KERNEL);
+		args->csa_rclists = kcalloc(args->csa_nrclists,
+					    sizeof(*args->csa_rclists),
+					    GFP_KERNEL);
 		if (unlikely(args->csa_rclists == NULL))
 			return htonl(NFS4ERR_RESOURCE);
 
-- 
2.43.0


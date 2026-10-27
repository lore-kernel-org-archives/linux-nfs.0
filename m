Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=37.230.196.243
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793103816;
	b=KDzEpHz2jkD2TwmMJRAxGiia5lGFtDWGIqcLhvj5FKWeeIdKn82i3dMlA2P6KGR6bFYA
	 p0MHoR6Ffe/JMoeGXbsMIanLIfGNCaWo4y6lV2zNEtdb8ERPTI9x2ECHZN7txQV1AvvWM
	 RcdgdkhgvTRk9CRxLOEPZnnOcOs3d1Cn5w36moi716l9VBSyxGwcKyCuLukkYOqzEsxFg
	 7mpcnavCU82kAQtFghUBVOu8I2KHbz0zrVBk/RHpS/WvdbHTIDPDkcnIBHQUxoGrcKQ/y
	 BlunK+exZ4wyj1WcCEILLiwOD5ay4Ireg81UsaX9NDS5vihKvAVP8+sbY5gsE8o+y0w==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793103816;
	h=DMARC-Filter:DKIM-Signature:Received:Received:Received:From:To:Cc:
	 Subject:Date:Message-ID:X-Mailer:MIME-Version:
	 Content-Transfer-Encoding:X-KSMG-AntiPhishing:X-KSMG-AntiSpam-Auth:
	 X-KSMG-AntiSpam-Envelope-From:X-KSMG-AntiSpam-Info:
	 X-KSMG-AntiSpam-Interceptor-Info:X-KSMG-AntiSpam-Lua-Profiles:
	 X-KSMG-AntiSpam-Method:X-KSMG-AntiSpam-Rate:X-KSMG-AntiSpam-Status:
	 X-KSMG-AntiSpam-Version:X-KSMG-AntiVirus:X-KSMG-AntiVirus-Status:
	 X-KSMG-LinksScanning:X-KSMG-Message-Action:X-KSMG-Rule-ID;
	bh=sYqvNFORyvDOQZXc7kZrBRIQxzHNGGA8imPy97/ddqQ=;
	b=aE1SwJyqcc79j+IZ3nYaLLpgN/lGN5Gpj8XFrc3zXbEjo1U/IxhY38HwzcSAsgJYHaPA
	 RbEITi6DvE6S286s02xqciq/spA4QUsC1RJ+e6v6XuPtambuvZMcGR+blCsghvlYm/MW3
	 3mCBxLTeMNHVXPA+ygxtcsaUM09sVf/YGN+tiytJYdTcwB5pOZG2yQz8X8+x9bzD0laHR
	 vs1gaHNQFEMcScxxqPBm9FMNr1GXl2QSipvDN+ejH+HnMt9pFh9deKjBAx4gMNOmlM8gu
	 Pw8JeE+CB8qxuX8lbnlNfYXj/HKKS2ReyW9m373ylzxzhBy8gA6G8HfNty4I0Iek+IA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=astralinux.ru;
	spf=pass smtp.mailfrom=astralinux.ru;
	dkim=pass header.d=astralinux.ru header.i=@astralinux.ru header.a=rsa-sha256 header.s=mail header.b=DnjjdCRR;
	arc=none smtp.remote-ip=37.230.196.243
Received: from mail-gw01.astralinux.ru (mail-gw01.astralinux.ru [37.230.196.243])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0F5CF606A320;
	Tue, 27 Oct 2026 12:23:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 0F5CF606A320
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=astralinux.ru
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=astralinux.ru
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=astralinux.ru header.i=@astralinux.ru header.a=rsa-sha256 header.s=mail header.b=DnjjdCRR
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=astralinux.ru;
	s=mail; t=1793103810;
	bh=P3E5JJo9apThsCrIhdY5xdcWa1BI+V6kQr+vHn2p5qM=;
	h=From:To:Cc:Subject:Date:From;
	b=DnjjdCRRmoprcy4jQCQtG7mESis82J6RBtAkK/OAVm4NKRr/AS7xllFmProxGSUIL
	 GCf6pc4qlM9+i55rZ7uUbTWh00QTBtTJn8IKuzEcDUXdoqG/rKDANlpQ7H+AWyCWQn
	 H9az5BZ6kyupil/an5Si5LDa5YQLQIsxqNfNSnJXqh3knGUbArP5v12hDXRdO7MkA/
	 S9FysrJhRWBGgLQw2j9mn9ICjGaBiYbepc2Eyhy3GdSJJklIHh7ODQ/xObPUP8/H9p
	 lGaafs0WzMZNHc4IhF/mc+lxtq0F5yOvW28bgEYHSc6GEzbw4d1mwKbSu0ehl9axEa
	 f5ncQEBlACRKw==
Received: from gca-sc-a-srv-ksmg01.astralinux.ru (localhost [127.0.0.1])
	by mail-gw01.astralinux.ru (Postfix) with ESMTP id 035A225E57;
	Tue, 27 Oct 2026 15:23:30 +0300 (MSK)
Received: from new-mail.astralinux.ru (unknown [10.205.207.10])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (P-256) server-digest SHA256)
	(No client certificate requested)
	by mail-gw01.astralinux.ru (Postfix) with ESMTPS;
	Tue, 27 Oct 2026 15:23:26 +0300 (MSK)
Received: from DESKTOP-D46TNHI (unknown [10.198.50.125])
	by new-mail.astralinux.ru (Postfix) with ESMTPA id 4jDTdn3vy6z2w2F;
	Tue, 27 Oct 2026 15:02:53 +0300 (MSK)
From: Mikhail Dmitrichenko <mdmitrichenko@astralinux.ru>
To: stable@vger.kernel.org,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Mikhail Dmitrichenko <mdmitrichenko@astralinux.ru>,
	Sasha Levin <sashal@kernel.org>,
	Chris Mason <clm@meta.com>,
	Chuck Lever <cel@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	Trond Myklebust <trondmy@kernel.org>,
	Jeff Layton <jlayton@kernel.org>,
	NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@kernel.org>,
	Jakub Kicinski <kuba@kernel.org>,
	Paolo Abeni <pabeni@redhat.com>,
	Simon Horman <horms@kernel.org>,
	linux-nfs@vger.kernel.org,
	netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	lvc-project@linuxtesting.org
Subject: [PATCH 5.10 v2 0/2] xprtrdma: Fix bcall rep leak and unbounded peek
Date: Tue, 27 Oct 2026 15:01:36 +0300
Message-ID: <20261027120143.1596-1-mdmitrichenko@astralinux.ru>
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
Content-Transfer-Encoding: 8bit
X-KSMG-AntiPhishing: NotDetected, bases: 2026/10/27 11:50:00
X-KSMG-AntiSpam-Auth: dkim=none
X-KSMG-AntiSpam-Envelope-From: mdmitrichenko@astralinux.ru
X-KSMG-AntiSpam-Info: LuaCore: 132 0.3.132 b92628ca234da971a1a6d61b32804bb3075f0fd2, {Tracking_uf_ne_domains}, {Tracking_from_domain_doesnt_match_to}, lore.kernel.org:7.1.1;d41d8cd98f00b204e9800998ecf8427e.com:7.1.1;new-mail.astralinux.ru:7.1.1;astralinux.ru:7.1.1;127.0.0.199:7.1.2, FromAlignment: s
X-KSMG-AntiSpam-Interceptor-Info: scan successful
X-KSMG-AntiSpam-Lua-Profiles: 207024 [Oct 27 2026]
X-KSMG-AntiSpam-Method: none
X-KSMG-AntiSpam-Rate: 0
X-KSMG-AntiSpam-Status: not_detected
X-KSMG-AntiSpam-Version: 6.1.1.27
X-KSMG-AntiVirus: Kaspersky Secure Mail Gateway, version 2.1.0.7854, bases: 2026/10/27 10:49:00 #28748526
X-KSMG-AntiVirus-Status: NotDetected, skipped
X-KSMG-LinksScanning: NotDetected, bases: 2026/10/27 11:50:00
X-KSMG-Message-Action: skipped
X-KSMG-Rule-ID: 1

This is a backport of the fix for CVE-2026-72466 to 5.10.y.

Patch 2 does not apply to 5.10 on its own: rpcrdma_is_bcall() there
still has the out_short label that commit 84dff5eb86ce ("rpcrdma: Fix
comments about reverse-direction operation") replaced with a direct
return in v5.12. Patch 1 takes that commit as a prerequisite. Apart
from comment rewording it only drops the pr_warn() on the short call
path, and with it in place patch 2 applies as is.

Changes in v2:
- take 84dff5eb86ce as a prerequisite instead of removing the
  out_short label as part of the fix itself

v1: https://lore.kernel.org/all/20261022115004.1615-1-mdmitrichenko@astralinux.ru/

Chris Mason (1):
  xprtrdma: Fix bcall rep leak and unbounded peek

Chuck Lever (1):
  rpcrdma: Fix comments about reverse-direction operation

 net/sunrpc/xprtrdma/backchannel.c          | 4 ++--
 net/sunrpc/xprtrdma/rpc_rdma.c             | 8 +++-----
 net/sunrpc/xprtrdma/svc_rdma_backchannel.c | 4 ++--
 net/sunrpc/xprtrdma/xprt_rdma.h            | 6 +++---
 4 files changed, 10 insertions(+), 12 deletions(-)

-- 
2.43.0


Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8B29F367B84
	for <linux-nfs@vger.kernel.org>; Mon, 14 Sep 2026 16:01:01 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789401662; cv=none; b=lP//+slZWtH8bBuUYn1KveKlraUQgsxtzFcu0wK0fhos8isRxo9Vyh+WYreqbWKJ2v2AZC6Cfj/mQY/OlNAcYFl0VZAoj0dXl+ojFTNz+9ZIWLraLJtW3wxGYfeghBAeUY1LKYmC4qoYbUW4ifQmtkLVvE1jyi6uCtnvKzD2HpQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789401662; c=relaxed/simple;
	bh=KgVpp8IztTSK+6VYdnCzD2ZD8paGKABVfZF90grzQzI=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=fMNjkxOwi8sPHGElOb05M4XZOUcLeZAftU5tNUJyVAoju0G8nlF6VQn1C+KK3cjYCjP9ZLvs+ZwO6sAVBdgOWlfWtn4U9Tz+FP6OY/pWcEPrLEnFXP+FA17yp5mEeqK/fjcqx5BNqK595N5RaTbYMurcAPyCgCmb54WryuDpc3Y=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=i6JLHo6A; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="i6JLHo6A"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id B0E081F000FF;
	Mon, 14 Sep 2026 16:01:00 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789401661;
	bh=iGX7uze2o1LDjnfQ6rxoQA0XGyDFnNG6eSEOCwyZCh0=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=i6JLHo6A1zAHVgJfg4b95pSPk4WMLXq8Wo6hZ2NhDOg5PQuEKT0Uu3f16MD7UpPGW
	 wnFMHtc9tR/8Uv5umHCfxll532N7mNwxUD0sp/0cBPC1tvqqyRZzEjRyIJ5Jt1Z0nn
	 pqOCQzhplx63PpHlPj8OOH/u7xNiEU25nlYO8PrhCJzF1H+2MTXFWlk2G50h2eR7o/
	 lZ9SkJIZgGLroAmPSYWaf5roUVxq5DopkmXLlPU8cGtkCaVyX6hPAAavt37LVr8aUI
	 gdC/eZD9EF7vznBMR1Jo6HVKkfFP5bWP3tl1psifRvut2TPz5H2hu49E94AmtN3ovQ
	 pnW5PRxOhEbDg==
From: Jeff Layton <jlayton@kernel.org>
Date: Mon, 14 Sep 2026 12:00:38 -0400
Subject: [PATCH RFC nfs-utils v2 10/10] nfsdctl: check the netlink
 attribute puts in set_listeners()
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260914-nfsdctl-rpcb-v2-10-b2c679ac0107@kernel.org>
References: <20260914-nfsdctl-rpcb-v2-0-b2c679ac0107@kernel.org>
In-Reply-To: <20260914-nfsdctl-rpcb-v2-0-b2c679ac0107@kernel.org>
To: Steve Dickson <steved@redhat.com>, Trond Myklebust <trondmy@kernel.org>, 
 Anna Schumaker <anna@kernel.org>, Chuck Lever <cel@kernel.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org, Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=1294; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=KgVpp8IztTSK+6VYdnCzD2ZD8paGKABVfZF90grzQzI=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqqBoyeO+uMa7hfrhReyR2QRWmxkLJ21Lf4JMiU
 W+RG88mD5aJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCaqgaMgAKCRAADmhBGVaC
 FdXyD/9BAvk8WN9hCA4QjJ+RtGLmDL08TZgaFfO2SINrh8WtCVdzEJFerw4At8aPDY4ZR2tIySw
 p82MKGF6HXmue70ZvSm4nM8uQGuZ4/GvPlyslXGlliKZO0Ea29J4LX7y/I6t+PM6nnbTsik/Fk0
 H8Nno1pXqZw5tg37T3GuX9k0h5MgadKvIhfCHXaJwqkWa49aAamkmcWuZHR7aLbVDQ+fElPEAAq
 Nzmm2c66M4hrVrZRZS+LCjGDZs8ejFXFYXhLI2XRDNuBGEUJE7osY8hb6R3CftH3JA7r0zunu5G
 iUjhxR8im0sobjWJOuboU/44jLh5C8KL9aDCzBX9y6ho/bRa+qaYLtTNXeA9aYo3UxlKmxSSa5b
 nOZ28RwrNp36J/to9k3nC4OY1aJtlaUk26+H6O6N/LrFU8D2sSr+osmeMGYjTPDQWeTJSJ+xMQI
 f1TBUz7f6yK/xIs7oQ8vUmIQA6O3ScGhNPWfSMppGlw845Gf+6+wTxhodi2HIEppZqNKjOF8D3p
 w82vUId9iCs1rJJtuCIN+PtPNDk6TX2OvkJkjdIVFRBiPuEZ3s6KhHBh3h3ojzRaW9TIBuO4qP+
 OMjYgjD2cY0JYbDh45R85rund/qC0YmuxbV7p2+qQTd8kPAB8shubTnL5NlO8uYGgGUrmREGy0Q
 HoJBl2iOKAxnpzQ==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

nla_nest_start() only reserves a 4-byte header, so it still succeeds on
a message that has no room for the 128-byte sockaddr that follows. The
puts inside the nest went unchecked, so an over-full message was sent
with silently truncated listener nests. The kernel then rejects it with
EINVAL, which says nothing about what went wrong.

MAX_NFSD_SOCKETS is 256 and nlmsg_alloc() defaults to one page, so
roughly 28 listeners overflow.

Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 utils/nfsdctl/nfsdctl.c | 10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

diff --git a/utils/nfsdctl/nfsdctl.c b/utils/nfsdctl/nfsdctl.c
index 7464baad279f..505b38d695ab 100644
--- a/utils/nfsdctl/nfsdctl.c
+++ b/utils/nfsdctl/nfsdctl.c
@@ -1493,8 +1493,14 @@ static int set_listeners(struct nl_sock *sock)
 			goto out;
 		}
 
-		nla_put(msg, NFSD_A_SOCK_ADDR, sizeof(sock->ss), &sock->ss);
-		nla_put_string(msg, NFSD_A_SOCK_TRANSPORT_NAME, sock->name);
+		if (nla_put(msg, NFSD_A_SOCK_ADDR, sizeof(sock->ss),
+			    &sock->ss) ||
+		    nla_put_string(msg, NFSD_A_SOCK_TRANSPORT_NAME,
+				   sock->name)) {
+			xlog(L_ERROR, "Too many listeners for one netlink message");
+			ret = 1;
+			goto out;
+		}
 		nla_nest_end(msg, a);
 	}
 

-- 
2.55.0


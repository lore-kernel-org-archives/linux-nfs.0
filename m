Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 94584363C53
	for <linux-nfs@vger.kernel.org>; Mon, 14 Sep 2026 16:00:58 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789401659; cv=none; b=qUS63Bv58P+HxAk/qCWg3fA3PL4u8HeYZ1TAbSif+/fctjPykW62NKM4NG5x4LG+q37bj4IZkuF1H5HwW/2wIXXnl9PxNW+bRn57hcHAcRLM4jkNVzAsecW+q7EqGN5P7VoAqOxil0eQoVZ5SS6Z6mr3JjJN4FmI5XBVs3XeN/Y=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789401659; c=relaxed/simple;
	bh=0Vo3/A0C9c0mOmJFLA277xdypjGxFzuZrZZNrh1r7gU=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=YuvPWQG7xNhO27c2Hxyav3DSlqIUXJdIESzd77UM+uWvsAADX1oEiBZqqurnMhoJfT3f5l3kK3k5IbwncvWI96nBnPxupuAqHJ3Gsmc6zkUbM8ZlJWsxqDkFFoziRsZpmTXzor+O5v7Ne5ZTMpb7Nl1srVrubPYU6eLc0WOyTT4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=X2AUyQDY; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="X2AUyQDY"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 9D2C51F00893;
	Mon, 14 Sep 2026 16:00:57 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789401658;
	bh=cBsDqAlD2ogxdT+sLLi9raxMGzMZkZ9AV7zrxUCB/GE=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=X2AUyQDYC1P+4dYWDkhpcdfzpexbPku7g3HmIJmEaY3gEu6TjDw3Y7yPeEwch/15i
	 i0iOJPk1BV4We8vicSklNZ1et+k0hmXCGaAXIPQ9nRXfzuPq7cUJ/b9zwW8ihd+Nbq
	 KWGkK/i/I81h354gKDxmoYa6dJ9ovuIMp+lIxOmd1h75wqEm95DoTJZxVzEefbCH8r
	 exBSvHBts2kjG2SY5oy6vSWA7q1fXsLEWqzSNzRqILw3aUwAWGSdPSNaiqJYBEP9xN
	 6z93ugGiNE8qRsyt7V+UhVpu1fewT+t1wKCDvSQ2L+Iy4O5Xwdd45VVKovy9t45roJ
	 c4Ve2XhIbz9iQ==
From: Jeff Layton <jlayton@kernel.org>
Date: Mon, 14 Sep 2026 12:00:35 -0400
Subject: [PATCH RFC nfs-utils v2 07/10] nfsdctl: add missing break in
 update_listeners()
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260914-nfsdctl-rpcb-v2-7-b2c679ac0107@kernel.org>
References: <20260914-nfsdctl-rpcb-v2-0-b2c679ac0107@kernel.org>
In-Reply-To: <20260914-nfsdctl-rpcb-v2-0-b2c679ac0107@kernel.org>
To: Steve Dickson <steved@redhat.com>, Trond Myklebust <trondmy@kernel.org>, 
 Anna Schumaker <anna@kernel.org>, Chuck Lever <cel@kernel.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org, Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=1167; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=0Vo3/A0C9c0mOmJFLA277xdypjGxFzuZrZZNrh1r7gU=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqqBoxw1d74nGRlMWNkjiEIVGoewItdkei+yiGo
 MkNvEygvlSJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCaqgaMQAKCRAADmhBGVaC
 FRYkEADKn+QUyns9SN6wYYn+bOOQqjCtIu2447NK7ZtAXNFaYuqXEChBcl3/1FwnCSnqgfvTQiB
 0hWhmYVKX8U0VyS945d4tIHEIa3XFm0DYdC5Hs3m1i0L9SGjk0qLaOqnBvjmJoMdgOh0oIpsV3w
 ri9Mswth+K4Uv9xy2N9mXXFcwpI1RG1vX1bLJnm266AD/ZMt1WzXTQ6A+SQgHbUgHtl5pl0WEb7
 cfzQ2znzYeJPJK9hpxI5Fb1ndy/6Xp9LROSEQq7aw/ozysoSJJqgjuvSJRxWX2MxOPyu+rpc1kG
 2sTt9fpIPKdebExtAZglX7DtK2JI+t2PD1HgTEqS603hKDehoSke3Ct5c/j67KpCdJBgpQj4Ywn
 4RqSnBcQDK0BpKFSw18/cSDETBZOUStqVyaBlH4crUl0XH6CSg+t3BKt3+pYEEXxBPTwNkrWk0Z
 Z4JoBYRygif/WgP55yX5I27glo3zb1LIS+Gi4CUT9nab+rPbRnJbWNHylEaSe1h38nnGYFR4wtn
 SKCbO4+t4PY/sbF3Ec19wISId/FxYIKD7x+pt67Uly8K4ThxUjaUCWuBQmZLpJJ1Ynu8PrVKafV
 91MZ8IVCtdekQnXznopf0tVbNfHGxp3wPs7pYJgss50s0t/7DYoswyPa1chirxMWpH0QtrQVkZY
 PtH/fNumyROrELA==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

The AF_INET arm fell through into AF_INET6, so a v4 listener that
matched on port and address was then re-tested as a sockaddr_in6 and
skipped. -Wimplicit-fallthrough is not enabled, so nothing caught it.

Terminate every arm. The AF_INET6 fallthrough was harmless, since
"default:" is empty, but it is a trap for the next case added.

Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 utils/nfsdctl/nfsdctl.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/utils/nfsdctl/nfsdctl.c b/utils/nfsdctl/nfsdctl.c
index 4cc33672a41f..ce4da2769e5a 100644
--- a/utils/nfsdctl/nfsdctl.c
+++ b/utils/nfsdctl/nfsdctl.c
@@ -1410,13 +1410,15 @@ static int update_listeners(const char *str)
 				if (r4->sin_port != l4->sin_port ||
 				    memcmp(&r4->sin_addr, &l4->sin_addr, sizeof(l4->sin_addr)))
 					continue;
+				break;
 			case AF_INET6:
 				if (r6->sin6_port != l6->sin6_port ||
 				    memcmp(&r6->sin6_addr, &l6->sin6_addr, sizeof(l6->sin6_addr)) ||
 				    !ipv6_is_enabled())
 					continue;
+				break;
 			default:
-
+				break;
 			}
 			sock->active = (sign == '+');
 			found = true;

-- 
2.55.0


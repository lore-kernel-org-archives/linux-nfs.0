Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 00498581229
	for <linux-nfs@vger.kernel.org>; Thu, 10 Sep 2026 18:22:16 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789064538; cv=none; b=Km6XwQfgUDr8rHDY+EJ7nRMqgKRVoXveYMHIOn4agggKn/X/jk9gqO9Mb6XmvPmGgox3e4HwAYvZGw0Sij7K/mCxleX+ClnWU52qhbIU7kOXGw9VRtzWnb7f9b/0YyU7ayBjRqxfo8HLNR7L+gr6Bdbutjqjbzdb6l8y5dhbgLw=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789064538; c=relaxed/simple;
	bh=/n8NqJH3+2CslaLwPgdUaE4QwIPTVK2qUb9oFETAOGY=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=ssU6hTVZSRbxGnsd7YDd4Gv3UHZQde0ktVIcCkHqncQuhcEQ11EsE1q6pLhuvzkEyMrw+T+5x/+ANXiGQdWZQRnDPiidXJvu2sFIGn/ItpnsEJjc2DZLTGZ125OUq23W5Bx1QSmUGxSsOzDYCWbVy1cVWRjpOJk/hwLJMuPMhc8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=Ei6aQwb8; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="Ei6aQwb8"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 27FE61F00893;
	Thu, 10 Sep 2026 18:22:16 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789064536;
	bh=KyVE9U+JJ2Yxk0SmVvOC5AhEiTRBpCGrTFc+7Ln2Nbc=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=Ei6aQwb8E7XXtxHcSRLa1ST8YQ9yVH25Uix8llFsdReEOkRdqLg3NoV6qr3Zb148F
	 K0MGZzeRCh8EXqF3RiFzwprEDsTuQbYATy5zgxAvsYL6RG3f4qfrB0wN2YzskcX8hL
	 /0ifFUEKcPenqQBEs5z/poGc45TopIP217978NRN+wZXwYUJSesODycevJXsoM2/CR
	 hAfmSM8VjYt9Wvs9oZudlRu+uHsp7sonmuij5pdW3N8MakGyfIPvWRC6de7pjBE6Zc
	 hGXkZaZi8O/XEkF4Z2BjxA/K30XR6WcMYwc/awvylj18oLyHgj+6+QvCa0zDKA8skH
	 +QQdKqQKNtx2Q==
From: Jeff Layton <jlayton@kernel.org>
Date: Thu, 10 Sep 2026 14:22:08 -0400
Subject: [PATCH RFC nfs-utils 7/7] nfsdctl: add missing break in
 update_listeners()
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260910-nfsdctl-rpcb-v1-7-4bba1e7a3a43@kernel.org>
References: <20260910-nfsdctl-rpcb-v1-0-4bba1e7a3a43@kernel.org>
In-Reply-To: <20260910-nfsdctl-rpcb-v1-0-4bba1e7a3a43@kernel.org>
To: Steve Dickson <steved@redhat.com>, Trond Myklebust <trondmy@kernel.org>, 
 Anna Schumaker <anna@kernel.org>, Chuck Lever <cel@kernel.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org, Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=1167; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=/n8NqJH3+2CslaLwPgdUaE4QwIPTVK2qUb9oFETAOGY=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqovVQntmPGshzxErjq2DpTQuYc6IrKkm797oB+
 dNhaLYnwRGJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCaqL1UAAKCRAADmhBGVaC
 FduCD/0dYLX9tpZY/lUGuoZR5ZbSPn2effrA/dN+6tbP8TiyUjqZcdBCN0VBXu0+n6zuOJFi6V7
 oSj4o34w+FKBn5bCSGyJbhHNYIuZvT/CH2u611NJniMP5WJKDOD8ileNVMdEXY7eDB7ihwNrdUu
 9J8rUVbkZcXVhNZEhNjs1SLBkJ6BckdZNOsua/8GAGADmReD7Qx1dp+i5Fgh0kXXc+y/BBFddMX
 yS5k/q9mQwbzlRjC18ixVpvhxsO45wruAiZPJYZ2fNUrW99pdlYP9yuJevJvXfmjXvtZLK2seYm
 e4RoBuzraZ+yakd2BkkGvqGiu3NDJNazRkfUng3bFBh9UBZxmN129kuJNCjFszzq2ySbOOu+CxQ
 ds60BMlZ/YwGWONE/PtEvdb8YWuZAM+2wcZ5TEXJ/Pl/kD3zmrWHzmy2JGhA06mL0gQpQIq9g7y
 9rzN77UsKDQpHrtHVVA2UAKc+y1/58/Txx+1paGx3s6pQ5d7zZcu0mZugZ+xd135HFBr1V5l3yQ
 XHLIaeryz+WmQ3dmP4BrSiD6ZrLnWV9IchPXfn6YFt00AuTPQ4XdYihE28qSznNa1Lm02CQ4PLY
 KrNOBTa91hdIIUH9JJBJN14dF/QD2YHNUNscknYwy6rQBjJg97oDsigHk/Yk8gU6jVlW6GOZyxm
 NZNt+35uPMm108Q==
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
index a96faee6cbea..7c639b56c8a1 100644
--- a/utils/nfsdctl/nfsdctl.c
+++ b/utils/nfsdctl/nfsdctl.c
@@ -1406,13 +1406,15 @@ static int update_listeners(const char *str)
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


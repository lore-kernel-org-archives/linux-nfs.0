Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D671447C0EE
	for <linux-nfs@vger.kernel.org>; Sun,  4 Oct 2026 19:40:35 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791142837; cv=none; b=ZNvRv/7mMlYJpZybFC0w2gt1/J4c5TGqVuH+odEzfQyFLCmvvHf4MVpPx1es+JwOA7gENILOAjXC5NruqUe8B3hQ9sGG9WRd77inci1PRUjtcHk3/SjbqD69kDBl+6xtKcgXKealw1+iyoQQYH58Jgylnj2SfiYL1I7J9tKf5vo=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791142837; c=relaxed/simple;
	bh=lFZjcI4qs9ssXOmvl73y3UwtKjWK/RlfRUJZMFX5Bgc=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=sBtnI7MZNYFahi3528aQAqwc2hbUwslhIAqODNDP1GXkjf8485qahWSsm4ntgRVWsYNUoStIExFxbPzV4cS7v87QBB8kL0ZaGtP8OarQg1lw/flbnEHlgQ4St+0RuA6W1bIPzBPe6m/jlymH+TzneQYodHZowijJD+oAQet5Rbk=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=Z/7d0Bvr; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="Z/7d0Bvr"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 42BB91F000FF;
	Sun,  4 Oct 2026 19:40:35 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1791142835;
	bh=VdPaWv2Oj9maEpOOgXRd85M96MVCdAK//kY8cn1n5sI=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=Z/7d0Bvrmf7Yp5X37ghWu7ajo4Oo6sM9Js8++Rx3LFG4IJPvhRUbulsnkf1F3yzyS
	 zcFESkf4Hey131MjSeQUylXRuxwlZvr5ZjhKhOdD13LYHuLCBoOSr8NtbeR6mf6xPA
	 wKvypLqEJ5c6G7HwQvSKex/3XCQpXupyx7pBNI0xjyGxUvx3E5Ncwnb8rOIeABwRPd
	 t51AtxO+BvQ4eplekIo+5nuLycNxPEJ/pluVQQatQBeoi9kZToPPcADYB3LC5RzLt4
	 9qCn7PKdP0i2AChzb9AovNO3CK5flJG+p+RGjMd3ct9nOQgrk8eEafe0tKfmrLyOdZ
	 UmriE5DQh8afQ==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH v1 6/7] sunrpc: preserve rq_daddrlen across request deferral
Date: Sun,  4 Oct 2026 15:40:28 -0400
Message-ID: <20261004194029.10714-7-cel@kernel.org>
X-Mailer: git-send-email 2.55.0
In-Reply-To: <20261004194029.10714-1-cel@kernel.org>
References: <20261004194029.10714-1-cel@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

svc_defer() saves rq_daddr in the svc_deferred_req but not
rq_daddrlen, and svc_deferred_recv() restores only the address. The
thread that replays a deferred request keeps the rq_daddrlen of the
last request it processed. A newly created thread has a length of
zero.

gen_callback() and nlmsvc_lookup_host() copy rq_daddrlen bytes of
rq_daddr to form the source address of an NFSv4.0 or NLM callback
transport. When a new thread replays a deferred SETCLIENTID that
arrived over IPv6, the copy is empty and the source address is left
as AF_UNSPEC. xs_bind() then fails with -EAFNOSUPPORT, and the
callback transport never connects. A length left over from an IPv4
request copies only part of an IPv6 address. Found by code
inspection.

Record rq_daddrlen in the existing daddrlen field of struct
svc_deferred_req when the request is first deferred, and restore it
in svc_deferred_recv().

Fixes: 849a1cf13d43 ("SUNRPC: Replace svc_addr_u by sockaddr_storage")
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 net/sunrpc/svc_xprt.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index bf5b2cdad35e..031cbac2a612 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -1343,6 +1343,7 @@ static struct cache_deferred_req *svc_defer(struct cache_req *req)
 		memcpy(&dr->addr, &rqstp->rq_addr, rqstp->rq_addrlen);
 		dr->addrlen = rqstp->rq_addrlen;
 		dr->daddr = rqstp->rq_daddr;
+		dr->daddrlen = rqstp->rq_daddrlen;
 		dr->secure = test_bit(RQ_SECURE, &rqstp->rq_flags);
 		dr->argslen = rqstp->rq_arg.len >> 2;
 
@@ -1377,6 +1378,7 @@ static noinline int svc_deferred_recv(struct svc_rqst *rqstp)
 	memcpy(&rqstp->rq_addr, &dr->addr, dr->addrlen);
 	rqstp->rq_addrlen     = dr->addrlen;
 	rqstp->rq_daddr       = dr->daddr;
+	rqstp->rq_daddrlen    = dr->daddrlen;
 	rqstp->rq_xprt_ctxt   = dr->xprt_ctxt;
 	/*
 	 * ->xpo_recvfrom() is bypassed for a deferred request, so the
-- 
2.55.0


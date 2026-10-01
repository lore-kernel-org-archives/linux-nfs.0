Received: from mail-pj2-f37.google.com (mail-pj2-f37.google.com [74.125.227.165])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id EE2AA521894
	for <linux-nfs@vger.kernel.org>; Thu,  1 Oct 2026 14:50:06 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=74.125.227.165
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790866208; cv=none; b=SaA6p7QF/FGZPiHn9uSH54RY4ipuRm0ABkXmO+R81h+QEiIyoQWE85NbjCp0uFEtZzmg/ZDQm+xaGAfyrNAOeuelSyBICKEbKH8v/AclQhkjfRLJEURI6r12uXySX6zPUNraw6L2MLK+yq7cMwO/HDq/JAwRnzbHItyRU3PCJr8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790866208; c=relaxed/simple;
	bh=tjrM6HMwhCnclRyWuQHKDDXnjPUf1nkvmMvYbi5CJHw=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=IbHGLJ+MWiTfQlSb9sC5aAZvmsRFlgi0eI4FPLcrV1g4aWhmzpsR+PC6fJSrR76HL6/Kccm+SHK1cWn7L3F6rvFUERQYKgTUI7VWtl/9u8De97noPg/sysLmzBkDWTRQD49hx1lcrN4NwEv+dxuNhpbt9aAcjlWhgae6OhYDg5Y=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=Ti0xoMl3; arc=none smtp.client-ip=74.125.227.165
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Ti0xoMl3"
Received: by mail-pj2-f37.google.com with SMTP id d9443c01a7336-2e300fa474aso5860495ad.0
        for <linux-nfs@vger.kernel.org>; Thu, 01 Oct 2026 07:50:06 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1790866206; x=1791471006; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=CJ1jkJ7PnUIceFAM/F8vaiV5gJj5Uk5tr+F+EFG9aPc=;
        b=Ti0xoMl3DWUdqcZS67EJhPnLUWHe29w9Fb+DYuzAOFaA7F6ygMsD8Tec+avevb90Po
         cGLkvmKmpto3yYyL79ZRYrudLqDyCGcfQ/Ujk77xDgxkFqV33V4lYDBeOY7O5BaB0cU6
         A6kEL5Wc1myPxfLFWKfWH0kh6K5/sVnvRJ5hVr0EP4EveHcJyCG1MdOYxutwZk8e6eXa
         nvOum9aUUpeLtLxSKHAHdCMXrsTTb06uczw7gvSS/zVQVfAmFc6x3CWIikDAEPL2+8jc
         lwhO7B6VB6duW4pWPI/Uew0M7r1LEPSvh5oWNup4jNxWKJ5SVuuMlghie/8Vl/zOVkkv
         twPw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1790866206; x=1791471006;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=CJ1jkJ7PnUIceFAM/F8vaiV5gJj5Uk5tr+F+EFG9aPc=;
        b=g9uSEHfGZFzS0CZ3pifojvWmTiVER+mjzYCCWtMFTfGD34yIehch1m8dGf4mW0wj74
         wLYHMPgE5dzXUXXirSutSYgL+B5RnJJ1tgo88U/MfiNnBUb7ypo9g48jUMkf/ZSWa+kw
         U5cPCnaF6J3XKqMUZGUDYa3s+Aie2sGfDpN43uMymaNGCy4Ut07a2hG2qWlPRYPEcDkA
         Db5T2EfvRkxwsj05JtxInPW9HzPBlth3J+2U/asXGzTGsrVUIp/iEMA7WLREOSz7jI07
         EzjYRNFb29pZnhDkoOU5QiR4I4wrN44fQtxQu3QYeaoAnKhajEkKPTzCZwcauvRu5qa5
         fijQ==
X-Forwarded-Encrypted: i=1; AKwUvBzH+/NB9neQgGRQyHlNRE59ydmFYuicxktRs3/1LcCnzi5w3Y/rvOhaMf06/QlmmRDi1tpZtnYq9iQ=@vger.kernel.org
X-Gm-Message-State: AFq9FYIDkFMzDmZYLC5w3fU1TqDWGXVkLO6EMGesvDMDMkwfKX88hQyh
	4HmkmZ3xAtnsN4ZIrURVQ8pIspBkt8glGJV2Zkqme98cWCdn+1Xniqod
X-Gm-Gg: AYBFou0WPdGM63oYwdInmV+jZcDKrgfMpXqCijM7C2CsZ4LuLKJ1SUfCAyaxRIS993u
	5+gL/Pnlk1R8AWG1dzqdzetAgDeynawMedE4bRsDEd+PjH4SSa2BNha+OApmd86zJ1z0bgrcQEZ
	yvZdizDUQNBINhUutc+xFOacuBtXHYg3HCU4luukN60EZuZajVFWqexLKgl1CNfviyXlL35js4+
	O4+T8yD5tC5tH7zpHcdU8tDRQkNgpYaNMUbuSmyhxHKkTjGL7joLsG73rmpU/pMrpmUKMrZcX/o
	JAMs92cxQ5qkMhxDqt0itOgf1M/HE7bqUd4JPsGzTCkqN89X/0r4qa3IU91iwxVoSq4evzly845
	bhstT7WvoqQ5QiZV8bHVs20a7y6YY7JP8utgEHbXm6UhTlwdmmpDg2nqDTUe/5QCEDqkllNdrJl
	csaf8o9vIP7TM1J+xkloApoI/WAQaawZRL+Z0p9L2o4A9z5z1jnckOMlxNXsErFFBh8KHYuEcAK
	yV7w+8bnNbVQwF/+/v1oBY=
X-Received: by 2002:a17:903:2448:b0:2e3:913:31a1 with SMTP id d9443c01a7336-2e30913f2a9mr22104945ad.33.1790866205789;
        Thu, 01 Oct 2026 07:50:05 -0700 (PDT)
Received: from Mac.tail7ad783.ts.net ([123.215.20.10])
        by smtp.gmail.com with ESMTPSA id d9443c01a7336-2e300b906f3sm11992105ad.82.2026.10.01.07.50.01
        (version=TLS1_3 cipher=TLS_CHACHA20_POLY1305_SHA256 bits=256/256);
        Thu, 01 Oct 2026 07:50:04 -0700 (PDT)
From: Jiwoong Wi <dwdnlzj@gmail.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>
Cc: NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	linux-nfs@vger.kernel.org,
	bobtobabz@gmail.com
Subject: [PATCH] SUNRPC: account for reply size in TCP backchannel allocation
Date: Thu,  1 Oct 2026 23:49:56 +0900
Message-ID: <20261001144956.38888-1-dwdnlzj@gmail.com>
X-Mailer: git-send-email 2.50.1
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

The TCP backchannel allocator places an RPC call and its reply in a
single page after struct rpc_buffer. bc_malloc() bounds rq_callsize but
then positions rq_rbuffer at the end of the call without checking whether
rq_rcvsize still fits.

AUTH_SYS reply verifier learning can increase au_rslack and therefore
rq_rcvsize. For CB_NOTIFY, a 3,648-byte call reservation and a 504-byte
reply reservation require 4,160 bytes including struct rpc_buffer, 64
bytes more than a 4 KiB page. receive_cb_reply() accepts the advertised
reply size and copies beyond the page before decoding the reply.

The TCP backchannel allocator is intentionally limited to one page. Check
rq_callsize first, then reject rq_rcvsize when it exceeds the remaining
capacity. Keeping the checks separate avoids arithmetic overflow and
avoids using the existing warning for a reply size that can be influenced
by a peer.

On the current nfsd-testing tree, a crafted AUTH_SYS/CB_NOTIFY reply
reproduced a 504-byte copy that extended 64 bytes beyond the allocated
page under KASAN before this change. With this change, the oversized
callback reservation was rejected before the final callback and no KASAN
report or warning was observed. A 424-byte boundary control callback
completed before and after the change.

A source reproducer and the complete KASAN log are available privately on
request.

NFSv4.2 and NFSv3 read/write/unmount smoke tests passed. A clean bzImage
and modules build completed without new warnings.

The vulnerability research and validation were conducted by members of
the Tobabz team as part of the Best of the Best 15th program.

Fixes: 5fe6eaa1f9a0 ("SUNRPC: Generalize the RPC buffer allocation API")
Assisted-by: LLM
Signed-off-by: Jiwoong Wi <dwdnlzj@gmail.com>
---
 net/sunrpc/xprtsock.c | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 7f60723fa..6018064ca 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -2969,15 +2969,17 @@ static void xs_tcp_print_stats(struct rpc_xprt *xprt, struct seq_file *seq)
 static int bc_malloc(struct rpc_task *task)
 {
 	struct rpc_rqst *rqst = task->tk_rqstp;
-	size_t size = rqst->rq_callsize;
+	size_t capacity = PAGE_SIZE - sizeof(struct rpc_buffer);
 	struct page *page;
 	struct rpc_buffer *buf;
 
-	if (size > PAGE_SIZE - sizeof(struct rpc_buffer)) {
+	if (rqst->rq_callsize > capacity) {
 		WARN_ONCE(1, "xprtsock: large bc buffer request (size %zu)\n",
-			  size);
+			  rqst->rq_callsize);
 		return -EINVAL;
 	}
+	if (rqst->rq_rcvsize > capacity - rqst->rq_callsize)
+		return -EINVAL;
 
 	page = alloc_page(GFP_KERNEL | __GFP_NORETRY | __GFP_NOWARN);
 	if (!page)

base-commit: 32eb1a60b456980761cf7a9cee8f907fdc08afb8
-- 
2.43.0

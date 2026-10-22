Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.128.53
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792694606;
	b=lxxFy+BaW4lhzxdNk2PYPhrtZan66nMg3XBC+/bzAJrwAwpMry4ve4E6LcNYPSXGH3z8
	 U37xu+GE+tg0CnClmqePJr1QQqmB9pTsZ3MPAoQah4FoO1mC/tr1ELCbI+u2ih6Q0N03a
	 hdJ1sZ3aHLMgkMTsKVjx00yjekZaOlm+3Sgj4TsrcGcS5W5mVt3j5oHDiY4bvoH1Z8h6V
	 /MQCgwvPquYcYOcZe8QK7rNxXASbAXXKWOMDmLzUNUsnImpQ13+BMzpj+Wk5oNz4xK41H
	 sx5GsP6MowbCqO9GiwTAhOFD+hw6bDDo1j+mclrR7J2TejJ4BZ/e07X2bgQsldgehhQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792694606;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:Received:
	 From:To:Cc:Subject:Date:Message-ID:X-Mailer:MIME-Version:
	 Content-Transfer-Encoding;
	bh=4TPL7MrPkZPEGgLFwRpHG0hwOCiY+0pCQuikmLA7G3U=;
	b=ceqF9SFk77Jjd2RMOZ+2wh5+kYinJBrOgiM0eaG44wLxTyVMDAtyh6Vo0UuPPdmSnMg/
	 JaQ0eks/udjAzRg+PHPFOMBC2l4lmjz/CLsuOMQfbjqTv0tRi6ctJGWx9RmBrWoXZ7IEb
	 QahK5361NgNLlLk4STTcF+EezFju1L25YwLMcMZPePHIA4S9WkwQx8pSboAnCjXIvBdjz
	 PIvTuShvLB7ol8Qbokl94V0XZWx1au6dJnzTFhWwPAYnUa2WKt9okIOru1C1LpmjYqlHk
	 KT8qRAbMw4D/Klq/LMJ+6V1X/A0blKjJQWdOfrTmI2HE2bQw14tDHIuXE8SHZs3pzfg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20251104 header.b=lFMM6DdU;
	arc=none smtp.remote-ip=209.85.128.53
Received: from mail-wm1-f53.google.com (mail-wm1-f53.google.com [209.85.128.53])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9CB72606A31D
	for <linux-nfs@vger.kernel.org>; Thu, 22 Oct 2026 18:43:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 9CB72606A31D
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20251104 header.b=lFMM6DdU
Received: by mail-wm1-f53.google.com with SMTP id 5b1f17b1804b1-4a20803a757so757215e9.0
        for <linux-nfs@vger.kernel.org>; Thu, 22 Oct 2026 11:43:25 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1792694604; x=1793299404; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=4TPL7MrPkZPEGgLFwRpHG0hwOCiY+0pCQuikmLA7G3U=;
        b=lFMM6DdU142DGDDpen5ibUZI0qU71coDlaMr6I6XYb9y2AeLQ+AAJF3yoegosvKtA5
         /8uqJKyGQRdYicr7VzDJe2Xz0/zNqI8VmrDenS/YV627RA6bc3sfqOwPCDVS8Ev/wBUG
         mAfUfKrLf50shby5xHhdDlWPyo91oB4lboXxAE6HRCGk6Ws2xUP2wOhaKdxGFl65+VV8
         t7Mk2tXzYRavcRmR0jIJvk3dpBqLegcERoERq9HxYANOaP6VJXMBKIxL/DaRAc40AsMz
         lL+xKIBLdF15BdIeDkUnj3/aTps9eckfOVauENul8Oe6tpKyv0sViqg0NNZknAEtLlX3
         HjvQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1792694604; x=1793299404;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=4TPL7MrPkZPEGgLFwRpHG0hwOCiY+0pCQuikmLA7G3U=;
        b=r25JWkuX/Yr23uYQqIhatdLG44/mCdJvHWFkjMX3LUtgJVJ3Nvbrj+rAQoWUIAdlIr
         WAYUdWl2Pwc+WlVLo15pizEapnzaYXTdD2v4L//EzZLiK5pasaMvBDKBUjghPz0T4NqM
         G2a8H/Vmh8t5ApBOrnytJYPLAek8VX1s/7S4lqs0QWpRWU53jjMFrDPTQQxT+SbyD76h
         +d/vD21HtOQLpeOFqLq1o2xWATqYIOWgsvKeZ1zBPlGqbl05zGyv5Gy+3cfjH4lza4g4
         nWl3dP+FL6lNhPKGedfbfpq+HKK35kSpV1d2U947jEw7xRG34/P4FMkyLWnGTegXxkT0
         LJeA==
X-Forwarded-Encrypted: i=1; AKwUvBxzG5e34teZDvSQv5kZ5LQUaVllA/NJfU+jZfk+h5gFmYQZLU/s7P+CUGq7kbMT8k/7DYyRgtLPe6A=@vger.kernel.org
X-Gm-Message-State: AFq9FYJQa8J4iqOTBF2mbm00hCLPehQkAvkaBXGXkZivDpHO8g9VhEp0
	Z8fFZjWWIaKuEuaHNqLr0005nrGL1efgNb8etU6TkAfImm9SlFelV+Y6
X-Gm-Gg: AYBFou3ZI1wH/NV6va+eyDRscDEGBPaEqe+AWDdkUWqmPj6FgF+lP7guAEeCtwbXhVX
	4k/1Yh25pziaAthF7YF7/WzEH5a+UO2y6BTOHL85C6FiLYONIV2zN9XdIBLhzaTzizrKKMgTD31
	ttOSdOA8gGbHfBy8V2GZItzTgMhfYRqtucO5t4wi4zGMjfDiJYYd6UuZyAslxCQ6dXwNveq9rS8
	G9L4kBOt5glGW9IkmIbvHvTfpy9Ul9UHOmtKn+TDlIiSedW+kYglJOmxp+CFDCiKZO7o/+YBrtS
	Zl/F+F0z+v0YbK8UcvMTjRawZKGTH2Vbp/W8zVw/7l4mp/7JDjUsfXDNzD4uggZ5x8uwhgcWnsv
	XWxEEILic0mBcCWU01XKJHCeup+zZ1cBjs3dNJPEzQ4/CuHJ2JfoTDQadvvgRD9mLPAoeD8D+iG
	RyJor2ylCuxr8JwY2TeVc2AP8p+T9gs0U6MrOXZ+MWOuNutm/Pbd9xRIA65FLg15vbVSXS3qXfa
	PZmekBs43WsPj9atzRpcgilh+z9U8p+s8wnLLSGbnNjGk8duzSRFkw8/VnnvxgyTy0xoziwtTkb
	oEQ0
X-Received: by 2002:a05:600c:1c09:b0:4a1:e3e2:93e0 with SMTP id 5b1f17b1804b1-4a1fdd3b20emr124757195e9.32.1792694603589;
        Thu, 22 Oct 2026 11:43:23 -0700 (PDT)
Received: from LAPTOP-AVI.taile24b5.ts.net ([147.234.101.15])
        by smtp.gmail.com with ESMTPSA id ffacd0b85a97d-48e379cf522sm102672f8f.17.2026.10.22.11.43.20
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 22 Oct 2026 11:43:22 -0700 (PDT)
From: Avi Weiss <thnkslprpt@gmail.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>,
	linux-nfs@vger.kernel.org
Subject: [PATCH 1/2] SUNRPC: preserve timeout policy when cloning clients
Date: Thu, 22 Oct 2026 21:43:16 +0300
Message-ID: <1596f1b91f9f6ad14a75e3889ab80ba7d98cb52e.1792694006.git.thnkslprpt@gmail.com>
X-Mailer: git-send-email 2.43.0
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

rpc_clone_client() and rpc_clone_client_set_auth() leave the
timeout argument unset, causing rpc_new_client() to use the
transport defaults instead of the parent's configured
timeout. This also affects pNFS data-server clients and
changes their request timeout and initial RTT calculations.

Use the parent's cl_timeout when no timeout is specified.
Preserve explicitly supplied timeout overrides.

Fixes: 1b63a75180c6 ("SUNRPC: Refactor rpc_clone_client()")
Signed-off-by: Avi Weiss <thnkslprpt@gmail.com>
---
Tested under x86_64 QEMU - without the patch, both clone
APIs replaced a configured 5-second initial timeout and 
16 retries with 60 seconds and 2 retries. After the fix, 
the configured timeout values and request timeout
calculations were preserved as expected.

 net/sunrpc/clnt.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 6cedc824cf82..0f6e44a11d83 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -653,6 +653,8 @@ static struct rpc_clnt *__rpc_clone_client(struct rpc_create_args *args,
 	}
 	args->servername = xprt->servername;
 	args->nodename = clnt->cl_nodename;
+	if (!args->timeout)
+		args->timeout = clnt->cl_timeout;
 
 	new = rpc_new_client(args, xps, xprt, clnt);
 	if (IS_ERR(new))

base-commit: 7be4bc52fd9e0e55dc9a2e0232b89427d2c4b614
-- 
2.43.0


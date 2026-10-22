Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.221.46
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792688123;
	b=fT/qwzhnqxvfPljGB8B/Xt7GRHDi9LfZ6bQvexeavBgJSEUJZ82aHMqURD331zyBMtkg
	 2Dgan7sfiZOL+0OQ4BByZcGC/i4xdWL2av7Q8HO3HbPKcLYvwgJGSwgxIez16pCeKb8RO
	 w6xQbXDpcXeWajwIjJRfuwufiO1bWB4rNonAkuNS36sxR6Aqz1usp0Sd0b0kEKykPVu5R
	 taufWJi72BjOQt991Edmhved5Utft4IQb1s0lDhcMmbiYRUNdpscnkYe4HVjZ0H0Top+A
	 vusXVhL+lByNbNTgGJ6ko8HRSDRm761j7Ah4NX9jPf9qGCQrZUHQI4cLrOvtWjLKk4A==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792688123;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Gm-Message-State:X-Gm-Gg:X-Received:Received:From:To:Cc:Subject:
	 Date:Message-ID:X-Mailer:MIME-Version:Content-Transfer-Encoding;
	bh=8LJyz6yBSIBklzGHanr4CKCxTTmcJOljkuUOuqKS8wo=;
	b=xKeBVjBOYMyZymwfU62DUm99y4hTm3zutwFKM7jYDpn4cfB9oP9W641/7ab+HKF1kOgO
	 dx6RlEixPymQngIFrEL4ZYAzz+xI4lHbUjTo6v9b3diZ8EzSNj9aBqj3LrCbxqDmBUGyK
	 2I9jMfIJuvIBEJ374ngmENPpRWui9/cTfIFbpoJrpfspnp2MFpy9c2qelshmFYiCmQ2HU
	 vIXCXQcU3Y9QfpMnYTdMZwdpCmMfuqWfR3We6s1nZ5V6D3+zn1BK1ijQol+4m7w0ozIR1
	 DMPFXYawI9mleX/4/94271z/VOt1YC4EMpegiZYn+adDk85aeoGUhRQjO3NVfcB6zyA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20251104 header.b=M1I2IhDr;
	arc=none smtp.remote-ip=209.85.221.46
Received: from mail-wr1-f46.google.com (mail-wr1-f46.google.com [209.85.221.46])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A9884606A319
	for <linux-nfs@vger.kernel.org>; Thu, 22 Oct 2026 16:55:22 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org A9884606A319
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20251104 header.b=M1I2IhDr
Received: by mail-wr1-f46.google.com with SMTP id ffacd0b85a97d-48e09aa5264so1452416f8f.2
        for <linux-nfs@vger.kernel.org>; Thu, 22 Oct 2026 09:55:22 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1792688121; x=1793292921; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=8LJyz6yBSIBklzGHanr4CKCxTTmcJOljkuUOuqKS8wo=;
        b=M1I2IhDrsKTJapXkqe6qm0Z4n0MwTfMN/LV8FXMp8DsDIqqTUX0MifNncP/oR560jK
         iNuGN4iD+1qlhyhdZTTElQiKkyC20J+yeQdio6RKwvSnG885LPa6XLvOBx6TEOa0d7rw
         ixBAVOucTIddciNBl3UF43Luha/dxcpNcN998Rf4irbURdWGNWDaKlEW/du0dvhlnkBJ
         hABMByk0xDnn9VldRWelBZYhJHyW/7U6CNfYT1LYJoIGV7YsgRhIaDi8tBMEm6GwwDI2
         gODYXW+eP37XJiB0ttAlC3/pg4kcAENLaPql/lB9bINfZCE/NuP6EDSvxpmiUa0eNgad
         wEZw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1792688121; x=1793292921;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=8LJyz6yBSIBklzGHanr4CKCxTTmcJOljkuUOuqKS8wo=;
        b=s9+FfVwmjbH+FMqgEcQ6UkO8ia2zR4znUt+L15kR3fzUjRzBNHl0/LAf2kKyYy5X0H
         WRFXTJO4Q0I7KdAtVYwb8qVrU/2iry4H1RZZDw/Xo5VOB33Uo+qQSB6gL36KsxuZvMvx
         pJe0MEwAxTnK5jlGG2QbRx1RF3zCKq0Zpfx7/hPdP2MZu6iuS952V5+xG3CDHJgFCGsV
         NWVT+TJxliUgWYWM7MZG3SVV3dCEQqFcWF6F3RScvU2lUMZO+Bwpb/veNTau7BW3lti9
         Ef4+HbFHTq066vbFHQIafLhNn1RJCZPpPetIBTLoZLDeTTGPyBZRxNGgE4aR9sakT2kT
         hsWA==
X-Gm-Message-State: AFq9FYKoKc43vmb7cQU/UajdTcaGJIPSQIV6ShOm0gQojygSDhBFJME6
	WkxEiZv0+slnDoCpa90QJlh9xpTZPRRXbioPeSdjTYx/nVvtWivpjTxvVm4NAw==
X-Gm-Gg: AYBFou3SwL+A+zFsgPqjioWhGKvcDqhBRg/VZeFF+qEj1azGHlkmVbYHaKZnhN3tzHy
	JM8Eg5J9TCsiVRWHVWDd7hnnhI40+/BbpfdBynuxuNK9OuAJQ10zNiCLsCndEZdbuQL2amzYp50
	2mQywmxUX0ODzyg4gUIsYKosdbLLzidLiXmSeNAawZaKjUM6qskaLPVquy2UQCnQIiT8oJDkeCr
	fDyJVWfEolZK681Qv+iPyaPKpHj3zECOLll1wJwiwPYzCwSLt+AJJRuS65f+7NGkZdHhBHVDM6a
	B8W7XuOJy8EbLYxPCYYPjclQybuIAJ3kdX8l51+WWlthhVc8pOhXAI6Mb+Mqcn3l3zD5y0ngsjq
	mvNc+9ogdH3wQZVdWHW4UTBFAtb4pGbiPeTpTfFEx7awVwKzPNNJ3REsm3XZGfN1An2KLqgHlky
	Y5oi+yoPV9Gw+7UFq1hzzzk7qJIDIGHVqy07oWzjfzbpP43CJBYVe+XXIyJua+gw+vPjkMeT4PO
	zPCBmFdBEuWpZDO9H5ucM3mrMRE8eNPNZ0HHGEZgSmf1CPMdHd8A2U6YTRttis1pNZ7vytGWDog
	fDtOFtkSEBf/5mUNSAOTFz9LwA==
X-Received: by 2002:a5d:6e8b:0:b0:48a:f404:695e with SMTP id ffacd0b85a97d-48e2650e290mr8838164f8f.50.1792688120863;
        Thu, 22 Oct 2026 09:55:20 -0700 (PDT)
Received: from LAPTOP-AVI.taile24b5.ts.net ([147.234.101.15])
        by smtp.gmail.com with ESMTPSA id ffacd0b85a97d-48e25828cd1sm13263503f8f.22.2026.10.22.09.55.18
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 22 Oct 2026 09:55:20 -0700 (PDT)
From: Avi Weiss <thnkslprpt@gmail.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>
Subject: [PATCH] SUNRPC: preserve fatal network errors during RPC binding
Date: Thu, 22 Oct 2026 19:55:14 +0300
Message-ID: <20261022165514.73560-1-thnkslprpt@gmail.com>
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

call_bind_status() initializes status to -EIO. When an unbound
transport's port lookup fails with -ENETDOWN or -ENETUNREACH
and RPC_TASK_NETUNREACH_FATAL is set, the function exits the
switch without updating status. The RPC task then reports -EIO
instead of the network error.

This can occur during NFSv3 port discovery with nconnect,
when an additional transport has not yet bound.

Preserve task->tk_status in the fatal branch. Leave the nonfatal
retry handling unchanged.

Fixes: 9827144bfb2b ("NFS: Treat ENETUNREACH errors as fatal in containers")
Signed-off-by: Avi Weiss <thnkslprpt@gmail.com>
---
 net/sunrpc/clnt.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 6cedc824cf82..73f8469767d3 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -2125,8 +2125,10 @@ call_bind_status(struct rpc_task *task)
 		goto retry_timeout;
 	case -ENETDOWN:
 	case -ENETUNREACH:
-		if (task->tk_flags & RPC_TASK_NETUNREACH_FATAL)
+		if (task->tk_flags & RPC_TASK_NETUNREACH_FATAL) {
+			status = task->tk_status;
 			break;
+		}
 		fallthrough;
 	case -ECONNREFUSED:		/* connection problems */
 	case -ECONNRESET:

base-commit: 7be4bc52fd9e0e55dc9a2e0232b89427d2c4b614
-- 
2.43.0


Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.128.53
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793077014;
	b=eZIEa64F8d9AP9ZP4LrbocY4FBoglRe2Cg7SGUwmLDPEvrr1fomuq+5Nj3opGenveOko
	 QObg0+JHJU2SP2Y9jvWV8ZgOl6Au8L/sS4dOU5hKlcaVzJRcxY3frV1n3X4ORrK+AHbyY
	 VvNZVTAD1PVKRabogXhSDHiK4wchDegOPLQDe3ER0ONI4nBpHYJgtaLVNK1rY4shZXYSD
	 RB4RzfKx4jMgT0+01qod8+Is3zwTBLpLKba37wZx91/NtwCPNpYZ4oHv5xIbgwXYQLjmo
	 Yq9ptRCjxtIVcHLjaHA6zM2G9kRGjw5SM+qbwbehAs3t+U2O/dv/NP5YmcGu/VD7Pew==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793077014;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Gm-Message-State:X-Gm-Gg:X-Received:Received:From:To:Cc:Subject:
	 Date:Message-ID:X-Mailer:MIME-Version:Content-Transfer-Encoding;
	bh=59zSRTis3iLyP94ouJYCK6ld1drRJizj8+O7+Jg/FVQ=;
	b=Wql+3RzM2jQpngIpul4G99AOYS3fYmN9aoBW0xNl8qlJRQL9Xsao+lNFAI6MIdXBPUAk
	 xBQKDBnBEb0hQszRQjIvm7wmoyNhhLuFMc3HIlXW/2lIbjQ4ge9TZSHNefHIxjoMH9F7D
	 QmtPDor2JGeFRx3ceWqCQ5hB4p/Q7wERowKlXKAz6NZAABPHcUESNQm3oU6gCrz+vEGkf
	 nxaMkotGzAgicUcxqjruhipIyr6czo4f5qo2UdRYq8Ktqk0byH8N9UdA8YOEEs5dj3e+D
	 YylK7ZPJWRNsOwLSIuR2Mrk2w7U7S28EQrQli38rPVCSeL0EfMVK4FJBOmI5/kV9OtA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20251104 header.b=jeu6Iv9+;
	arc=none smtp.remote-ip=209.85.128.53
Received: from mail-wm1-f53.google.com (mail-wm1-f53.google.com [209.85.128.53])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7F89B606A31A
	for <linux-nfs@vger.kernel.org>; Tue, 27 Oct 2026 04:56:54 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 7F89B606A31A
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20251104 header.b=jeu6Iv9+
Received: by mail-wm1-f53.google.com with SMTP id 5b1f17b1804b1-4a35db1f202so19553525e9.3
        for <linux-nfs@vger.kernel.org>; Mon, 26 Oct 2026 21:56:54 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1793077013; x=1793681813; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=59zSRTis3iLyP94ouJYCK6ld1drRJizj8+O7+Jg/FVQ=;
        b=jeu6Iv9+YB9WucJPCGkfmaSPlzu/1qNrHNJjS6Ybk9D6ummiu/l83o6XFmoHNYwzzP
         DNlKTQ6CxBqF6ELOc//Wk6enxM8QUgImB/1HW6nUVO4CzAhPzXiW/kb5Fu5CTTIdbN9J
         QgrXNksxcZFT54NOyS2SmylfjpPC2C/Zed9dg7uZctffConN/rsavVPWVV8MkMpAP5vz
         t+c2ZyijhbNX8aClqJ+1jSIo90XEuTSzQdwNPZqMkwHtaVxzsgFAj6GUWFdNcu3ri52p
         PeGi9lBlapG8AWeokgr4xxNDgmWKj7nsqmeWTnX66SvFTEe73K7m2i60i7qmY8QfQ3dD
         k5RA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1793077013; x=1793681813;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=59zSRTis3iLyP94ouJYCK6ld1drRJizj8+O7+Jg/FVQ=;
        b=ewCVa9OUmhFrWdPAOBVQTA/1eSBoqNlCp8ISVqddd04k7AY9tsQjy+IQhGW71AATmo
         JMHuQnjQwAJGiRZ8tA1fjQKDBj8GgdNPAogbWEIRu0hceRxH49m4dHV7pEMvZzzHsfMq
         MUSXjByC5ssi2TygOMrVnpo3WO3vP652lJ8lym3cLcAQDdmR++h8cHrWC83O6QbP3KJ3
         A9aTqRT6kldH+gBMAOPlToojDyVeKK9IYWxH2OT/ezkiGsKgs7GgQBsalxJXHgJJkSwm
         3npZbDKnUqFKA3wNS6qclft3Ijl9I3Sfi9/dsIGSmCbMVoBA9Xo+hhdqKWVcDI0KtDll
         fDvA==
X-Gm-Message-State: AFq9FYJnZ/582ueyQuInwuSZv8GG5207N0jcflIJcMUoegZDpmzMRfnX
	i7CZ81PZ9SPzymOG2uBkChn2M0xhAh/kbK5FXKayoy1r5SLht5BMeBAF
X-Gm-Gg: AYBFou359UxAuotZVqdM7x2gyXilMOhpsBXwuXowtJ71Z3jUwiWnJwOlerB/QJg/xMY
	t6ud6lru/8RFz9GNgahOj9ZqpzBahtQ/ZAYghKVqHvV6WhJGvA6W/clkFydub6U3gpheExW/j6F
	i9KBvQLrz3UDk0pn6HQJsfKfyllT900xyKzuujXrSQK8Jk9maEd9fuDf+MMcuRpKNa+BcOwCHMZ
	ApevqP74pXstsYf4gRqtKiGXYVtiry8wFyAHzbYMfXaI6L1aawchyPpK2QdUnGzd0EvbZXRNvDo
	QIdaWj3+yhDhlVUiAJ93lbLJIy1VtG04CaFcmehmt+7uzXEk0fVCyeENXMtRlWuFEE9Hez5l+ko
	eeW3Cdq7SFobGSq5m4vpaauWWO7hmwMtPHGwbY5h1YGiNORzCxdGrMmddKTyLXowQePo7HJcdUX
	0H1mtlpX1gsT6I8tW2OH2KBP6G9SYtrA49zivCTn1IqsbcP1JODPzCQD7gIHsg/fvf41JPjPqg+
	eqFRoXXzIAI6BOrXapcnj26WE1X/qfTDsx4lf4ax2bUqz0+OP8Uco9ViKVs7Zg=
X-Received: by 2002:a05:600c:1c06:b0:4a1:e7ce:107b with SMTP id 5b1f17b1804b1-4a35ac407fdmr218773015e9.2.1793077012671;
        Mon, 26 Oct 2026 21:56:52 -0700 (PDT)
Received: from LAPTOP-AVI.lan ([2a06:c701:4778:c500:5658:786c:2fea:4768])
        by smtp.gmail.com with ESMTPSA id 5b1f17b1804b1-4a35a033702sm193880835e9.2.2026.10.26.21.56.49
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 26 Oct 2026 21:56:51 -0700 (PDT)
From: Avi Weiss <thnkslprpt@gmail.com>
To: trondmy@kernel.org,
	anna@kernel.org
Cc: linux-nfs@vger.kernel.org,
	Avi Weiss <thnkslprpt@gmail.com>
Subject: [PATCH] SUNRPC: Balance queue accounting when relocating a task
Date: Tue, 27 Oct 2026 06:56:43 +0200
Message-ID: <20261027045642.3810207-2-thnkslprpt@gmail.com>
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

When rpc_task_set_transport() relocates a movable task from an
offline transport, it releases the request and drops the
transport reference without decrementing the old transport's
queuelen or the switch's xps_queuelen. Releasing the task
later only accounts for the replacement transport.

The stale counts affect transport selection and can prevent
xprt_delete_locked() from removing an otherwise idle transport.

Use rpc_task_release_xprt() to balance the previous assignment
before selecting a replacement. Pass clnt explicitly because
rpc_task_set_client() can assign a transport before tk_client
is initialized.

Fixes: 82ee41b85cef ("SUNRPC don't resend a task on an offlined transport")
Signed-off-by: Avi Weiss <thnkslprpt@gmail.com>
---
 net/sunrpc/clnt.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 6cedc824cf82..7e5d1dcf2804 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -1194,7 +1194,7 @@ void rpc_task_set_transport(struct rpc_task *task, struct rpc_clnt *clnt)
 		      (task->tk_flags & RPC_TASK_MOVEABLE)))
 			return;
 		xprt_release(task);
-		xprt_put(task->tk_xprt);
+		rpc_task_release_xprt(clnt, task->tk_xprt);
 	}
 	if (task->tk_flags & RPC_TASK_NO_ROUND_ROBIN)
 		task->tk_xprt = rpc_task_get_first_xprt(clnt);

base-commit: 7be4bc52fd9e0e55dc9a2e0232b89427d2c4b614
-- 
2.43.0


Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.214.225
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795460905;
	b=mJxDPOEGxq0/9upc7c09x4Y0afhSdhDKmgyU1DNO1Zvhvh2ETEAeyClOwfIWFOQ6Vt2f
	 YqpB+0t9B3SShNHqQcdl3kw1dbJSmjT3ABO3WfiPXoU8uqhS+Gf9I1HiOSs4tQmrGYnZO
	 qzgC5cF9aeUqKv7HHwWxBNonR/XouYTIAYjCQe3fiSqxx3yRHdhYKwb2Mxkoii3UieWc+
	 WObhqdtCstuFqZPLsLerrJZ2a6RlVupI6oUTWxLQ159Se7tvxCy1Dtp/sVAOmEHgpQG+Q
	 E5ZgnG19Q2Wtb/OC8Sh2/2YN4xHyq+IlCCqxge2/KXnc+G9dyfleaM2Icc4CJi7n36w==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795460905;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:Received:
	 X-Relaying-Domain:Received:From:To:Cc:Subject:Date:Message-ID:
	 X-Mailer:MIME-Version:Content-Transfer-Encoding;
	bh=VYHxPFKmOwY5V9RAEDUHx1RPEhbWi3XhYNTJz3MSmaM=;
	b=uq8xv4Cda2ZYt182FG8DzN3d5qqVylEwioDCzA2y4vW1mDLg6mxZofIB4ujhq2WkWs4c
	 RcLewB6BWGhl8LXzjnjAy41MU9W5A6vXWO6cTMFPIJbsp5rNEuyji8YU50UEDK8IWs0sE
	 nOZOHLiUb5vG/+h/bc1FbXshFkRYl1HYal/AKhvMlxfy/9PZW5GXJaxdKUY8aOFDT3g+R
	 s3XRMuvT/vn9nAitb2GWgKKg+uKuFjyezn9sC2HVjNXNPcFHrkdiledb6rb0L+DdUxvI1
	 osDeUTqiu1JQb84lB7F2eHkEGvKTQJcrVtcsfX/6eI7ZbhMgPGWZ7vK6IVzpsqC6VLA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=everpuredata.com;
	spf=pass smtp.mailfrom=everpuredata.com;
	dkim=pass header.d=everpuredata.com header.i=@everpuredata.com header.a=rsa-sha256 header.s=google header.b=mpU6Bd1x;
	arc=none smtp.remote-ip=209.85.214.225
Received: from mail-pl1-f225.google.com (mail-pl1-f225.google.com [209.85.214.225])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A9E8E606A31E
	for <linux-nfs@vger.kernel.org>; Mon, 23 Nov 2026 19:08:24 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org A9E8E606A31E
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=everpuredata.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=everpuredata.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=everpuredata.com header.i=@everpuredata.com header.a=rsa-sha256 header.s=google header.b=mpU6Bd1x
Received: by mail-pl1-f225.google.com with SMTP id d9443c01a7336-2f066274caeso12958935ad.2
        for <linux-nfs@vger.kernel.org>; Mon, 23 Nov 2026 11:08:24 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=everpuredata.com; s=google; t=1795460904; x=1796065704; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=VYHxPFKmOwY5V9RAEDUHx1RPEhbWi3XhYNTJz3MSmaM=;
        b=mpU6Bd1xNO/ofpxU+xyxw8WSfk8MLDZhj0XbqMK8hHBAVUBDwF0nX6uXxvxG7wV6oC
         qykEDHArhBqXJwIus0GnOnxcdIlEsK4VBIEW8/3tBX3H4qjFbLYkcZIUkCYgCLOIVrno
         1nUf7v+Ik7u+sXiqljQ1dDirwey0Uf6FdwOMzqkjX0dLvdxm/2Uxu6SGIpx4Oi4Diqsi
         mUQ/aBpKO4FuEvoLtdY3lxyArZhqPh1g0dradBEJVVyHwOxCkhymjc7ReFB+1iBDWQbO
         QgkTg/APAQYuGdXSAfb9ryOQxCqSXmsK8XR0HHC3tXF1YMXCJ0G71f7nq57i1MWipCNN
         87Pw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1795460904; x=1796065704;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=VYHxPFKmOwY5V9RAEDUHx1RPEhbWi3XhYNTJz3MSmaM=;
        b=dk2RVFpIJAXf3xTs4eVjnYgf8unzt9dqjGr9OheqTajGKoH4UafNSfWxw3N418navY
         xxCcSBkdKhdP24XEpGgxc9JlVKtP8SkWv8czSqZe8upoaS6JCCe/mLUF1Rdy9bS+g3TV
         s9262VwKc+ha4Ws4NRrEn5CFSXvfyPgNLki5NvWzy6klZZ+wTNRjByPA4OoZimgr5Bcx
         7ZUQLG8uqja5jpsOYochO9Lsv7PaKay46HOQ+PLDll6onHCEsToN/0DNFPQQXCGNaixL
         DbUYaeQ1HyzV/uS5NGtI2uk9ic/vWeuOV/bfR1Z8RpZeuAXAEzjuPQRRfntwGey+jD/u
         omQQ==
X-Forwarded-Encrypted: i=1; AL+hErEQdVlDZ+k47XMbob5Kpl95J4uj8gDmX3M8fv4M766ggC5vgvLTS7ctiMPhRb2RDxNTjdgt1RPGcUk=@vger.kernel.org
X-Gm-Message-State: APuU4Z/k90GH1c/Abh+97qHMs5gDkrJRghUKC2PpZSf+diWXFluNxpt7
	2AT+G0hh760PSUv4aPBqFyH70lUmgbw4OiJyvokwxePm3b8K9REw3v9c673DzUpP6yrldJWu2KC
	gf4yG9P11ptphZCGo9bVTB0Ysh/c5Qn0A3txZ
X-Gm-Gg: AZFdTZdxaCPSd3lMzMBQwxhpcYfnIeyxD0GFV8CRayA8eHvCzfBSibSM4R4nS3Om+zr
	rwtDZdTgsRivlbgPJ12sQTbxaAvVZoUK73Wrr1uMK2YQuNSDKtvPUC60nhxqDucWYwiLgLk3Rlj
	ZAByl8nqxCsQeV2RlyOP8paUnbuOY5Eb6Cnh+z+mNMm0Q0waPYNmaI0sVf07lgdjFu4+Ftq0eS+
	HJjL/aTIVVMrC8e2acsapaurudDWGBm7y04aWxCTo6rIZbbk0vAgnKaaUGyhzEwiX8SL5YdONgP
	Je5Dwt6nuRFbp8xc4HMDa5BSjnxg3xyDrkE4pMLqd0hEwma3rxmGDhaKasUisrSnMV76i7Gcnf3
	LR+4oy4bNI7MRDxKeAZMK1FZc8TRJNC6MIOvem+A=
X-Received: by 2002:a17:90b:2c84:b0:3b3:c3b9:7de6 with SMTP id 98e67ed59e1d1-3b41c8fe20emr10529365a91.13.1795460903946;
        Mon, 23 Nov 2026 11:08:23 -0800 (PST)
Received: from c14-smtp-2023.dev.purestorage.com ([208.88.158.128])
        by smtp-relay.gmail.com with ESMTPS id 98e67ed59e1d1-3b41d245549sm4735121a91.2.2026.11.23.11.08.23
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 23 Nov 2026 11:08:23 -0800 (PST)
X-Relaying-Domain: everpuredata.com
Received: from irdv-tmenninger.dev.purestorage.com (irdv-tmenninger.dev.purestorage.com [10.32.149.15])
	by c14-smtp-2023.dev.purestorage.com (Postfix) with ESMTPS id 32D0E34015E;
	Mon, 23 Nov 2026 11:08:23 -0800 (PST)
From: Tim Menninger <tmenninger@everpuredata.com>
To: cel@kernel.org,
	anna@kernel.org,
	trondmy@kernel.org
Cc: ebadger@everpuredata.com,
	jcurley@everpuredata.com,
	linux-nfs@vger.kernel.org,
	slingappa@everpuredata.com,
	stable@vger.kernel.org
Subject: [PATCH v2] xprtrdma: Retire the connection generation when a connect attempt fails
Date: Mon, 23 Nov 2026 19:08:23 +0000
Message-ID: <20261123190823.1680365-1-tmenninger@everpuredata.com>
X-Mailer: git-send-email 2.53.0
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

When a connect attempt fails, xprt_rdma_connect_worker() wakes the tasks
waiting on the transport with the connect error. For errors such as
-ECONNREFUSED, call_connect_status() can then call
xprt_conditional_disconnect() with the task's rq_connect_cookie, which
was copied from xprt->connect_cookie when the task started waiting for
the connection.

The failure path tears down the endpoint through
rpcrdma_xprt_disconnect() without advancing connect_cookie, so that
cookie still matches and the conditional disconnect requests an
autoclose. If another task has already started the next connect attempt,
that attempt holds XPRT_LOCKED and the close request sets XPRT_CLOSE_WAIT.
When the attempt succeeds and releases the lock, the pending autoclose
tears down the newly established connection.

This was observed on 7.4-rc3 after restarting the NFS service on a pNFS
data server reached over RDMA. Connect attempts made while the server
was not yet listening were rejected, and the first connections that then
succeeded were closed within a millisecond of being established.

Advance connect_cookie once per connect attempt, whether it succeeds or
fails, before waking its waiters, so that their conditional disconnects
no longer match.

Also wake pending tasks before releasing the connect lock. Otherwise, a
task can capture the updated cookie and join the pending queue for the
next attempt before the previous attempt's error is delivered.

Fixes: f99fa50880f5 ("SUNRPC/xprtrdma: Fix reconnection locking")
Cc: stable@vger.kernel.org
Reviewed-by: Chuck Lever <cel@kernel.org>
Signed-off-by: Tim Menninger <tmenninger@everpuredata.com>
---
Changes in v2:
- Advance connect_cookie in one place, just after
  xprt_clear_connecting(), for every connect attempt (Chuck)
- Add a comment explaining why pending tasks are woken before the
  connect lock is released (Chuck)
- Update the commit message to match

v1: https://lore.kernel.org/all/20261120010342.2152535-1-tmenninger@everpuredata.com

 net/sunrpc/xprtrdma/transport.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
index e38637c2ec787..d27de0ad6732b 100644
--- a/net/sunrpc/xprtrdma/transport.c
+++ b/net/sunrpc/xprtrdma/transport.c
@@ -232,8 +232,8 @@ xprt_rdma_connect_worker(struct work_struct *work)
 		current->flags |= PF_MEMALLOC;
 	rc = rpcrdma_xprt_connect(r_xprt);
 	xprt_clear_connecting(xprt);
+	xprt->connect_cookie++;
 	if (!rc) {
-		xprt->connect_cookie++;
 		xprt->stat.connect_count++;
 		xprt->stat.connect_time += (long)jiffies -
 					   xprt->stat.connect_start;
@@ -241,8 +241,11 @@ xprt_rdma_connect_worker(struct work_struct *work)
 		rc = -EAGAIN;
 	} else
 		rpcrdma_xprt_disconnect(r_xprt);
-	xprt_unlock_connect(xprt, r_xprt);
+	/* Wake waiters before unlocking, so that a task which records the
+	 * new connect_cookie cannot receive this attempt's result.
+	 */
 	xprt_wake_pending_tasks(xprt, rc);
+	xprt_unlock_connect(xprt, r_xprt);
 	current_restore_flags(pflags, PF_MEMALLOC);
 }
 

base-commit: aebb7274476403040d582c61478df8f4a7bf9cd3
-- 
2.53.0


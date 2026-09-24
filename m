Received: from mail-oi1-f226.google.com (mail-oi1-f226.google.com [209.85.167.226])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 06E164B126A
	for <linux-nfs@vger.kernel.org>; Thu, 24 Sep 2026 20:35:14 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.167.226
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790282121; cv=none; b=Zl+9+w/EmgP3AAIxuUIKvBhyIkzvDLXZmdB0VKB+Vtl3KD2lYQ0wSUq1m9uwC/HQS31F76XKkZ6PoMWrHk2zG1Wwg6HlyjtyvXl/muTnCFpqoNrAZnX6Zu/tj+rVVEdp/0oTaCbwTufJUjLjYBqKdIBp1k5uvoYoVX1x2RawxyE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790282121; c=relaxed/simple;
	bh=he8h19blVEKXmFgd5AjOMguu+c4odRF3eMcDKFO8pqQ=;
	h=From:To:Cc:Subject:Date:Message-Id:MIME-Version; b=MlmxfNHkmTH6h00RWzy/eHH9moRsi0Vkw9LLXmFEE5zX4WSHHwJx9PvUTqCGMWKkP7MMWVcjG27dzktTE//WRl7670Riqw6awG2s5UzXIbSy7ODthvsq8OWT5zn/cSnvp+4Y7l1tHEW+fMSbkoZF23y2CrDlRCeH3eyv9qSB2Ig=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=everpuredata.com; spf=pass smtp.mailfrom=everpuredata.com; dkim=pass (2048-bit key) header.d=everpuredata.com header.i=@everpuredata.com header.b=PdSfBD2T; arc=none smtp.client-ip=209.85.167.226
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=everpuredata.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=everpuredata.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=everpuredata.com header.i=@everpuredata.com header.b="PdSfBD2T"
Received: by mail-oi1-f226.google.com with SMTP id 5614622812f47-4b1fcd3b1a9so26966b6e.0
        for <linux-nfs@vger.kernel.org>; Thu, 24 Sep 2026 13:35:13 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=everpuredata.com; s=google; t=1790282111; x=1790886911; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=MjyFqQ40ZwRfzwYJsmnvVXLveHQtD8lJFjX8AzpEmB8=;
        b=PdSfBD2T2XXPxw0vtp8PdyhzeMepR36GlC6ejNY2+81nzoiMXNq/pRUotOHgEWHkbf
         NGkuHU90bBFCJTv0AHHv9f57pF9fEKyTlbmjmDQSYhMiTOBFEOz9KIdLJ+2n9zlYsv+v
         qaxMt7KpR5PpeqTEj/4uD/IVpnQhuZZx0RfAszN8gyId8+C+hqtnHcRULcm6z7clmRkh
         De4gBWyru98P56KSRGdrOP+6k4FkhyLfJfD35MNoB9Tu6ENu7ifcXmPjxcluVrgZSwI8
         FKVMp1J6AK2QDypJxUgT1sCONd8j4yYDbKLMBr2WNuJwWUv9Ggy0j1kUyZ/dhYzvvfl4
         X/5g==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1790282111; x=1790886911;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=MjyFqQ40ZwRfzwYJsmnvVXLveHQtD8lJFjX8AzpEmB8=;
        b=JOnkeo9ym8CSJAO4JjrXqKppugWbaYSaHdLwbKHIL7PSGIHrZBIxKKfXLBowor9SQj
         n8TSGdAzkgDPwZkUCgCg2d8+4nJvqA7ih+LckKldTDP0EYDBwPs0RKv/JgQsj3EYc9uZ
         OtIzx9hlOkKHMX+DHg71+JPPey/azxFsP2vO6+Z4VhyohTFxGuek4A7znG/M1nyeL4Lf
         kKJICq+7fRHE712uDVd/74nexwvgZke3cUJ6U6oqJTqDMG103uaLFERz7QMxOKKKoK1+
         noUH4O9uIpOvfFzq/Su+swNotgXtMRB02R2FQ5oEHwMfV+SahWXbHpiqgeTDD3gURD+Q
         9Zbw==
X-Gm-Message-State: AFuF++lQxQ6D0KpHhwIoqHj0cC9kDtca9ZkWsvKycxEdDazre1Cpgszf
	tQOe6sq9MmJre66Xby/G8HaEYCZXSxBgyGv+Qlta/+GRpYlxwGTudvdZeTBjvQprK73mz+AlKC+
	kceUCUQ5Sx/ibDuDFMGc4E9vU/cwHRlpwNfqm
X-Gm-Gg: AYBFou0QA1CHVbyGpIpAxo5sVljrFqnDEaY2tIvNV+fmq3jc92kn5QAJt8Mci3gRuND
	ntqtjNDURV/7jT4ufLqqebM14/JcDqhkKG5f3m7ZWnD9DQ2qs639QgA67Qsx4tbCymqig2W1kY0
	eYXhPgA19zRJNSGAYlVOymb+Gy1xZ0nEDVXgyNlQLf9iUKmrBJcoH7tlhmC+k7doqzRpBdulWl3
	R3MF3Y/ZI9kb/rq0MxmEUc40lJG03VclPQ70FM4o8w0I82KuQ+hLKB4JGidcrgLT7NnyZVIvOmV
	u6W1X/nF9yWjPSvRZN/wgD4Jhf26GjXHiMHeOTqp+lLCDbtNpswHSa1f244cCMiTCxCgCB8kFNa
	aPBYIjn0SQEOFzY3Y6vFk7uv9qfgc/bQQPyv0k2c=
X-Received: by 2002:a05:6808:178a:b0:4b9:e5fa:8a17 with SMTP id 5614622812f47-4d72912226dmr4663704b6e.28.1790282111383;
        Thu, 24 Sep 2026 13:35:11 -0700 (PDT)
Received: from c14-smtp-2023.dev.purestorage.com ([208.88.158.129])
        by smtp-relay.gmail.com with ESMTPS id 586e51a60fabf-493331e4187sm49196fac.2.2026.09.24.13.35.11
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 24 Sep 2026 13:35:11 -0700 (PDT)
X-Relaying-Domain: everpuredata.com
Received: from irdv-tmenninger.dev.purestorage.com (irdv-tmenninger.dev.purestorage.com [10.32.149.15])
	by c14-smtp-2023.dev.purestorage.com (Postfix) with ESMTPS id 6E12C3403DA;
	Thu, 24 Sep 2026 13:34:40 -0700 (PDT)
From: Tim Menninger <tmenninger@everpuredata.com>
To: Chuck Lever <cel@kernel.org>,
	Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	Jeff Layton <jlayton@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	Eric Badger <ebadger@everpuredata.com>,
	Jon Curley <jcurley@everpuredata.com>,
	Shiva Lingappa <slingappa@everpuredata.com>,
	stable@vger.kernel.org
Subject: [PATCH] xprtrdma: prevent disconnect feedback during endpoint teardown
Date: Thu, 24 Sep 2026 20:34:40 +0000
Message-Id: <20260924203440.3374889-1-tmenninger@everpuredata.com>
X-Mailer: git-send-email 2.34.1
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

xprt_autoclose() clears XPRT_CLOSE_WAIT before invoking the transport's
->close() operation. For RPC/RDMA, ->close() calls
rpcrdma_xprt_disconnect(), which disconnects the RDMA CM endpoint and
drains its QP.

Since commit 31e62d25b5b8 ("xprtrdma: Simplify RPC wake-ups on
connect"), RDMA_CM_EVENT_DISCONNECTED requests a SUNRPC transport
disconnect. Today that path, along with failed completion handling,
reaches xprt_force_disconnect() through rpcrdma_force_disconnect().

Commit c487eb7d8e41 ("xprtrdma: Clean up disconnect") later added
re_force_disconnect to ensure that multiple failure indications request
only one SUNRPC disconnect. However, the gate remains open when SUNRPC
itself begins endpoint teardown.

If re_force_disconnect is still clear, either a CM disconnect event or a
completion error can set XPRT_CLOSE_WAIT again while the current close
is in progress. When the transport send lock is subsequently released,
xprt_clear_locked() observes XPRT_CLOSE_WAIT and queues another
autoclose.

Requesting a disconnect this way is necessary when a connection is lost
unexpectedly, but not when the event was generated by
rpcrdma_xprt_disconnect() itself. In that case SUNRPC is already
committed to closing the transport.

Mark re_force_disconnect before initiating local endpoint teardown so
that CM events and completion errors caused by that teardown cannot
request another close. An unexpected error that wins the race before
local endpoint teardown begins can still request a disconnect normally.

Use a fully ordered exchange so that the gate is globally closed before
rdma_disconnect() can transition the QP to error and generate the
callbacks that the gate suppresses.

In 30-second traces of a sustained recovery loop, without this change
there were 7,693 xprt_force_disconnect() calls, 6,267 SUNRPC autocloses,
and 172,892 receive-side IB_WC_WR_FLUSH_ERR completions. With this
change, the same tracepoints recorded 3,512 xprt_force_disconnect()
calls, 3,212 autocloses, and 131,287 receive-side flush completions.
Thus QP teardown continues to produce flushed completions, but closing
the disconnect gate before teardown substantially reduces their
feedback into the SUNRPC close path.

Fixes: 31e62d25b5b8 ("xprtrdma: Simplify RPC wake-ups on connect")
Cc: stable@vger.kernel.org
Signed-off-by: Tim Menninger <tmenninger@everpuredata.com>
---
 net/sunrpc/xprtrdma/verbs.c | 9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index be335eed329d..54957295a631 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -114,9 +114,9 @@ static void rpcrdma_xprt_drain(struct rpcrdma_xprt *r_xprt)
 	rpcrdma_ep_put(ep);
 }
 
-/* Ensure xprt_force_disconnect() is invoked exactly once when a
- * connection is closed or lost. (The important thing is it needs
- * to be invoked "at least" once).
+/* Ensure xprt_force_disconnect() is invoked at most once for an
+ * unexpected endpoint failure. Local endpoint teardown closes this
+ * gate before it can generate CM events and flushed completions.
  */
 void rpcrdma_force_disconnect(struct rpcrdma_ep *ep)
 {
@@ -587,6 +587,9 @@ void rpcrdma_xprt_disconnect(struct rpcrdma_xprt *r_xprt)
 	if (!ep)
 		return;
 
+	/* Prevent teardown-generated events from requesting another close. */
+	atomic_xchg(&ep->re_force_disconnect, 1);
+
 	id = ep->re_id;
 	rc = rdma_disconnect(id);
 	trace_xprtrdma_disconnect(r_xprt, rc);
-- 
2.34.1


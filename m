Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.215.227
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793844202;
	b=wcmZSDYaQcR7NgLmGKfP+w4FAe3SAMt6mIgsQ/pLRvcZNpUjt0zsxEjlmHPRj3BTvcEX
	 6QfIY6i/BImehrNXeGJV3cqK48iPSS79VVtgzHpz03jZmsQslk966RALL8nEsr3IqQgWZ
	 HoNgaitnhP82jzfkDsHqyvJiWS0SDqZCBef47UwHRgyu9kOOV6g75PL7V+6yIfD9iirhW
	 g5wcVJxLPxzSIT3+Ty/5kQVl0MWzXnGKVRHIRtXGoPW8ueMrpRb4V2/iW+gxVIgOEIsWp
	 SDXXeWq84PfadimMBK3yA6GByG0kFIpQL1ahNYa6aeoXxD04iUFqMUwNq+x3dIkY94A==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793844202;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:Received:
	 X-Relaying-Domain:Received:From:To:Cc:Subject:Date:Message-ID:
	 X-Mailer:MIME-Version:Content-Transfer-Encoding;
	bh=EQfIAOrQJdusvyYnUH0bVt07oZDCi/o3NqYD4NHITMs=;
	b=d/BnRkBYaMi6stTdrRcFiBKfy7QZUMOKmBqKUSg+7zdHj3iswXxP87lyljW2RxtyxPPU
	 OHf0pfovds8Ic6xd6NZ+pP0clxACB3JSJT3We6gFVQgBMQDPbCKqZ+NR7yhZn4HwjbzWC
	 92bjyvAohegiZoHQMoCAynker63YKhNIRknWGAzowazuFpe0VIkUlcjTzM+h40kaGmMJm
	 eGTwQe5jpoz8A8UtvClG6GDuNm/liui+gDI1d52fBX72sSoeY6w4HMkqBdpXGRYBCZjB7
	 IcolD8PUDBjcvrihCR9tDWMZqqh7APXWXLkI6os0UduEZw8BIvPbupJKUe0ZHqmnWYg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=purestorage.com;
	spf=pass smtp.mailfrom=purestorage.com;
	dkim=pass header.d=purestorage.com header.i=@purestorage.com header.a=rsa-sha256 header.s=google2022 header.b=GkW1ZmRS;
	arc=none smtp.remote-ip=209.85.215.227
Received: from mail-pg1-f227.google.com (mail-pg1-f227.google.com [209.85.215.227])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4A9DE606A337
	for <linux-nfs@vger.kernel.org>; Thu,  5 Nov 2026 02:03:21 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 4A9DE606A337
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=purestorage.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=purestorage.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=purestorage.com header.i=@purestorage.com header.a=rsa-sha256 header.s=google2022 header.b=GkW1ZmRS
Received: by mail-pg1-f227.google.com with SMTP id 41be03b00d2f7-cdab8873d9dso580256a12.1
        for <linux-nfs@vger.kernel.org>; Wed, 04 Nov 2026 18:03:21 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=purestorage.com; s=google2022; t=1793844201; x=1794449001; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=EQfIAOrQJdusvyYnUH0bVt07oZDCi/o3NqYD4NHITMs=;
        b=GkW1ZmRSpSFfkokdZSUjXrT1WnzmH4jmdbE5YxNIOWGzejsxgAzJ+QcbgMaYBr/TcY
         y/9DTwSGT2OAqkiPA9DO3xjoeDMNWq/cglIDmENrAsciQv2pHOjPeTvYheYhniVp8Vws
         0jTFpd5+218Tf2l9uj9L4a3jJ+AT69WnxcI5nshMC0GZjbQ3flZrbHoukEUHFZ5lX7na
         tQj0YP0umvFSqQKkqgLRYSXR2lnXTHCFzGEi07kLXxEOUM4wceSpGSKGerical0TWjqa
         eQAus6mWnUAJZ455DpUBGUPG/pnAKEcoRdKZ4TvNUZhMDcdHJNF8jUZ7zEdfv9zTa0Bz
         bOTQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1793844201; x=1794449001;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=EQfIAOrQJdusvyYnUH0bVt07oZDCi/o3NqYD4NHITMs=;
        b=iIR33V4ZRqF9b8+i7RcXCqmHYKSysIE7QuThh4s+AipYNHwJI2DKy7NNXb+gaop2LK
         4Q9eGX3wI4k5BESIrzwrBLSWag3kJiD8hg9T8FFhflvhVtpHjpKtdJamxFvaUWtyuabA
         WLXBEXwYx7R54kvRoNlgbj1bUuFGfjQrEd5/0prSqPk/soWwUkBdjs4XuFFDhAR+pFou
         MaCuubS72imV5iaITZDHk6fJ35dlES5ybcEJyn2fsAcl2Ep37q4529k1blT1+r1JfmNf
         VE2bMvXvNL5NXBQ1FPADVl6b8shLFDtv5yWHCMq9q1w4ZYhr89Ynhw9os1RToyPwy2Uf
         yFxg==
X-Forwarded-Encrypted: i=1; AKwUvBzCfHhAJreacvYFjDsq91s2yPQP8/fB3zM7WbL4DWS91sxNpFZARk2DPAjoqfNdJgf+YMBihDO+98I=@vger.kernel.org
X-Gm-Message-State: APuU4Z+xy9N1Gb+Po3E6r8yy7AXxLJfPbgG0cpErDMqcohGBs0W/CqiM
	cYpH2JcfZeH5ByEN/0McXeRT9AjLaGAdg+DI6Bsqtv3xOQKXjiBLpMEAe4R+2edRlKF5Y03X5Ya
	c6ufS7fNZaCmXCcVGtoqDN1JGTN9ygQD5fSwE
X-Gm-Gg: AYBFou05SCShIraZP1CmV4fm4sh+7x3zAXDHnFYzqaaG9U05rOaZDilkSNik5zdHTW2
	dk4gzIj0vWVxNYsPartk6qfMCjsf4bMKYsTvDj1SBd/nlbDFSqiF15xCnUyCbRh01Y5LTKgI/Eo
	QWE9NnAA034LnJFRASnyNWJC8y2Bq9OZcezqJo42BfdMUN9esbL0pWME0KC9Kq5+NwTFgGGPOiu
	vXG4g7daBGjUveQhP1eAg2J35s9OJ8uPuvRCBQX3hWIhXYPhA0HrdVnrRC/C4VGZZlQX39oGeQ4
	p/5+CBY7vfQpt/T9LIwezDs+LT6tGzOTFdkPKaq5gSAcVT6+8TrJ2EUy7bRgr913/q8mM3Vd2w/
	tT7Z4t70N592V7RpuYO9tfvSA/bsPWTO9UiIqzg==
X-Received: by 2002:a17:90b:2d84:b0:3b0:9a1b:b708 with SMTP id 98e67ed59e1d1-3b09a1bb881mr3168053a91.62.1793844200546;
        Wed, 04 Nov 2026 18:03:20 -0800 (PST)
Received: from c14-smtp-2023.dev.purestorage.com ([208.88.158.128])
        by smtp-relay.gmail.com with ESMTPS id 98e67ed59e1d1-3b0b31f880fsm824975a91.7.2026.11.04.18.03.20
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 04 Nov 2026 18:03:20 -0800 (PST)
X-Relaying-Domain: purestorage.com
Received: from irdv-tmenninger.dev.purestorage.com (irdv-tmenninger.dev.purestorage.com [10.32.149.15])
	by c14-smtp-2023.dev.purestorage.com (Postfix) with ESMTPS id 943B534014E;
	Wed,  4 Nov 2026 18:02:49 -0800 (PST)
From: tmenninger@purestorage.com
To: anna@kernel.org,
	trondmy@kernel.org
Cc: cel@kernel.org,
	ebadger@everpuredata.com,
	jcurley@everpuredata.com,
	jlayton@kernel.org,
	linux-kernel@vger.kernel.org,
	linux-nfs@vger.kernel.org,
	netdev@vger.kernel.org,
	slingappa@everpuredata.com,
	Tim Menninger <tmenninger@everpuredata.com>
Subject: [PATCH v2 0/2] SUNRPC/NFS: limit transport disconnects when cancelling flexfiles I/O
Date: Thu,  5 Nov 2026 02:02:47 +0000
Message-ID: <20261105020249.2607367-1-tmenninger@purestorage.com>
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

From: Tim Menninger <tmenninger@everpuredata.com>

This series narrows the transport disconnects performed when flexfiles
cancels I/O for a recalled or revoked layout segment.

Today ff_layout_cancel_io() first cancels matching RPC tasks and then
calls rpc_clnt_disconnect() if any tasks matched. rpc_clnt_disconnect()
operates on the entire rpc_clnt, so for a data server client using
multiple transports it disconnects transports that may have had no I/O
associated with the affected layout segment.

I encountered this while testing pNFS over RPC/RDMA during data server
recovery. Restarting the NFS service on a data server while sustained
direct-read I/O was active could cause repeated reconnect activity and a
large throughput drop. The client-wide disconnect from
ff_layout_cancel_io() amplified the disruption by tearing down otherwise
unaffected transports.

The first patch adds a SUNRPC helper that combines task cancellation with
request-scoped conditional disconnects. Matching tasks are cancelled as
before. A subsequent transport-queue pass marks matching requests
belonging to the same rpc_clnt that remain on the transmit or receive
queues so that, when released, xprt_conditional_disconnect() is called
using the request's saved connection cookie.

The disconnect state is stored on struct rpc_rqst rather than struct
rpc_task. A task can release one request and later acquire another, so a
task-scoped indication could otherwise be consumed by a successor
request and applied to the wrong transport generation.

The request-marking pass also preserves the rpc_clnt selection used by
rpc_cancel_tasks(). An rpc_xprt may be shared by multiple rpc_clnt
instances, so requests belonging to other clients sharing the same
transport are not marked.

The second patch switches flexfiles to the new helper, preserving its
I/O cancellation behavior while avoiding client-wide transport
disconnects.

Testing:

The code in this series does not depend on:

    https://lore.kernel.org/all/20261105000131.2512336-1-tmenninger@everpuredata.com/

However, I used that change while collecting the results below because,
without it, the client enters the earlier recovery livelock before the
transport-disconnect behavior can be observed cleanly.

As a control experiment, I also tested skipping the
ff_layout_cancel_io() task-cancellation and client-disconnect path
entirely for RPC/RDMA. Doing so eliminates the reconnect pathology. This
shows that the pathology depends on the cancellation/disconnect path
introduced by commit b739a5bd9d9f ("NFSv4/flexfiles: Cancel I/O if the
layout is recalled or revoked"), but simply opting RPC/RDMA out of that
behavior would also remove the cancellation that is intended to drain
I/O associated with a recalled or revoked layout segment.

This series instead preserves that cancellation while limiting transport
disconnects to matching requests that remain in flight.

I have repeated the data-server restart test many times and the behavior
is consistent. The counters below are intentionally collected after the
restart event, once throughput has partially recovered and the client has
entered the post-recovery state in which it remains until the workload
completes.

This distinction matters because some transport activity during the
data-server restart itself is expected. The problem addressed here is
the continued reconnect activity after that transition has completed:
once recovery has settled, the client should not continue cycling
otherwise healthy RPC/RDMA connections.

Over a 30-second post-recovery sampling window, this series reduces
sunrpc events from 4,526 to 289, a roughly
16-fold reduction. RPC/RDMA disconnect and connect events fall by about
6.6-fold. During the same interval, read throughput improves from
approximately 0.4-1.1 GB/s to 1.9-2.2 GB/s.

Before (throughput: approximately 0.4-1.1 GB/s):

    Performance counter stats for 'system wide':

                 4,526      sunrpc:xprt_disconnect_force
                 1,911      rpcrdma:xprtrdma_disconnect
                 1,909      rpcrdma:xprtrdma_connect

          30.021267692 seconds time elapsed

After (throughput: approximately 1.9-2.2 GB/s):

    Performance counter stats for 'system wide':

                   289      sunrpc:xprt_disconnect_force
                   289      rpcrdma:xprtrdma_disconnect
                   291      rpcrdma:xprtrdma_connect

          30.080790959 seconds time elapsed

---
Changes in v2:
- Rebase onto v7.4-rc1.
- Adapt to the device-ID-aware ff_layout_cancel_io() interface,
  preserving device-node reference cleanup.
- No functional changes to the SUNRPC implementation.

v1: https://lore.kernel.org/all/20260924204525.3381590-1-tmenninger@everpuredata.com/

Tim Menninger (2):
  SUNRPC: add request-scoped disconnects when cancelling tasks
  NFSv4/flexfiles: limit transport disconnects when cancelling I/O

 fs/nfs/flexfilelayout/flexfilelayout.c |  7 +-
 include/linux/sunrpc/sched.h           |  4 ++
 include/linux/sunrpc/xprt.h            |  5 ++
 net/sunrpc/clnt.c                      | 94 +++++++++++++++++++++-----
 net/sunrpc/sunrpc.h                    |  5 ++
 net/sunrpc/xprt.c                      | 76 +++++++++++++++++++++
 6 files changed, 170 insertions(+), 21 deletions(-)

-- 
2.53.0


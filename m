Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.128.103
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793848034;
	b=nc4B0RmtH01jTLscS1Zto4Af/nH8vQuZm0yZaS7qDTLyWPjKvqHOMNExyo7ebsRcUwDG
	 Am+ONm5vG/LS7wH/+arlaLFEgMIMDdOVAXDj93Ny3ix56TVOuEULhLCHPlkN8p9faB25t
	 HMJlZKKjNzFvT4/VEVKUwRQdgmQ9b6NcWIaAIiPIueemqZYvJPwq8VjBRCfxFAkmWDEwJ
	 6HhNjcOVL6gMObO9tQjM8Ayxx818WANfWNehsGVkTXT1Mj8Iu3CJUZSSq0fh2m2fuwYn9
	 Gi20O97h3LBt6LfD0pIdOFjAoSupK3hFtz1kGRu/lUeZ6rSM1h5X2+DVbxQSOYuHF6g==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793848034;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:Received:
	 X-Relaying-Domain:Received:From:To:Cc:Subject:Date:Message-ID:
	 X-Mailer:MIME-Version:Content-Transfer-Encoding;
	bh=5gHM2b/r5UdddtGztOAveat2VzMHH0Xvqre8s1JTorQ=;
	b=SalC9nkqFK3SfsPugUa5PHRWoiegA3nJGHTMqs9R3Aolj0M3wH1kYLODZp7OB8VUYMRs
	 WoH/aRJRmYOSbVn4kTM98gjSMJkEa21MDv/oqb+hG7ZfXKte1Jwa4ZJIA/Hy35Ao6AL+k
	 eTvLuauhKwOIXKkmbEWJYw+/8RVU1KZ8uwlyIWVPTilJ5ZA+coUGOih1aA9hEik3EQ8Cm
	 l12NSM/0m5IrXQqS51zDXYDb/lzX5B2Rd3fjQpp4USs72+dtYbmJfYqiOFDfxKL8mn72c
	 a5B8ws/buVaQUiLcpb3k2kfLX6CXH/D4lCtUZGoZJrOOxcwaV808dhThwPUj/nRFyJg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=everpuredata.com;
	spf=pass smtp.mailfrom=everpuredata.com;
	dkim=pass header.d=everpuredata.com header.i=@everpuredata.com header.a=rsa-sha256 header.s=google header.b=TXeOGWTx;
	arc=none smtp.remote-ip=209.85.128.103
Received: from mail-wm1-f103.google.com (mail-wm1-f103.google.com [209.85.128.103])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 32FFD606A328
	for <linux-nfs@vger.kernel.org>; Thu,  5 Nov 2026 03:07:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 32FFD606A328
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=everpuredata.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=everpuredata.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=everpuredata.com header.i=@everpuredata.com header.a=rsa-sha256 header.s=google header.b=TXeOGWTx
Received: by mail-wm1-f103.google.com with SMTP id 5b1f17b1804b1-4a5177d78c7so12130965e9.2
        for <linux-nfs@vger.kernel.org>; Wed, 04 Nov 2026 19:07:13 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=everpuredata.com; s=google; t=1793848031; x=1794452831; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=5gHM2b/r5UdddtGztOAveat2VzMHH0Xvqre8s1JTorQ=;
        b=TXeOGWTxyKrUAG5UlVaLWM8MTJ5y878zTZp2B4GhP6fv/ziq9FI5Vgu4kCEk03e/WY
         B5OPaX3fTw4BYizuycDAZyBqE6lEDA+ij60PYy5wuZG3c9AbJ+crNPr2bxemacY/Aww+
         Mxj5+vOHmkc1x2vhyAEOm8xd4MlZSBfZCS2BX1Lvb5DsydmXCTBWy642XOlijXrYhpn3
         G6iWGrU+SDZ8B4VcQXZkPenyFcc0zvIVok+4W/tto7HTMX4z39ABA6vpMdxh/MlETtSq
         4MFlb8b6FW3+szipeM0krIx9dfh5Gry/MUSxNn8F82kZFt6LBqFS7QKCPfTlvvHpaKBQ
         ZIAQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1793848031; x=1794452831;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=5gHM2b/r5UdddtGztOAveat2VzMHH0Xvqre8s1JTorQ=;
        b=VJbE6xQCm84AIBbxiZireJsMuY7z8v/SzfyfEc03kzsTKzohqZ4xefMO9rnvE3maOh
         by1xjLLTWKUsWFBnqoJuQiQXTVOHA0tVqjPmTZ/zR6t1ijSOdnVUh59CrHX1LlGYFn+0
         73QP1giCtNzOKGWy0PK/Vw36t4K4wrNaV3fTEN94POwh7xTwdKFxUn3WnLcuN9YtdJoe
         06CGmLsLbPfCH5dgRPRqBYb7hGcFhGGMd90JIofFeYIaY1LBLfu0FuigEWS74vXGURX2
         +uPCw7vg0Qf7P5DPOcrvqAcETBo1ggbta0yFjvbRhvPpgcWOihnTzrHxcaHJobe1UJMu
         /Qnw==
X-Forwarded-Encrypted: i=1; AKwUvBzkzJkSJvsf3m+bPmW732L506lgZKwSefHxd61jUDubtWqazzUCekxF1ym+rs9pDj3w7J0F/sE9HJ0=@vger.kernel.org
X-Gm-Message-State: APuU4Z+s7xB6NcD0IwBARyhtanGSvPWH2VqawS+6Mji3O/s5X7S4UEhP
	MjyEjwUPLcB8meTjYqLo/4E5ihC3FrnMHXexHYLH0PJZwfB9HyT9cqAnwFX44Fkd3lgpWxHeXNB
	/bfnacgDiogxHfoZ5M6Y5e/kBm2HAKR6Fmkcu
X-Gm-Gg: AYBFou2THI2LOBy667Po2xqoYD0tYOz9/vXmUyjc0S8B2p7WXYQjN6RgCrnRmCXYAIP
	SooghdjAR+0eQ0cGEbo6k392VyLWr52dSN+lnBlpy+mbRjOcuqcXOKmw706klfuKnGv2TXKM/i5
	6OBYcz3FIihih2Xzd5QVvw//X6V10mKALI1xEvDGmpMdTsN5EKE5EkpKo46iD6rKFbXFXfH7nNc
	yD2jT010oblMIeaNwCsD2kLHKnHWc7XUhfGpG2D+pt6cKIQ8ZYhS0QjetENEVJJuwmLeatpnWku
	X9yoxiuu5lg1EqBWwy+Cd06w71YL4MBtYQTJ3Xmlq4e5zbfkMZpYE5WCBllEf/F+eXfbEOYtcfj
	Vorh2aJJsVQxJQHHqK5ZiZ2pw+H4i4+jPcrOWrHk=
X-Received: by 2002:a05:600c:4f0f:b0:4a1:e00b:a10b with SMTP id 5b1f17b1804b1-4ac17b2cde9mr454931595e9.7.1793848031562;
        Wed, 04 Nov 2026 19:07:11 -0800 (PST)
Received: from c14-smtp-2023.dev.purestorage.com ([208.88.158.129])
        by smtp-relay.gmail.com with ESMTPS id 5b1f17b1804b1-4b57373e36asm2412705e9.10.2026.11.04.19.07.11
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 04 Nov 2026 19:07:11 -0800 (PST)
X-Relaying-Domain: everpuredata.com
Received: from irdv-tmenninger.dev.purestorage.com (irdv-tmenninger.dev.purestorage.com [10.32.149.15])
	by c14-smtp-2023.dev.purestorage.com (Postfix) with ESMTPS id 0AFEF3403F8;
	Wed,  4 Nov 2026 19:07:10 -0800 (PST)
From: Tim Menninger <tmenninger@everpuredata.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>,
	NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Eric Badger <ebadger@everpuredata.com>,
	Jon Curley <jcurley@everpuredata.com>
Subject: [PATCH 0/2] SUNRPC: let cancelled RPC/RDMA requests drain before release
Date: Thu,  5 Nov 2026 03:07:07 +0000
Message-ID: <20261105030710.2652306-1-tmenninger@everpuredata.com>
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

Restarting a data server's NFS engine during sustained pNFS/flexfiles
READ I/O over RPC/RDMA can leave the client repeatedly reconnecting
after the server becomes available again. I reproduced this on Linux
6.8.0, 6.18.34, and 7.4-rc1.

Cancelling an RPC task does not establish that the server has finished
accessing its advertised Read or Write chunks. Releasing the request can
invalidate those registrations before the server finishes using them. A
subsequent remote access can fault the QP, disrupting other RPCs and
driving further layout cancellation and transport recovery.

This series lets eligible cancelled RPC/RDMA requests remain available
for normal Reply-driven cleanup instead of immediately releasing them.

Patch 1 records the first RPC error and any (possibly subsequent) signal
indication in one atomic state. This allows a signal to interrupt
optional draining even when an earlier cancellation error is already
recorded, without overwriting that error. Accepted RPC restarts clear
both together atomically, leaving the behavior from commit 5bbd6e863b15
("SUNRPC: Prevent looping due to rpc_signal_task() races") in tact.

Patch 2 adds transport-controlled deferred release for cancelled
asynchronous tasks. RPC/RDMA opts in while registered MRs remain on the
same live connection. Wake callbacks retain their transport status, and
waiting uses the existing request timeout and transport timer.  After
normal no-reply timeout handling, an already-cancelled task exits rather
than repeatedly re-entering draining with an expired timeout.  A request
whose Reply completed before release no longer triggers its previously
requested conditional disconnect.

Testing:

This series is based on v7.4-rc1.

There is a patch in
https://lore.kernel.org/all/20261105000131.2512336-1-tmenninger@everpuredata.com/:

  pNFS: avoid repeatedly cancelling I/O for the same lseg

which is required to cleanly observe the transport-recovery behavior.
Without this, my client livelocks after NFS restart.

There are also two strict prerequisite patches in
https://lore.kernel.org/all/20261105020249.2607367-1-tmenninger@purestorage.com/:

  SUNRPC: add request-scoped disconnects when cancelling tasks
  NFSv4/flexfiles: limit transport disconnects when cancelling I/O

Those patches are required for applying this series and are required to
observe full recovery after DS restart.

Finally, I applied the patch in
https://lore.kernel.org/all/20260823134640.3083136-1-tmenninger@everpuredata.com/

  xprtrdma: serialize unmap_sync with xprt_disconnect

to avoid a separate disconnect-time deadlock. The described reconnect
storm makes this otherwise rare condition easier to encounter.

The principal workload used one client, one MDS, and one DS, with
RPC/RDMA, nconnect=16, sustained direct READ I/O, 160 threads, iodepth
64, and 1 MiB I/O.

With this series in the tested configuration, restarting the DS's NFS
engine restores full throughput and normal operation in approximately 20
seconds, matching the expected recovery interval.  The continuous
post-recovery reconnect loop is no longer observed.

Related experiments:

While not the direct cause, this is exacerbated by commit b739a5bd9d9f
("NFSv4/flexfiles: Cancel I/O if the layout is recalled or revoked").
Skipping this behavior for RDMA xprt suffices to avoid the issue during
DS/NFS restart, but the underlying issue remains that stale rkeys can
access invalidated MRs.

In antoher experiment, fencing MRs during teardown and waiting for all
request-release waiters before disconnecting sufficed to eliminate
protection error messages in dmesg during recovery, but does not slow
down the xprt disconnect feedback loop.

When applied, a separately posted layoutreturn-seqid change at
https://lore.kernel.org/all/20260921235520.502987-1-tmenninger@everpuredata.com/
leaves some workload ranks slow after recovery even though the reconnect
loop is gone. The cause of that interaction is not yet established, and
I've asked to hold off merging that submission.

Tim Menninger (2):
  SUNRPC: maintain an rpc_task signalled flag
  SUNRPC: let cancelled RPC/RDMA requests drain before release

 fs/nfs/nfs4proc.c               |  12 ++-
 fs/nfs/pnfs.c                   |  11 ++-
 include/linux/sunrpc/sched.h    |  21 +++++-
 include/linux/sunrpc/xprt.h     |   3 +
 include/trace/events/sunrpc.h   |   1 +
 net/sunrpc/clnt.c               |   2 +-
 net/sunrpc/sched.c              |  53 ++++++++++---
 net/sunrpc/xprt.c               | 129 +++++++++++++++++++++++++++++++-
 net/sunrpc/xprtrdma/transport.c |  33 ++++++++
 9 files changed, 241 insertions(+), 24 deletions(-)


base-commit: 05441d697f7f9a927264f4058cbbc6a03dfcac9d
prerequisite-patch-id: 2e8f35e38c760c42d04307b131ce55f80df66fef
prerequisite-patch-id: e7030ad56461efdd80f97ab1e0790fd4593805a7
prerequisite-patch-id: 8be1a2d2043bc7c018bb8e85af50ef438786a2aa
prerequisite-patch-id: 17803adca3ad2c820fc719d6976327e5981adafe
-- 
2.53.0


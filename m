Received: from mail-oo1-f42.google.com (mail-oo1-f42.google.com [209.85.161.42])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0021533123D
	for <linux-nfs@vger.kernel.org>; Tue,  6 Oct 2026 18:07:15 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.161.42
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791310037; cv=none; b=Uj4tA7Uyo5M4kJ/b4U7DcdL32YhslxeDlW9a0RwrVa3ZzDZde0RtydYvX7gMZ435tb3iiYKJCVGsGAcMRWoiZN3azVnvxuhjvxLY/Uw8Y47ZWP8En68A/qy7RPD4VjPUlDm2uoWvunXr6YWTCz9DJfVF3g4nX2rnqaoL7HfXzIc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791310037; c=relaxed/simple;
	bh=f8RI8Kd9rK1DyxLnzdpp99zjZNKaD5gNeknx9jaA+9w=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=PiiKZeLvgwuUgIN8gSW3IjEbddeUWxNos+LQfAECx6+4r1rizACMt1RdTpXeKV+4T+MYUJyonIPC5/ORqXkt6ULVaAJwEPS8eFy1iALA37o1b/viVys4j1RYSubdekBkc/clcRWcjVYwCQVstfkEU7CqDVj0f9pN8BTnYdWjFQ8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=d0G2+neX; arc=none smtp.client-ip=209.85.161.42
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="d0G2+neX"
Received: by mail-oo1-f42.google.com with SMTP id 006d021491bc7-6dcf573c429so613141eaf.2
        for <linux-nfs@vger.kernel.org>; Tue, 06 Oct 2026 11:07:15 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1791310035; x=1791914835; darn=vger.kernel.org;
        h=content-type:mime-version:references:in-reply-to:message-id:date
         :subject:cc:to:from:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=rLaWmoDbC4L3lfor7i+9aRJ7PjVCdrifW2GTwUJb9Zs=;
        b=d0G2+neXmE+ja+L+Ir4lVE37iGqr8fSAPuNd39d3qZmOhqeI9y8rnM8Q/xL0LD7UYK
         TiyN8xeKdQsItkl1ZRRi6t2OdvYWxlH6nKGbzakqD93+bUwubsXRk6QTkYp7vfznX6vN
         lvEkwqsBRYWtXEU1AfepGV9CJFc1ZaFdGkZ9Ns8DhP0ppRx+HHSFBrW5CMhBIhcoItvI
         J8fPdBL4aUejGYiYs8rfy/KiBB8fHAZrrzFGaN2REgWYTxlf/gHTfKL5FQ+rmI3HisNS
         iJ91CinnFCung+wMnmLEQ8/fOI0VX4edCPfpmM75z5XzUSSFWFziAPakvoXWLazmQlxF
         Jdpw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1791310035; x=1791914835;
        h=content-type:mime-version:references:in-reply-to:message-id:date
         :subject:cc:to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=rLaWmoDbC4L3lfor7i+9aRJ7PjVCdrifW2GTwUJb9Zs=;
        b=PXhaI2x+OLBe30DYOfpoh4+PqCvZTWjt2FZaMi/MHsqDAKwFwQbUK4m7BsLoLCVj1c
         NlWV+xBnBlyAWZy+LYVk+ysf6wThQAwNeqtCfxYaQh+dwFfxZux5awCINnyvsegLAWxX
         0HOCS0BsG5tzFeFkLLF1BzHZcamtXE26fpHObsLUFESXI6SEE/XZx4CESaMbjIoUNJPw
         s+3PhtWIPk54PNIBXZy2zGl6LVzJffRkMTBa/d5ttwQLv3mZKNL6vayal4EOXJfpuHrt
         8OKd+V4wdb8tg1G7gTxfd9w5jSZKgwDRAJ36TPywYAm84KAXdYii1lEL12FxfnqkyBzy
         4aGg==
X-Forwarded-Encrypted: i=1; AKwUvBz8/nPq5pmEJyrQoEDtcyKVkcfjAi8hovqOb+jVdGgxWE6KeIbdoeDXAEhiByft/ZhPWqRj4KxlbS0=@vger.kernel.org
X-Gm-Message-State: AFuF++nmoLWy5exxM0N2x4b+KWXnrHANdWtZdu68FVOuKPps/gvddpnI
	97I297Q/KsE+r5GmhdLQA+uiv6oDOZ60bz4XzoU7+TLNHHEWSUhOXNZr65YhhkOza1g=
X-Gm-Gg: AYBFou2VwWR5BQp2wgARiEUvaeofXvGuY7qJG1aQudWGD1LLDTmvlUXOWHhiBydXQn5
	+CmPmUArc7ox92myb1Y18URqdRJHXqDwkM8+uh3iN+xmpe+iOQsshbLRek8fyh6CFaX6gck5JVu
	nli/XI/5lY3VyhcYUUreCxASLsXBHKvByKMdvRElkUj7eaWkG7N0YPG555ggAKA1BKaStVSkm7D
	G7n1lLpp9KMfncyTnSnGutzwNhOa6x1iMmANtZCFh4Et7Yg0wzBw5XJc2qtBweJzGjO84ZDh1KT
	lfyAPyYIzlXApW5re/9MIAJk/KV/Vkb5YxduMvGVFG59oVM9C02uYf7P0wBkomRO2V5ZcbGEohv
	xKPcApBYqN+zPzgHi1eS2/rlzptKTz9KO+8SzLMfBAYxF9xXN2sM4uKgxmWhBjEZspNbpe51goP
	mLsjgr6L0rUVyWvG+iTAFqQlGBK+l3BAMA9qxVjBUGfcSswi+LyvPvqMcDbDFO+kwzzFhDhrpqx
	4yKgpUcZr5HJXfPklc=
X-Received: by 2002:a4a:ee98:0:b0:6d9:4131:5037 with SMTP id 006d021491bc7-6e554eaca9bmr2126406eaf.45.1791310034521;
        Tue, 06 Oct 2026 11:07:14 -0700 (PDT)
Received: from [192.168.254.51] ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id 46e09a7af769-82adc3f1006sm180679a34.11.2026.10.06.11.07.13
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 06 Oct 2026 11:07:13 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
X-Google-Original-From: Benjamin Coddington <bcodding@hammerspace.com>
To: Chuck Lever <cel@kernel.org>
Cc: Benjamin Coddington <ben.coddington@hammerspace.com>,
 Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>,
 linux-nfs@vger.kernel.org, Daire Byrne <daire@dneg.com>
Subject: Re: [PATCH RFC 0/2] SUNRPC: dispatch ready transports round-robin
 across clients
Date: Tue, 06 Oct 2026 14:07:12 -0400
X-Mailer: MailMate (2.0r6272)
Message-ID: <7840A427-7BD2-4C87-95FC-2E5325130CAB@hammerspace.com>
In-Reply-To: <cb5d00b3-008f-4876-b284-c8cbabfea3ad@slotpi15m67>
References: <cover.1790953694.git.bcodding@hammerspace.com>
 <cb5d00b3-008f-4876-b284-c8cbabfea3ad@slotpi15m67>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain

On 4 Oct 2026, at 16:48, Chuck Lever wrote:

> Jittering the injected service time would show how much of the
> shortfall comes from the harness. Counting consecutive dispatches
> of the same client in the trace might show the rest.
> ...
> Any server with more than one NUMA node gets the diluted result by
> default. I would like to see numbers for a two-node per node
> configuration, and your thoughts on whether the client queue belongs
> to the pool at all.
> ...
> That result and the "alone" column disagree. Can you repeat both on a
> kernel without KASAN, with enough runs to show the variance? If the
> unloaded slowdown is real, we need to know where it comes from.

Here are the two-node numbers I promised, and the rest of what you asked
for, from real hardware this time.

Where the cover letter's numbers came from: a VM on my laptop, 10 vCPUs
and 6G, KASAN kernels, with the host busy with everything else I do in
a day.  The guest can't see any of that (no steal time, every vCPU looks
the same), so when the "alone" column came out 36% slower I had no way
to tell the kernel from the laptop.  Not the rig to measure a
microsecond with, and I should have said so.

I got a day on a two-socket box (2 x Xeon 6542Y, 96 threads, 1 TB), so
here's the review's list again from that.  Kernels are v7.2 with the
el9 config run through olddefconfig, no KASAN, A with the test hook and
B with the wake fix and the two patches on top.  Loopback unless said,
16 threads, 10ms injected.  Two things changed in the harness: the hook
sleeps with usleep_range(us, us) now instead of fsleep(), which was
giving every request the same 25% timer slack and releasing the threads
in batches, and the load generator jitters the requested service time
by 50%.  Each kernel was booted twice and every figure below came out
the same on both boots.

XPT_BUSY first.  With the service time jittered the single connection
gets 49.9% in all six runs against the 8-connection client, and 3 of the
other client's 2414 dequeues landed in its dequeue-to-requeue window,
which is 1us on this box.  So that whole shortfall was the harness, as
you said.

Two nodes.  The box has a 400G port on each node, so I put the client
side in a namespace on the node 0 port and the server on the node 1
port, through the switch.  Three pool setups, 16 threads:

                              one pool    per node,     per node,
                                          IRQs local    IRQs split
    total ops/s               1600/1600    797/797     1600/1600
    1x16 vs 8x4, share       11.1/49.9    11.1/50.0    8-22/25-28
    2x8 vs 16x4, share       11.1/50.0    11.1/50.0     7.7/50.0
    burst 32 vs K=16, p50     350/63       690/101      449/101
    1-conn client walk, s    37.7/2.6     75.4/4.9      4.9/5.2

(A/B in each cell.)  Two things in there.  With per node pools and the
NIC's queue IRQs where mlx5 put them, on the NIC's node, every request
lands in that node's pool and the other eight threads never run: half
the server, on both kernels.  With the IRQs spread over both nodes you
get what you described: a client's share is its share of each pool it's
in, so a single connection gets half of one pool, 25% here instead of
50%, and two connections get 50% or 25% depending on where RSS puts
them.  On A the same client got anywhere from 8% to 22% run to run on
the same luck, and that's also why the real client's walk comes out
even in the last column: A's victim happened to land in the light pool.
Those cells want a lot more runs than I gave them.

On whether the client queue belongs to the pool: making it exact across
pools would mean a thread on one node serving a transport that arrived
on the other, which is what the pools are there to avoid.  I'd rather
keep it per pool and say so.

The "alone" column doesn't reproduce.  Serial walk of 2000 files, 14k
RPCs, ten runs: 0.24-0.26s on both kernels, pinned to one node.  fio with
4 jobs on one connection: 126.6k IOPS on both.  What does show up is at
the top of the overhead test, 5 x 20s each:

                                   A        B
    nconnect=1, 16 jobs        152.8k   152.2k   -0.4%
    nconnect=8, 16 jobs        483.8k   475.5k   -1.7%
    nconnect=8, 64 jobs        584.2k   581.0k   -0.5%

That's about half a microsecond per dispatch, and all eight connections
there are one client, so every dequeue takes the pool's client lock and
then that client's lock.  My read is that it's the extra cache lines
moving between the enqueuing core and the dequeuing one (the client's
transport list and its queued bit, plus the pool's client list), not the
atomics themselves.  I haven't attributed it with perf yet.

The cover's tables again, NFSv3 burst completion p50 in ms, floor 37ms:

    K             4      8     16     32
    A            70    195    351    671
    B            56     62     61     63

    N (K=16)      1      8     32     64     96    128
    A            21     98    350    690   1035   1365
    B            11     31     62    103    144    179

    M hosts x 4   1      2      4      8
    A            70    192    351    670
    B            57     81    121    192

    S: 2x8 vs K, share   4      8     16     32
    A                 41.0   20.0   11.1    5.9
    B                 50.3   50.0   50.0   50.0

v4.1 is within 2% in every cell.  Totals are 1591-1604 ops/s in every
saturated cell on both.  The real v3 client walking 500 files against a
16-connection aggressor: 37.8s on A, 2.5s on B, 0.12s alone on both;
its fio 99 vs 1590 IOPS.

On the question in your second mail, an admin setting one table for
more than one fairness behavior: the posted kernel keys on source
address, so I can emulate "all movers are one class" today by giving
the movers one address.  Six movers against customers, share of
dispatches on B:

                                movers on six addrs   on one addr
    one customer, 1 conn x 16          14.3%              49.9%
    one customer, 4 x 4                14.3%              49.8%
    four customers, 4 x 4 each         40.0%              80.0%

Burst of 32 against M busy hosts, p50: hosts on their own addresses 57
81 121 192ms, hosts on one address 56 62 62 62ms.  And a mixed run of
six movers, two backlogged customers and one burst client: movers on
one address gives movers 28.9%, each customer 28.9%, burst p50 100ms;
on six addresses it's 68.9%, 11.5%, 11.5%, 192ms.  So one line in a
table does both at once: the movers held to a share, the customers
served per host, and the burst client's wait bounded by the number of
classes instead of hosts.  A is unchanged by the address either way.
What a table like that doesn't give is a third discipline on top; it's
still round-robin across whatever the keys are, and anything like a
weight or a cap would be an attribute on the class.

..and on the cost: if nothing is configured the old single queue could
stay in place, which would make that half a microsecond zero for anyone
who hasn't asked for anything.

Ben

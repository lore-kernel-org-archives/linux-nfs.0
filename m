Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9BC0A388377
	for <linux-nfs@vger.kernel.org>; Sun,  4 Oct 2026 20:48:34 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791146915; cv=none; b=KdQZi1a1GLWKAlhIGxT7YgQRcs5I+at0exWM7P/DENdcf79wRiu31c+eltvs2iIh4YGYmLP9WcXz23RY1weZkB5wKZOvTETnf3Gryeg2MiQNkJxVJrGh47rv195WVoJE7GiFSEeLC/D/z28+wJAEuHJfe7S972EKsHBJ0+Ub2c4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791146915; c=relaxed/simple;
	bh=ITdAbKl80y6z5UTXNOj4W9pol3loaa1gunsuZYJgeLI=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=c/g5x5tS90ztJo/6FOMVxWOks2n5kpA67hR+wz3AJOGiJJj/sRB1bxxEUjbZ3Hy0oM3Elw1QVMnKuUbzvxiUyIfptah1smjXR6aRYn64bw7kfjm0g5Ym050OO5/A6twigtZdJe0FdWLMi0FNhtsMNpuGPqEia9ivKOvZqMvIIhQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=AYPRunwS; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="AYPRunwS"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 051FC1F00898
	for <linux-nfs@vger.kernel.org>; Sun,  4 Oct 2026 20:48:33 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1791146914;
	bh=ZRB+5EakXP8ZZ6LsqnIW2a5D6Ke2vrYczEG0YEocfeE=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=AYPRunwSF3/SET1sCIOpMOJS2gnzUB+RVq4gPwVoDhjrxxomSasJvwySbMYOwirHm
	 ZHagDCq915XssqvBCHo6ft9xR3egEN5iIPIPMyb6nRKL71XxdGvCxe/uYrOgRzLyQw
	 gYzLvimU9kcD+1cehuw5YhvB6Yrrq1vAAUoHIn5Hgj6gkUIeqmoIUGb1NQf3BNogMu
	 1lHGjvoxKc3+BufP+Z2tkkouVrlYAsbiv5udbVcDULCPNPYYAe9ugOQUVq4ET+O64F
	 y8IQk6dQQ/rhkddEFwKWJ/vVIMeekDl1MDU3MMVyOqAfgJ+7PNqjGPNuSOsIqVAhS8
	 R1cFN+OPv963w==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id 23414F40066;
	Sun,  4 Oct 2026 16:48:33 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Sun, 04 Oct 2026 16:48:33 -0400
X-ME-Sender: <xms:obvCanrAzf7HeXiIXFJWKTKUpOVj_02MK2h5X29J7vDwQIRMiZRnJQ>
    <xme:obvCasdjj3BfFPbzMMGhiZINotVrCl784Bq-C4mKYh50KuTCklMVcfviyZJVSPevp
    0z7_TrzVH6Ihwo-t6PlCDDdOTHWVgsufS36dZJJkGPRa__QM1E6AVgj>
X-ME-Proxy-Cause: dmFkZTGYTAOmP710rp1RRrNYluB066Qpb64PInXhtr8p6vmZrPC4B/A6JBZIbud905GrpV
    tHYY0vk1QeKoVceODzOQPj9wgnV1dV8KEmzi72gbpexXscZ4HQNqCJNYxZ0yifGUB41ncu
    NDnnz6pWrwUwg5zMoD/9BQmF0uF1OtjfBPtM0y6G1Ei/vPCxoOWLQUCT+D6jDWqjwflen3
    4kdUAFU7SMnaXrfIscarZG1jF3SrSz6jwr/QkQaCcyuVXLJzSfvypAJpanaXu12XWXnZ7l
    lhYbH3CN05Sj0x/o9XMs2NMfFuAeKfgbTA4B4b0njLyJWUiDxFNKLSI5IUJDZEtWROqibY
    Q7+54WTFS3nsS8xN7dpQ1gO5XiKz0ZnFIkxPr7HksOT9ZWDuoOFlT/Sa8XmW0emLgy9PsE
    bJ7L+EFSnFo3S97smBXLcpkwkDZtCgkfWfU2uFLsnCXXeXkBQyBUhgxKlDxaf3f4UxsOV8
    s86BEJEw7DhLYR79kxPn9rVUZtCGsE68dYQmP6pgy8AdDjbskVRIOwyIF8M95P9PBlb7Iq
    svjsHPBds5HNSApDRcVWXXKS0sWBxW339RQIV8fX9QgOaIFVDXJzheD8C6V4ulG11xSSQS
    rt+KUiYfwgocTw/HzF1BfcHz7LTO7brhopWGh3vwxMqbLGvfZhUqrPDf5Ohw
X-ME-Proxy: <xmx:obvCalv_3p3tK6bAjJBost7K51bhAguE6JtN4oQ_gaVZEwe0vXe2wg>
    <xmx:obvCav-l42iJKol9PGGCclsJDHc7hUUlnX1RVcljbmCYMidA2vxxsQ>
    <xmx:obvCao2EOo5vYnOzuYQqZFeq_G3JWqVqSy5Bl4m3809gGTRJdlkGAA>
    <xmx:obvCasB3-Z1FbVESYmXtjNcL3CRDXS8n6hI6EtU4lzCNt_eYXwNaBg>
    <xmx:obvCasfEB6BiS4KYBSQZ552TPfUbQ2HmIqAD3FFEJQ3yyztb03B83Miw>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 019B2780075; Sun,  4 Oct 2026 16:48:33 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: AB0QkRkUO1Do
Date: Sun, 04 Oct 2026 16:48:12 -0400
From: "Chuck Lever" <cel@kernel.org>
To: "Benjamin Coddington" <ben.coddington@hammerspace.com>
Cc: "Jeff Layton" <jlayton@kernel.org>, NeilBrown <neil@brown.name>,
 linux-nfs@vger.kernel.org, "Daire Byrne" <daire@dneg.com>
Message-Id: <cb5d00b3-008f-4876-b284-c8cbabfea3ad@slotpi15m67>
In-Reply-To: <cover.1790953694.git.bcodding@hammerspace.com>
References: <cover.1790953694.git.bcodding@hammerspace.com>
Subject: Re: [PATCH RFC 0/2] SUNRPC: dispatch ready transports round-robin across
 clients
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Hi Ben -

On Fri, Oct 2, 2026, at 12:42 PM, Benjamin Coddington wrote:
> This is a third pass at the problem from [1] and [2].  It's the design
> Neil described on [1], close to as he wrote it: a client object per peer,
> a queue of ready transports per client, and a queue of ready clients per
> pool.  A pool takes turns across clients instead of across transports.

I read through your patches and did not find a problem with the
SVC_CP_QUEUED handshake or with the client's lifetime. My concern
is with what the pool takes turns across, and with a few of the
results.


> Each transport belongs to a client, one per peer address and network
> namespace.

> The one piece of Neil's description I left out is moving a transport
> between clients.

I think that piece has to come back.

svc_client_find() matches on the full peer address, so each source
address gets its own turn. A host with N addresses is served N times
per round. That is the curve from your May numbers with the address
count in place of the connection count.


> It's fair by host, not by class.  Six movers get six turns.

It is fair by address. That covers more than six movers:

 - A multi-homed data mover gets a turn for each interface it
   connects from.

 - An NFSv4.1 client that trunks a session over N of its own
   addresses is one clientid and N svc_clients. It gets the larger
   share without asking for it.

 - An IPv6 host can connect from as many addresses in its prefix as
   it likes.

Meanwhile a NAT or a re-export gateway with hundreds of users behind
it gets one turn. A client with many users is held to one turn and a
client with many addresses is not. The multi-homed client case is
not something we can easily ignore.

For the next version, please add a case to the harness where one host
drives load from N source addresses against a single-address client.


> Chuck asked on [2] for something real rather than the synthetic victim.

>                     alone (A / B)     loaded A    loaded B
>     walk            1.53s / 2.08s      328.55s     107.74s
>     fio 4k IOPS     21876 / 19776           80         777

The "alone" column worries me more than the loaded ones. With no
aggressor, the walk takes 36% longer on B and fio loses about 10%.
A single client with one connection pays for one more lwq dequeue
and a few atomic operations per dispatch. That's a regression even
Linus will notice.


> For the cost on the dispatch path I used fio over a loopback mount of a
> tmpfs export, 4k O_DIRECT reads, nconnect=8, five 20s runs each: 95.5k
> vs 95.8k IOPS at 16 jobs and 139.0k vs 139.2k at 64, A vs B.  I can't see
> a difference.  That's one client on a KASAN kernel, so I wouldn't lean on
> it too hard.

That result and the "alone" column disagree. Can you repeat both on a
kernel without KASAN, with enough runs to show the variance? If the
unloaded slowdown is real, we need to know where it comes from.


> Fairness is per pool.  With ten pools (pool_mode=percpu) a client with 2
> connections against one with 16 got 26% where a single pool gives 49%.
> v7.2 gives it 12% there.  Now that pools are per node this matters
> more than it used to.

Any server with more than one NUMA node gets the diluted result by
default. I would like to see numbers for a two-node per node
configuration, and your thoughts on whether the client queue belongs
to the pool at all.


> A single connection with 16 requests outstanding gets about a third
> against a client with 8 connections in my synthetic harness, not half.
> From tracing, its transport is dispatched within about 150us of becoming
> ready and alternates with the other client, so I think that's my load
> generator not keeping one connection supplied.

XPT_BUSY might account for part of that. Once a thread dequeues
the client's only transport, the client is off sp_clients until
svc_xprt_received() enqueues that transport again. The 8-connection
client goes back on the tail immediately. A thread that comes free
in that window takes the other client. The window is one recvfrom,
so it matters only when several threads come free together. The
fixed 10ms service time makes them do that. Your first RFC's cover
letter attributed the same shortfall to XPT_BUSY.

Jittering the injected service time would show how much of the
shortfall comes from the harness. Counting consecutive dispatches
of the same client in the trace might show the rest.


> Control events take turns
> like data.  A close queued behind k of its own client's transports gets
> dispatched k rounds later, where today it waits behind every queued
> transport in the pool.  I didn't add a separate queue for them.  I can if
> that's wanted.

A round is as long as the number of ready clients. With k transports
queued ahead of it and M clients ready, the close waits about k * M
dispatches. For a client with many connections on a server with many
busy clients, that is longer than the wait in today's FIFO. Those are
the connections NFSD most wants to close promptly. Let's dispatch
XPT_CONN, XPT_CLOSE, and XPT_HANDSHAKE ahead of XPT_DATA within a
client.


> Is the anonymous client the right home for listeners?  A connection flood
> gets one turn per round that way.

I think so.


> Does anyone want the pool_stats or a tracepoint to show clients?  I left
> observability out to keep this small.

Yes, please. A tracepoint at dequeue that reports the client is
enough for now.


-- 
Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)

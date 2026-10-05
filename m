Received: from mail-ej1-f47.google.com (mail-ej1-f47.google.com [209.85.218.47])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C56DF443E3B
	for <linux-nfs@vger.kernel.org>; Mon,  5 Oct 2026 12:19:24 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=pass smtp.client-ip=209.85.218.47
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791202767; cv=pass; b=jJh4rMcr/el67lHcxYaHdpvVfXe9gD50vcAf/Y2Hs5xjK6Lq8aoBaX2ZPaZ6faLEpc+YNUaHaCc/Ph2BeqVTpoZyhBAHSE4YsDc/ynpSAv+PKMA1kG90RuAgntuRIPX5LiOc95lMy0/8Msp9m8P9FsrIMfn1ypk5/8ns/0BdvMw=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791202767; c=relaxed/simple;
	bh=LYVq1M0J74qFX7BJdJEDB30rUitdJ+HdaBCWxbEQTxk=;
	h=MIME-Version:References:In-Reply-To:From:Date:Message-ID:Subject:
	 To:Cc:Content-Type; b=qeMRttgJrcVS9VFV4cFEXgLtHFd1ze9exDw2XtYAVJttvpW9LO63LLQYPdcRTevTRsV0TuxnhRT6PDBGJUbLDMpwLFMteSMpAZtZHPp58CbyJwG8XA6+8nn/3c7Ea1f4MG/UscOZW9E4NR6lfsyF7n/17q8O5X1ugQLyZ61QQZ0=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=dneg.com; spf=pass smtp.mailfrom=dneg.com; dkim=pass (2048-bit key) header.d=dneg.com header.i=@dneg.com header.b=cEVOwN9n; arc=pass smtp.client-ip=209.85.218.47
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=dneg.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=dneg.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=dneg.com header.i=@dneg.com header.b="cEVOwN9n"
Received: by mail-ej1-f47.google.com with SMTP id a640c23a62f3a-c20ce3c118aso148069466b.0
        for <linux-nfs@vger.kernel.org>; Mon, 05 Oct 2026 05:19:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1791202763; cv=none;
        d=google.com; s=arc-20260327;
        b=BbLFSdZyOXMEbUKOCfWtdXfDPp96U6gUgS9mNARBg+l5tzPMgn7C+ku2ehVdQyHQh+
         KwhoAlpkvyMgYy2wcc4IpulQePdT10Ow0IcHb9XjQ0lCxJxHMUJLArye3lODYIvt62lQ
         Cjdw++yuIOTT8eTdLjRqe/juVMWMdBlX57IK3thL0c4P8IgE+1yJ4ixDHYwqOwWCbsAG
         DMechGx/Z94OazoJJdR9SeTOcJZGqioh+vuKsq44lPyjf2CZIUfL0LqfNVo0Nlb4/YdP
         9C3CYgZXqBu76tUQQFSYEtYtpbUJ4lnLJwWiM/XpaKT4ntMjokzzdJ7f1t/qeTVR+zK5
         bK1Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=c6B1QiTGXXTjUaHOXigIZ6IbEU9q9C8ERdhJQhT/Lwc=;
        fh=sWjQa2cX/qWhzy3bdUzoPUTJGR56svGI3UzVKjr483I=;
        b=OR4scn7FUeRM+TjtA2Q/hGfMeqbmOtnTmN6w3yLFUw0HBFV6yqYucPLwlH819TEAm8
         df18lKGnAQT8FvMWupsjxwtbL/hBQg2a8WYwQTjYZqzj3qpTn6iBXt4FEJ6snFM76rCQ
         sbksrXLTJeMI4myTFTTY3BYMyCiitrO9+3NBonQMtmGsvs7KZZpuKzjcXbGZJBVsjQLv
         E/q/vj0Qaj6I0cxQSqEhlFzitorKsiC1IYgv9o10XA0Z1LH0Sh+NHLswCVfTQMSjcGk5
         9G7KsXiu0xy3XiPW2t/1qYnoo0uRovys7BRJlLDCeyKHdMfLkggbB4kkFKXeUNP6vbNw
         zoFw==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=dneg.com; s=google; t=1791202763; x=1791807563; darn=vger.kernel.org;
        h=content-type:cc:to:subject:message-id:date:from:in-reply-to
         :references:mime-version:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=c6B1QiTGXXTjUaHOXigIZ6IbEU9q9C8ERdhJQhT/Lwc=;
        b=cEVOwN9nBMvUIX3HTLodTaCIhog403fpNu9/LcpWLTUneefzK3a+mnyron5NYpomlZ
         e2IaizfT9s/a7f9ZtJ5yOWI2O0dvKte0rOM9oaTg2HZ6gytkfTud7t+WzH7X+mM9a0zL
         vgvZWlbdMCvU74gLNeD8xoOBQQmjAUmvP+RMX+AEgYYJIOTeb0fETT/HMM5cLC7AIMlX
         G8DlPtaGT45iXZOTpj/ZEM9DuWrVFHkUnFAu5DHNPFKXd/TnqV3hI7slzZGIyeJyECai
         I2ZWoasS+LSsy6fXIK2DE9HydL13WuKMm7Xb3ARzn/JcJbOLfpfpqKwQe9Ia6IH9MCZ1
         CMkg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1791202763; x=1791807563;
        h=content-type:cc:to:subject:message-id:date:from:in-reply-to
         :references:mime-version:x-gm-gg:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to:content-type;
        bh=c6B1QiTGXXTjUaHOXigIZ6IbEU9q9C8ERdhJQhT/Lwc=;
        b=byxvF2TfANi7Pzics/8zuBQbgdWI9c2YUOmcpgJ34/yxYmV8tXpFHqAXnW6dDzFVPo
         csWwrOA708j/Aa6bDchZMwIweFWouYA4+Fb6ZEv6nwdZoaVhItUtEnpbbFcLLBJr3EeX
         GTiQL/qEZpskKYu+uI21j7uboWZ6FktHqC2m+2uNhvnG+ZTvBYsW1QtgDS+AGW1uxnWs
         iYZWHs78RjxnPtSs3yXwBnUO9yUZIA8r5Q29J+Wey1irQaIG8ye/XhBHKegvEuVhcy4F
         Tsr2UI44dOBpmLrUgOLt9mxfc8ppfEtUtZ7u6GyMUatJfhJhUAyH0TLee+/s6CvezBYI
         9ORQ==
X-Forwarded-Encrypted: i=1; AKwUvByqCYSJg9k8DPtCduYUH9Nz8FF20shbGKv57iATpMlcjlPHV0+diSBRgtiScqB3DoESnbcFFWBSLzk=@vger.kernel.org
X-Gm-Message-State: AFuF++njFUBA2WyqUNpx3ZMKMcLCHDToLAhTQIrh/wkYuBIwHgI+bov9
	+Q+UaGbsR+GWSoTP2CWCNNhcD0xbI08USql7LFlOxAG/MXtPBIVwaDoUT7WGUyF4imh1560Dkka
	DoPUWbEoEhb3HgbkodaZ/nD7xony38eSAUL85RiOgoA==
X-Gm-Gg: AYBFou2BLwbA3DedSNZz7W0nUyVY6kJxa6JNMHPvKnkJ+QZRRGGB5q7DFcSjwpp5AeV
	TbUisAuDBtjdWWfA9YZ20ByR7WHdLRJAWNu6ybTXUiAfUOfdqGoOgrFsu07k80LWFq7w9mIag+2
	3cH7017nlQVC8/3ejnX5F9zb2MlUY/4abdCq+sT1/BzpbMwcDxE3rKI5Kmm+wVUzGcZU4iPsVeD
	4G+/OpLrDD31lIBiPjyHh7v+7FkNY2FDrJ7oIoloaBhZopFWaC9ufujVaIPszqcOTzBF+NDY7tq
	ICQlr9wUId8wPQF5PXjHr3yXdM+r8a1VLJJE/pX6oqcRVpZ9XvlYNYFVOpJEoZ68E86RH73KgRy
	xG32VJXWCTrdG
X-Received: by 2002:a17:907:6ea2:b0:c2a:b008:8cc0 with SMTP id
 a640c23a62f3a-c2e3407dab1mr1248689866b.28.1791202762751; Mon, 05 Oct 2026
 05:19:22 -0700 (PDT)
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
References: <cover.1790953694.git.bcodding@hammerspace.com>
In-Reply-To: <cover.1790953694.git.bcodding@hammerspace.com>
From: Daire Byrne <daire@dneg.com>
Date: Mon, 5 Oct 2026 13:18:45 +0100
X-Gm-Features: AclHuK9ndHJpxdYDrgX7_jyuVIOkJu8L2nXkSTTPmp-Q7uRML8TnzPN4LFR1Nes
Message-ID: <CAPt2mGPTskN+JoEBQftKvW=LZnRQLRcGm+1o2iO1RqPQpQC4rw@mail.gmail.com>
Subject: Re: [PATCH RFC 0/2] SUNRPC: dispatch ready transports round-robin
 across clients
To: Benjamin Coddington <ben.coddington@hammerspace.com>
Cc: Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
	linux-nfs@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"

Hi,

I can't give much critique of the approach, but I thought it might be
useful to add an "end user" story point.

We use NFS re-export servers/gateways heavily, and one of the big
issues we come up against time and again, is when the re-export
gateway starts doing bulky reads from the source server (which then
get cached to disk by FS-Cache).

When this happens, lots of the GETATTR and LOOKUP calls get a back
seat which then affects all the clients who are asking for data that
is already in the re-export server's page cache or FS-cache disk
backend. But they can't have the data served to them before first
checking the source file for changes (and we run with very long
actimeo=3600).

This is similar to your data movers versus filesystem walking fairness
tests. Except here it is knfsd thread processes on a single
client/server host.

We use nconnect, set tcp_slot_table_entries=256 and use
svc_rpc_per_connection_limit=4 in an attempt to allow for more
requests in flight (NFSv3) and limit greedy clients. But just a
handful of greedy clients (of the re-export server) can cause
starvation such that the re-export server doesn't service the metadata
lookups required to serve the already cached data to other clients in
a timely manner. It's annoying, the data is cached, ready and waiting,
but we can't serve it until we check for changes (there are none - we
rarely overwrite files).

Now I understand that these patches don't affect the re-export
server's connection to the upstream servers, but I am interested to
see what effect they have on the re-export server's clients. If we can
give a more equal share of requests to the clients does that in turn
reduce the re-export server bottleneck? Do those greedy readers reduce
their rops/s such that the re-export server doesn't flood the
connection to the backend server with bulky read requests?

I was going to test the patches but I got as far as they don't apply
cleanly to v7.2 and then got caught up in other things.

Anyway, I hope that's useful.

BTW - in case anyone is interested, AWS have put together a repo for
"re-export" servers: https://github.com/awslabs/knfsd-file-cache

Daire


On Fri, 2 Oct 2026 at 17:42, Benjamin Coddington
<ben.coddington@hammerspace.com> wrote:
>
> This is a third pass at the problem from [1] and [2].  It's the design
> Neil described on [1], close to as he wrote it: a client object per peer,
> a queue of ready transports per client, and a queue of ready clients per
> pool.  A pool takes turns across clients instead of across transports.
>
> I owe an explanation for leaving sparse-flow behind.  Two things:
>
> The re-arm trigger Chuck asked about on [2] is a cliff wherever it's put,
> and softening it means picking between watermarks and decaying credits
> against real interactive workloads under load.  I ran some of that and
> found the behavior depends on timing from several actors at once.  I
> don't think I can characterize it well enough to defend a heuristic.
>
> ..and Neil's objection on [1] holds: the interactive frame only works
> for clients with one or a few users.  A latency floor helps a client
> while it's idle between requests.  What I have is a data mover with a
> lot of connections sharing a server with clients that keep I/O in flight
> themselves, a re-export gateway for one.  Sparse-flow puts those in the
> same queue as the mover and they split the pool by connection count.
> Neil asked then whether fairness between a client with one connection
> and one with sixteen wasn't what I wanted -- but it is.
>
> Approach
> --------
>
> Each transport belongs to a client, one per peer address and network
> namespace.  A client has a queue of its ready transports, and the pool
> has a queue of clients that have something ready.  A thread takes the
> client at the head, dispatches one of its transports, and puts the client
> back at the tail if it has more.  So every peer with work queued gets one
> dispatch per round, however many connections it holds.
>
> Enqueue is still lockless.  Dequeue takes one more lwq lock than before.
> The client table is only touched when a connection is accepted and when a
> client's last transport goes away, so there's no lookup on the dispatch
> path and no RCU.  Listeners and UDP sockets share an anonymous client.
> The one piece of Neil's description I left out is moving a transport
> between clients.
>
> It's always on and there's nothing to tune.
>
>   patch 1  track clients by peer address, no change to dispatch
>   patch 2  dispatch round-robin across clients
>
> These go on top of the svc_clean_up_xprts() wake fix I sent separately
> [3], on nfsd-testing.  That's the pre-existing issue Chuck asked me to
> look at on [2].  I've only compiled them on nfsd-testing; the numbers
> below are from v7.2.
>
> What happened to the review items from [2]: there's no trigger and no
> credit to tune, nothing is classified as batch or interactive, and there's
> no priority tier, so nothing can be starved.  Control events take turns
> like data.  A close queued behind k of its own client's transports gets
> dispatched k rounds later, where today it waits behind every queued
> transport in the pool.  I didn't add a separate queue for them.  I can if
> that's wanted.
>
> Results
> -------
>
> Same harness as [2], with one change: every load group now comes from its
> own source address, so the server sees it as one client.  16 threads, 10ms
> injected per op by the same test-only hook (not part of this series).  A
> is v7.2 with the hook, and B adds the wake fix [3] and this series.
> NFSv3 burst completion p50 in ms.  NFSv4.1 is within a few percent in
> every cell.
>
> Interactive burst of 32 against one busy client with K connections
> (unobstructed floor 45.8ms):
>
>     K       4      8     16     32
>     A    82.8  249.0  439.9  838.9
>     B    73.5   90.1   94.6   90.0
>
> That's two clients taking turns, so about twice the floor, and it doesn't
> move with K.  Against burst size N at K=16 it stays about twice the floor
> too.  There's no knee any more:
>
>     N        1      8     32     64     96    128
>    floor  14.9   31.6   45.8   72.5   98.6  123.6
>     A     31.6  125.3  440.0  865.8 1290.1 1705.3
>     B     18.0   40.2   91.9  151.3  217.4  278.0
>
> What it does scale with is the number of busy clients.  M clients with 4
> connections each, burst of 32:
>
>     M       1      2      4      8
>     A    80.9  245.3  441.1  839.0
>     B    75.0  112.5  158.3  252.3
>
> That's the cost of dropping the priority tier.  A light client on
> a server with a lot of busy peers waits its turn behind each of them.  It
> still beats waiting behind each of their connections.
>
> Share of the pool for a client with 2 connections against a client with K,
> both backlogged:
>
>     K        4      8     16     32
>     A    46.3%  19.9%  11.1%   5.9%
>     B    49.4%  47.6%  47.9%  48.4%
>
> Six movers, against clients that are backlogged too.  Share for one
> client with 4 connections, and for four such clients together:
>
>                          movers at 4 conns    movers at 8 conns
>                             A        B           A        B
>     one client           14.3%    14.3%        7.7%    14.3%
>     four clients         40.0%    40.0%       25.0%    40.0%
>     one client, 1 conn    4.0%    13.0%        2.0%    13.0%
>
> A client that already matches the movers' connection count sees no change.
> What changes is that the movers can't buy more by opening more.
>
> Chuck asked on [2] for something real rather than the synthetic victim.
> A kernel v3 mount with one connection (noac, lookupcache=none) of a tmpfs
> export, walking 2000 files with find | xargs stat (about 26k RPCs) and then
> reading with four fio jobs, while the 16-connection aggressor runs from
> another address:
>
>                     alone (A / B)     loaded A    loaded B
>     walk            1.53s / 2.08s      328.55s     107.74s
>     fio 4k IOPS     21876 / 19776           80         777
>
> Both loaded columns are worse than a real mix would be.  With every
> request taking exactly 10ms the threads finish in batches, and a request
> that shows up mid-batch waits for the next one.
>
> Aggregate throughput is the same A and B in every saturated cell (about
> 1280 vs 1290 ops/s).  With every group on one source address B gives A's
> numbers back, which is what I'd expect.
>
> For the cost on the dispatch path I used fio over a loopback mount of a
> tmpfs export, 4k O_DIRECT reads, nconnect=8, five 20s runs each: 95.5k
> vs 95.8k IOPS at 16 jobs and 139.0k vs 139.2k at 64, A vs B.  I can't see
> a difference.  That's one client on a KASAN kernel, so I wouldn't lean on
> it too hard.
>
> What this doesn't do
> --------------------
>
> Peers are told apart by address.  Everything behind one address shares
> one client's turns: NAT, a gateway re-exporting for a lot of users, pods
> behind a node address.  Chuck raised this on [1] and I don't have an
> answer for v3.  For v4.1 the clientid could be the key, but the transport
> would have to move between clients at session bind and I left that out.
>
> Fairness is per pool.  With ten pools (pool_mode=percpu) a client with 2
> connections against one with 16 got 26% where a single pool gives 49%.
> v7.2 gives it 12% there.  Now that pools are per node this matters
> more than it used to.
>
> It equalizes dispatches, not thread time.  A client whose requests each
> hold a thread for a long time still ends up holding most of the threads.
>
> It's fair by host, not by class.  Six movers get six turns.
>
> A single connection with 16 requests outstanding gets about a third
> against a client with 8 connections in my synthetic harness, not half.
> From tracing, its transport is dispatched within about 150us of becoming
> ready and alternates with the other client, so I think that's my load
> generator not keeping one connection supplied.  I haven't measured the
> share a real single-connection client gets when it's backlogged.
>
> Questions
> ---------
>
> Is the anonymous client the right home for listeners?  A connection flood
> gets one turn per round that way.
>
> Does anyone want the pool_stats or a tracepoint to show clients?  I left
> observability out to keep this small.
>
> [1] https://lore.kernel.org/linux-nfs/cover.1780498019.git.bcodding@hammerspace.com/
> [2] https://lore.kernel.org/linux-nfs/cover.1782314746.git.bcodding@hammerspace.com/
> [3] https://lore.kernel.org/linux-nfs/5b162e1a03d59bd0d3cc479891965834d0d4f0c8.1790948398.git.bcodding@hammerspace.com/
>
> Benjamin Coddington (2):
>   SUNRPC: track service clients by peer address
>   SUNRPC: dispatch ready transports round-robin across clients
>
>  include/linux/sunrpc/svc.h      |  34 +++++-
>  include/linux/sunrpc/svc_xprt.h |   1 +
>  net/sunrpc/svc.c                |  36 +++++-
>  net/sunrpc/svc_xprt.c           | 191 ++++++++++++++++++++++++++++----
>  4 files changed, 240 insertions(+), 22 deletions(-)
>
> --
> 2.53.0
>

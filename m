Received: from mail-oo2-f40.google.com (mail-oo2-f40.google.com [74.125.231.168])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id CD7194A8FEB
	for <linux-nfs@vger.kernel.org>; Fri,  2 Oct 2026 16:42:58 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=74.125.231.168
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790959380; cv=none; b=itfNkTB6qRCPwaYfErpkCxpTNxQRDT01G/mIZZ04/BUo8dOUW41OSSpWnRlQu2ShEuTqLMqVCxKQJ2D+a7p4YTscd9OJoozNBhLKqpN4YNPYSiOfZ4ISrvZIsxFKFFAcU6PetN/LVjnSk5k3jfR3nkjtPRFTLA4tPJybTtliuvo=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790959380; c=relaxed/simple;
	bh=1Gt3ibARcYwwA6GCLFBUoCvrp8Gi/l/tXKJ5q6gH0cE=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=phR7kcwUi8kMsa4r6Ud6/kP2ubQ5FY3kJPyyvVdWVensHBoAhYC1bFbFWD4mdoRZugSSWikDj7bmh4h7cYs/Q2Xp627ZoXuSvbvVMunq+amxBXUiufu9IJlxIEF6E9oCUeuXg8LSP5z7YAnh3AS552G2VQqJ17PX2qtGrBvZaXw=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=gW2rLljJ; arc=none smtp.client-ip=74.125.231.168
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="gW2rLljJ"
Received: by mail-oo2-f40.google.com with SMTP id 46e09a7af769-82328163e12so60557a34.1
        for <linux-nfs@vger.kernel.org>; Fri, 02 Oct 2026 09:42:58 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1790959377; x=1791564177; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=LimnJDcVd7npcILwB8VutY33Lt6UDgFe/VvLPRBts3A=;
        b=gW2rLljJsSRWDpV7iNu7VFDeqNymQxu1uihtCACahd/La6gwR2AKcZY3TfAuF6FgEg
         GwWg6pqEWrTljKrtNJ8xgRvUk21C86rYti4DPBdrIclSlHGEqCD/V98LXH9LJx5wrq55
         ykGodpoyOjvlwgJKDpQWEBBZ9XpOOOaOfcJuBw74wmbGDQ23zWPMUkdcfP9QLIZqOCe/
         QeTPkiZVVSQCkeDxtrsMIZYyP1nwv7pvazMxuPyapI8EJ17gtETG9r+qrQN188nVMHDL
         sxNs3HUVRWxfRoe17EU3wKLxP3av5gPZlhm+42k/6h0feDS8yhuSazbwX0yM72/WUeOq
         4WeA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1790959377; x=1791564177;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=LimnJDcVd7npcILwB8VutY33Lt6UDgFe/VvLPRBts3A=;
        b=KAnkButn908if5XxDR51NCEZszxRb2MxD3uphCIi7+RDYqIdnPe6E7nt49V5wrq7/x
         kdgi4rGkhAgtzWNVKYdhI6LDrSYW5CNSUnDJdf1HrbZqXWtE6LE9bXl6qxeBJM+H4OcE
         qZwEDsMq1xwnbo/t4t/Iz6od7TOsfBVledS9NiblSXsTqcEGURxzTl6k5/+g1HCpL47B
         jFXw7Gcdxh4Ilc1nqfxYVoo3tVNvg/E6asLPGjXZUnkRGZbt9rNNrwmz5Z3s+vrBrEUI
         pDAQxcOpvyDxZIV+HgIxnduFoeyqy/2fJ3wCrt7myegBPeJUMKushZBffdEbsACHoHWH
         P79w==
X-Gm-Message-State: AFuF++mwZjc1wXtfwIEVqDHux+buw1m/Lh/IjJjKEnMgbGTCQydWDc40
	8Dwq3rH2ONObLHAI9wQRTg/JojVIyypfBy77Tviy0/Uz+CDXP8NPaEhhtotP+EXNNPrIJQSk0xA
	AqxYC
X-Gm-Gg: AYBFou3xhTLzMwxGwphqkFx38Ff786jtlLGfyYz9aUs/0NfvMRk0NZJ20YH1/aSzP+6
	jdPQ7pSrhs8ticRzlvHGKoMW7Kz4CCICLSTJRB6njpcsFrwCjq162TVEMZtr54v7kK903Kjo5aV
	3WxDyVzBzBDy2xm6EGp1/PGJdjDOaCZO5lNz5kR9mFuHT/3WCD0he/YoFWBEdf8v8Oe0SQIcMvZ
	RYodUL6irq5ViAfdcoei+o+IDt17Dpx7CjnE9lULMVr7k6854D6I25bhFbMxM5qJkbnrX+dfNIE
	MKfLz7ZHRtVB9o2smLOVxJS8/Cg95kVzl5Ubdn7jZc36pfy43PVJ/8tJfR1GX7Odr4PqhCpflg+
	tNdeX/N2ASprO5EVW77Ykwlg/AGgnHnZuT6P+3XSWwox9v7bpiWHzuDG95O7mc5MdIB8l/f0hka
	+Tzb6PaLEkIipBrziZoaq4t/mJ/BEEUKK4hThPJa/wps0T3gzaol0NJNbXFuF864BE/mnOSyNdm
	Ybg5u48z34g+09fKO+XQgTtIDQzUjbRSw==
X-Received: by 2002:a05:6830:4890:b0:7fa:ac4f:79a with SMTP id 46e09a7af769-822854529eemr3303325a34.22.1790959377314;
        Fri, 02 Oct 2026 09:42:57 -0700 (PDT)
Received: from bcodding.csb.hammerspace.com ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id 46e09a7af769-8227a66c6dfsm3238524a34.23.2026.10.02.09.42.56
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 02 Oct 2026 09:42:56 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
X-Google-Original-From: Benjamin Coddington <bcodding@hammerspace.com>
To: Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>,
	NeilBrown <neil@brown.name>
Cc: linux-nfs@vger.kernel.org,
	Daire Byrne <daire@dneg.com>
Subject: [PATCH RFC 0/2] SUNRPC: dispatch ready transports round-robin across clients
Date: Fri,  2 Oct 2026 12:42:53 -0400
Message-ID: <cover.1790953694.git.bcodding@hammerspace.com>
X-Mailer: git-send-email 2.53.0
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

This is a third pass at the problem from [1] and [2].  It's the design
Neil described on [1], close to as he wrote it: a client object per peer,
a queue of ready transports per client, and a queue of ready clients per
pool.  A pool takes turns across clients instead of across transports.

I owe an explanation for leaving sparse-flow behind.  Two things:

The re-arm trigger Chuck asked about on [2] is a cliff wherever it's put,
and softening it means picking between watermarks and decaying credits
against real interactive workloads under load.  I ran some of that and
found the behavior depends on timing from several actors at once.  I
don't think I can characterize it well enough to defend a heuristic.

..and Neil's objection on [1] holds: the interactive frame only works
for clients with one or a few users.  A latency floor helps a client
while it's idle between requests.  What I have is a data mover with a
lot of connections sharing a server with clients that keep I/O in flight
themselves, a re-export gateway for one.  Sparse-flow puts those in the
same queue as the mover and they split the pool by connection count.
Neil asked then whether fairness between a client with one connection
and one with sixteen wasn't what I wanted -- but it is.

Approach
--------

Each transport belongs to a client, one per peer address and network
namespace.  A client has a queue of its ready transports, and the pool
has a queue of clients that have something ready.  A thread takes the
client at the head, dispatches one of its transports, and puts the client
back at the tail if it has more.  So every peer with work queued gets one
dispatch per round, however many connections it holds.

Enqueue is still lockless.  Dequeue takes one more lwq lock than before.
The client table is only touched when a connection is accepted and when a
client's last transport goes away, so there's no lookup on the dispatch
path and no RCU.  Listeners and UDP sockets share an anonymous client.
The one piece of Neil's description I left out is moving a transport
between clients.

It's always on and there's nothing to tune.

  patch 1  track clients by peer address, no change to dispatch
  patch 2  dispatch round-robin across clients

These go on top of the svc_clean_up_xprts() wake fix I sent separately
[3], on nfsd-testing.  That's the pre-existing issue Chuck asked me to
look at on [2].  I've only compiled them on nfsd-testing; the numbers
below are from v7.2.

What happened to the review items from [2]: there's no trigger and no
credit to tune, nothing is classified as batch or interactive, and there's
no priority tier, so nothing can be starved.  Control events take turns
like data.  A close queued behind k of its own client's transports gets
dispatched k rounds later, where today it waits behind every queued
transport in the pool.  I didn't add a separate queue for them.  I can if
that's wanted.

Results
-------

Same harness as [2], with one change: every load group now comes from its
own source address, so the server sees it as one client.  16 threads, 10ms
injected per op by the same test-only hook (not part of this series).  A
is v7.2 with the hook, and B adds the wake fix [3] and this series.
NFSv3 burst completion p50 in ms.  NFSv4.1 is within a few percent in
every cell.

Interactive burst of 32 against one busy client with K connections
(unobstructed floor 45.8ms):

    K       4      8     16     32
    A    82.8  249.0  439.9  838.9
    B    73.5   90.1   94.6   90.0

That's two clients taking turns, so about twice the floor, and it doesn't
move with K.  Against burst size N at K=16 it stays about twice the floor
too.  There's no knee any more:

    N        1      8     32     64     96    128
   floor  14.9   31.6   45.8   72.5   98.6  123.6
    A     31.6  125.3  440.0  865.8 1290.1 1705.3
    B     18.0   40.2   91.9  151.3  217.4  278.0

What it does scale with is the number of busy clients.  M clients with 4
connections each, burst of 32:

    M       1      2      4      8
    A    80.9  245.3  441.1  839.0
    B    75.0  112.5  158.3  252.3

That's the cost of dropping the priority tier.  A light client on
a server with a lot of busy peers waits its turn behind each of them.  It
still beats waiting behind each of their connections.

Share of the pool for a client with 2 connections against a client with K,
both backlogged:

    K        4      8     16     32
    A    46.3%  19.9%  11.1%   5.9%
    B    49.4%  47.6%  47.9%  48.4%

Six movers, against clients that are backlogged too.  Share for one
client with 4 connections, and for four such clients together:

                         movers at 4 conns    movers at 8 conns
                            A        B           A        B
    one client           14.3%    14.3%        7.7%    14.3%
    four clients         40.0%    40.0%       25.0%    40.0%
    one client, 1 conn    4.0%    13.0%        2.0%    13.0%

A client that already matches the movers' connection count sees no change.
What changes is that the movers can't buy more by opening more.

Chuck asked on [2] for something real rather than the synthetic victim.
A kernel v3 mount with one connection (noac, lookupcache=none) of a tmpfs
export, walking 2000 files with find | xargs stat (about 26k RPCs) and then
reading with four fio jobs, while the 16-connection aggressor runs from
another address:

                    alone (A / B)     loaded A    loaded B
    walk            1.53s / 2.08s      328.55s     107.74s
    fio 4k IOPS     21876 / 19776           80         777

Both loaded columns are worse than a real mix would be.  With every
request taking exactly 10ms the threads finish in batches, and a request
that shows up mid-batch waits for the next one.

Aggregate throughput is the same A and B in every saturated cell (about
1280 vs 1290 ops/s).  With every group on one source address B gives A's
numbers back, which is what I'd expect.

For the cost on the dispatch path I used fio over a loopback mount of a
tmpfs export, 4k O_DIRECT reads, nconnect=8, five 20s runs each: 95.5k
vs 95.8k IOPS at 16 jobs and 139.0k vs 139.2k at 64, A vs B.  I can't see
a difference.  That's one client on a KASAN kernel, so I wouldn't lean on
it too hard.

What this doesn't do
--------------------

Peers are told apart by address.  Everything behind one address shares
one client's turns: NAT, a gateway re-exporting for a lot of users, pods
behind a node address.  Chuck raised this on [1] and I don't have an
answer for v3.  For v4.1 the clientid could be the key, but the transport
would have to move between clients at session bind and I left that out.

Fairness is per pool.  With ten pools (pool_mode=percpu) a client with 2
connections against one with 16 got 26% where a single pool gives 49%.
v7.2 gives it 12% there.  Now that pools are per node this matters
more than it used to.

It equalizes dispatches, not thread time.  A client whose requests each
hold a thread for a long time still ends up holding most of the threads.

It's fair by host, not by class.  Six movers get six turns.

A single connection with 16 requests outstanding gets about a third
against a client with 8 connections in my synthetic harness, not half.
From tracing, its transport is dispatched within about 150us of becoming
ready and alternates with the other client, so I think that's my load
generator not keeping one connection supplied.  I haven't measured the
share a real single-connection client gets when it's backlogged.

Questions
---------

Is the anonymous client the right home for listeners?  A connection flood
gets one turn per round that way.

Does anyone want the pool_stats or a tracepoint to show clients?  I left
observability out to keep this small.

[1] https://lore.kernel.org/linux-nfs/cover.1780498019.git.bcodding@hammerspace.com/
[2] https://lore.kernel.org/linux-nfs/cover.1782314746.git.bcodding@hammerspace.com/
[3] https://lore.kernel.org/linux-nfs/5b162e1a03d59bd0d3cc479891965834d0d4f0c8.1790948398.git.bcodding@hammerspace.com/

Benjamin Coddington (2):
  SUNRPC: track service clients by peer address
  SUNRPC: dispatch ready transports round-robin across clients

 include/linux/sunrpc/svc.h      |  34 +++++-
 include/linux/sunrpc/svc_xprt.h |   1 +
 net/sunrpc/svc.c                |  36 +++++-
 net/sunrpc/svc_xprt.c           | 191 ++++++++++++++++++++++++++++----
 4 files changed, 240 insertions(+), 22 deletions(-)

-- 
2.53.0


Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=178.63.21.144
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793945276;
	b=yF7ngJhqbabKxYzC6w57eARlKuP9uX+TmuZx21LH2nRS4pj8wQrC5XO5SUWYMlSM6X0W
	 YGxu79y8sBQyc2h28gK6ExHOJQrZkaBqrYupds/7p09FySdsB8VTvtVoS9gkg1SUsbZjQ
	 Qlir4d/agpxPa2zDqgU0unZghVpZ385op1Sl5BMiKh6NK1aSCf0Q7Vos7QH8w/ZmzNBMT
	 TLhtJlYrv/z7UrrQcAGnYPsF+IoQ8YdNM+ytZK6waAfH0R0Rp7k3tw00rv5o9T6CBW//+
	 uPDb89zJm7OGZ8rjHaiV/1ijlDo/8j19UwHxIwdMFVyu3THiG47/5AlucJ6i+YpB9/w==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793945276;
	h=DMARC-Filter:DKIM-Signature:Received:Received:Received:X-ME-Sender:
	 X-ME-Received:X-ME-Proxy-Cause:X-ME-Proxy:Feedback-ID:Received:From:
	 To:Cc:Subject:Date:Message-ID:X-Mailer:MIME-Version:
	 Content-Transfer-Encoding:X-Greylist:X-Virus-Scanned:X-Virus-Status;
	bh=xrii6SIU+qxyuqPwVHrMrhLnkskiBOzLTdTq8uav0D4=;
	b=RXanGeHSf7AMYi628znpzWhWE7yyiV2AfGZBdVLl139u2dvJ3UR67AvyO2lmZ8hA1Q4v
	 CmxSrSGGpFGr3uUkaXstanMOjPZR9VuU6bFomOc3SYZ7vD//Luea5SLG1wtLd/nGwkagA
	 MC9vy7WNw59kaiFfZTvK3z9Nmvk5nA7QSzI0y/N6A9O7GT8/K2bxnzi7MZg0dO+LNQMZc
	 w+WK3C9txsGYD1uZ6iSacIfZJJTis7wXG/XRzU3L8sut8UdPxvLWNKXCFfXcD4BUpK64+
	 RX7GsttG+3EIWJJTdqwZ0J8NvMd0ypFJv4klufxhZeocRzQ4rcElW2uYQAJdT0jt2RQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=sericyb.com.au;
	spf=pass smtp.mailfrom=shining.glasswings.com.au;
	dkim=pass header.d=sericyb.com.au header.i=@sericyb.com.au header.a=rsa-sha256 header.s=shining header.b=dSDHHsY5;
	arc=none smtp.remote-ip=178.63.21.144
Received: from shining.glasswings.com.au (shining.glasswings.com.au [178.63.21.144])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id AD696606A326;
	Fri,  6 Nov 2026 06:07:54 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org AD696606A326
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=sericyb.com.au
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=shining.glasswings.com.au
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=sericyb.com.au header.i=@sericyb.com.au header.a=rsa-sha256 header.s=shining header.b=dSDHHsY5
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=sericyb.com.au;
	s=shining; t=1793945267;
	bh=f1UM51SyvQSYNrUdbBBbFyZ8Wcbkg+Aekj1lQIOxtbM=;
	h=From:To:Cc:Subject:Date:From;
	b=dSDHHsY54pxmp3+WWPvxg3LkiWFYdr0bn8iKiEykRLfQxCc227W6LLFly0nj+vTU2
	 vy1TQzwxdXU5LQYCHg4PVItTtNkFnq79qT5lk4k7AdLv7xG3B81HI/xpDkGGcS3NAk
	 ilQp9MRwieI2HuqtOXkLvX81ZODJh6rNGGqB4n9YD6v5lkWYT4DZalg2IWumI8vHCg
	 e+0PXUoAH0nvZElXanLJoI9PJ5SkDHGbF0vTxiereNYAuUgJpL7GHAaN7aUF6BJzcv
	 0xnvM0ilQyzCtGhsbL2Q3tBzdSOJd+ACpNtu7mTBbIzvBhNBp2UYr9pYo6n3PWDqJ3
	 pev2cI4GLQ5lg==
Received: from fauth-a2-smtp.messagingengine.com (fauth-a2-smtp.messagingengine.com [103.168.172.201])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by shining.glasswings.com.au (Postfix) with ESMTPSA id AE32D10924103;
	Fri,  6 Nov 2026 06:07:45 +0000 (UTC)
Received: from phl-compute-04.internal (phl-compute-04.internal [10.202.2.44])
	by mailfauth.phl.internal (Postfix) with ESMTP id 94B8AF40066;
	Fri,  6 Nov 2026 01:07:44 -0500 (EST)
Received: from phl-frontend-03 ([10.202.2.162])
  by phl-compute-04.internal (MEProxy); Fri, 06 Nov 2026 01:07:44 -0500
X-ME-Sender: <xms:sG7taleNKQkIX5cnxRopJkfikPrcCeoYasmM36zI2s4HZGO31juXjw>
    <xme:sG7tatlsFoEvIVmtAHmMNob4-6_o6h6gvQ-LpM5yH3E4scXO3bieJ8L_KEoEpi1Tv
    VJdoGcjCb2XlEk8cTP0AzYZLOeeFJImRelEpYtS4miVyv6JAuNkTiEE>
X-ME-Received: <xmr:sG7takruKU_JAjEzhXu9fHtXwc86rOdsdrjpC2zH1n0gM47W09Relsw5YRcedaXd7bq9fnrqUjN5WUdGeayNews35QfcjHrsVdSaWzuRZ9I>
X-ME-Proxy-Cause: dmFkZTF5zp9N70rTNNyRObcsbNLCHEblCJV1PhIAp82kWTvcMs1ApYibyC2wxAfXy1BwF7
    stD+QmUpltJrsJaZ8Xwc5n/zK/SxEVN+t71K9iQoIys8M/EJ3LB6GDy6gXvE6v9y6sMvRi
    HyByzbZmvj7CPriPwHn2RHrIkQndbRyqT+fdqcA2TtPFwDzH7hf/WSYjYGv3OiD04bwKHq
    pMvZGjW7dIQPNAfTAB6JVZvp/ZBsMYiU0ayoS710t9b30yGsGXL/EDp4a2bW02q4Gdu+FG
    nqaxsSifd3Ete63zO+T9nZIeTHUjXdqXEPIQi5VRpJOjt9VYSFghyet8NDeryIjqy96llx
    t5bCJ79uy23ojGDs7xy8QFEd7v1ZDVcu5LFhYh5iuia+qGbQoPo88LZ9P48lt2F0Yh2LOH
    7knxNUhuXthOLrXaHZos6YkQM+BKNCxso0Nuq+WStfsFxBP/FT+URapNvThhw6b/LoBS9n
    +tl6FVqOQ2Tcsz5wXpn6411t0pxD6ScM3142PGwU4NCvSoC/NVe6mkGb2FIRIH4FfOuvmN
    o6Vp/uXd89+x/fBUqbjLL3WShGi/Rc7uNDT2rhq/GO/rrJdjKGwB5cEb06oEQH2w+8GXRk
    e23+bazX4P/Ed2fs6h30i3xioAY//0yiE+GARdby5qQLBbfIDN5EP6IDzbkQ
X-ME-Proxy: <xmx:sG7taqEVkFTDj6NCSZ51EHGEolvaUtTYXAceIQaCQ5zgbnY4sWaaSg>
    <xmx:sG7taqTgXpfmmBKEO_di--uypA9q4M3UA0O6w0zo7u4GMsEXVJsIrw>
    <xmx:sG7tagNxEzSf6WKABU15jpgT-65H9CjHqFCMdwASsYZq7BVMK1N2Kg>
    <xmx:sG7tanlAd81erHrICBHDRrWcwVB-SGmw3ox-LLidbOE8fBGEF86SKA>
    <xmx:sG7taib50FMh40SJPnsy2NQajS1mbn2fjh6SGncwYWobodBjQyPyEzUf>
Feedback-ID: i558e4b61:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Fri,
 6 Nov 2026 01:07:40 -0500 (EST)
From: Andrew Pam <andrew@sericyb.com.au>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: Andrew Pam <andrew@sericyb.com.au>,
	Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>,
	NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	"Rafael J . Wysocki" <rafael@kernel.org>,
	linux-nfs@vger.kernel.org,
	linux-pm@vger.kernel.org,
	netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 0/3] SUNRPC: keep NFS client connections consistent across hibernation
Date: Fri,  6 Nov 2026 17:07:28 +1100
Message-ID: <20261106060735.637295-1-andrew@sericyb.com.au>
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
X-Greylist: Sender succeeded SMTP AUTH, not delayed by milter-greylist-4.6.2 (shining.glasswings.com.au [178.63.21.144]); Fri, 06 Nov 2026 06:07:47 +0000 (UTC)
X-Virus-Scanned: clamav-milter 1.4.6 at shining
X-Virus-Status: Clean

An NFS client that hibernates with a mount active can resume with the
mount hung, until the server's nfsd is restarted. The underlying
problem was described on linux-pm in 2011 ("hibernate hangs TCP") and
not fixed. This series fixes it for SUNRPC clients.

After hibernation takes its snapshot, the kernel thaws devices, the NIC
among them, to write the image. Freezable kernel work stays frozen until
the image is restored, but rpciod, xprtiod and the NFSv4 lease renewal
work are not freezable. So RPCs are still sent and answered while the
image is written, and TCP acknowledges data from the server, none of
which the restored image knows about. On resume the client's TCP
sequence numbers, its acknowledgement point and its NFSv4.1 session slot
sequence ids are all behind the server's. Depending on what happened in
that window, the client:

  - resends data that the server discards as a duplicate, so the
    connection carries nothing;
  - gets NFS4ERR_SEQ_MISORDERED on a slot indefinitely, while the state
    manager waits in nfs4_begin_drain_session() for that slot; or
  - waits for replies it acknowledged before the restore, which the
    server will not send again.

A partial overlap also makes nfsd read the middle of a request as a
record marker ("svc_tcp_read_marker nfsd RPC fragment too large").
Patch 1 includes a capture from a Linux 7.0 client and a 6.12 server
showing the first two cases byte by byte.

Patches 1 and 2 make rpciod, xprtiod and lease renewal freezable, so
nothing is sent after the snapshot. That keeps the session slots
consistent, but not the receive side: TCP still acknowledges replies
that arrive after the snapshot. Patch 3 therefore disconnects every
client transport once the system has resumed. Requests in flight are
retransmitted on the new connection, and the server's reply cache
answers any it has already executed.

Tested in QEMU/KVM on 7.4-rc2: a 7.4-rc2 nfsd with a 10 second lease
and an NFSv4.2 client hibernating in test_resume mode, with the image
write throttled to 81 seconds:

                                         unpatched   1-2 only   1-3
  RPCs received during the image write       12          0        0
  20 hibernations under continuous I/O    hung at 1  hung at 6  20/20

Every freeze of kernel threads completed in 1 ms or less. A capture of
the stress runs confirms patch 3's case: the client's acknowledgement
went backwards on the cycle that hung with patches 1-2 only, and on two
of the twenty cycles with patch 3, where the client reconnected and
carried on. The test harness (two busybox initramfs VMs, no root
needed) is available on request.

Not addressed: the same window affects every active TCP connection, not
only SUNRPC. Keeping network devices quiet while the image is written,
or resetting TCP connections on restore, would fix that generally, but
would need agreement between the PM core and netdev. This series fixes
the case where protocol state outlives the connection and the client
cannot recover by itself. Patches 1 and 2 also freeze rpciod and xprtiod
during suspend to RAM, which is harmless there.

The analysis of the packet captures, the patches, their changelogs, the
QEMU test harness and this letter were drafted with an AI coding
assistant (Claude, from Anthropic), working from the hung client and
server, their logs and captures. It also ran the tests. I have
reviewed the patches and am responsible for them.

Andrew Pam (3):
  SUNRPC: freeze rpciod and xprtiod across system sleep
  NFSv4: run lease renewal on a freezable workqueue
  SUNRPC: reconnect client transports after resuming from hibernation

 fs/nfs/nfs4renewd.c      |  2 +-
 net/sunrpc/clnt.c        | 85 ++++++++++++++++++++++++++++++++++++++++
 net/sunrpc/sched.c       | 11 ++++--
 net/sunrpc/sunrpc.h      |  2 +
 net/sunrpc/sunrpc_syms.c |  7 ++++
 5 files changed, 103 insertions(+), 4 deletions(-)


base-commit: f66469d9905b39d2c260a15d7d6db450f4db67c1
-- 
2.53.0


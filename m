Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795535059;
	b=MPDrGnMmHTupnGJnofehEKWirSevjysL6Yr1doimtmeSti08heUnm82p+URIpGcSxJEu
	 JaRYEKxbKx5XipYwaOAzM/LCVcaigjpoHpj+5sJEyzVpUCGujHUE6bkRcKjHhzlNQDYOD
	 yzFN9U/4LDDy+YjKQw/0VBABvOm7ZKdFXbmhEB7KqCmPmc5bJ/VjXTkVw3x8zCH9FEscd
	 Avkst5foITNyRdQ1Uf6Aw79jbAzX8TJ4XKZQELDmoZzoA+IOxgF/KW7FP6FYBp5991xru
	 3AJjqaf3EfOaXaN4v0viFLRkk0LoMfONbUtceNGjVcZqni4+rM1zQOxg768yBzcNweg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795535059;
	h=Received:DKIM-Signature:Received:Received:X-ME-Sender:
	 X-ME-Proxy-Cause:X-ME-Proxy:Feedback-ID:Received:X-Mailer:
	 MIME-Version:X-ThreadId:Date:From:To:Cc:Message-Id:In-Reply-To:
	 References:Subject:Content-Type:Content-Transfer-Encoding;
	bh=hYa5jI4sBfdZ5+ynStkvD4T9Wxx6UdnF4uKYGcJYp9E=;
	b=kJ7ooC2LG8K6R/ZUa2LIkbDgsFjAIwhv+QdgWpQY8PBh4K3siQYgCMAsqCzucKiO1vAb
	 7U1WkGIasy3yeL4Fd2ywK5VYgEwmo+75JMkcOtaWE1uyuCml6FPEZdpuGwQ27uo8TuJ66
	 hucpHmqhEM3ZmwNa3O67XiJQ0IH+zObH4v18i2kdKdz56UJN7N9Yow9tVHlLLnKzS0Kpv
	 XcaMgRsOyHmma0e2eyJOhKP0iMz+TEsWv/gKcW/gK7zJxW5nW8ctD7JO8W7UrAM/iindj
	 yjMzHImzzTXe0joaZsc/yzWeCNr2y9sDIUgVy3JFq9Hmbt6OEjSmFeDTsyGmMbgTu6w==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=cZcUXnbK;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0AB60606A335
	for <linux-nfs@vger.kernel.org>; Tue, 24 Nov 2026 15:44:19 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=cZcUXnbK
Received: by smtp.kernel.org (Postfix) with ESMTPSA id B786A1F00A03
	for <linux-nfs@vger.kernel.org>; Tue, 24 Nov 2026 15:44:18 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1795535058;
	bh=hYa5jI4sBfdZ5+ynStkvD4T9Wxx6UdnF4uKYGcJYp9E=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=cZcUXnbKQ+RQpQcB5yojqafmP7mf7XfsSRNPYAAILUGJWTH+T5wNydiX6KUsLHHVd
	 qUd6LqVR1ANBInAXRm04BcrddhPW9FqpY6Pbqw0u3bYtyPoJn/9pXrNM0dQRqkTJXq
	 Bfs0cnI33ylcThyDpSTJ+F1nNaGy++A5/FufkgpSTM6dRouVLsgvxduwBLeW+CzCsP
	 6ZMth2KvQu2Is/DFKFDpGYYvdUnSeU20Rnwlddq0fvYLXQsX/SZ8nM2//eslQVfqhS
	 YG1IeKfhJjX6TFyvyIvqTj9bcUgbfaX+uMzqUpog7dE61ElQIKbQGRwY+44UJZs3VY
	 5ZXqKpAbBtZtg==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id E6020F40066;
	Tue, 24 Nov 2026 10:44:17 -0500 (EST)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Tue, 24 Nov 2026 10:44:17 -0500
X-ME-Sender: <xms:0bAFa73cqeN_mT5_eTbzITN5BDy-x9r3IQSwey6o4Xkbhx7vEEDbKA>
    <xme:0bAFa06eb8ulwjXhBzlJBxJyx6c08TgVCVVOwYH14CTQKivQUcqVXlfbr4NzBHMxa
    FBGdraAM22pt1MwBUFBIxoP2owo273uCkRGLzOnwZL4DxkcuCuk7hAX>
X-ME-Proxy-Cause: dmFkZTEJfo7yR7uyX2uKmdBv9HMMsVaYMGkYZR9yVRaMhor+pxgufW8LviRO5G6d+c2z9D
    iCW3zkBf6Ye4W+lcxfonoj1JdjjdKYJ2MCXOtyGJZ4ROHuFmZgwKUx+DK97ppQUuRzA4/K
    GpS57riB+KFqBwNd8xVHNLzA1+LdC8aI7NQWz1XARyUqFBYuc/6oJsW3445pH9PTBrIfRK
    IZ2FVRJuH3N+OykZvlAssxccUSfADdCuLD2q9EpbzLCXUwR/YtJX/SfAGAMgOGiGlGaJ89
    8hGWSeyBeaap6tkK9Rr+NXloiIVP5/jfVZz7+5dc/omBSN9knC8axbiLriayZlWVvShaku
    iFNXxlQAJELgeMOCVvHfldVIwQC5RqIUZWOLNmWVb97jlxno0B6MNNzqL3JeAIJ01Did30
    qLv37G5JTSDu1/ZhvCbSDmMvugbpF8BAhmi0I9ubJwbxEc7DjFdsjuTqoA8g0F8Wasfcxn
    zSM4RYP4r5qnvGn6s90s0hwNsidM5vRUSpv8BX6jpGHbXweBaS9Ed8isqes5zI82d9dTfK
    /jmeXk8n4zVuuD+d9vKvi9+yNVASiPd5v9f2FhCfCVifTnmR2UpMV0Wyc4vNMFseSyJAWR
    XzGMCWAeVseTlMHws9OrbTT9/T0JdPywRTelLDecQE+Q6fyggcHD9eHD0v1w
X-ME-Proxy: <xmx:0bAFaxcLcdjorqIJzBMhbaPCfZbIl3WjMvIbajCBAyKbRPP37RrI0g>
    <xmx:0bAFa9BwbLy7lT3HGjD5SzyYsmVmPRGEP61M6g6-r19uyPw4vRpN7Q>
    <xmx:0bAFa08eiLSbTboNDgIhqtfggVXa8JQHX6gA_KeHnf8s28U3cF5Wdw>
    <xmx:0bAFa4IvmuqcjVawGoAyn_71ahiXtkgE7w0uTh2N5I2UoAxpIN4_nw>
    <xmx:0bAFa9gZGHoG5dPtfU0K__hrUGifHYukpfxrKeUqPBarQyyCVo1u5rDw>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id C34D2780070; Tue, 24 Nov 2026 10:44:17 -0500 (EST)
X-Mailer: MessagingEngine.com Webmail Interface
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
X-ThreadId: AkK9xiJcrb7R
Date: Tue, 24 Nov 2026 10:43:57 -0500
From: "Chuck Lever" <cel@kernel.org>
To: "Rida Shamasneh" <ridahani@gmail.com>,
 "Calum Mackay" <calum.mackay@cdmnet.org>, "Jeff Layton" <jlayton@kernel.org>
Cc: linux-nfs@vger.kernel.org
Message-Id: <525d6d4a-f015-415a-a4b9-9ffdbb8966be@app.fastmail.com>
In-Reply-To: 
 <CANkg2rNRVyYLYLaVnCz75nYvC0DAKrphNazX1Asacf8MuBnxAg@mail.gmail.com>
References: 
 <CANkg2rNRVyYLYLaVnCz75nYvC0DAKrphNazX1Asacf8MuBnxAg@mail.gmail.com>
Subject: Re: RFC: RPC-over-RDMA client transport for pynfs (testserver.py --rdma)
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

[ Corrected Calum's email address ]

On Mon, Nov 23, 2026, at 4:08 PM, Rida Shamasneh wrote:
> Hi Calum,
>
> (Resending in plain text: my first copy was rejected by the list for
> having an HTML part.)
>
> I've added an RPC-over-RDMA (RFC 8166) client transport to pynfs, so the
> NFSv4.1/4.2 tests can be run against a server over RDMA:
>
>     ./testserver.py --rdma SERVER[:PORT]/PATH <tests>
>
> Before I clean it up for submission, I'd like to know whether you would
> be interested in having this upstream, and how you would like it split.
>
> WHY
> pynfs can only exercise a server over TCP today, so the RDMA transport
> code of a server (svcrdma in nfsd, for one) gets none of the
> protocol-level coverage the tests give it over TCP. This runs the same
> tests over RDMA, including chunks, the backchannel (RFC 8167) and the
> connection setup (RFC 8797).
>
> WHERE
> https://github.com/RidaShamasneh/pynfs/tree/add_rdma
> 17 commits on top of master, about 3,000 lines added: ~1,200 for the
> transport (rpc/rdma.py, rpc/rdma_verbs.py), ~1,350 of unit tests
> (nfs4.1/rdmatests), ~150 of README (nfs4.1/README, "RPC over RDMA"),
> and the rest glue in nfs4client.py, nfs4lib.py, rpc.py, testserver.py
> and environment.py.
>
> WHAT IT DOES
> - Pure Python and no new dependency: it talks to librdmacm and
>   libibverbs through ctypes, loaded when the first RDMA connection is
>   made. TCP behaviour is unchanged (apart from the logging fix below).
> - The inline size is negotiated with the RFC 8797 private data (4 KB
>   with nfsd, 1 KB otherwise).
> - Read, Write and Reply chunks. The Reply chunk is sized per call from
>   the session's maximum response size and a bound on the COMPOUND's
>   reply. READ data goes in a Write chunk. The data of a big WRITE is
>   sent from the caller's own memory with a Read chunk at its position,
>   so nothing of it is copied in Python.
> - The backchannel works over the same connection, with separate forward
>   and backward credits.
> - A lost connection fails the waiting calls at once, instead of leaving
>   them to pynfs's 300 s timeout.
>
> TESTING
> Against a Linux nfsd 5.15 over soft-RoCE (rxe), the pass/fail results
> over RDMA are identical to TCP, test for test, as NFSv4.2 sessions
> (testserver.py's default minorversion) and, for the 179-test subset, as
> NFSv4.1 sessions too. That subset is what I used as a regression
> (exchange_id, create_session, sequence, open, rename, file, dir and
> others). The remaining groups (copy, xattr, deleg, pnfs, flex and
> others) and courteous/callback were run as NFSv4.2 and also match TCP.
> The failures are ones nfsd also has over TCP. The reboot group has not
> been run over RDMA. The transport has 80 unit tests of its own (from
> nfs4.1: python3 -m unittest discover -s rdmatests -t .); about half of
> them need no server.
>
> NOT COVERED / LIMITATIONS
> - Only tried against nfsd 5.15 over soft-RoCE: no iWARP, real hardware,
>   other servers or RPCSEC_GSS.
> - Client side only, and NFSv4.1/4.2 only (nfs4.0, nfs3client, the proxy
>   and the data server are not wired).
> - No reconnect: a lost connection stays lost.
> - Some of it is nfsd-specific (5.15 wants the Reply chunk to cover the
>   whole reply even with a Write chunk, and mishandles a Write list with
>   more than one chunk). It is documented in the README.

Fwiw, I'm interested in seeing pynfs get RDMA capabilities. Or, as the
kids say these days: +1


> A SEPARATE IMPROVEMENT FOR TCP TOO
> While measuring I found that rpc.py formats a whole reply with %r for
> its debug logging before checking the log level: 2.6 million characters
> for a 900 KB reply, twice. Passing the arguments to the logger instead
> makes a 900 KB READ over TCP about 2.8 times faster (48.8 ms to
> 17.2 ms). It is one small patch (c99c9b2 on the branch) and I am happy
> to send it on its own, whatever you think of the RDMA work.

IMHO you should post the TCP improvement before.


-- 
Chuck Lever

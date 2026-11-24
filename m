Authentication-Results: smtp.subspace.kernel.org; arc=pass header.oldest-pass=0 smtp.remote-ip=74.125.224.54
ARC-Seal: i=2; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=pass;
	t=1795556697;
	b=ggTl8h6tbbEQWzHi6jBbr0iTxUwx4emNS98CAgI0QlEaAgCIi61K1zXy3NxJNEM/e1xG
	 CZ8YBLo3a/WfsaZ6/uYG+S5AUYzV0CmN9uB/f59IQ5PD/bM6LwwsrpfvTL+fIXfzy//Rz
	 Gow7o/AuXzSaLwKe4ia6fOC4weZH2qFPzADbXGy1FSUE3I6oV9BAOGvxqZx+oCFWZswaT
	 vQmYqfU96jyzx1qHmgg59tvjk00IAsbEe50DjZ7W1ri0XwFUQZxjzjvvHYQAd9kDJaz83
	 7KpSpAHf/HhWMRbZ2hH+FKtKIMB8GxEOBTX2MgzEzffPnC06QWfmf8qYnOXFGjtcs/Q==
ARC-Message-Signature: i=2; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795556697;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:
	 MIME-Version:References:In-Reply-To:From:Date:X-Gm-Features:
	 Message-ID:Subject:To:Cc:Content-Type:Content-Transfer-Encoding;
	bh=mhBBcvigEeJv8WwgmT61lN2C87AqVrn19gaexCd3NZo=;
	b=bFlfPXoxsO8HKA7X5dYlS0tzlDVz9D7LsSTT5t/CJP7em36C6e0oYfyQLjjy/W2VlNSW
	 bNqpzi7czEV5XWx5UfbrI1v+iQpMudMOWeKHcB4nIYTRg9Vii2vtW8icEw/IPWe2Hnupr
	 2dwfeIQEOobaTjNPag51lKB63AvKPN/hRJMEwdyYo33+CITo9Nf4pnTHfV20Phk/LXgb9
	 CDEZmwgq16NWKmtz/wIEml/LsgeCyz3DAtyRGkTznr6lznIjn0rRJjt3lwBfmSMXEpKV0
	 f5clElnNMJe7E7laOCmDkvVgXDlgezsJjZgZC3lWTX0klOiib4vg73bMRocgOuQGmuA==
ARC-Authentication-Results: i=2; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=GtywVkXK;
	arc=pass header.oldest-pass=0 smtp.remote-ip=74.125.224.54
Received: from mail-yx1-f54.google.com (mail-yx1-f54.google.com [74.125.224.54])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 98A83606A33A
	for <linux-nfs@vger.kernel.org>; Tue, 24 Nov 2026 21:44:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 98A83606A33A
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=GtywVkXK
Received: by mail-yx1-f54.google.com with SMTP id 956f58d0204a3-67da3d03263so5343865d50.1
        for <linux-nfs@vger.kernel.org>; Tue, 24 Nov 2026 13:44:56 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1795556696; cv=none;
        d=google.com; s=arc-20260327;
        b=W4l8Hx1l49IQvJKYJCz8huLpz2+sFrWG43K2NBPLU6njPUYdckbhJ2UOfLY9YVZ98N
         03S/4vXsldiI0mbaeLXeJDByTNcD9CYmWxTsyCBn1sLovw5+yCOgYSEYEYbIIGbvaXHk
         UyCCeLyVVJBfBcWeonY2rK39uusspM+zuJzgTXyDvFlygO+yL0yB7EHjLZioJMhOkkDD
         /DIID2p0AGolfPxXdD7dT9eGzkWz9ZuPjwbMimYvfsKb1Y2QW8kqMoUqNlXDscmuPqOc
         VqGDxFckwvcTOsoFC+uUCmbblHk33LDazgsQs5lxH3eqHNp5sjJmLFRiAYouteQ9+66f
         ZiaA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=mhBBcvigEeJv8WwgmT61lN2C87AqVrn19gaexCd3NZo=;
        fh=l5BSUo7U7MOAz4BquPRKZAhqtIDnKiMp69LK7X/JLl0=;
        b=W+aQFAdDc+/sQNp2PDC9ie+nL9L5Nv7kqnrB/rl/QXOOd6dONYS5oL7OQGlVMk0ja5
         wQCcHdyPF7cGWBO9VQcwGuj21tQjb4OgwUf6V3Kxyi3Br7bNeDurlVGok6C5TZues26x
         eO1NYFfnme9fEyrZRpMVkNa7So9WRUylIdHXnndiXHQRFM4VsCJxd9FQqz5IlVAN0zMa
         1TGPG5yFcdtDoAeZe2+KaENsGERxVXrv+MslVEHE/F9j/cGPk4aoj1QxKRhbw2W72+fd
         nXbz9CRKS4JPvho7/RHRAMA3aeCBy12hRI3MdbD+2bCppe4L2XbeRq3B1aVQQ/IOW0Qz
         wRlA==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20260707; t=1795556696; x=1796161496; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=mhBBcvigEeJv8WwgmT61lN2C87AqVrn19gaexCd3NZo=;
        b=GtywVkXKqe+qOuTcTWa78La+/7eGkXu8s5mvc3JnjpXNB1LeMxRwtT2JjMJOp5OxnJ
         IV4Dkmr7Mr4AdQDIphWzmoPt7LB6ltbP0OffoDZx19gTeocJHMekAppSszw3Au7PO5U0
         KEI21BSF9w+e69CSHw6fJhmvwVMzMTNFmrEsWzO3tY/9VpmdHfqhWPaA7eotRb46kDbd
         jHF+JXNngfNXFuzKFM6aeskvzhx7K3L1IXC6m+RHTfQTVzkoH5XZ0FENFSL2frKwVmFI
         EzpGnz3DSGL3M8XRK2xE13U+eA7pHMC85ag1ldhqsuqFUUh97KbLAX4KjS8uzTHaejA3
         ub3g==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1795556696; x=1796161496;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=mhBBcvigEeJv8WwgmT61lN2C87AqVrn19gaexCd3NZo=;
        b=zCorOEm+sjpx6YSEp0lgI5NaTGgpwPtMEa39WnqrWKxpsLbuM4q/G3R0019d5TZVM8
         uoW4HspNLJsMs/FscucD1cbXPEGAc1FL7woxnx6k6strtaoV5vKz1EE7MfWQRVQyVpJz
         OIUHvzbFCDGSjV4x7RhYY7UO0atVsADFE3XgVQYVRlvPYxae1W/rZBab3r5KFxSrdXUa
         FTj47loNhUXNrLaVFdU0aTHUiRLvxQT31hhj9j7UFESF+9r/+hgWpuJMk9EGqIis1itR
         lNw/g8e5/co+LHwjHCNgkTfhNaddxV24RscUfME4k9BgqIt//deh9KdWNzX8M0mtzI4r
         RTqQ==
X-Forwarded-Encrypted: i=1; AL+hErGoRHeJWxTF/NTyPNRq9jDYYi5o5W+EoMWguqdVf6zFpzGJtykd5YqnE1w/ZbOnHRtn7YWp5YMn4P8=@vger.kernel.org
X-Gm-Message-State: APuU4Z8ECFBZ1Q1dTpEK2XdK9CzU0Leq3cBPzfluqplDbesuzXNZwYpO
	ljTU01j38nsEIy0NYraygDpkcEUUSvLBWZSVrzIldSL6+jBFjzTq1OPzlXL5LpGhtghfIJofh3y
	tEjXqPswJc4xDeM2w7CB4yj/Bv0Qk3AY=
X-Gm-Gg: AZFdTZfpIHMiR5Jlq8YQCS3onWbtAWkDxhqjJAMbFIiACIE4cxEbS3hi3ZsRvSwiJfQ
	v3LIt2rTExaMkO8AS9zz1eDs7EwLdTjxVEIQ2qo8aDZIoXrzXxucGCSqdsEzApALbVLsuc/fJ2m
	NqHFZUmpTQ4VTCKpCTz4mBnwe22ai1frkrqhHpDYiTcUdtYCZXDrjVxiDwiqzLDEP8benRpu8g8
	l+Z7zygXuNix6uc57tJgVOcThviDe1j9dZ5QZnaaz9yNqgyoC08sj/k9UKZGxuqBwBaW3lLAdvg
	/HFHWqtxbN+83oixb3MG4c0V4u4YHyDzz0x58K5J8w3nqgws5arsGMeF6fbLazVCO0V8aMr0uEH
	o9S3ijKSHr7Rw/U5293cG5U/7aYNMuDutzPg=
X-Received: by 2002:a05:690e:150e:b0:67d:b3d9:4d7d with SMTP id
 956f58d0204a3-67df448bc33mr4738248d50.119.1795556695633; Tue, 24 Nov 2026
 13:44:55 -0800 (PST)
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
References: <CANkg2rNRVyYLYLaVnCz75nYvC0DAKrphNazX1Asacf8MuBnxAg@mail.gmail.com>
 <525d6d4a-f015-415a-a4b9-9ffdbb8966be@app.fastmail.com>
In-Reply-To: <525d6d4a-f015-415a-a4b9-9ffdbb8966be@app.fastmail.com>
From: Rida Shamasneh <ridahani@gmail.com>
Date: Tue, 24 Nov 2026 23:44:43 +0200
X-Gm-Features: Aa3M54pXMF6qhup8XIwu_EYPEOakf3783eC-u9cNaQx0wLvjcZk1s-KyLxYi-d0
Message-ID: <CANkg2rM7XsiVriVzDr52WcxD-xFb4qu3qxiPJNyJUYYOTLUmNg@mail.gmail.com>
Subject: Re: RFC: RPC-over-RDMA client transport for pynfs (testserver.py --rdma)
To: Chuck Lever <cel@kernel.org>
Cc: Calum Mackay <calum.mackay@cdmnet.org>, Jeff Layton <jlayton@kernel.org>, 
	linux-nfs@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

I sent the patch via email "[PATCH] rpc: do not format a whole reply
for the debug log";
Do I need to open a PR as well?

On Tue, Nov 24, 2026 at 5:44=E2=80=AFPM Chuck Lever <cel@kernel.org> wrote:
>
> [ Corrected Calum's email address ]
>
> On Mon, Nov 23, 2026, at 4:08 PM, Rida Shamasneh wrote:
> > Hi Calum,
> >
> > (Resending in plain text: my first copy was rejected by the list for
> > having an HTML part.)
> >
> > I've added an RPC-over-RDMA (RFC 8166) client transport to pynfs, so th=
e
> > NFSv4.1/4.2 tests can be run against a server over RDMA:
> >
> >     ./testserver.py --rdma SERVER[:PORT]/PATH <tests>
> >
> > Before I clean it up for submission, I'd like to know whether you would
> > be interested in having this upstream, and how you would like it split.
> >
> > WHY
> > pynfs can only exercise a server over TCP today, so the RDMA transport
> > code of a server (svcrdma in nfsd, for one) gets none of the
> > protocol-level coverage the tests give it over TCP. This runs the same
> > tests over RDMA, including chunks, the backchannel (RFC 8167) and the
> > connection setup (RFC 8797).
> >
> > WHERE
> > https://github.com/RidaShamasneh/pynfs/tree/add_rdma
> > 17 commits on top of master, about 3,000 lines added: ~1,200 for the
> > transport (rpc/rdma.py, rpc/rdma_verbs.py), ~1,350 of unit tests
> > (nfs4.1/rdmatests), ~150 of README (nfs4.1/README, "RPC over RDMA"),
> > and the rest glue in nfs4client.py, nfs4lib.py, rpc.py, testserver.py
> > and environment.py.
> >
> > WHAT IT DOES
> > - Pure Python and no new dependency: it talks to librdmacm and
> >   libibverbs through ctypes, loaded when the first RDMA connection is
> >   made. TCP behaviour is unchanged (apart from the logging fix below).
> > - The inline size is negotiated with the RFC 8797 private data (4 KB
> >   with nfsd, 1 KB otherwise).
> > - Read, Write and Reply chunks. The Reply chunk is sized per call from
> >   the session's maximum response size and a bound on the COMPOUND's
> >   reply. READ data goes in a Write chunk. The data of a big WRITE is
> >   sent from the caller's own memory with a Read chunk at its position,
> >   so nothing of it is copied in Python.
> > - The backchannel works over the same connection, with separate forward
> >   and backward credits.
> > - A lost connection fails the waiting calls at once, instead of leaving
> >   them to pynfs's 300 s timeout.
> >
> > TESTING
> > Against a Linux nfsd 5.15 over soft-RoCE (rxe), the pass/fail results
> > over RDMA are identical to TCP, test for test, as NFSv4.2 sessions
> > (testserver.py's default minorversion) and, for the 179-test subset, as
> > NFSv4.1 sessions too. That subset is what I used as a regression
> > (exchange_id, create_session, sequence, open, rename, file, dir and
> > others). The remaining groups (copy, xattr, deleg, pnfs, flex and
> > others) and courteous/callback were run as NFSv4.2 and also match TCP.
> > The failures are ones nfsd also has over TCP. The reboot group has not
> > been run over RDMA. The transport has 80 unit tests of its own (from
> > nfs4.1: python3 -m unittest discover -s rdmatests -t .); about half of
> > them need no server.
> >
> > NOT COVERED / LIMITATIONS
> > - Only tried against nfsd 5.15 over soft-RoCE: no iWARP, real hardware,
> >   other servers or RPCSEC_GSS.
> > - Client side only, and NFSv4.1/4.2 only (nfs4.0, nfs3client, the proxy
> >   and the data server are not wired).
> > - No reconnect: a lost connection stays lost.
> > - Some of it is nfsd-specific (5.15 wants the Reply chunk to cover the
> >   whole reply even with a Write chunk, and mishandles a Write list with
> >   more than one chunk). It is documented in the README.
>
> Fwiw, I'm interested in seeing pynfs get RDMA capabilities. Or, as the
> kids say these days: +1
>
>
> > A SEPARATE IMPROVEMENT FOR TCP TOO
> > While measuring I found that rpc.py formats a whole reply with %r for
> > its debug logging before checking the log level: 2.6 million characters
> > for a 900 KB reply, twice. Passing the arguments to the logger instead
> > makes a 900 KB READ over TCP about 2.8 times faster (48.8 ms to
> > 17.2 ms). It is one small patch (c99c9b2 on the branch) and I am happy
> > to send it on its own, whatever you think of the RDMA work.
>
> IMHO you should post the TCP improvement before.
>
>
> --
> Chuck Lever



--=20
--=20
Thanks,
Rida Shamasneh

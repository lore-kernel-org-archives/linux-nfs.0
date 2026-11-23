Authentication-Results: smtp.subspace.kernel.org; arc=pass header.oldest-pass=0 smtp.remote-ip=74.125.224.41
ARC-Seal: i=2; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=pass;
	t=1795468138;
	b=cv84deygAdFXxf6Qbd5NEbXfuV7Zzr1/n31eNNUnAL3v/OR5Auc/53xqO52eOKG4sQZO
	 Mx88woidS/qoFS+fOQciSSEYjEhz7opN+F3NL9pW4Myvm1V9QvV5XBk7T5cCWoA7VFua8
	 NT75FJebMlInJP+XLpLQFt4+C2EH9UWcqIDlIUh6f8CaTzAO1TMlU5wiHLzcoOSWUoEKe
	 zjBtpDkLRQhEW2DTqICMTNA5+o0BCNzKVky8Ber3oQRG5kLQPOzzrW8IhSIzb+88DlkFN
	 DjbBq4GX5V+iE4PMm7dbHi8Gv7yjv7Xm65H//Uy2t9h9Df/llzkN/s8aVtsHjwuHr2g==
ARC-Message-Signature: i=2; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795468138;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Gm-Message-State:X-Gm-Gg:X-Received:MIME-Version:From:Date:
	 X-Gm-Features:Message-ID:Subject:To:Cc:Content-Type;
	bh=XgkS96fRXa23YjNKmcYL16LZat3djx6n1fYAYGtgNIQ=;
	b=BhVw8vVJ0U/DOmV8nxmlD/xvE7Kqo+glo2oJ7UOiw4qxFJRuhMD7al9lejXuHbu8aGf+
	 G3Wv/ywrzUbMwSy/T+g6nI26VLMZwxifh92w77maqoLueIUaDlz3wSkM6HpKSNw4SzTJa
	 gE51EWic7LhbX1ipKli2TAzyqROYaHxYUvWqhqpXTNxWxneereRn18DvnnppixGa8ooXh
	 VhwAGUxKM03w7gD/gopJqfxdbetlzkyWSaMIQGqong3pDIet4/7FNEbGKqag7HHeTBLIz
	 8XSUibw2C+xcMcArAN3jECyCMwQYiJBq1StXSwP7yZbtneChaUnjrNQJ2SkFJ+/X/Mw==
ARC-Authentication-Results: i=2; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=VQryG0fO;
	arc=pass header.oldest-pass=0 smtp.remote-ip=74.125.224.41
Received: from mail-yx1-f41.google.com (mail-yx1-f41.google.com [74.125.224.41])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C5371606A32C
	for <linux-nfs@vger.kernel.org>; Mon, 23 Nov 2026 21:08:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org C5371606A32C
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=VQryG0fO
Received: by mail-yx1-f41.google.com with SMTP id 956f58d0204a3-67990a45e02so3882492d50.3
        for <linux-nfs@vger.kernel.org>; Mon, 23 Nov 2026 13:08:57 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1795468137; cv=none;
        d=google.com; s=arc-20260327;
        b=LPMYUSmHCMMTiu5Kz1y7yhtbl+bOJtCVFEs9cJJ6SsOlp5ODuaEg0j/ocp1xkjBX82
         spYosUgV/14hEMXt3urbbhlcUCUdiQxS6xKYALqRRYfb5AwFlmphkJsiuUCJNOdVRuLV
         Nuy3PRzess0rwtWYMZVBRpZB46zJ9ZwJrCLteTsTFWVAyn6RS49Da6QY5RaPFS8JUAQx
         PEFBhWXIJ1kitKBV3h4OXVhs68HsiUzFtoXoKXcV3S1bPG5pfxO0qlaI5exzC+Soc4Oo
         R58An0yXbZHA6ZlLFGj5NJtg0ma4l4DASr2KM7BL3xYmeRFIYYUZiX9Vg0gKorUjHdK8
         dWTw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=cc:to:subject:message-id:date:from:mime-version:dkim-signature;
        bh=XgkS96fRXa23YjNKmcYL16LZat3djx6n1fYAYGtgNIQ=;
        fh=E/FXhmUauEGefm5R+oU9bYmTxswclnb8UjR8wmV9z8I=;
        b=YxV55egmwbkzfgQ7E5pPZs0KVGWu165/KQPShSPyrnaBe9H5H97tqiZIt9Kgqapg+c
         UurRQg8Tp47pyZbh9yK6OuI5Fdvtcr+G4fT4AFKBNNgmSMx5/cv0FLSzNhtECHSg+h0p
         k3SYYxHCpJFASQ7oTnTr3Xj6sVI+YnxD90yqb35k66yVi54EuYx22Y491GGc6vdzQaul
         L1kM5aDFviqV5pjifpQh8UCNAMj4x8epdI8hX5VYEDDhU6o4Urii103uQskB4VnEKLzw
         U7+89KB/dWwXEAD+Oe4KiBmz3Ki7LeDF2db2u518va8YCEibCNd1PoBnswtubmIk1gNx
         +myQ==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20260707; t=1795468137; x=1796072937; darn=vger.kernel.org;
        h=content-type:cc:to:subject:message-id:date:from:mime-version:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=XgkS96fRXa23YjNKmcYL16LZat3djx6n1fYAYGtgNIQ=;
        b=VQryG0fO/FTgsAoHhddAa4JpR89usfRXNU149y/W9dkoKuAzGbhnIUxjM0QdXiPcsL
         cfYV4taqtguRgbbAFs3iFKJljFO6mmc5tmZxR1cNOKD76jAk1KiNy4C0596aR5dkN0qk
         +nuglzRtOFb5sImxdvabVXz0VuBTsJqCfdCp0SJ59y7s/+oSRg5VqFgMZMpdI1p4m5de
         l65Ad/CAnd6avdStDcdyoIB4S9OLq8HvzuJGTZ/4TG2dXsZtCWJO3q2TdJyIVERo6t7G
         gplAuNCbhNfNAm66FE0Y1Rzpdf69yFwCiXBV+I0PQ3Qf3vxKyFTdVr3tHp3A85LKmVGd
         fVvg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1795468137; x=1796072937;
        h=content-type:cc:to:subject:message-id:date:from:mime-version
         :x-gm-gg:x-gm-message-state:from:to:cc:subject:date:message-id
         :reply-to:content-type;
        bh=XgkS96fRXa23YjNKmcYL16LZat3djx6n1fYAYGtgNIQ=;
        b=WbgoOEMZbbYcOF/WjQF5+LgX3YL/b/HHEY034JIMDAZuWtu6HYf9LbNQpyhcipRhzY
         M13gGGoZpKJ5j9HvdlC9GbQATTmIk9F0ybWwA2eGg7E45gRpUGTnvzY8wkn3PT8PqNXL
         fPpLUNb6NVJQRkpqr2JCQomAnijFrEXkmrmdNJXnucwd0bCmnvdSRd98vEWYUwWsXen1
         4xVm3WVsIU/cdSsf2qmR/37PGaU5rKnJ3huBNu7GgD2Z84nQXm95VkF+RgN+cG8ocWhw
         z3KBYpTNWHS1O5XuzdvgFLvAzDxc2iAJdAnsxwegqKv/jXu9h0glBEYc0rYA4nAIxo/z
         SG6A==
X-Gm-Message-State: APuU4Z/DARec9/X7XtiBM1iUNqSssX/efqKRdK52CSHZBhWBq8Okj7kk
	L/W+k20aH+sB9GOoNgf6edqbqb5/6jzqCJZDRHtDkhkHAZPrM+K3JXeoohfVdKHuOnOdtlkdutz
	p6Kfftzb/cnDHb7Op18aD9k8piWoVb8YDxAov3u0=
X-Gm-Gg: AZFdTZfu6khQlG8O0eBVcqMfich6aVxtCK9y80uso43w0ZtrS59uCXd+rOWJIIj9xeE
	xpay39rOnpCOLU824zSaebzsdneJNqtXwPWGJ7+ODyo5ApI6XXhPa85ZCiuJ/3QE0m12FvU3t51
	pHjC6xBfkQRnfA12Ff0XD14NRYkgBSxk7GbWV1haI2CfcQJQ2g2lTj0CV5Vd7WB4AEaO477RHWt
	wylfElWS4enTaNZCeuN20daV27FZfQTEeMQWSaMcwr4YDX9zdpqDoz7pYEKZAq/OT6tHdAJHo3Z
	9pFRzGhW5FanxJd5JIGYbFGNO0gfX7Qw1ExSjfLPDWr+n3civ0kxSk5Fa0s2BjSFASQa1gzX8KE
	wGQnLnzPZ4DEyj3iGvLl5frBkBK4673x7F2E=
X-Received: by 2002:a05:690e:4384:b0:679:2a5f:52e0 with SMTP id
 956f58d0204a3-67df4499489mr3874431d50.94.1795468136895; Mon, 23 Nov 2026
 13:08:56 -0800 (PST)
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
From: Rida Shamasneh <ridahani@gmail.com>
Date: Mon, 23 Nov 2026 23:08:44 +0200
X-Gm-Features: Aa3M54q1VDNab3BNcS9Eff9gDetkE9c0cArCNdruQLwbnhVo5b8mpXWUR_d9Zhg
Message-ID: <CANkg2rNRVyYLYLaVnCz75nYvC0DAKrphNazX1Asacf8MuBnxAg@mail.gmail.com>
Subject: RFC: RPC-over-RDMA client transport for pynfs (testserver.py --rdma)
To: calum.mackay@oracle.com
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"

Hi Calum,

(Resending in plain text: my first copy was rejected by the list for
having an HTML part.)

I've added an RPC-over-RDMA (RFC 8166) client transport to pynfs, so the
NFSv4.1/4.2 tests can be run against a server over RDMA:

    ./testserver.py --rdma SERVER[:PORT]/PATH <tests>

Before I clean it up for submission, I'd like to know whether you would
be interested in having this upstream, and how you would like it split.

WHY
pynfs can only exercise a server over TCP today, so the RDMA transport
code of a server (svcrdma in nfsd, for one) gets none of the
protocol-level coverage the tests give it over TCP. This runs the same
tests over RDMA, including chunks, the backchannel (RFC 8167) and the
connection setup (RFC 8797).

WHERE
https://github.com/RidaShamasneh/pynfs/tree/add_rdma
17 commits on top of master, about 3,000 lines added: ~1,200 for the
transport (rpc/rdma.py, rpc/rdma_verbs.py), ~1,350 of unit tests
(nfs4.1/rdmatests), ~150 of README (nfs4.1/README, "RPC over RDMA"),
and the rest glue in nfs4client.py, nfs4lib.py, rpc.py, testserver.py
and environment.py.

WHAT IT DOES
- Pure Python and no new dependency: it talks to librdmacm and
  libibverbs through ctypes, loaded when the first RDMA connection is
  made. TCP behaviour is unchanged (apart from the logging fix below).
- The inline size is negotiated with the RFC 8797 private data (4 KB
  with nfsd, 1 KB otherwise).
- Read, Write and Reply chunks. The Reply chunk is sized per call from
  the session's maximum response size and a bound on the COMPOUND's
  reply. READ data goes in a Write chunk. The data of a big WRITE is
  sent from the caller's own memory with a Read chunk at its position,
  so nothing of it is copied in Python.
- The backchannel works over the same connection, with separate forward
  and backward credits.
- A lost connection fails the waiting calls at once, instead of leaving
  them to pynfs's 300 s timeout.

TESTING
Against a Linux nfsd 5.15 over soft-RoCE (rxe), the pass/fail results
over RDMA are identical to TCP, test for test, as NFSv4.2 sessions
(testserver.py's default minorversion) and, for the 179-test subset, as
NFSv4.1 sessions too. That subset is what I used as a regression
(exchange_id, create_session, sequence, open, rename, file, dir and
others). The remaining groups (copy, xattr, deleg, pnfs, flex and
others) and courteous/callback were run as NFSv4.2 and also match TCP.
The failures are ones nfsd also has over TCP. The reboot group has not
been run over RDMA. The transport has 80 unit tests of its own (from
nfs4.1: python3 -m unittest discover -s rdmatests -t .); about half of
them need no server.

NOT COVERED / LIMITATIONS
- Only tried against nfsd 5.15 over soft-RoCE: no iWARP, real hardware,
  other servers or RPCSEC_GSS.
- Client side only, and NFSv4.1/4.2 only (nfs4.0, nfs3client, the proxy
  and the data server are not wired).
- No reconnect: a lost connection stays lost.
- Some of it is nfsd-specific (5.15 wants the Reply chunk to cover the
  whole reply even with a Write chunk, and mishandles a Write list with
  more than one chunk). It is documented in the README.

A SEPARATE IMPROVEMENT FOR TCP TOO
While measuring I found that rpc.py formats a whole reply with %r for
its debug logging before checking the log level: 2.6 million characters
for a 900 KB reply, twice. Passing the arguments to the logger instead
makes a 900 KB READ over TCP about 2.8 times faster (48.8 ms to
17.2 ms). It is one small patch (c99c9b2 on the branch) and I am happy
to send it on its own, whatever you think of the RDMA work.

QUESTIONS
1. Would you want RDMA support in pynfs at all?
2. If so, is a separate rpc/rdma.py and rpc/rdma_verbs.py (ctypes)
   acceptable, or would you rather depend on pyverbs?
3. Are the tests fine as a unittest package under nfs4.1/rdmatests, or
   would you prefer them somewhere else?
4. I would redo the history as a clean series (logging fix; RPC
   plumbing; transport; NFS-layer changes; tests and docs) with
   Signed-off-by, and send it as CONTRIBUTING describes, to you and
   linux-nfs. Does that split work for you?

Thanks,
Rida Shamasneh

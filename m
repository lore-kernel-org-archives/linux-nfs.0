Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=23.83.222.45
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793374773;
	b=hgxLBK/ZImPZTEnNqbwYUHGDN5VNdo7Q7SenMnMcMsxlKqB2xuhor5tHhhFF8N8fnZ/9
	 X9M6OlHDGwukniUFGgolLEzPdwLv+c2IMO32gy49ouUd96BH/9OUkQNlur1xsJ26kt5lc
	 tDGAbBUC/zLPsQzaFFWpztXZKwf95IWehm1JaVryLD4LFjwdW9WriPpQMGT2QpMvKLUsr
	 u5Lx7DmPSDwohZBuYisBk33wy5/gkW53e5QuRjE9QbFwQyMq/HEymHDAaLiVXvoWqyAwA
	 m8cQaxkLW10xQ5ECqPmuv5G7ZLejRRXmOYj191nHHcM39NLTzn0/6MvyMRWJrVPhnJw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793374773;
	h=DMARC-Filter:X-Sender-Id:Received:Received:X-Sender-Id:X-MC-Relay:
	 X-MailChannels-SenderId:X-MailChannels-Auth-Id:X-Illegal-Sponge:
	 X-MC-Loop-Signature:X-MC-Ingress-Time:Received:Received:
	 DKIM-Signature:Received:X-Gm-Message-State:X-Received:MIME-Version:
	 References:In-Reply-To:From:Date:X-Gmail-Original-Message-ID:
	 X-Gm-Features:Message-ID:Subject:To:Content-Type:
	 Content-Transfer-Encoding;
	bh=ro5m+asWHdgxIRPHRbIXNYFeP2uek6H+pfLUT2P6194=;
	b=Ks6P3Y++nzDncZamFYJmX0ktC0N1+B7vwKjHvYvMZhzl4wiDhI+RK/TefyxFeKtCDjKV
	 ErMuWF5SN+oNL0sXndlVZ3mYKwhhJ7bmfzoDcX111vTiLLITXKAcV2+FL+cD7BIsOH9IT
	 NbkPmFs5lFiPDRFJ3SQVW+R3B3pBE3dLaGwMTx+a0M4OVCciSAf+AolfCcV7/m3NWyf3M
	 bk2F8FFZMeLMn+cQCvuSKwRYvM0YZb3D2cJM0cP0DQTuJC21m/17a3jMHnc3f+0fiDPdg
	 s1VG0Z0d/2+LTveoinkqUjnz+dSatw2AEm7N5lwkEDUMVOzbU0aNWGtOCiIPN9svznw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=none header.from=nrubsig.org;
	spf=fail smtp.mailfrom=nrubsig.org;
	dkim=pass header.d=nrubsig.org header.i=@nrubsig.org header.a=rsa-sha256 header.s=dreamhost header.b="YNm/tVGX";
	arc=none smtp.remote-ip=23.83.222.45
Received: from crocodile.ash.relay.mailchannels.net (crocodile.ash.relay.mailchannels.net [23.83.222.45])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 27D0C606A31A
	for <linux-nfs@vger.kernel.org>; Fri, 30 Oct 2026 15:39:32 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 27D0C606A31A
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=nrubsig.org
Authentication-Results: smtp.subspace.kernel.org; spf=fail smtp.mailfrom=nrubsig.org
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=nrubsig.org header.i=@nrubsig.org header.a=rsa-sha256 header.s=dreamhost header.b=YNm/tVGX
X-Sender-Id: dreamhost|x-authsender|gisburn@nrubsig.org
Received: from relay.mailchannels.net (localhost [127.0.0.1])
	by relay.mailchannels.net (Postfix) with ESMTP id 71F259437D9
	for <linux-nfs@vger.kernel.org>; Fri, 30 Oct 2026 15:39:26 +0000 (UTC)
Received: from pdx1-sub0-mail-a246.dreamhost.com (trex-green-5.trex.outbound.svc.cluster.local [100.99.211.79])
	(Authenticated sender: dreamhost)
	by relay.mailchannels.net (Postfix) with ESMTPA id 4FCC194399E
	for <linux-nfs@vger.kernel.org>; Fri, 30 Oct 2026 15:39:26 +0000 (UTC)
X-Sender-Id: dreamhost|x-authsender|gisburn@nrubsig.org
X-MC-Relay: Neutral
X-MailChannels-SenderId: dreamhost|x-authsender|gisburn@nrubsig.org
X-MailChannels-Auth-Id: dreamhost
X-Illegal-Sponge: 5462c9856c3a06fe_1793374766357_547058653
X-MC-Loop-Signature: 1793374766357:3105927846
X-MC-Ingress-Time: 1793374766357
Received: from pdx1-sub0-mail-a246.dreamhost.com (pop.dreamhost.com
 [64.90.62.162])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384)
	by 100.99.211.79 (trex/8.0.2);
	Fri, 30 Oct 2026 15:39:26 +0000
Received: from mail-wm1-f52.google.com (mail-wm1-f52.google.com [209.85.128.52])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	(Authenticated sender: gisburn@nrubsig.org)
	by pdx1-sub0-mail-a246.dreamhost.com (Postfix) with ESMTPSA id 4jGQJG1NQWz105H
	for <linux-nfs@vger.kernel.org>; Fri, 30 Oct 2026 08:39:26 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nrubsig.org;
	s=dreamhost; t=1793374766;
	bh=ro5m+asWHdgxIRPHRbIXNYFeP2uek6H+pfLUT2P6194=;
	h=From:Date:Subject:To:Content-Type:Content-Transfer-Encoding;
	b=YNm/tVGXvjFvXrXjzE1GZJdCh+RFW/J2dspN2h92L5J2l/Pu2Xy+zLcLiSSBABB9e
	 W9iNdBDh0Gd/xXPr4+PSogs1Si4G+YuDQDNiFI2ZA2ZlwKPrwuPtaTigR+nx0v8uXm
	 iVHQrTa34NXYjxrHnpWhmPncy7cDNLTJ0hO8E3vWh4jpyU12c2PJWNbXQfqj3jLZl1
	 LAi2RMwQwFDITRiBqoDeiHU1JT/hs63uULvMzz/jm2lXaAkuCQdNJgbmwWEUBx5uIQ
	 ipZGYM/agiJzwDaUBQnbWgx/HTAOkaa52KOXxe3cSRCWRCnV0v50g3j4sRe60IcwUR
	 3YL6Afg4ud5zw==
Received: by mail-wm1-f52.google.com with SMTP id 5b1f17b1804b1-4a5177d78c7so8744405e9.2
        for <linux-nfs@vger.kernel.org>; Fri, 30 Oct 2026 08:39:26 -0700 (PDT)
X-Gm-Message-State: AFq9FYJtIXm2h41nV05dtAHPJ/s7FsqJ6PDenjfOZ/DFJAVSjxSXMgHZ
	WBb/MqWuuegIaz3E3n3EKgxLzvyMlG5TKgl15GdUiqOutakzy2pAokm3+dds1cpmFmSPLS9Oqsk
	kY0uwqY04ItY8ohf6ScjZUFQHgndNTxg=
X-Received: by 2002:a05:600c:c16a:b0:4a0:1c10:1372 with SMTP id
 5b1f17b1804b1-4ac18c74638mr57529525e9.27.1793374765035; Fri, 30 Oct 2026
 08:39:25 -0700 (PDT)
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
References: <20261029-random-stateids-v1-0-8648878fec8c@kernel.org> <877e743a38f4784f351615a9d72a4d6033a3869d.camel@kernel.org>
In-Reply-To: <877e743a38f4784f351615a9d72a4d6033a3869d.camel@kernel.org>
From: Roland Mainz <roland.mainz@nrubsig.org>
Date: Fri, 30 Oct 2026 16:38:46 +0100
X-Gmail-Original-Message-ID: <CAKAoaQm__zC=xuL-gqzqdv4127Tv=Ro+6J7=utN0qBqG=RgUfg@mail.gmail.com>
X-Gm-Features: AclHuK8ZyFqsDGq5UHSmCURcJLbh7fPPF0IhH323k8Ymz2-Ojmtmc8s5WB5ay-M
Message-ID: <CAKAoaQm__zC=xuL-gqzqdv4127Tv=Ro+6J7=utN0qBqG=RgUfg@mail.gmail.com>
Subject: Re: [PATCH 00/10] NFSD: Randomize clientids, session IDs, and
 COPY_NOTIFY tokens
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, Oct 30, 2026 at 12:28=E2=80=AFPM Jeff Layton <jlayton@kernel.org> w=
rote:
>
> On Thu, 2026-10-29 at 09:40 -0400, Chuck Lever wrote:
> > NFSD currently assigns a clientid from a per-netns counter, a session
> > ID's sequence word from a global counter, and a COPY_NOTIFY stateid's
> > so_id from a cyclic allocator with a fixed clientid word. Each of the
> > three is a bearer token. NFSv4.0 resolves a presented stateid against
> > the client named inside it rather than the caller, and the errors the
> > protocol mandates (EXPIRED for an unknown clientid, BAD_STATEID for a
> > known clientid with an unknown index) let the two halves be searched
> > separately. Under SP4_NONE, nfsd4_sequence() does not check a
> > credential, so a session ID alone can reach another client's slot
> > table. Adjacent counter values let a malicious requester find a
> > neighbor's token in a few dozen probes by counting outward from its
> > own.
> >
> > After this series, the clientid, the session ID, and the COPY_NOTIFY
> > token's clientid word are random. Predicting a live clientid costs
> > about 2^32 / C probes for C clients of the probe's minor version,
> > and a session ID 2^64. An ordinary stateid's so_id stays cyclic, so
> > it stays cheap to search once a clientid is known. RFC 8881 forbids
> > reusing an "other" value for a different purpose, and the cyclic
> > allocator is the non-reuse mechanism clients rely on.
> >
> > Tested with the new KUnit suite, pynfs 4.0 and 4.1 over loopback, and
> > pynfs-based probes that confirm the three tokens are unpredictable,
> > that a LOCKT denial no longer carries a clientid, and that a
> > COPY_NOTIFY stateid with a wrong clientid word is rejected. A
> > same-second restart loop confirmed STALE_CLIENTID on RENEW and a
> > clean shutdown with live COPY_NOTIFY state.
> >
> > ---
> > Chuck Lever (10):
> >       NFSD: Serialize forced client expiry with state shutdown
> >       NFSD: Check machine credentials before expiring a client in DESTR=
OY_CLIENTID
> >       NFSD: Make nn->boot_time strictly increase across state starts
> >       NFSD: Give each client a display id independent of cl_id
> >       NFSD: Generate the clientid at random instead of from a counter
> >       NFSD: Stop disclosing the conflicting lock holder in a lock denia=
l
> >       NFSD: Destroy the COPY_NOTIFY stateid IDR at netns teardown
> >       NFSD: Put a random word in each COPY_NOTIFY stateid
> >       NFSD: Fill the session ID's sequence and reserved words at random
> >       NFSD: Add KUnit tests for the random identifier generators
> >
> >  fs/nfsd/Kconfig          |  16 ++
> >  fs/nfsd/netns.h          |   9 +-
> >  fs/nfsd/nfs4layouts.c    |  10 +-
> >  fs/nfsd/nfs4proc.c       |   2 -
> >  fs/nfsd/nfs4state.c      | 308 ++++++++++++++++++------
> >  fs/nfsd/nfs4state_test.c | 591 +++++++++++++++++++++++++++++++++++++++=
++++++++
> >  fs/nfsd/state.h          |  16 +-
> >  fs/nfsd/xdr4.h           |   2 -
> >  8 files changed, 867 insertions(+), 87 deletions(-)
> > ---
> > base-commit: 19bbac00ad1cfa28e9127488f161ffc2ac03fad4
> > change-id: 20261029-random-stateids-c66f263d7800
[snip]
>
> This seems reasonable overall, but I do wonder if trying to keep these
> things non-guessable is a losing battle. I guess it doesn't hurt
> anything.

IMO it would be nice to have a way to turn this off at NFS server startup..=
.

----

Bye,
Roland
--=20
  __ .  . __
 (o.\ \/ /.o) roland.mainz@nrubsig.org
  \__\/\/__/  MPEG specialist, C&&JAVA&&Sun&&Unix programmer
  /O /=3D=3D\ O\  TEL +49 641 3992797
 (;O/ \/ \O;)

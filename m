Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E3EFB1A5B9D;
	Fri, 31 Jul 2026 00:12:44 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785456766; cv=none; b=bZaxlY7q0rhvWTmgwPl9aVy6o+oa8s+9G3++QHpoRUJxKLZB3S92MuNwoiVzfSaOTX2nX24JW5F0ACJRrid+5MEy63Sgl6B1Ggc5Ea5CArkvxmFOBkCVtFBdFbA7ExnVfQGssIqKmJFGN20xgJe0EtU9rOXT+M2517jFlPrJNdU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785456766; c=relaxed/simple;
	bh=A8Dj6H7QzH3XzHeD7yOzZoPzQdbmNshpi6BLWTalVCQ=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=Ly4dNyrOA3R0Myi3hA3gdB80L4xwCC0Z5iJJGpXvZxnodq9kpdY12pOXCdob62oGe6eZf70N4joy0+yHs243DbVZMxQPHISdlYoMXDzYw6ZGhEyCKfGi1ZDMDYNV6r/+9Uxfe6oL1rzJinz2j439ulrm0bw98rxJzptx8Lqh1NQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=Vm9xHL5H; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="Vm9xHL5H"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id ECE8F1F00A3A;
	Fri, 31 Jul 2026 00:12:43 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1785456764;
	bh=sUInQQ+TXDPnLDaLaENRUylWtDaYSByt9K6puYMzCzM=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=Vm9xHL5HWNuIIBzPxfchac/y48lbB/ddbpjw6TTydr5FWsKFAD/BYwiexUamR9i+/
	 yBLuggo2llIz4KA5UIpZ00a2TAeQ8CfHB7Z79/1uW2oW1XICJTnQzPHN5crv5Qpllq
	 WkNppqxZd8kI3Qz99SjcYcSOmqXpBixPegD7puCzb6mh1aDNcnsIb89B9m/n1TyuiT
	 FAM4RF18y0zsqyOEYShRdRCdoR1JRr/dbTkPj3+eXDWS2Alk/wZ2Lz128NRWvfNmDE
	 qIc1t/6EYp6m3fVAhLDjidc6wQAtfyWY42xcHlBOwoUPje41aFQWRbjUR9zitwiXK6
	 2q3utl1v3K+Mw==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id D85EEF40066;
	Thu, 30 Jul 2026 20:12:42 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Thu, 30 Jul 2026 20:12:42 -0400
X-ME-Sender: <xms:euhravmq5PVctrIbTX-2lxPG5dorAB-rPfzTGRZrQSQv98A6tFUr4w>
    <xme:euhratpVE4uQ1_DuLL4XPG6FFtwQrWKaIGFdEpjRkTo9cXP0jyQRo2N5-WB3HQQv2
    PH-_TdnlV9CrR4Frp77xijEjQ9obVSzu91B6xplEkt2A5TaD--vSjg>
X-ME-Proxy-Cause: dmFkZTFJrgQabfdF4mKP0DSqrKv5jkS8cmKlfITPUYHi7fDJO7sdUGKzMonyawgBbwMKfZ
    gBvgxuGLmVsz5UuxTWinmfqbBZDk7lNHH9BbNrb/UYvai1QgC6G/JCpuJJHeS6ErT7YUsd
    euvZLqM6bx27hotayrsFr8B7Gw2cRKoFbm81WgAeL2EDYqJ6rM9b3OzYYs+rDLGSOLbsbZ
    6oI8IgDmijSO/qgLOGlHJEBh/pG8+ugYZY2YOAlTmguiw72Z0IgrDSku1lenfjY7Lp055m
    sCDwq3a3pO8IS40L7IcwKNomUxxGPz2UApY408Nxep4l/zEVNTeSx3UgPBdfsgxeSqZUhT
    A/JBaxYMtSU5ryGmEwZUregUwYtWOirReVZWjvkhYglg/L847/NF4K6qNO8zFsQZhbgMbv
    AGPE0k44G8RFcFC9hJifpHYXvfIwKIQTWVGQbqsyetFZ2z8hyUIxC7Vfb32H2V3e0grp5M
    2x0QO+r+oUZyfl5iT5xkD4IFJNn+5yhb7Fmjn9TT7ZMf7Nim5q201vgBgYLsNFuJtg6as3
    QbhWhamu9g+DRNa8iumLda3bZEI3ENqkjX8CishTedJsCxtFaZ/0067aX6TAHMTxYQPeva
    wNPumOGC/Cm3B85sLuC/+axDZlfhsHzfwl33c3URC9Fd8drjzbc0bzSOpPIg
X-ME-Proxy: <xmx:euhrakcKeR6-bB2f-BTfo8mpqOD_Y556TRTrWSgLDd_3cwXpUccSGg>
    <xmx:euhratz5yhr-bYSN4XduCgY93TtnjIFPiAIzcQ87PB1MP7hneTQY6g>
    <xmx:euhralIVY_7zMh4Pg4fcpgk9okivZ9_9m_UrU_SaLFYfJe0qrdeaIg>
    <xmx:euhramsfo8ysNqErIQg5oy9v9I6Bg-4KDZlW0Hx00-AogSIQZi_9cQ>
    <xmx:euhranQKpISpdYBqmFreDBcWTFQC7LtNFusZ5iaYOcPaaTHnm_KuFXq9>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id B1B2C780076; Thu, 30 Jul 2026 20:12:42 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Date: Thu, 30 Jul 2026 20:12:22 -0400
From: "Chuck Lever" <cel@kernel.org>
To: "Jakub Kicinski" <kuba@kernel.org>, "Sabrina Dubroca" <sd@queasysnail.net>
Cc: "Paolo Abeni" <pabeni@redhat.com>, "Simon Horman" <horms@kernel.org>,
 "John Fastabend" <john.fastabend@gmail.com>, "Shuah Khan" <shuah@kernel.org>,
 "Jeff Layton" <jlayton@kernel.org>, NeilBrown <neil@brown.name>,
 "Olga Kornievskaia" <okorniev@redhat.com>, "Dai Ngo" <Dai.Ngo@oracle.com>,
 "Tom Talpey" <tom@talpey.com>, netdev@vger.kernel.org,
 kernel-tls-handshake@lists.linux.dev, linux-kselftest@vger.kernel.org,
 linux-nfs@vger.kernel.org
Message-Id: <6deaada6-b916-4232-9df9-fff27472e98c@app.fastmail.com>
In-Reply-To: <20260730143556.4a8463fd@kernel.org>
References: <20260720-tcp-read-sock-v2-0-29545d034f3c@kernel.org>
 <20260720-tcp-read-sock-v2-2-29545d034f3c@kernel.org>
 <20260728185124.72e421c8@kernel.org>
 <480a8337-a91e-40e5-8dbd-d165599fba4b@app.fastmail.com>
 <20260728193058.7f6b453b@kernel.org>
 <a6fb364d-8344-408e-bcd5-0cee4ffabdc3@app.fastmail.com>
 <20260729163142.4f41484f@kernel.org> <amtcwSO24GGq_qd0@krikkit>
 <20260730143556.4a8463fd@kernel.org>
Subject: Re: [PATCH net-next v2 2/6] net: Introduce read_sock_rectype proto_ops for
 control record delivery
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable



On Thu, Jul 30, 2026, at 5:35 PM, Jakub Kicinski wrote:
> On Thu, 30 Jul 2026 16:16:33 +0200 Sabrina Dubroca wrote:
>> 2026-07-29, 16:31:42 -0700, Jakub Kicinski wrote:

>> > Off the top of my head I think a setsockopt which pre-seeds the con=
tent
>> > type so that the read returns an errno if the queued content type is
>> > different could be a simple fix. You'd configure that on your socke=
ts
>> > to DATA and once you see a EWHATEVER you'd assume that some special
>> > record arrived and the socket has to be handed back over to the TLS
>> > control path. This is literally the first thing that comes to mind,
>> > IDK how ugly it will look in reality so no promises. =20
>>=20
>> But then you're back to "read_sock stopped, caller has to take some
>> special action to handle the next bit of payload". It's not better
>> than "read_sock, and do a recvmsg when read_sock says it's not DATA".

But the =E2=80=9Crecover the control type with a separate operation=E2=80=
=9D is strictly
better than =E2=80=9Cpass a CMSG buffer to every I/O operation just in c=
ase=E2=80=9D ;-)


> My bad, I replied without looking at the code.
> We already constrain control records in the way I proposed.
> rcvmsg (w/o cmsg) and read_sock will error out if the next
> record is control.

Almost.

There is no API contract for ->read_sock, but the TLS read_sock
implementation itself will return -EINVAL for two unrelated reasons:

  - net/tls/tls_sw.c:2068-2072 =E2=80=94 entry gate: sk_psock_get(sk) re=
turns
    non-NULL, so the socket is under sockmap/BPF. Drop the ref and
    refuse before even acquiring the reader.

  - net/tls/tls_sw.c:2111-2115 =E2=80=94 per-record: tlm->control !=3D
    TLS_RECORD_TYPE_DATA. The record is requeued rather than consumed.

As far as I can tell, no other socket provider that implements read_sock
will return -EINVAL. But this isn=E2=80=99t a documented guarantee that a
socket consumer can depend on, currently.

What would make this just a little friendlier is having distinct errnos
for these two conditions, and a kdoc API contract that documents them.


--=20
Chuck Lever

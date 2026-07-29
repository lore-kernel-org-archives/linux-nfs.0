Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B854231E844;
	Wed, 29 Jul 2026 01:57:43 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785290264; cv=none; b=WwVEAuv/8l18bkic/r1AxHaUz7MIRih/4v2Zzv/Ztv1mxMuPkgZNo1PqYTLAW8OFR9UzkyYfrP8Llu2lM0aPe8vVBsuFjsA+6ebRAJyXHAyOT12gJJi/BZeC25cfAr05p7SM6TM8A1Hfrf57Nd50KSYfqP6EbP+9sniu3LYxZ4o=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785290264; c=relaxed/simple;
	bh=5OkhLWRYqzzlrEs3tNAc5E8NFPZTiumniFn+j9yEE0c=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=W0+mCFviCRQZFAA/tCt75w5P/6lduZNIQXTPdL3AtVj3iENnmpTvlmf/y3wotjAmXp9/Gigth+OUdixk61gswefJDsfLX6N01b94aPUfXKDe97k4op6t7PjYPMTntrrr23o6667bgjcxC8mRq84yLqtcTUtW9T2dgCsOTRuZD+g=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=PUYgffNP; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="PUYgffNP"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 04DC71F000E9;
	Wed, 29 Jul 2026 01:57:42 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1785290263;
	bh=5OkhLWRYqzzlrEs3tNAc5E8NFPZTiumniFn+j9yEE0c=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=PUYgffNPi+xyOFbrxAwLETO3JMLN4uL2uMLFP56UrLiQAwhaVzmKozMJP4odlG+kS
	 2dFHV38MGam9dvP+2BWQPHJHgr7V8TPlfw2LGLUEqZr+VEVvTh/P9uhLxgDOUUdWfp
	 v6r9fkijDL0M6xzOdDtg5UA2xuuqAyGy2U+/IR+WtJKx19nRIDHvDbHPkbCWjajXbA
	 GI6GFVZNnBDO9Dwn8q8JNKb8OjRl5DwIwYVfD9wLvduMrRyffaU/sdeQWAhwOIcEej
	 p/lwIsCIn2L3rQuN4p9MdIx/yM2L605OARAhvAGZEeIKv46YIvED7mUxO3ixMOIgLj
	 w3TcDKEh7GCIQ==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id 13655F4007E;
	Tue, 28 Jul 2026 21:57:42 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Tue, 28 Jul 2026 21:57:42 -0400
X-ME-Sender: <xms:Fl5pavciOmfnwmR7NnYc-k9aiGegQWMoVgZx9uV1aVI-PMwnsIQbSw>
    <xme:Fl5pagChbXjQf7GFykgguQQJitTq20ARCq2HTH8NrawXH7HES_xr8LNYwWziKigSx
    hhpI3qtGK10xaWCAY6fU8vOJD_5WqZAqtUYIb50BBSai1yL9C_fPy43>
X-ME-Proxy-Cause: dmFkZTE2njLt6bc4C+ONPhcsqDTWLplw/BscVJ4IrKcSS3qMgETdQhaIIilEuO0oNFqqdJ
    RVs1BgblNna7PDTVvX6T0qlTjCVou+LR+iXZw2Lgs8y3JW/jp324mMzWK+41WvG3BO1PJg
    729eaIAnJhyGYyw//5c+mz1ExSBlpAfpJfnVtnX4LTcsKQsZtvNczr72BLx2bbx7zcdDmP
    5vyERrsPwAIBO/fccN0vli4CYtmiQhLjC5JcJVwG1FOA1zbwYtHyDmWtBNTgG89VwcLIkn
    STIpZuXBzQW+/fZ3obVWhZawUkJBY9eQ8QIPhVpP5N9mqfRrmv/yFpwDOxWazIGOxzafHH
    1iie+0em+FJtZxDC/5yZnrUnqEvtnGnCS4qodE4J4IPuBWH4unvdFtCfDyRWBeTiL+jZ9/
    w/zSQjqrZAUEYnZcxR4wCjW9ELgMBkdgoGfXZc5L7zVXDfqT2WljcgpNeNDjkrh5d98758
    iHx0WXT1t8B/10T+fmIrHCZUb7zEC0H281dRlCic0+NXXDw1PTOCOOJe7cO3eIjPKMpLYZ
    W1cYp20E1PUM2GJ2OJmEnAXRCf2Y4K/+X3cGJT0dydIrqMGvBFcl3nJjcDM8ds5PdXMk17
    Qxxn20uwI30VNSrVIfnNGLk7G2smBp6S7wPseV6h5xk93UuqiGAl3U6rKdUQ
X-ME-Proxy: <xmx:Fl5paiWZnJ2PFgkdpXCn69XDfIZjcWU4X3322b2Pdx2T4Avb_Fq-PA>
    <xmx:Fl5pamJC8mf5IAJbeRtk3vR5DhIjIJZx8eyoyNdu15eNS-yMPZqXRA>
    <xmx:Fl5pamBazTJjbHi_8d7q8QhkC6kk1CujgCyNgyDiRAAoMlCF_4wecA>
    <xmx:Fl5pamEa1WRNgF2fmy78_8EqP-_fqE3_N4tpk9XmQSkRTyopOcFJ2Q>
    <xmx:Fl5pajLpLOgXGSXXaX_IvU5FszafMWB0PU29yEqISXrjOklReMpHSZQe>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id E8E69780070; Tue, 28 Jul 2026 21:57:41 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Date: Tue, 28 Jul 2026 21:57:21 -0400
From: "Chuck Lever" <cel@kernel.org>
To: "Jakub Kicinski" <kuba@kernel.org>
Cc: "Paolo Abeni" <pabeni@redhat.com>, "Simon Horman" <horms@kernel.org>,
 "John Fastabend" <john.fastabend@gmail.com>,
 "Sabrina Dubroca" <sd@queasysnail.net>, "Shuah Khan" <shuah@kernel.org>,
 "Jeff Layton" <jlayton@kernel.org>, NeilBrown <neil@brown.name>,
 "Olga Kornievskaia" <okorniev@redhat.com>, "Dai Ngo" <Dai.Ngo@oracle.com>,
 "Tom Talpey" <tom@talpey.com>, netdev@vger.kernel.org,
 kernel-tls-handshake@lists.linux.dev, linux-kselftest@vger.kernel.org,
 linux-nfs@vger.kernel.org
Message-Id: <480a8337-a91e-40e5-8dbd-d165599fba4b@app.fastmail.com>
In-Reply-To: <20260728185124.72e421c8@kernel.org>
References: <20260720-tcp-read-sock-v2-0-29545d034f3c@kernel.org>
 <20260720-tcp-read-sock-v2-2-29545d034f3c@kernel.org>
 <20260728185124.72e421c8@kernel.org>
Subject: Re: [PATCH net-next v2 2/6] net: Introduce read_sock_rectype proto_ops for
 control record delivery
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable



On Tue, Jul 28, 2026, at 9:51 PM, Jakub Kicinski wrote:
> On Mon, 20 Jul 2026 10:27:56 -0400 Chuck Lever wrote:
>> Kernel TCP consumers that use the read_sock interface
>> (proto_ops.read_sock) cannot receive TLS control messages (Alerts,
>> Handshake records) when kTLS is active. The current
>> tls_sw_read_sock() method rejects non-data records with -EINVAL, and
>> the sk_read_actor_t callback has no channel for delivering record-
>> type metadata.
>>=20
>> Four kernel subsystems are affected: NFSD (sunrpc svcsock), NFS
>> client (sunrpc xprtsock), NVMe target (nvmet-tcp), and NVMe host
>> (nvme-tcp). Each of these either falls back to the sock_recvmsg()
>> API or lacks TLS alert handling entirely.
>>=20
>> A new read_sock_rectype method in struct proto_ops provides a
>> separate code path that delivers non-data TLS records to a callback,
>> without changing the behavior seen by existing read_sock consumers.
>>=20
>> The new sk_read_rectype_actor_t callback type extends the
>> sk_read_actor_t signature with a rectype parameter carrying the
>> protocol-layer record type (for example, TLS_RECORD_TYPE_ALERT). The
>> record-type callback returns 0 to consume a record or a negative
>> value to requeue it and stop delivery; unlike the data callback, its
>> return value does not count bytes.
>
> To me this is an ugly one-off workaround that doesn't fit into=20
> the proto_ops (only TLS will use it). And you seem to net out
> to the same LOC on SUNRPC side with and without this?

It=E2=80=99s not about LOC. It=E2=80=99s about not cluttering the normal=
 I/O
path with a lot of exception processing to handle TLS Alert
records. The CMSG API is very difficult to use and leaks the
alert messages into I/O buffers (which for in-kernel consumers
are page cache pages). It=E2=80=99s piss-poor API design.


> There needs to be a very strong reason for us to add APIs for
> in kernel consumers.

This is not a helpful position. Your objection is the same
every time, treating the in-kernel users as second-class
citizens. You haven=E2=80=99t provided a single alternative to address
our concerns, and you have not explained why an additional API
is a problem.

Please put down your hostility and elaborate. You seem to be
the only one who has a problem with any of this.

--=20
Chuck Lever

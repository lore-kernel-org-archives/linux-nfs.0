Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=80.69.43.37
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795265669;
	b=jd4xJC//eFzdEhL23zeHFLj61Y3p/mn01VkSyBwCmnZPrrV0NZTC9YKSQ3vuqmCIamfK
	 ALETfRG5dPzd3fvGAyYr3g+367vutirack+iDpYJmDekjsUtL5aYsq/DtEPk4iu3CHula
	 pveJWXSGU6o3nmBjxL1M/7B4kWBnlfSfrsHCPnJTSiPO0xgCLQr5f2p0OdULl2QoZc82t
	 oeEB0+oFwvIJzQMqEjOsmvr7Sa3I3osaGNs8YcDFjKV80KVJ187GhD+IGsd8x4pCoaSYj
	 SI6hNpqrmx/M+s31+O5JdQsIToMVq2Cus4YPugmEhSTeT3pjyZ+ygLQpMJ++pq8AWyQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795265669;
	h=DMARC-Filter:Received:DKIM-Signature:Received:Date:From:To:Cc:
	 Subject:Message-ID:References:MIME-Version:Content-Type:
	 Content-Disposition:In-Reply-To;
	bh=1uVgY2z+hshq7F0ZSrAjjHHeZk9uqmH1avdHg94R25I=;
	b=vdASHpRZYrdViehdgd8ui33cI0BnrqBITL0Iaqg9fgKiCXGUTenUqus/mjZDZbs3thM3
	 XXt44YNOs0BgO0X8EiqcxRKXzed7mbuCvbR2OXGc7yJYP3NOVyuTQCKbpXgEhCevdJ37I
	 TsKRXM+Wx2wsh3utSlh0TfXQuWz4/uplZt+90AhDHrOAInKUrYj1c5rMJ7nez2YaPVGJz
	 4QXE+ZyEJwpB7sahh3qZuO6XptBCrhv65xcyxw2wdMDL9teDVss2PCqqpPDdU4YM4e+dI
	 nAO4LQR0TXZYlAHYJ5CWM1TI32ppPyRsiQTzl5Ul8aqgsageoyt4CwsK3w301L7xSkQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=vozeler.com;
	spf=pass smtp.mailfrom=vozeler.com;
	dkim=pass header.d=vozeler.com header.i=@vozeler.com header.a=rsa-sha256 header.s=max-2024-2 header.b=WZCZ+79K;
	arc=none smtp.remote-ip=80.69.43.37
Received: from imap.hinterhof.net (imap.hinterhof.net [80.69.43.37])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5A75C606A320;
	Sat, 21 Nov 2026 12:54:27 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 5A75C606A320
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=vozeler.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=vozeler.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=vozeler.com header.i=@vozeler.com header.a=rsa-sha256 header.s=max-2024-2 header.b=WZCZ+79K
Received: from dp.vpn.hinterhof.net (i59F45518.versanet.de [89.244.85.24])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange x25519)
	(Client CN "x201t.vpn.hinterhof.net", Issuer "Max Vozeler" (not verified))
	by imap.hinterhof.net (Postfix) with ESMTPS id 3EF578FB862;
	Sat, 21 Nov 2026 12:54:25 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=vozeler.com;
	s=max-2024-2; t=1795265665;
	bh=Co2PLgesTLFmsH1fAtY9kckuLxDISae4B5FYwQnvqMM=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=WZCZ+79KFo2IJ0xo0vmrpBenYLPfmmfWOFL9HMclYXg7q9gUs0GlmHTBts3YfTSss
	 M5RyJRcE/I/8rdlrp0Z5OS6e7Im7dgO3arsAvw67HuA/X8Mt5146n5H1UTlsQmQhXK
	 QzGv32E2dpwFonaB0nJ3OJO+p0nPYfq0JSb93TYWOjqKX49Td/LEB+bB/ArDu8MiKB
	 zqEjQN+K8kEa3W4MdE6yAGcOgdyrdgtvUz3rc+jLkC+caulOeMQDx8OMBIbu7l/ecp
	 8hD5KbRsj/rD4vE9CCD+WrRRVsucEtufEkP21OQtlLfjExxBONCsPyNchS/ExJBVmN
	 3uW/VW9hV/5Pg==
Received: by dp.vpn.hinterhof.net (Postfix, from userid 1000)
	id F203A26018A; Sat, 21 Nov 2026 13:54:24 +0100 (CET)
Date: Sat, 21 Nov 2026 13:54:24 +0100
From: Max Vozeler <max@vozeler.com>
To: Chuck Lever <cel@kernel.org>, Sasha Levin <sashal@kernel.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Chris Mason <mason@kernel.org>, Jeff Layton <jlayton@kernel.org>
Cc: linux-nfs@vger.kernel.org, stable@vger.kernel.org,
	regressions@lists.linux.dev
Subject: Re: [Regression linux-6.1.y]: NFSv4 server: sec=krb5p mount fails
 with EIO in 6.1.192
Message-ID: <awGUgH8RBMjjKIEk@dp.vpn.hinterhof.net>
References: <awBIdxOJ4XSXuc7S@dp.vpn.hinterhof.net>
 <awFyZbQE8pDyOxUy@dp.vpn.hinterhof.net>
 <awGO-R42ggk_WEga@dp.vpn.hinterhof.net>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <awGO-R42ggk_WEga@dp.vpn.hinterhof.net>

[Resend to @kernel.org for Chuck and Chris; previous mail bounced]

On Sat, Nov 21, 2026 at 01:30:49PM +0100, Max Vozeler wrote:
> #regzbot introduced: 82cf21374fb7ee55b37be9afb6704ba0eeffb236
> 
> On Sat, Nov 21, 2026 at 11:28:53AM +0100, Max Vozeler wrote:
> > On Fri, Nov 20, 2026 at 02:17:43PM +0100, Max Vozeler wrote:
> > > after upgrading an NFS server (Debian bookworm) to 6.1.192
> > > (Debian linux-image-6.1.0-55-amd64), NFSv4 clients fail to mount exports
> > > using sec=krb5p with EIO.
> > > 
> > > Downgrading the server back to 6.1.190 (linux-image-6.1.0-54-amd64)
> > > makes things work again.
> > > 
> > > Good: 6.1.190 (Debian linux-image-6.1.0-54-amd64)
> > > Bad:  6.1.192 (Debian linux-image-6.1.0-55-amd64, linux-image-6.1.0-56-amd64)
> > 
> > Reproduced with vanilla 6.1.191 and 6.1.192
> > 
> > Good: 6.1.190
> > Bad: 6.1.191, 6.1.192
> 
> bisect points to
> 
> commit 82cf21374fb7ee55b37be9afb6704ba0eeffb236
> Author: Chuck Lever <chuck.lever@oracle.com>
> Date:   Mon Jan 2 12:07:07 2023 -0500
> 
>     SUNRPC: Convert unwrap_priv_data() to use xdr_stream
>     
>     [ Upstream commit 42140718ea26c47fb06c679451a6aa6703545136 ]
>     
>     Done as part of hardening the server-side RPC header decoding path.
>     
>     Reviewed-by: Jeff Layton <jlayton@kernel.org>
>     Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>     Stable-dep-of: a919c5c88769 ("SUNRPC: svcauth_gss: enforce krb5 token minimum length")
>     Signed-off-by: Sasha Levin <sashal@kernel.org>
> 
> This seems to have been part of a larger series, only parts of which
> were backported for a919c5c88769 ?
> 
> Best regards,
> Max

> git bisect start
> # status: waiting for both good and bad commits
> # bad: [08889840163ebcdb7e24bf7ec311bc2e6fc3aaea] Linux 6.1.191
> git bisect bad 08889840163ebcdb7e24bf7ec311bc2e6fc3aaea
> # status: waiting for good commit(s), bad commit known
> # good: [79807e970724c1f90cee1316361d61b80db4eef6] Linux 6.1.190
> git bisect good 79807e970724c1f90cee1316361d61b80db4eef6
> # good: [91c2a5d201daf66fa3f42b8a383bb89174bde2c8] serial: core: fix infinite loop in handle_tx() for PORT_UNKNOWN
> git bisect good 91c2a5d201daf66fa3f42b8a383bb89174bde2c8
> # bad: [ab8c8e027fa8f9314340a96999dd3309b7f80d61] fbdev: ssd1307fb: defer I2C transfers from damage callbacks
> git bisect bad ab8c8e027fa8f9314340a96999dd3309b7f80d61
> # good: [35b46918d5deee01fade7e2f2075a7c238a2a0e8] cifs: prevent readdir from changing file size due to stale directory metadata
> git bisect good 35b46918d5deee01fade7e2f2075a7c238a2a0e8
> # good: [91abd8383fd0588d1fcc31120d6344150a64ba5a] net: sched: cls_api: add filter counter
> git bisect good 91abd8383fd0588d1fcc31120d6344150a64ba5a
> # bad: [ed126ca71d4d949ad99f40b974a8f7685e808f8b] net/packet: defer vmalloc TX_RING free until skbs finish
> git bisect bad ed126ca71d4d949ad99f40b974a8f7685e808f8b
> # bad: [82cf21374fb7ee55b37be9afb6704ba0eeffb236] SUNRPC: Convert unwrap_priv_data() to use xdr_stream
> git bisect bad 82cf21374fb7ee55b37be9afb6704ba0eeffb236
> # good: [8da6f765098d46e5b3178ef4b2f8273c9ba1d3bb] SUNRPC: Rename automatic variables in unwrap_priv_data()
> git bisect good 8da6f765098d46e5b3178ef4b2f8273c9ba1d3bb
> # first bad commit: [82cf21374fb7ee55b37be9afb6704ba0eeffb236] SUNRPC: Convert unwrap_priv_data() to use xdr_stream

Context: https://lore.kernel.org/regressions/awBIdxOJ4XSXuc7S@dp.vpn.hinterhof.net/T/#rd62f582e83e56dd3f5e8b430de3de07bee6b60b7


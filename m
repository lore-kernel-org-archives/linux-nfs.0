Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=103.168.172.152
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794884465;
	b=PTD835emRMe52fZTDjhdDE6qUm1YSUQQi8YEuQPYRntLSoSOiMe1pEk1Mn8ZFJzcdrTQ
	 ldJBP6XxRyK10MUuqp6tGZXtsM8b/9PuWeOjnJi8Mdyl2G9cpKChuX+jftlRI8S7TMsex
	 WQVyXAkdK23r+v5VhzGJcBJ4x6qOVhiH/IyE+BjZDY5PBtGbZSjLKJHBpc07gZeReFfhb
	 ESEumnDdicm+AaZ86O64Rk481HnO+DrfuwIj2CNMULjNNWtl05RpBB/Echucr1tLr4Y4o
	 JGT3Q7Rqh7TdNDBj0CPPK7WOCNGiHqPdZ2OiKQ2jo5s22HxFrx/l3P/HgTdTSLPaGhg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794884465;
	h=DMARC-Filter:Received:Received:DKIM-Signature:DKIM-Signature:
	 X-DKIM2-Info:DKIM2-Signature:X-DKIM2-Info:Message-Instance:
	 X-ME-Sender:X-ME-Received:X-ME-Proxy-Cause:X-ME-Proxy:Feedback-ID:
	 Received:Content-Type:Content-Transfer-Encoding:MIME-Version:From:To:
	 Cc:Subject:In-reply-to:References:Date:Message-id:Reply-To;
	bh=36M+zBqzwV+UofiBww7U0Hvs36Q7P09aHPOOs9tQWMU=;
	b=kD4OIzLS7qlL02/GdW5SCH9qy06OlcZShKrGuLC23PqW0YpYgb8Sc4dolNXNd1k+ACwg
	 jzjltRg4PPQ1jVSacsBs2QDV9Z4h6VFqJWOicQzrBQsUVwH8ivIn5G84bF52rbG1RLCMq
	 wvV0gxHDy5zurgFLImDkguui8YnaaaDYwlKxShhQeQdVyybKgOosTNT5EZzfA1rSZhUTK
	 cDSYTc9qmLwWOdhoW7uSMFC0JEBAVNXrW/6O1d9jJ2OkM0TFdpHaTUvFTD55W49vh3Zrz
	 iIdBfhW8tu13pAbSw6TXXsBfQkotMlxLy87dvgHmXydx8H0lsXWvBpM9tyYE108RQbQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=ownmail.net;
	spf=pass smtp.mailfrom=ownmail.net;
	dkim=pass header.d=ownmail.net header.i=@ownmail.net header.a=rsa-sha256 header.s=fm3 header.b=JqKXWgag;
	dkim=pass header.d=messagingengine.com header.i=@messagingengine.com header.a=rsa-sha256 header.s=fm3 header.b=5kenHVoO;
	arc=none smtp.remote-ip=103.168.172.152
Received: from fhigh-a1-smtp.messagingengine.com (fhigh-a1-smtp.messagingengine.com [103.168.172.152])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id CBE2A606A31C
	for <linux-nfs@vger.kernel.org>; Tue, 17 Nov 2026 03:01:04 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org CBE2A606A31C
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=ownmail.net header.i=@ownmail.net header.a=rsa-sha256 header.s=fm3 header.b=JqKXWgag;
	dkim=pass (2048-bit key, unprotected) header.d=messagingengine.com header.i=@messagingengine.com header.a=rsa-sha256 header.s=fm3 header.b=5kenHVoO
Received: from phl-compute-01.internal (phl-compute-01.internal [10.202.2.41])
	by mailfhigh.phl.internal (Postfix) with ESMTP id B97D014000CA
	for <linux-nfs@vger.kernel.org>; Mon, 16 Nov 2026 22:01:03 -0500 (EST)
Received: from phl-frontend-03 ([10.202.2.162])
  by phl-compute-01.internal (MEProxy); Mon, 16 Nov 2026 22:01:03 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:content-type:date
	:date:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to; s=fm3; t=
	1794884463; x=1794970863; bh=36M+zBqzwV+UofiBww7U0Hvs36Q7P09aHPO
	Os9tQWMU=; b=JqKXWgagLQUQDq2jG5B9+DPzhSxQkUWJ4op7gdRgxjEHO0YX6ov
	05+oD3nSynWEf+kFN7AHcCb12PRh08WdJFZo/D8bv7MHubqX55ek83xbc7f1cGJ6
	1+hlJxt1v51t2dwKHphfWDXcrxYVt9O+Rrjtp0FjWGMA92d+N30zDjnpUOQon9y5
	1qh6J2wbC9ob46FggC5nJbXjCtPi9KNJKaO9QTdXUQjW+ktmL85jdMcDuy3NQPMZ
	tnaw33W9+kO0IpXqQpGyd0PVveyjbilcvQbI0aUv4HNt61mggn7GIPMW4pJhz75+
	CauSGALgvf209VJwfpHnANuYJ9NbLTPs7gA==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:content-type:date:date:feedback-id:feedback-id
	:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to:x-me-proxy
	:x-me-sender:x-me-sender:x-sasl-enc; s=fm3; t=1794884463; x=
	1794970863; bh=36M+zBqzwV+UofiBww7U0Hvs36Q7P09aHPOOs9tQWMU=; b=5
	kenHVoObOno2bcp7k5zNvzlZnUWogIyhTYf4PR0R4UbF7QMJh2KCnOxjvyeso5AS
	7hShN0H9NGxCxCPhaCzdvb4P5byPDbh4aqZnyemE+DEFNn+zhwwxRNVN0LKNlOdI
	+xOSXTF6RffBs37f50Ga7U5ERat/XnBdMvd9RXUWE6kGAodiq82yi0YPwaWudKpU
	tGK0tBQ/16k5YNT7UXc2anxaWQnEgs9eTKOxb1ViNhwXy2h16FbhM+0TtuCGi/SD
	LTNNkr7xPsGRVeUu49h70LHJoI68witcQPPAD7k3PxV5etzsZhli3X5/1SarxxH9
	BuUs6p8Ltf6sgA3g/a0cg==
X-DKIM2-Info: draft=ietf-dkim-dkim2-spec-09;
	repo=github.com/dkim2wg/interop; date=2026-11-03; sw=lmtpprox;
	action=sign d=ownmail.net a=rsa-sha256;
DKIM2-Signature: i=1; m=1; t=1794884463; d=ownmail.net;
	mf=PG5laWxiQG93bm1haWwubmV0Pg==;
	rt=PGxpbnV4LW5mc0B2Z2VyLmtlcm5lbC5vcmc+;
	s=fm3:rsa-sha256:lb4Mhd71NdT1YjAjV+sdFg14IQNPK1a0zh6LfWTQ0Um8wmP
	AQLeObUB4TmcBKD1mH576e29N2EhQ2T11FftiYdlpQzCbTYacVBSe+RBb84iLKHC
	q72iFz9GRb+TFZ91YdC/VRtJmKbeeYVMPoZMN4vmKp42Nzb+e/JXVdwTOqUuevT1
	ZHAYsyFEjtMY/sonxfsuebJpgMj0EqQGdNpJEIx+zqwB8Q5Zk35ob7lPYI8lyjXe
	L8qnLzcHCIUBecCpq0JUNFACapEKdT3MDVrEqp2N6E1rhstODzom8HSwyclKzNSw
	Cd9n5HIvoTtDSaiGEt5rEusnWkPW9pTE563nQCg==;
X-DKIM2-Info: draft=ietf-dkim-dkim2-spec-09;
	repo=github.com/dkim2wg/interop; date=2026-11-03; sw=lmtpprox;
	action=mi-m=1; hc=13;
	hn=cc,content-transfer-encoding,content-type,date,feedback-id,
	from,in-reply-to,message-id,mime-version,references,reply-to,
	subject,to;
Message-Instance: m=1; h=sha256:lTxqzXnTSWKZtnAjfKsv5Bza5hH6fMZvnjJeGaLWW8s=:RR0ulbXLhdfg0zXbjzTfde9f+R7K4wb83PL/FmDq9Z0=;
X-ME-Sender: <xms:b8P7asYEp4k5AEwGzXMqT0eHv6P4voX1um6iuTDnP4-hk4quNYGuVg>
    <xme:b8P7auTSG-CjOAs6ZSQFyAOMCvi2cvxoNdgy6oNnNRQFVtS1HNFZUAtUCAaWTsy3h
    -A3AzMRXB47jXD_4-ZXIQrOSw3UTRdR82X3ZIBheWFcag2vkR4>
X-ME-Received: <xmr:b8P7avQ1lDAJRIjkYOmcpX99d6rJfoDVqE_mK5Taq-xm45N69fd4OEzIUXbuGtyLLE_eZhBKnr5Au91xO9v5__JS4y10R-I>
X-ME-Proxy-Cause: dmFkZTGSz9S1/Zr80RmDc069yJ1hGwhp7aoOqkqVwqDGCx7W64GPxL4FvbUnTrcVkevljt
    1Jqcs668klymdM3u+8LdgYBPVyWFJbcRKyumOXDc9sotN+1vrnY1QV1DOjlYlirLL9QJ8c
    pMOljTZOnpXcl7vzC8g/NhjSClUKszbGLjBKHawab54ihth4cvFExmR705pM0n/GxwEeQj
    HSIL6enAqDQ4QAb6pNzkRiOmqBRoGKKcJxRtMpExhr1yYe/zz7NOO1FY+VKZaEAoNy9ga1
    iV0KSIii6XyXgk1QBK0KwzKJHY2oqKMsSxNQjBiK9tZ67WZuwxSz9eL7OBP00Ep4jdjkIb
    yMCcU4ViLqRyycXznX/9RO/YETvJCUMJHGfugLxRUNSeF/YWwCrhCIautBf96Amdn+GH9K
    pl44JhrXEvqPvM9GIRdJbmJOM8RjNncBgH8Ete9Z2gF1gAMb1ZYmLQjKxZ/PoGa5IEmkFo
    ImGmPQNttssiT8sUxO0Nt6XjTKull5iWnS9WSZzs0U9lIcowQCxOVYse9B9pjlQVIPfBFa
    Fd7RRrKQ1e4T10CjpxCe3DG1qgX33NHLjbzDvnmfJb92RnyBJvO+x0MkkBgk13NSzjh2Sm
    8QGnmQGEVg+zHhyLGiPrW7wT7PSCbI8sgXo3MFrP8NKFV1S4JcfIZ2puDr1w
X-ME-Proxy: <xmx:b8P7aiRbJbLfP3V3pQXEh5Ss0uDNWDgB9YP4RwQonjKylc8y2f7q8w>
    <xmx:b8P7ak7jD9x134KFHG6zDoPNvoKy_HTjj9RLv1LhcvCwdPIb5oVD9Q>
    <xmx:b8P7au014Cz4t97wOiRBtdV_5rvwWIWtK3BUokPrHRkX8VSEVFUtJA>
    <xmx:b8P7avArnx5i3SF0SB8CxRZVKHR6_Wem7-BlGPzdhWKzF4abpad5Yg>
    <xmx:b8P7ameyaySuXkUYGHRaE0KbvGkaD1EbloWYxJRQUTpklgrL70dzbkD->
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Mon,
 16 Nov 2026 22:01:01 -0500 (EST)
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: quoted-printable
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
From: NeilBrown <neilb@ownmail.net>
To: "Trond Myklebust" <trondmy@kernel.org>, "Anna Schumaker" <anna@kernel.org>
Cc: "Jeff Layton" <jlayton@kernel.org>,
 "Jonathan Flynn" <jonathan.flynn@hammerspace.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v5 0/8] nfs: prepare for locking changes.
In-reply-to: <20261109005504.1804605-1-neilb@ownmail.net>
References: <20261109005504.1804605-1-neilb@ownmail.net>
Date: Tue, 17 Nov 2026 14:00:58 +1100
Message-id: <179488445814.1728055.9049767251296971441@noble.neil.brown.name>
Reply-To: NeilBrown <neil@brown.name>


Hi Anna/Trond,
is there any chance this series might land for the next merge window?

Thanks,
NeilBrown


On Mon, 09 Nov 2026, NeilBrown wrote:
> In this v5 I've dropped "nfs: fix nfs_call_unlink()" because it enabled cod=
e that was
> buggy.  I have ideas how to fix this properly but it belongs in a separate =
series.
>=20
> I've also revised the barriers in "nfs: fix open-blocking with d_fsdata", t=
hanks
> in part to Jonathan's input.
>=20
> I think the rest is unchanged.
>=20
> Thanks,
> NeilBrown
>=20
>  [PATCH v5 1/8] nfs: fix open-blocking with d_fsdata
>  [PATCH v5 2/8] nfs: remove d_drop()/d_alloc_parallel() from
>  [PATCH v5 3/8] nfs: use d_splice_alias() in nfs_link()
>  [PATCH v5 4/8] nfs: don't d_drop() before d_splice_alias()
>  [PATCH v5 5/8] nfs: don't d_drop() before d_splice_alias() in
>  [PATCH v5 6/8] nfs: Use d_alloc_trylock() in nfs_prime_dcache()
>  [PATCH v5 7/8] nfs: use d_alloc_trylock() in silly-rename
>  [PATCH v5 8/8] nfs: use d_duplicate()
>=20
>=20


Received: from fhigh-b8-smtp.messagingengine.com (fhigh-b8-smtp.messagingengine.com [202.12.124.159])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2A04B3D0BE4
	for <linux-nfs@vger.kernel.org>; Fri, 28 Aug 2026 11:33:18 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=202.12.124.159
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787916801; cv=none; b=LZxLpvkd6SBkOofQoFJSh+wuAFZtdU5uaxNrdKSGhq7ZHdV1ArGAHgmNLcIBywdVggIUxcQCutS0GLl06S8eEyZwfXTKy7ZQ5u3KTpz1dSa2gZAelzn4V1y4XlxAQzaH2Yh4bPTAzoL4S6tuxBjdocAnHAX30NffJH47I8uGAZk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787916801; c=relaxed/simple;
	bh=nalpzAzWD3rMBoHbwct7eEAkwMKZdwkFghsFUxA1i6Q=;
	h=Content-Type:MIME-Version:From:To:Cc:Subject:In-reply-to:
	 References:Date:Message-id; b=ZJN4xatIaF3NyxLRHqHB41BRrigTfj9k3iKRaKchTYfuHgRvKLdfdJP+U9Hax9X2UN/paHWKeUeVaUOrIKO9T4eIe+HVRwobB193xN69SaHs/i0fw15Boro/M16TCET9j03K/VQ9V02VkbfUjhY3re5pP7GxCTkdFT1XHcbKvDQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=jv/3/gKS; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=GwTih2nD; arc=none smtp.client-ip=202.12.124.159
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="jv/3/gKS";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="GwTih2nD"
Received: from phl-compute-04.internal (phl-compute-04.internal [10.202.2.44])
	by mailfhigh.stl.internal (Postfix) with ESMTP id 119637A0120;
	Fri, 28 Aug 2026 07:33:18 -0400 (EDT)
Received: from phl-frontend-04 ([10.202.2.163])
  by phl-compute-04.internal (MEProxy); Fri, 28 Aug 2026 07:33:18 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:content-type:date
	:date:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to; s=fm3; t=
	1787916797; x=1788003197; bh=RqfQVKY3XgcXdWJZKW1w1tfQXx8sjJlzemV
	ozLayP5E=; b=jv/3/gKSpUMav3sFndcYOYiApjVMgnfnAny7p7ei0ji2dVr9XAM
	Q+HGhFRLu3sjf3sA/6y9NDyCfB+jWduXjGYMimTJw6ygyC1Sf8JzuJGgU3HHKbR9
	vGSnkvf6gyA6PMZptvRCi5cpa9IgnYJn4xlNcuEtK9lzMYoHd2PptQMjyy9UVKQA
	hSeBGnK6qt77nJOQp6Nqq8hjNH1ihoN502gVghDDz4jeTsCsC6y7v69B0JRkVMln
	dyQjcCyy2GJk38fgF3Fh6258Eew348qU6MYZxvp6HkNSZ1FfSHaqLm+9bGJexury
	SnqBe56mQOBN/l4mSVz8dkgff0VxtNt7NZQ==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:content-type:date:date:feedback-id:feedback-id
	:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to:x-me-proxy
	:x-me-sender:x-me-sender:x-sasl-enc; s=fm3; t=1787916797; x=
	1788003197; bh=RqfQVKY3XgcXdWJZKW1w1tfQXx8sjJlzemVozLayP5E=; b=G
	wTih2nDuh+FFRgNyDFnVGVtP+Q6tS2iAN9D8HrqLWplhSIyt5cL4oFHkEJR5BNwY
	ZDvO7c6wiMS5SBUcHtIZkwT2zI+VS8VE6H/Ysv3nXROJRrkZYNBiQAmYXCyQa48G
	ztYMEjOU4XoqXjA/Z1xAVNtGOcupp1qjf/yFAi6sjafvMyk/N4pRGlyj5ictSm1Q
	WPC+qiRo144NFKSpokzBnrtBihhB4cq83Rrt2U2fh9GE+IxsYlVP0blHMv2IXbZA
	ldlkMDRXrly47OCTD+M/CGMcy3ED9OC6UAOBRJkgTrH2T5ErzjVGrqWNLo+9Irf+
	xOm/jdzlOqfqXgi2qaeJg==
X-ME-Sender: <xms:_XGRapR5MneZ5ASc47qHIdOyvIOVh8B-XujglVB0WCVuB9-EtOGEzw>
    <xme:_XGRah23kRSDU1YAjhWauMxGgVes3nAloMd7NR-bDbucXfrkJ2Z4ljz9S5oyJhIz3
    z5mC01ktRta4ZGWGf89zFRPyydRaIzMUfFHbWP9-qoHioROKbY>
X-ME-Received: <xmr:_XGRalDD1zQ7ZJ3FvTGCAsVlqTTB67ieTeizdpasyvJlRZ2EGGhfsDiiB1EB2TeDZkGjPeoXAkbkRiKd2BQoh51tlxvk7qE>
X-ME-Proxy-Cause: dmFkZTEXTYvKFB6Lr64f2r2pNcWisboOmKYGZ4oF4f0JmFjRO2XIeYz8DtB/7EPKNx3sqG
    R7ODq5AbwrkNxEdA+eYA1SqCxU30W+q+hVzcVt4wF9XTikJN+3Lbl0bcF4OyMt3/lZNNni
    2RIGQ7dA/nFl9ewuen5uaAi0bfIutCIkGv2ttjwNfAS1aTxM6Tb9xL2+9EFIpKLLjLi9/a
    s4dBL2EqFXa7PH3UnlmH27CPBVYy54S1nE8FE5ebfOcVyKNO4/BIrIWeXDKoCp7Fvira15
    8h/QpjbIofxQkBDO7nF+PqIwnrloST5bbrs1VfH1BOf3IFwDbTM8ugx2ZSZ2uDnOtiiNXB
    CYsJtqFnhDr7ktbl6hMJZwVKUoHis+w1n5LwsSp4NfvfaMq67Ki8RRRAXBrzWn54+ExuNC
    jVryakvNe1N9aWIo34oKOsybvgGKRIZUwv30aGp7PBPZezKBcxhJRdnsM9ZtEjUREVjN1x
    eSc6Dvc0FSHSc66Bv9mcuCeW77YcEaDTkm4sH04kGjD8PDGU6MSRCNSWioEERVQFGuopc+
    jiOvuXuYN5xyZQbPgn7fdgAh/Wp6BHZEroenj5Bcazdm0KurTO7bcja4I8xcdCiPrVkQty
    QBfGqTA9h5Mvb5MbY8tx2CRTGFWAkW6GpyBGz+RVkpycp7QJ6NJXWdfARo6w
X-ME-Proxy: <xmx:_XGRatgmATwMqwVIxdXxZSFsRs3oybvjHAxbRe2s4ZYeUEbhQE_LEQ>
    <xmx:_XGRanMowtx5JaDFjlAAmuSHLKk6H0__O658tKHSEG92WNDFj8xPSQ>
    <xmx:_XGRat-IvlM_EnCFo0XVw9oRDYsfNKdi2ufKhFxdOl1OwN27xeFczQ>
    <xmx:_XGRaofxb-mYCDeZDl7Ff95ztu5Wq8ILVX11xqG4B0Bh-8cutAxFqw>
    <xmx:_XGRasRmCyQipX-Ymx7wZk1LtO0FqdB-4J6PxdjJio1MymHayZ-EhUxJ>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Fri,
 28 Aug 2026 07:33:14 -0400 (EDT)
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
From: NeilBrown <neilb@ownmail.net>
To: =?utf-8?q?J=C3=B6rg?= Sommer <joerg@jo-so.de>
Cc: "Chuck Lever" <cel@kernel.org>, "Jeff Layton" <jlayton@kernel.org>,
 "Olga Kornievskaia" <okorniev@redhat.com>, "Dai Ngo" <dai.ngo@oracle.com>,
 "Tom Talpey" <tom@talpey.com>, linux-nfs@vger.kernel.org,
 "Chuck Lever" <chuck.lever@oracle.com>
Subject: Re: [PATCH 2/2] NFS: NFSERR_INVAL is not defined by NFSv2
In-reply-to: <apE90ZRZB8IW_AiS@jo-so.de>
References: <20251210002850.318350-1-cel@kernel.org>
  <20251210002850.318350-3-cel@kernel.org>  <apE90ZRZB8IW_AiS@jo-so.de>
Date: Fri, 28 Aug 2026 21:33:10 +1000
Message-id: <178791679053.3510150.70411349578293852@noble.neil.brown.name>
Reply-To: NeilBrown <neil@brown.name>

On Fri, 28 Aug 2026, J=C3=B6rg Sommer wrote:
> Chuck Lever schrieb am Di 09. Dez, 19:28 (-0500):
> > From: Chuck Lever <chuck.lever@oracle.com>
> >=20
> > A documenting comment in include/uapi/linux/nfs.h claims incorrectly
> > that NFSv2 defines NFSERR_INVAL. There is no such definition in either
> > RFC 1094 or https://pubs.opengroup.org/onlinepubs/9629799/chap7.htm
> >=20
> > NFS3ERR_INVAL is introduced in RFC 1813.
>=20
> Hello,
>=20
> since this commit 0ac903d1bfdce8ff40657c2b7d996947b72b6645 was added, U-Boot
> 2022.04 (I don't know about newer versions) can no longer access symlinks in
> NFS shares. When I revert this commit, U-Boot can load the file behind the
> symlink. Real files are no problem.
>=20
> The file I want to load is a symlink at the server:
>=20
> ```
> % ls -l /srv/nfs/boot/Image.gz*
> lrwxrwxrwx 1 root root      41  7. Jul 16:29 /srv/nfs-con/boot/Image.gz -> =
Image.gz-5.15.213-imx8mm+gfffa4b6d4aea+p1
> -rw-r--r-- 1 root root 5279373  7. Jul 16:29 /srv/nfs-con/boot/Image.gz-5.1=
5.213-imx8mm+gfffa4b6d4aea+p1
> ```
>=20
> Without this commit:
>=20
> ```
> u-boot=3D> nfs 0x42000000 /srv/nfs/boot/Image.gz
> Filename '/srv/nfs-con/boot/Image.gz'.
> Load address: 0x42000000
> Loading: #################################################################
> done
> Bytes transferred =3D 5279373 (508e8d hex)
> ```
>=20
> But with this commit:
>=20
> ```
> u-boot=3D> nfs 0x42000000 /srv/nfs/boot/Image.gz
> Filename '/srv/nfs-con/boot/Image.gz'.
> Load address: 0x42000000
> Loading:
> done
> ```
>=20
> This is the network traffic:
>=20
> ```
> No.	Time	Protocol	Length	Info
> 3	0.000370	Portmap	98	V2 GETPORT Call (Reply In 4) MOUNT(100005) V:1 UDP
> 4	0.000607	Portmap	70	V2 GETPORT Reply (Call In 3) Port:60340
> 5	0.000949	Portmap	98	V2 GETPORT Call (Reply In 6) NFS(100003) V:2 UDP
> 6	0.001046	Portmap	70	V2 GETPORT Reply (Call In 5) Port:2049
> 7	0.001368	MOUNT	126	V2 MNT Call (Reply In 8) /srv/nfs-con/boot
> 8	0.008026	MOUNT	102	V2 MNT Reply (Call In 7)
> 9	0.008389	NFS	146	V2 LOOKUP Call (Reply In 10), DH: 0x8c279135/Image.gz
> 10	0.008754	NFS	170	V2 LOOKUP Reply (Call In 9), FH: 0xcdddf154
> 11	0.009095	NFS	146	V2 READ Call (Reply In 12), FH: 0xcdddf154 Offset: 0 Co=
unt: 1024 TotalCount: 0
> 12	0.009189	NFS	70	V2 READ Reply (Call In 11) Error: NFS2ERR_IO
> 13	0.009511	MOUNT	102	V2 UMNTALL Call (Reply In 14)
> 14	0.010301	MOUNT	66	V2 UMNTALL Reply (Call In 13)
> ```
>=20
> From packet 11 V2 READ Call
>=20
> ```
> Remote Procedure Call, Type:Call XID:0x000050e1
>     XID: 0x000050e1 (20705)
>     Message Type: Call (0)
>     RPC Version: 2
>     Program: NFS (100003)
>     Program Version: 2
>     Procedure: READ (6)
>     [The reply to this request is in frame 12]
>     Credentials
>         Flavor: AUTH_UNIX (1)
>         Length: 20
>         Stamp: 0x00000000
>         Machine Name: <EMPTY>
>         UID: 0
>         GID: 0
>         Auxiliary GIDs (0)
>     Verifier
>         Flavor: AUTH_NULL (0)
>         Length: 0
> Network File System, READ Call FH: 0xcdddf154 Offset: 0 Count: 1024 TotalCo=
unt: 0
>     [Program Version: 2]
>     [V2 Procedure: READ (6)]
>     file
>         [hash (CRC-32): 0xcdddf154]
>         FileHandle: 010004010100540020bb3809040054002f2edde4000000000000000=
000000000
>     Offset: 0
>     Count: 1024
>     Total Count: 0
> ```
>=20
> From packet 12 V2 READ Reply
>=20
> ```
> Remote Procedure Call, Type:Reply XID:0x000050e1
>     XID: 0x000050e1 (20705)
>     Message Type: Reply (1)
>     [Program: NFS (100003)]
>     [Program Version: 2]
>     [Procedure: READ (6)]
>     Reply State: accepted (0)
>     [This is a reply to a request in frame 11]
>     [Time from request: 94.000 microseconds]
>     Verifier
>         Flavor: AUTH_NULL (0)
>         Length: 0
>     Accept State: RPC executed successfully (0)
> Network File System, READ Reply  Error: NFS2ERR_IO
>     [Program Version: 2]
>     [V2 Procedure: READ (6)]
>     Status: NFS2ERR_IO (5)
> ```
>=20
>=20
> I can locally revert this commit in our kernel, but is there any other way
> to get it working again?

This is unfortunate.
U-boot has

		} else if ((rlen =3D=3D -NFSERR_ISDIR) || (rlen =3D=3D -NFSERR_INVAL)) {
			/* symbolic link */
			nfs_state =3D STATE_READLINK_REQ;
			nfs_send();

so we either need nfsdv2 to return NFSERR_ISDIR (for something that
isn't a directory) or NFSERR_INVAL (which is not a valid v2 error code),
or change u-boot to also check for NFSERR_IO (which is 5).

There is no "good" option.
I suspect we should revert this change and document that we violate the
RFC for historical compatibility with u-boot.

NeilBrown


>=20
>=20
> Thanks in advance.
>=20
> Best regards J=C3=B6rg
>=20
> --=20
> Optimisten haben gar keine Ahnung von den freudigen =C3=9Cberraschungen, die
> Pessimisten erleben.
>                                                 (Peter Bramm)
>=20


Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9400E346766
	for <linux-nfs@vger.kernel.org>; Fri, 28 Aug 2026 21:06:34 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787951195; cv=none; b=hImoNlUDfjs7jOagAvfMFoWf4FE/cFEXFFOKg9we9oLi2tl6it3Ohch4TwuVrgrxe9Kky1phmVaO1y1NKGptfRoOGuiheWojC6FemTYc5a1SYT9wPb744WWq4ntd49PRCUK5PRsITdmgK2vTFSRmtrsYUfS1xNMdDbPJ9hHpmBg=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787951195; c=relaxed/simple;
	bh=iKt6NHeTCDhe2nwCV5YS+tmyD5Z8MEH/5egpWy1mQfk=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=VxfV9AluwDg/aq9poSHkM4xeH3eiQRbATk/CycQPFPXUDLOf5UpUDkyXLdlar+axi48LmnrwRDXlgMVoW+bvI69ZCwowfEtNFY9ekQbTFG9cQMC0T02lPDy2eil8/5p6F5n/bdMVMPdPUXlvsMNI/VFTIOXiDaFK9MVEQGRjghM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=Rk5pOh2Q; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="Rk5pOh2Q"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id D43561F00A3E;
	Fri, 28 Aug 2026 21:06:33 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1787951194;
	bh=uB0YOnCUqjAXG/HWcCEEDtxm1fOte+w7wCQmvUzSnmo=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=Rk5pOh2QXwf77Etbz0PkvreGQzldO/lBsLXnWL8zj876Z3OVta/2hHFfF91WV3lV6
	 ZNdc7zsBIDYScORSDcifCgre0Ry7DaBHprEcEcx2VDEbeSsYDSXPOXXj/D2KpquWnC
	 XqX0YC152OHAjF/YyfLZnHirEQVgDi09JFenX/oLKkYrr8+QffXEFrUqOKGTNS3kuw
	 E0pqI77/eJM2lAyHX8jQaOiY1iJXjcl5RpK7928jQ9VbxdSBGkg3cRn99VgAgloz9g
	 ftoY8tutrzJfL4oukRIATjengv1Gw2lnlw5doYHmYPy6yt3lJAqJVdmaMG5EI3GxWM
	 cqJUFh9q2vfkg==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id 15BE3F40066;
	Fri, 28 Aug 2026 17:06:33 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Fri, 28 Aug 2026 17:06:33 -0400
X-ME-Sender: <xms:WPiRagq7e_bw8lQWxzKlz3EGsKcmEHaOq_59CHHP4GWn2cC4jH9m5Q>
    <xme:WPiRahdzgBHZ4kJcdZz9om43LXfpzkkFBU-HXom-A40kXjhcGOxV93UJnpStqyrcS
    m1aCXKRbQtlVs6jJOD0ULRtaFGjuOxdxPjPFHMaK3UMC8iLeBjoT4QN>
X-ME-Proxy-Cause: dmFkZTFqgC9udJVXthMq+vj4WaciAURf5lfTQELNoelSwW3sOXzEOJV9S3gmN0Li5jPwdA
    /88noHu2tQI8kbK1DrHFVgqWqKwYa5GPmcvTVXWbr6GUuGXMVjplgat2nhE2MfJumCm3r4
    3itz1RNSHUXSkEkMqhOzZfc482xD3rQLenq2P+0Ij9JEleLbjBpZ/zouUO5gwzv1rpEhly
    v45qw8lbu873kXv/wv5Nlw4HqlGmUveCKbQPonHRmLfDjlF4qWBFiUVgPmtpZ4QjNXhhOy
    RloXO1m+KMOe6CvsdBzyX+o7pvqqXryy88F3Z6H06bC60ApSezr0edixl/k6op63CmtQJR
    EscH36WMLFuBg7QsY45ZpMP9YDmJbu4QLbUljdw2l4C/bTgjZyEf2WhkWkbmP2mj06Q0uy
    rviK57Aqphx5t4+/eAEK8q6t+vviI5JyEewwvwebE5WLe7qjglMKEbtyKOcSs8180jNMWI
    CJP56x7Uu/F9xZdDG3H3UAJ9n++sizGrKWYHhYh9VxfzIIvOTLfHRqwWp4aj+M+RTHUjAT
    FpFFXvM1jWKsNz8lRXSQH7SiUNC7q57huF5Vr22260vYj7sKqwNBufi936KV0/zyne6dUK
    ic2BwsSQ7F0ab1D9FYunYJZW30AKchfvv29iynHVT1iYkluil2Uz73MesGLQ
X-ME-Proxy: <xmx:WPiRatnXOhGa7G4x75Y61m6-sfjKBndGabdz3A-6HIHm1wTZjMxQig>
    <xmx:WfiRatySk2sfYDocDMhU5gP6G6ENzr9pIeu5tPeXfshlaPi9t6SNSg>
    <xmx:WfiRan5fFxB1e9KPbkQuuGw7KccXPp9yj4fd2mAGr95OTLYsFEcPdQ>
    <xmx:WfiRatWSiDdYBlZzYGs_PNhsrFcdpvgxT_JQZa83TloeWyvs1Zt11Q>
    <xmx:WfiRavLedDSYyuKHkLJREFayF8b0TGnoFp6DtA25-fBa2kQgEnxTK9bn>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id DCFBB7811F4; Fri, 28 Aug 2026 17:06:32 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: AcUrMSdZQCF-
Date: Fri, 28 Aug 2026 17:06:14 -0400
From: "Chuck Lever" <cel@kernel.org>
To: "Tom Rini" <trini@konsulko.com>
Cc: NeilBrown <neil@brown.name>,
 =?UTF-8?Q?J=C3=B6rg_Sommer?= <joerg@jo-so.de>,
 "Jeff Layton" <jlayton@kernel.org>,
 "Olga Kornievskaia" <okorniev@redhat.com>, "Dai Ngo" <dai.ngo@oracle.com>,
 "Tom Talpey" <tom@talpey.com>, linux-nfs@vger.kernel.org,
 "Chuck Lever" <chuck.lever@oracle.com>
Message-Id: <a9a48faa-2663-40d7-86c8-ec2eaa967cdf@app.fastmail.com>
In-Reply-To: <20260828205116.GA266670@bill-the-cat>
References: <20251210002850.318350-1-cel@kernel.org>
 <20251210002850.318350-3-cel@kernel.org> <apE90ZRZB8IW_AiS@jo-so.de>
 <178791679053.3510150.70411349578293852@noble.neil.brown.name>
 <91e02ca3-e985-47fa-aed8-0b50a5d7a3c9@app.fastmail.com>
 <20260828205116.GA266670@bill-the-cat>
Subject: Re: [PATCH 2/2] NFS: NFSERR_INVAL is not defined by NFSv2
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable



On Fri, Aug 28, 2026, at 4:51 PM, Tom Rini wrote:
> On Fri, Aug 28, 2026 at 09:27:41AM -0400, Chuck Lever wrote:
>>=20
>>=20
>> On Fri, Aug 28, 2026, at 7:33 AM, NeilBrown wrote:
>> > On Fri, 28 Aug 2026, J=C3=B6rg Sommer wrote:
>> >> Chuck Lever schrieb am Di 09. Dez, 19:28 (-0500):
>> >> > From: Chuck Lever <chuck.lever@oracle.com>
>> >> >=20
>> >> > A documenting comment in include/uapi/linux/nfs.h claims incorre=
ctly
>> >> > that NFSv2 defines NFSERR_INVAL. There is no such definition in =
either
>> >> > RFC 1094 or https://pubs.opengroup.org/onlinepubs/9629799/chap7.=
htm
>> >> >=20
>> >> > NFS3ERR_INVAL is introduced in RFC 1813.
>> >>=20
>> >> Hello,
>> >>=20
>> >> since this commit 0ac903d1bfdce8ff40657c2b7d996947b72b6645 was add=
ed, U-Boot
>> >> 2022.04 (I don't know about newer versions) can no longer access s=
ymlinks in
>> >> NFS shares. When I revert this commit, U-Boot can load the file be=
hind the
>> >> symlink. Real files are no problem.
>> >>=20
>> >> The file I want to load is a symlink at the server:
>> >>=20
>> >> ```
>> >> % ls -l /srv/nfs/boot/Image.gz*
>> >> lrwxrwxrwx 1 root root      41  7. Jul 16:29 /srv/nfs-con/boot/Ima=
ge.gz -> Image.gz-5.15.213-imx8mm+gfffa4b6d4aea+p1
>> >> -rw-r--r-- 1 root root 5279373  7. Jul 16:29 /srv/nfs-con/boot/Ima=
ge.gz-5.15.213-imx8mm+gfffa4b6d4aea+p1
>> >> ```
>> >>=20
>> >> Without this commit:
>> >>=20
>> >> ```
>> >> u-boot=3D> nfs 0x42000000 /srv/nfs/boot/Image.gz
>> >> Filename '/srv/nfs-con/boot/Image.gz'.
>> >> Load address: 0x42000000
>> >> Loading: #########################################################=
########
>> >> done
>> >> Bytes transferred =3D 5279373 (508e8d hex)
>> >> ```
>> >>=20
>> >> But with this commit:
>> >>=20
>> >> ```
>> >> u-boot=3D> nfs 0x42000000 /srv/nfs/boot/Image.gz
>> >> Filename '/srv/nfs-con/boot/Image.gz'.
>> >> Load address: 0x42000000
>> >> Loading:
>> >> done
>> >> ```
>> >>=20
>> >> This is the network traffic:
>> >>=20
>> >> ```
>> >> No.	Time	Protocol	Length	Info
>> >> 3	0.000370	Portmap	98	V2 GETPORT Call (Reply In 4) MOUNT(100005) V=
:1 UDP
>> >> 4	0.000607	Portmap	70	V2 GETPORT Reply (Call In 3) Port:60340
>> >> 5	0.000949	Portmap	98	V2 GETPORT Call (Reply In 6) NFS(100003) V:2=
 UDP
>> >> 6	0.001046	Portmap	70	V2 GETPORT Reply (Call In 5) Port:2049
>> >> 7	0.001368	MOUNT	126	V2 MNT Call (Reply In 8) /srv/nfs-con/boot
>> >> 8	0.008026	MOUNT	102	V2 MNT Reply (Call In 7)
>> >> 9	0.008389	NFS	146	V2 LOOKUP Call (Reply In 10), DH: 0x8c279135/Im=
age.gz
>> >> 10	0.008754	NFS	170	V2 LOOKUP Reply (Call In 9), FH: 0xcdddf154
>> >> 11	0.009095	NFS	146	V2 READ Call (Reply In 12), FH: 0xcdddf154 Off=
set: 0 Count: 1024 TotalCount: 0
>> >> 12	0.009189	NFS	70	V2 READ Reply (Call In 11) Error: NFS2ERR_IO
>> >> 13	0.009511	MOUNT	102	V2 UMNTALL Call (Reply In 14)
>> >> 14	0.010301	MOUNT	66	V2 UMNTALL Reply (Call In 13)
>> >> ```
>> >>=20
>> >> From packet 11 V2 READ Call
>> >>=20
>> >> ```
>> >> Remote Procedure Call, Type:Call XID:0x000050e1
>> >>     XID: 0x000050e1 (20705)
>> >>     Message Type: Call (0)
>> >>     RPC Version: 2
>> >>     Program: NFS (100003)
>> >>     Program Version: 2
>> >>     Procedure: READ (6)
>> >>     [The reply to this request is in frame 12]
>> >>     Credentials
>> >>         Flavor: AUTH_UNIX (1)
>> >>         Length: 20
>> >>         Stamp: 0x00000000
>> >>         Machine Name: <EMPTY>
>> >>         UID: 0
>> >>         GID: 0
>> >>         Auxiliary GIDs (0)
>> >>     Verifier
>> >>         Flavor: AUTH_NULL (0)
>> >>         Length: 0
>> >> Network File System, READ Call FH: 0xcdddf154 Offset: 0 Count: 102=
4 TotalCount: 0
>> >>     [Program Version: 2]
>> >>     [V2 Procedure: READ (6)]
>> >>     file
>> >>         [hash (CRC-32): 0xcdddf154]
>> >>         FileHandle: 010004010100540020bb3809040054002f2edde4000000=
000000000000000000
>> >>     Offset: 0
>> >>     Count: 1024
>> >>     Total Count: 0
>> >> ```
>> >>=20
>> >> From packet 12 V2 READ Reply
>> >>=20
>> >> ```
>> >> Remote Procedure Call, Type:Reply XID:0x000050e1
>> >>     XID: 0x000050e1 (20705)
>> >>     Message Type: Reply (1)
>> >>     [Program: NFS (100003)]
>> >>     [Program Version: 2]
>> >>     [Procedure: READ (6)]
>> >>     Reply State: accepted (0)
>> >>     [This is a reply to a request in frame 11]
>> >>     [Time from request: 94.000 microseconds]
>> >>     Verifier
>> >>         Flavor: AUTH_NULL (0)
>> >>         Length: 0
>> >>     Accept State: RPC executed successfully (0)
>> >> Network File System, READ Reply  Error: NFS2ERR_IO
>> >>     [Program Version: 2]
>> >>     [V2 Procedure: READ (6)]
>> >>     Status: NFS2ERR_IO (5)
>> >> ```
>> >>=20
>> >>=20
>> >> I can locally revert this commit in our kernel, but is there any o=
ther way
>> >> to get it working again?
>> >
>> > This is unfortunate.
>> > U-boot has
>> >
>> > 		} else if ((rlen =3D=3D -NFSERR_ISDIR) || (rlen =3D=3D -NFSERR_IN=
VAL)) {
>> > 			/* symbolic link */
>> > 			nfs_state =3D STATE_READLINK_REQ;
>> > 			nfs_send();
>> >
>> > so we either need nfsdv2 to return NFSERR_ISDIR (for something that
>> > isn't a directory) or NFSERR_INVAL (which is not a valid v2 error c=
ode),
>> > or change u-boot to also check for NFSERR_IO (which is 5).
>>=20
>> U-Boot's NFSERR_ISDIR check (quoted above) is the Sun-compatible
>> path. The NFSERR_INVAL arm was presumably added for Linux NFSD?
>>=20
>> So the pre-0ac903d1bfdc code is not something I want to go back to.
>> Returning NFSERR_INVAL is incompatible with the reference NFSv2
>> implementation, and so is NFSERR_IO.
>>=20
>> Mapping nfserr_symlink to NFSERR_ISDIR affects the READ, WRITE, and
>> SETATTR procedures. The Solaris NFS server returns NFSERR_ISDIR for
>> READ and WRITE of a non-REG object, which suggests to me that is
>> the behavior clients will expect.
>>=20
>> IMO we should leave nfserr_wrong_type alone until we have a specific
>> real-world complaint to address.
>
> On the U-Boot side of things, the code in question dates back to when
> NFS support was originally added in 2004. The history here says that
> someone added the symlink support on top of what was borrowed from
> NetBSD, so yes, we're likely the originator of the incorrect behavior.
> But also, this means that everything U-Boot that's ever been using this
> feature now fails. And given the lag between the kernel change and the
> bug report, it's not something that's in rapidly changing areas and
> probably also in deployments that can't be updated. So perhaps things =
do
> need to go back to the way it was.

That argument doesn't make sense to me, and moves NFSD backwards
instead of forward.

Reverting the commit is fine for stable kernels, but getting the
revert into mainline will take just as long as fixing it correctly.

The "deployments can't be updated" also doesn't make sense: if
they can't be updated, they won't be able to get the revert
either.

I'm not convinced.


--=20
Chuck Lever

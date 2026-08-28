Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 24BB3466B17
	for <linux-nfs@vger.kernel.org>; Fri, 28 Aug 2026 13:28:04 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787923691; cv=none; b=CSJB3I4/pzyVRrG83DIGrQ51+e+B9QR2054pasfE9bVY53bYQ9em08EYsZ/gqig4IgIcBhagwEDkNTn6PYHRdN/1mQv7wJOn0cYL1/JRiQn0+7yyY+nmYLAZQQKdnZOvgZKyBZGe1LL1jSzDDsuVZgbwVwjiR6ayf/sAJmFVDAw=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787923691; c=relaxed/simple;
	bh=eS+6dKXMZGVoghFGmm4rmXCF1N1RdG1lUvJu4NenEqQ=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=USpYETuGbQn2B+/GVwrv61zkd4ng3lzIcJYEYA20RJgyx+xSxatz4F97006mcMJxcGz258k2bC9TCpPmP8kYHVuYv9NCxZ8FPFoYnPK3nK5d3WJfAfzBoGshrVEcmed9dSgM6CgIL1wm6QOMIyvDQxG7itChYrsm8nlkWE8oK38=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=VQJOH8yw; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="VQJOH8yw"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 99EDE1F000E9;
	Fri, 28 Aug 2026 13:28:00 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1787923681;
	bh=zQZFgpSS7kS41hbMGzZFI7HbsgQE/zr8/NEtYc/ZJ2o=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=VQJOH8yw8jdjc9dsh0WP6GP12KGvXBczdZToNTNV78iTeB7+zK/wF70zSPMsCyaUb
	 rCEF3u8uj2pDUWsxEFwsu0mLM/tbQluuoYbGfIJiptPr7uHmTzYLmL0v2zLEmHRvMa
	 G7VeEkTVe9gk2FDR79P0du3Klmm7oLxEfBa5Eq+KuQCFVRaoVxtbIKSFr0Fe6cCKOR
	 jxevaeSNEDTF14lhm3Bhhx/Im0D64Sk3a4icwUBuW3yuiEbZhYBm8YPmNX8Xvlltfi
	 eUhqH4mX2VeTTwZxBJaEkQZyQJlk10Huz4ZGWD8jFLkFUUq8WD8DELl+MKuRsiJGqN
	 kllf1SDOBL8GA==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id B1A0EF40066;
	Fri, 28 Aug 2026 09:27:59 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Fri, 28 Aug 2026 09:27:59 -0400
X-ME-Sender: <xms:34yRanlmHu8V8VCj_cPOpFvvKHaFM4MPjvVvYVj4Ls6oXL6yuPItUw>
    <xme:34yRalorHWGF9q8zw3UGhFMA33pHk0X5EFgvNz2RB4s-10vBtHTT5V0oz5p5Ezvhb
    CC04Kptj51sDeu6gQH7i--tK-fjA4ir8ZmFACiNrsUDAKHohwG7IPbx>
X-ME-Proxy-Cause: dmFkZTEQDytCQ29F786vC+MzG23/IXDKN1u9smHGzGi33g9bSkjm7iBDyRHzuQN1xMQb+C
    Wy+BP6n/FrEPTSE/XpzbMW8c5WufgeqSWw7lSww5MH7NIkrYO+XoZ40pN2cY1q2QhRl69t
    yd0ZwXyc/5sNpso0mFuNaecfGgK8bjQcLMgVY8HLRFE5XyjV6+MinKg2iZY8RLfav2iemH
    mMoWJqxurE4MESo/3xkf195lmJwkpZeyJFLshEnG1rlwwaZuFac232pG9MTHhXwEVsUnRR
    Nzwopev4IbKXm7xJgeeWtmnDV96VwGDdy9mhG5e9YjYqR+hbZL7RcMI272ooQ8aN6NIdjF
    PBF389k0lxnSPVFN2CmwGhOAufuL+PazdNUfRhe3RSGZYhgUQaK5HS7YEu/VWf0r2MSuVv
    bWHyz5Knm+V1t/6fvYzmmsnkmq1yhQLMM04+nRUS1UeIsAY+xnsKS98m695FAZIJcq0mNy
    fCL2EBlpszilkp7yjZgwhVDSs3Om4Wi7mxc5jMH/fxVP30T13IQLL2MdNbd78EBmjsUjqL
    w/je8jZBoTtM3eVUMw6lyj9XqQBgXgI0MvG2ukRXlK0ZEjJjnukjP0xBGMM9kjcoU5JyIV
    RcXsURmRUM7Zlr+pG2W2/zfnylYbFUMa5f6QNjXQJymGR3JYhmBmba/Rj0Lg
X-ME-Proxy: <xmx:34yRau5TGh5S_FlZ-ta1-BE54YZ4t4R0DyKHKcgU3pE0viwtGQ1jsQ>
    <xmx:34yRah6u7rD8dasbLt6JSFawykR8kPfxq6habvjp5admwuGTkIciAA>
    <xmx:34yRakGl9XWaIESgFNchwiAS5-vVECtPDRbqpWTsyfMKoCqtjKxHmA>
    <xmx:34yRapXAs4LZLh_RCXsf-qqssS_vFRA9OptkJ4tNNTbOBeX8JE9I8A>
    <xmx:34yRagUurmeuskgX4i3dK8KCEMh6-et5sNBb7AFCw1xdG4HbMkOujEFB>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 8F86D7811F0; Fri, 28 Aug 2026 09:27:59 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: AcUrMSdZQCF-
Date: Fri, 28 Aug 2026 09:27:41 -0400
From: "Chuck Lever" <cel@kernel.org>
To: NeilBrown <neil@brown.name>, =?UTF-8?Q?J=C3=B6rg_Sommer?= <joerg@jo-so.de>
Cc: "Jeff Layton" <jlayton@kernel.org>,
 "Olga Kornievskaia" <okorniev@redhat.com>, "Dai Ngo" <dai.ngo@oracle.com>,
 "Tom Talpey" <tom@talpey.com>, linux-nfs@vger.kernel.org,
 "Chuck Lever" <chuck.lever@oracle.com>
Message-Id: <91e02ca3-e985-47fa-aed8-0b50a5d7a3c9@app.fastmail.com>
In-Reply-To: <178791679053.3510150.70411349578293852@noble.neil.brown.name>
References: <20251210002850.318350-1-cel@kernel.org>
 <20251210002850.318350-3-cel@kernel.org> <apE90ZRZB8IW_AiS@jo-so.de>
 <178791679053.3510150.70411349578293852@noble.neil.brown.name>
Subject: Re: [PATCH 2/2] NFS: NFSERR_INVAL is not defined by NFSv2
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable



On Fri, Aug 28, 2026, at 7:33 AM, NeilBrown wrote:
> On Fri, 28 Aug 2026, J=C3=B6rg Sommer wrote:
>> Chuck Lever schrieb am Di 09. Dez, 19:28 (-0500):
>> > From: Chuck Lever <chuck.lever@oracle.com>
>> >=20
>> > A documenting comment in include/uapi/linux/nfs.h claims incorrectly
>> > that NFSv2 defines NFSERR_INVAL. There is no such definition in eit=
her
>> > RFC 1094 or https://pubs.opengroup.org/onlinepubs/9629799/chap7.htm
>> >=20
>> > NFS3ERR_INVAL is introduced in RFC 1813.
>>=20
>> Hello,
>>=20
>> since this commit 0ac903d1bfdce8ff40657c2b7d996947b72b6645 was added,=
 U-Boot
>> 2022.04 (I don't know about newer versions) can no longer access syml=
inks in
>> NFS shares. When I revert this commit, U-Boot can load the file behin=
d the
>> symlink. Real files are no problem.
>>=20
>> The file I want to load is a symlink at the server:
>>=20
>> ```
>> % ls -l /srv/nfs/boot/Image.gz*
>> lrwxrwxrwx 1 root root      41  7. Jul 16:29 /srv/nfs-con/boot/Image.=
gz -> Image.gz-5.15.213-imx8mm+gfffa4b6d4aea+p1
>> -rw-r--r-- 1 root root 5279373  7. Jul 16:29 /srv/nfs-con/boot/Image.=
gz-5.15.213-imx8mm+gfffa4b6d4aea+p1
>> ```
>>=20
>> Without this commit:
>>=20
>> ```
>> u-boot=3D> nfs 0x42000000 /srv/nfs/boot/Image.gz
>> Filename '/srv/nfs-con/boot/Image.gz'.
>> Load address: 0x42000000
>> Loading: ############################################################=
#####
>> done
>> Bytes transferred =3D 5279373 (508e8d hex)
>> ```
>>=20
>> But with this commit:
>>=20
>> ```
>> u-boot=3D> nfs 0x42000000 /srv/nfs/boot/Image.gz
>> Filename '/srv/nfs-con/boot/Image.gz'.
>> Load address: 0x42000000
>> Loading:
>> done
>> ```
>>=20
>> This is the network traffic:
>>=20
>> ```
>> No.	Time	Protocol	Length	Info
>> 3	0.000370	Portmap	98	V2 GETPORT Call (Reply In 4) MOUNT(100005) V:1 =
UDP
>> 4	0.000607	Portmap	70	V2 GETPORT Reply (Call In 3) Port:60340
>> 5	0.000949	Portmap	98	V2 GETPORT Call (Reply In 6) NFS(100003) V:2 UDP
>> 6	0.001046	Portmap	70	V2 GETPORT Reply (Call In 5) Port:2049
>> 7	0.001368	MOUNT	126	V2 MNT Call (Reply In 8) /srv/nfs-con/boot
>> 8	0.008026	MOUNT	102	V2 MNT Reply (Call In 7)
>> 9	0.008389	NFS	146	V2 LOOKUP Call (Reply In 10), DH: 0x8c279135/Image=
.gz
>> 10	0.008754	NFS	170	V2 LOOKUP Reply (Call In 9), FH: 0xcdddf154
>> 11	0.009095	NFS	146	V2 READ Call (Reply In 12), FH: 0xcdddf154 Offset=
: 0 Count: 1024 TotalCount: 0
>> 12	0.009189	NFS	70	V2 READ Reply (Call In 11) Error: NFS2ERR_IO
>> 13	0.009511	MOUNT	102	V2 UMNTALL Call (Reply In 14)
>> 14	0.010301	MOUNT	66	V2 UMNTALL Reply (Call In 13)
>> ```
>>=20
>> From packet 11 V2 READ Call
>>=20
>> ```
>> Remote Procedure Call, Type:Call XID:0x000050e1
>>     XID: 0x000050e1 (20705)
>>     Message Type: Call (0)
>>     RPC Version: 2
>>     Program: NFS (100003)
>>     Program Version: 2
>>     Procedure: READ (6)
>>     [The reply to this request is in frame 12]
>>     Credentials
>>         Flavor: AUTH_UNIX (1)
>>         Length: 20
>>         Stamp: 0x00000000
>>         Machine Name: <EMPTY>
>>         UID: 0
>>         GID: 0
>>         Auxiliary GIDs (0)
>>     Verifier
>>         Flavor: AUTH_NULL (0)
>>         Length: 0
>> Network File System, READ Call FH: 0xcdddf154 Offset: 0 Count: 1024 T=
otalCount: 0
>>     [Program Version: 2]
>>     [V2 Procedure: READ (6)]
>>     file
>>         [hash (CRC-32): 0xcdddf154]
>>         FileHandle: 010004010100540020bb3809040054002f2edde4000000000=
000000000000000
>>     Offset: 0
>>     Count: 1024
>>     Total Count: 0
>> ```
>>=20
>> From packet 12 V2 READ Reply
>>=20
>> ```
>> Remote Procedure Call, Type:Reply XID:0x000050e1
>>     XID: 0x000050e1 (20705)
>>     Message Type: Reply (1)
>>     [Program: NFS (100003)]
>>     [Program Version: 2]
>>     [Procedure: READ (6)]
>>     Reply State: accepted (0)
>>     [This is a reply to a request in frame 11]
>>     [Time from request: 94.000 microseconds]
>>     Verifier
>>         Flavor: AUTH_NULL (0)
>>         Length: 0
>>     Accept State: RPC executed successfully (0)
>> Network File System, READ Reply  Error: NFS2ERR_IO
>>     [Program Version: 2]
>>     [V2 Procedure: READ (6)]
>>     Status: NFS2ERR_IO (5)
>> ```
>>=20
>>=20
>> I can locally revert this commit in our kernel, but is there any othe=
r way
>> to get it working again?
>
> This is unfortunate.
> U-boot has
>
> 		} else if ((rlen =3D=3D -NFSERR_ISDIR) || (rlen =3D=3D -NFSERR_INVAL=
)) {
> 			/* symbolic link */
> 			nfs_state =3D STATE_READLINK_REQ;
> 			nfs_send();
>
> so we either need nfsdv2 to return NFSERR_ISDIR (for something that
> isn't a directory) or NFSERR_INVAL (which is not a valid v2 error code=
),
> or change u-boot to also check for NFSERR_IO (which is 5).

U-Boot's NFSERR_ISDIR check (quoted above) is the Sun-compatible
path. The NFSERR_INVAL arm was presumably added for Linux NFSD?

So the pre-0ac903d1bfdc code is not something I want to go back to.
Returning NFSERR_INVAL is incompatible with the reference NFSv2
implementation, and so is NFSERR_IO.

Mapping nfserr_symlink to NFSERR_ISDIR affects the READ, WRITE, and
SETATTR procedures. The Solaris NFS server returns NFSERR_ISDIR for
READ and WRITE of a non-REG object, which suggests to me that is
the behavior clients will expect.

IMO we should leave nfserr_wrong_type alone until we have a specific
real-world complaint to address.


--=20
Chuck Lever

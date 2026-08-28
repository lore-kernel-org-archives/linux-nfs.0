Received: from s1.jo-so.de (s1.jo-so.de [37.221.195.157])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E0FCF21ABD7
	for <linux-nfs@vger.kernel.org>; Fri, 28 Aug 2026 09:07:37 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=37.221.195.157
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787908061; cv=none; b=TTSOGAR4w7z0II+KBQEOaq5Fhi27rTfV0EYj4goolDdjVo0knyJwI5J+vHEskS2Dme/RFjaCDe4ddjZX2s1++4qfmG/2V/WTFFM8DtU2b8uPLQj0lTBbgLpmCOlynhoGAXtgf6W8EHaIfG/jURb70OJhM0KXRa02Ct9pBITe0sE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787908061; c=relaxed/simple;
	bh=2g3m+7m0K0rQKrM+MN1DRMflJlRbPqoMnO/B7mQM4mI=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=RexGg/btutg6Wks09QaMCpIoQ6EZFVfmJjb77khm1xSyxAHBY3XGSMZ0aInIqqT+t8spnVNEKSyLByxEhC9kANSG6KM38DaLFpG0F0VZVgHg6gUOd1df73BNeseleTs+HxMEOyzbPA11F11BwV+JGuqxMyArtbQ7Lf2boTOn24o=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=jo-so.de; spf=pass smtp.mailfrom=jo-so.de; arc=none smtp.client-ip=37.221.195.157
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=jo-so.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=jo-so.de
Received: from mail-relay (helo=jo-so.de)
	by s1.jo-so.de with local-bsmtp (Exim 4.98.2)
	(envelope-from <joerg@jo-so.de>)
	id 1wzsGa-00000007yk9-0mfb;
	Fri, 28 Aug 2026 10:48:52 +0200
Received: from joerg by tux.jo-so.de with local (Exim 4.100-RC3)
	(envelope-from <joerg@jo-so.de>)
	id 1wzsGZ-00000002PRO-2b6s;
	Fri, 28 Aug 2026 10:48:51 +0200
Date: Fri, 28 Aug 2026 10:48:51 +0200
From: =?utf-8?B?SsO2cmc=?= Sommer <joerg@jo-so.de>
To: Chuck Lever <cel@kernel.org>
Cc: NeilBrown <neil@brown.name>, Jeff Layton <jlayton@kernel.org>, 
	Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <dai.ngo@oracle.com>, Tom Talpey <tom@talpey.com>, 
	linux-nfs@vger.kernel.org, Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 2/2] NFS: NFSERR_INVAL is not defined by NFSv2
Message-ID: <apE90ZRZB8IW_AiS@jo-so.de>
OpenPGP: id=7D2C9A23D1AEA375; url=https://jo-so.de/pgp-key.txt;
 preference=signencrypt
References: <20251210002850.318350-1-cel@kernel.org>
 <20251210002850.318350-3-cel@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="altxtfjgh3nkdwkx"
Content-Disposition: inline
In-Reply-To: <20251210002850.318350-3-cel@kernel.org>


--altxtfjgh3nkdwkx
Content-Type: text/plain; protected-headers=v1; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable
Subject: Re: [PATCH 2/2] NFS: NFSERR_INVAL is not defined by NFSv2
MIME-Version: 1.0

Chuck Lever schrieb am Di 09. Dez, 19:28 (-0500):
> From: Chuck Lever <chuck.lever@oracle.com>
>=20
> A documenting comment in include/uapi/linux/nfs.h claims incorrectly
> that NFSv2 defines NFSERR_INVAL. There is no such definition in either
> RFC 1094 or https://pubs.opengroup.org/onlinepubs/9629799/chap7.htm
>=20
> NFS3ERR_INVAL is introduced in RFC 1813.

Hello,

since this commit 0ac903d1bfdce8ff40657c2b7d996947b72b6645 was added, U-Boot
2022.04 (I don't know about newer versions) can no longer access symlinks in
NFS shares. When I revert this commit, U-Boot can load the file behind the
symlink. Real files are no problem.

The file I want to load is a symlink at the server:

```
% ls -l /srv/nfs/boot/Image.gz*
lrwxrwxrwx 1 root root      41  7. Jul 16:29 /srv/nfs-con/boot/Image.gz -> =
Image.gz-5.15.213-imx8mm+gfffa4b6d4aea+p1
-rw-r--r-- 1 root root 5279373  7. Jul 16:29 /srv/nfs-con/boot/Image.gz-5.1=
5.213-imx8mm+gfffa4b6d4aea+p1
```

Without this commit:

```
u-boot=3D> nfs 0x42000000 /srv/nfs/boot/Image.gz
Filename '/srv/nfs-con/boot/Image.gz'.
Load address: 0x42000000
Loading: #################################################################
done
Bytes transferred =3D 5279373 (508e8d hex)
```

But with this commit:

```
u-boot=3D> nfs 0x42000000 /srv/nfs/boot/Image.gz
Filename '/srv/nfs-con/boot/Image.gz'.
Load address: 0x42000000
Loading:
done
```

This is the network traffic:

```
No.	Time	Protocol	Length	Info
3	0.000370	Portmap	98	V2 GETPORT Call (Reply In 4) MOUNT(100005) V:1 UDP
4	0.000607	Portmap	70	V2 GETPORT Reply (Call In 3) Port:60340
5	0.000949	Portmap	98	V2 GETPORT Call (Reply In 6) NFS(100003) V:2 UDP
6	0.001046	Portmap	70	V2 GETPORT Reply (Call In 5) Port:2049
7	0.001368	MOUNT	126	V2 MNT Call (Reply In 8) /srv/nfs-con/boot
8	0.008026	MOUNT	102	V2 MNT Reply (Call In 7)
9	0.008389	NFS	146	V2 LOOKUP Call (Reply In 10), DH: 0x8c279135/Image.gz
10	0.008754	NFS	170	V2 LOOKUP Reply (Call In 9), FH: 0xcdddf154
11	0.009095	NFS	146	V2 READ Call (Reply In 12), FH: 0xcdddf154 Offset: 0 Co=
unt: 1024 TotalCount: 0
12	0.009189	NFS	70	V2 READ Reply (Call In 11) Error: NFS2ERR_IO
13	0.009511	MOUNT	102	V2 UMNTALL Call (Reply In 14)
14	0.010301	MOUNT	66	V2 UMNTALL Reply (Call In 13)
```

=46rom packet 11 V2 READ Call

```
Remote Procedure Call, Type:Call XID:0x000050e1
    XID: 0x000050e1 (20705)
    Message Type: Call (0)
    RPC Version: 2
    Program: NFS (100003)
    Program Version: 2
    Procedure: READ (6)
    [The reply to this request is in frame 12]
    Credentials
        Flavor: AUTH_UNIX (1)
        Length: 20
        Stamp: 0x00000000
        Machine Name: <EMPTY>
        UID: 0
        GID: 0
        Auxiliary GIDs (0)
    Verifier
        Flavor: AUTH_NULL (0)
        Length: 0
Network File System, READ Call FH: 0xcdddf154 Offset: 0 Count: 1024 TotalCo=
unt: 0
    [Program Version: 2]
    [V2 Procedure: READ (6)]
    file
        [hash (CRC-32): 0xcdddf154]
        FileHandle: 010004010100540020bb3809040054002f2edde4000000000000000=
000000000
    Offset: 0
    Count: 1024
    Total Count: 0
```

=46rom packet 12 V2 READ Reply

```
Remote Procedure Call, Type:Reply XID:0x000050e1
    XID: 0x000050e1 (20705)
    Message Type: Reply (1)
    [Program: NFS (100003)]
    [Program Version: 2]
    [Procedure: READ (6)]
    Reply State: accepted (0)
    [This is a reply to a request in frame 11]
    [Time from request: 94.000 microseconds]
    Verifier
        Flavor: AUTH_NULL (0)
        Length: 0
    Accept State: RPC executed successfully (0)
Network File System, READ Reply  Error: NFS2ERR_IO
    [Program Version: 2]
    [V2 Procedure: READ (6)]
    Status: NFS2ERR_IO (5)
```


I can locally revert this commit in our kernel, but is there any other way
to get it working again?


Thanks in advance.

Best regards J=F6rg

--=20
Optimisten haben gar keine Ahnung von den freudigen =DCberraschungen, die
Pessimisten erleben.
                                                (Peter Bramm)

--altxtfjgh3nkdwkx
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iHUEABEIAB0WIQS1pYxd0T/67YejVyF9LJoj0a6jdQUCapFLaAAKCRB9LJoj0a6j
dVgxAP41cf/OWFUWrICZYwHsRmiKEE9gvSEm6Q8ce58sbqWO3QD7BM+UCUAYT39w
/byeObAW38YjLyIQ/rNoDXMOeDF/eP0=
=56Kv
-----END PGP SIGNATURE-----

--altxtfjgh3nkdwkx--

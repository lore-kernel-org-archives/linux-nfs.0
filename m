Received: from s1.jo-so.de (s1.jo-so.de [37.221.195.157])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id DF02A40F749
	for <linux-nfs@vger.kernel.org>; Fri, 28 Aug 2026 11:59:51 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=37.221.195.157
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787918414; cv=none; b=V1u6sWW+tDJWrWCy02kxN9/OPEgPLN/UJ5hRek5iz40m0uhnf1I6wQ6CmYIPtMzl0yiz0BB/p+nb9JgCt7m79TJCHAM337o0cZF9q3acI9T8DGV3rren3pKBW9SQXiS4MxFT6WIwkYvAmzf/q9pic19kQXvSz6wr9UWvVIIzGj4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787918414; c=relaxed/simple;
	bh=/e9XKwwiusOrZZn9pPc6VeXWYZEO2IA7OZaOMhfGG4E=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=EkZiDDCF2a2a3ROYsbbcXo53Qq/Ve9JxnOiQguqY1wfOwsVb/Z0B18lN/HzaRX5VanE23UKd695O4zXSHItDZMr59bfU0zZ6cswPy9aNP5e8mXLyV8hunOu5seXi+BNfxU2DS1QPwmhLQYEbbdSxfJkcVWS/elW+1s4HBBHdI3c=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=jo-so.de; spf=pass smtp.mailfrom=jo-so.de; arc=none smtp.client-ip=37.221.195.157
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=jo-so.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=jo-so.de
Received: from mail-relay (helo=jo-so.de)
	by s1.jo-so.de with local-bsmtp (Exim 4.98.2)
	(envelope-from <joerg@jo-so.de>)
	id 1wzvFH-000000081Dk-2Gt8;
	Fri, 28 Aug 2026 13:59:43 +0200
Received: from joerg by tux.jo-so.de with local (Exim 4.100-RC3)
	(envelope-from <joerg@jo-so.de>)
	id 1wzvFG-00000002Xn3-3jXi;
	Fri, 28 Aug 2026 13:59:42 +0200
Date: Fri, 28 Aug 2026 13:59:42 +0200
From: =?utf-8?B?SsO2cmc=?= Sommer <joerg@jo-so.de>
To: NeilBrown <neil@brown.name>
Cc: Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, 
	Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <dai.ngo@oracle.com>, Tom Talpey <tom@talpey.com>, 
	linux-nfs@vger.kernel.org, Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 2/2] NFS: NFSERR_INVAL is not defined by NFSv2
Message-ID: <apF3Kv66IaDONfqo@jo-so.de>
OpenPGP: id=7D2C9A23D1AEA375; url=https://jo-so.de/pgp-key.txt;
 preference=signencrypt
References: <20251210002850.318350-1-cel@kernel.org>
 <20251210002850.318350-3-cel@kernel.org>
 <apE90ZRZB8IW_AiS@jo-so.de>
 <178791679053.3510150.70411349578293852@noble.neil.brown.name>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="owpsdqwe4h2dwp6f"
Content-Disposition: inline
In-Reply-To: <178791679053.3510150.70411349578293852@noble.neil.brown.name>


--owpsdqwe4h2dwp6f
Content-Type: text/plain; protected-headers=v1; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable
Subject: Re: [PATCH 2/2] NFS: NFSERR_INVAL is not defined by NFSv2
MIME-Version: 1.0

NeilBrown schrieb am Fr 28. Aug, 21:33 (+1000):
> On Fri, 28 Aug 2026, J=F6rg Sommer wrote:
> > Chuck Lever schrieb am Di 09. Dez, 19:28 (-0500):
> > > From: Chuck Lever <chuck.lever@oracle.com>
> > >=20
> > > A documenting comment in include/uapi/linux/nfs.h claims incorrectly
> > > that NFSv2 defines NFSERR_INVAL. There is no such definition in either
> > > RFC 1094 or https://pubs.opengroup.org/onlinepubs/9629799/chap7.htm
> > >=20
> > > NFS3ERR_INVAL is introduced in RFC 1813.
> >=20
> > Hello,
> >=20
> > since this commit 0ac903d1bfdce8ff40657c2b7d996947b72b6645 was added, U=
-Boot
> > 2022.04 (I don't know about newer versions) can no longer access symlin=
ks in
> > NFS shares. When I revert this commit, U-Boot can load the file behind =
the
> > symlink. Real files are no problem.
> >=20
> > The file I want to load is a symlink at the server:
> >=20
> > ```
> > % ls -l /srv/nfs/boot/Image.gz*
> > lrwxrwxrwx 1 root root      41  7. Jul 16:29 /srv/nfs-con/boot/Image.gz=
 -> Image.gz-5.15.213-imx8mm+gfffa4b6d4aea+p1
> > -rw-r--r-- 1 root root 5279373  7. Jul 16:29 /srv/nfs-con/boot/Image.gz=
-5.15.213-imx8mm+gfffa4b6d4aea+p1
> > ```
> >=20
> > Without this commit:
> >=20
> > ```
> > u-boot=3D> nfs 0x42000000 /srv/nfs/boot/Image.gz
> > Filename '/srv/nfs-con/boot/Image.gz'.
> > Load address: 0x42000000
> > Loading: ##############################################################=
###
> > done
> > Bytes transferred =3D 5279373 (508e8d hex)
> > ```
> >=20
> > But with this commit:
> >=20
> > ```
> > u-boot=3D> nfs 0x42000000 /srv/nfs/boot/Image.gz
> > Filename '/srv/nfs-con/boot/Image.gz'.
> > Load address: 0x42000000
> > Loading:
> > done
> > ```
> >=20
> > This is the network traffic:
> >=20
> > ```
> > No.	Time	Protocol	Length	Info
> > 3	0.000370	Portmap	98	V2 GETPORT Call (Reply In 4) MOUNT(100005) V:1 UDP
> > 4	0.000607	Portmap	70	V2 GETPORT Reply (Call In 3) Port:60340
> > 5	0.000949	Portmap	98	V2 GETPORT Call (Reply In 6) NFS(100003) V:2 UDP
> > 6	0.001046	Portmap	70	V2 GETPORT Reply (Call In 5) Port:2049
> > 7	0.001368	MOUNT	126	V2 MNT Call (Reply In 8) /srv/nfs-con/boot
> > 8	0.008026	MOUNT	102	V2 MNT Reply (Call In 7)
> > 9	0.008389	NFS	146	V2 LOOKUP Call (Reply In 10), DH: 0x8c279135/Image.gz
> > 10	0.008754	NFS	170	V2 LOOKUP Reply (Call In 9), FH: 0xcdddf154
> > 11	0.009095	NFS	146	V2 READ Call (Reply In 12), FH: 0xcdddf154 Offset: =
0 Count: 1024 TotalCount: 0
> > 12	0.009189	NFS	70	V2 READ Reply (Call In 11) Error: NFS2ERR_IO
> > 13	0.009511	MOUNT	102	V2 UMNTALL Call (Reply In 14)
> > 14	0.010301	MOUNT	66	V2 UMNTALL Reply (Call In 13)
> > ```
> >=20
> > From packet 11 V2 READ Call
> >=20
> > ```
> > Remote Procedure Call, Type:Call XID:0x000050e1
> >     XID: 0x000050e1 (20705)
> >     Message Type: Call (0)
> >     RPC Version: 2
> >     Program: NFS (100003)
> >     Program Version: 2
> >     Procedure: READ (6)
> >     [The reply to this request is in frame 12]
> >     Credentials
> >         Flavor: AUTH_UNIX (1)
> >         Length: 20
> >         Stamp: 0x00000000
> >         Machine Name: <EMPTY>
> >         UID: 0
> >         GID: 0
> >         Auxiliary GIDs (0)
> >     Verifier
> >         Flavor: AUTH_NULL (0)
> >         Length: 0
> > Network File System, READ Call FH: 0xcdddf154 Offset: 0 Count: 1024 Tot=
alCount: 0
> >     [Program Version: 2]
> >     [V2 Procedure: READ (6)]
> >     file
> >         [hash (CRC-32): 0xcdddf154]
> >         FileHandle: 010004010100540020bb3809040054002f2edde400000000000=
0000000000000
> >     Offset: 0
> >     Count: 1024
> >     Total Count: 0
> > ```
> >=20
> > From packet 12 V2 READ Reply
> >=20
> > ```
> > Remote Procedure Call, Type:Reply XID:0x000050e1
> >     XID: 0x000050e1 (20705)
> >     Message Type: Reply (1)
> >     [Program: NFS (100003)]
> >     [Program Version: 2]
> >     [Procedure: READ (6)]
> >     Reply State: accepted (0)
> >     [This is a reply to a request in frame 11]
> >     [Time from request: 94.000 microseconds]
> >     Verifier
> >         Flavor: AUTH_NULL (0)
> >         Length: 0
> >     Accept State: RPC executed successfully (0)
> > Network File System, READ Reply  Error: NFS2ERR_IO
> >     [Program Version: 2]
> >     [V2 Procedure: READ (6)]
> >     Status: NFS2ERR_IO (5)
> > ```
> >=20
> >=20
> > I can locally revert this commit in our kernel, but is there any other =
way
> > to get it working again?
>=20
> This is unfortunate.
> U-boot has
>=20
> 		} else if ((rlen =3D=3D -NFSERR_ISDIR) || (rlen =3D=3D -NFSERR_INVAL)) {
> 			/* symbolic link */
> 			nfs_state =3D STATE_READLINK_REQ;
> 			nfs_send();
>=20
> so we either need nfsdv2 to return NFSERR_ISDIR (for something that
> isn't a directory) or NFSERR_INVAL (which is not a valid v2 error code),
> or change u-boot to also check for NFSERR_IO (which is 5).
>=20
> There is no "good" option.
> I suspect we should revert this change and document that we violate the
> RFC for historical compatibility with u-boot.

Maybe not revert the whole change, but add an exception for symlinks.

+++ fs/nfsd/nfsproc.c
@@ -33,7 +33,7 @@ static __be32 nfsd_map_status(__be32 status)
           break;
   case nfserr_symlink:
+          /* this is invalid, but U-Boot ... */
+          status =3D nfserr_inval;
+          break;

   case nfserr_wrong_type:
-          status =3D nfserr_inval;
+          status =3D nfserr_io;


--=20
Es liegt in der Natur des Menschen, vern=FCnftig zu denken und
unlogisch zu handeln! Das Gesagte ist nicht das Gemeinte und das Geh=F6rte
nicht das Verstandene!

--owpsdqwe4h2dwp6f
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iHUEABEIAB0WIQS1pYxd0T/67YejVyF9LJoj0a6jdQUCapF4KgAKCRB9LJoj0a6j
dYhpAP9tD8lXsLUaGrE8y5duh2D5Hn9qKVLkdFIqxDKyUn8JjQD/cCZSYIeKMy+n
Ix78iZ1GbmumdMKbZ5y6QVewQsKNdAA=
=shks
-----END PGP SIGNATURE-----

--owpsdqwe4h2dwp6f--

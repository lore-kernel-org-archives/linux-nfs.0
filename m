Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mout.gmx.net ([212.227.17.21]:64973 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755396Ab3DZQ4X (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 26 Apr 2013 12:56:23 -0400
Received: from mailout-de.gmx.net ([10.1.76.2]) by mrigmx.server.lan
 (mrigmx001) with ESMTP (Nemesis) id 0MEYS7-1UGbVs2BXV-00Fk3K for
 <linux-nfs@vger.kernel.org>; Fri, 26 Apr 2013 18:56:21 +0200
Message-ID: <517AB1B3.7000301@gmx.de>
Date: Fri, 26 Apr 2013 18:56:19 +0200
From: =?UTF-8?B?TWFsdGUgU2NocsO2ZGVy?= <maltesch@gmx.de>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: NFS4 sec=krb5 broken in 3.9-rc8
References: <5176E715.2070201@gmx.de> <20130423215807.GL3676@fieldses.org> <51777494.8010306@gmx.de> <20130424140152.GA9794@fieldses.org> <5178116F.1010608@gmx.de> <20130424192353.GI20275@fieldses.org> <517A46E7.1020404@gmx.de> <20130426152334.GC17268@fieldses.org>
In-Reply-To: <20130426152334.GC17268@fieldses.org>
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="----enig2VSMFHEMRHISLODWQLRPS"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
------enig2VSMFHEMRHISLODWQLRPS
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 26.04.2013 17:23, J. Bruce Fields wrote:
> On Fri, Apr 26, 2013 at 11:20:39AM +0200, Malte Schr=C3=B6der wrote:
>> On 24.04.2013 21:23, J. Bruce Fields wrote:
>>> On Wed, Apr 24, 2013 at 07:07:59PM +0200, Malte Schr=C3=B6der wrote:
>>> Probably some of those "svc_process dropit"s are coming from attempts=
 to
>>> look up the newly created cred (so lookups in the rsc_cache) which fa=
il
>>> for some reason.  I'm not sure what that would be.
>>>
>>> --b.
>>
>> Hi,
>> I tried bisecting the problem. It identified
>> 683428fae8c73d7d7da0fa2e0b6beb4d8df4e808 as the problem, reverting it
>> didn't fix the problem, though. During the process there where some
>> states where mounting wouldn't hang but be denied. I will try bisectin=
g
>> again, later.
>=20
> Oh, so probably 3c34ae11fac3b30629581d0bfaf80f58e82cfbfb "nfsd: fix krb=
5
> handling of anonymous principals" needs backporting to stable--could yo=
u
> confirm whether applying that helps?
>=20
> Thanks for the bisection.
>=20
> --b.
>=20

Well, I have the problem on 3.9-rc8, 3.8.5 works totally fine for me.
Just for fun I reverted the path you mentioned, and now the behaviour
has changed: It doesn't hang anymore, now I get access denied from the
server.

/Malte


------enig2VSMFHEMRHISLODWQLRPS
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iEYEARECAAYFAlF6sbMACgkQ4q3E2oMjYtVjYwCgxqKzkwKUwDrh24JhvvnJ6qG5
lJwAoOF82itCn7pdugW3gMMHsyFug2Xr
=5B+v
-----END PGP SIGNATURE-----

------enig2VSMFHEMRHISLODWQLRPS--

Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailgate-01.zdv.uni-mainz.de ([134.93.178.241]:7076 "EHLO
	mailgate-01.zdv.uni-mainz.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751364AbbHTJkl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 20 Aug 2015 05:40:41 -0400
Message-ID: <55D59E4B.9010404@uni-mainz.de>
Date: Thu, 20 Aug 2015 11:30:51 +0200
From: Christoph Martin <martin@uni-mainz.de>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Andy Adamson <andros@netapp.com>, Markus Tacke <tacke@uni-mainz.de>,
        <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] make nfsd_drc_max_mem configurable
References: <55816C84.1080608@uni-mainz.de> <20150618161657.GC10305@fieldses.org> <559A7BBF.2080201@uni-mainz.de>
In-Reply-To: <559A7BBF.2080201@uni-mainz.de>
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature";
	boundary="7RkMxiiEk7NXn2g5IEVUkridANvEW2T9Q"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--7RkMxiiEk7NXn2g5IEVUkridANvEW2T9Q
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

Hi Bruce

>=20
> I found the following calls to kmem_cache_create:
>=20
>>
>> nfs4state.c:2635:	openowner_slab =3D kmem_cache_create("nfsd4_openowne=
rs",
>> nfs4state.c:2639:	lockowner_slab =3D kmem_cache_create("nfsd4_lockowne=
rs",
>> nfs4state.c:2643:	file_slab =3D kmem_cache_create("nfsd4_files",
>> nfs4state.c:2647:	stateid_slab =3D kmem_cache_create("nfsd4_stateids",=

>> nfs4state.c:2651:	deleg_slab =3D kmem_cache_create("nfsd4_delegations"=
,
>> nfscache.c:168:	drc_slab =3D kmem_cache_create("nfsd_drc", sizeof(stru=
ct svc_cacherep),
>=20
> At a first look, they all use different methods to administer this
> memory if at all.
>=20

Another solution would be to simply remove the upper limit for the drc
cache size.

What do you think? How do we solve this problem?

Christoph


--7RkMxiiEk7NXn2g5IEVUkridANvEW2T9Q
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBCAAGBQJV1Z5LAAoJEPqBswqWsQmco0YP/A9mBx07zWM59UtAkXmdVZp0
NuFN3Vlq9HKv/opNtTJiyKUEQthqChwYcSZWZrQ2hnQeTdrgKJE39liX80nK6EOX
z0Fp6SDylKjPBxLkLADoF5Y2U/dcqo0GLGhy+jJd8XTsiDZkihsW8Z7umw076IiX
X+eEO4qCQiSxv0IxkV55K66CqbsqA57fgs7DtH/MdGKkGyi1GgTnLnSo5mRsLD6q
dxWZMqF3FNOejZiLJuCxB/nhmWTIymPF1et4mTySCB29iR8c+Re0C9/SbUCJw+Zq
tfoZkN09beUrIMME1uCakXPqCGBqmY3SLaszhfP8r+Da9LrYJvXbmIxjAteVy7h7
Nwpw8mGlQrzilnsssmyA9kGmBMWlv8WyygPGwtclvPUo6eBCAIB7GddNS5lBYzVe
wFD8h1W9qenBRt60XeebI3/cMBgQIZJIo6F/Zy7ukqwq9OnpP2AyZFfmVjEUYTVj
uKwGccZJJS6Q7JmZtK7VCq1K0OdmCozKX/XMDmLT6w/6255bSLkrLjIHikbsmHKK
GqE4Sx9bL2ZVCcnD+djK9SQRSeyNYRxEvcK8Hmiu0uRvdyee7crFyr1Ss5HPyBSb
22TBSs3kEKDXdFcT4Ycy0rhDJQKa3Tmz7oTi6Vw9xL37APocFKAMbKc9DfcMlA1Y
SoFwEoIjHasuboztr4N8
=uoAt
-----END PGP SIGNATURE-----

--7RkMxiiEk7NXn2g5IEVUkridANvEW2T9Q--

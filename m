Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50328 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751013AbbGaMwx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 31 Jul 2015 08:52:53 -0400
Subject: Re: [PATCH for-4.3 14/15] qib: Support ib_alloc_mr verb
To: "Marciniszyn, Mike" <mike.marciniszyn@intel.com>
References: <1438241568-3685-1-git-send-email-sagig@mellanox.com>
 <1438241568-3685-15-git-send-email-sagig@mellanox.com>
 <32E1700B9017364D9B60AED9960492BC257782EE@fmsmsx120.amr.corp.intel.com>
Cc: Sagi Grimberg <sagig@mellanox.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "target-devel@vger.kernel.org" <target-devel@vger.kernel.org>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>
From: Doug Ledford <dledford@redhat.com>
Message-ID: <55BB6FA2.3070205@redhat.com>
Date: Fri, 31 Jul 2015 08:52:50 -0400
MIME-Version: 1.0
In-Reply-To: <32E1700B9017364D9B60AED9960492BC257782EE@fmsmsx120.amr.corp.intel.com>
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="0gmfdd7capbxLGl6TSvrVdvPMIDv1oLko"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--0gmfdd7capbxLGl6TSvrVdvPMIDv1oLko
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

On 07/31/2015 07:41 AM, Marciniszyn, Mike wrote:
>> Subject: [PATCH for-4.3 14/15] qib: Support ib_alloc_mr verb
>>
>=20
> Doug,
>=20
> Have you staged this anywhere?
>=20
> Mike
>=20

Yes.  In my github repo this is present on the mr-cleanup and
to-be-rebased/for-4.3 branches.

--=20
Doug Ledford <dledford@redhat.com>
              GPG KeyID: 0E572FDD



--0gmfdd7capbxLGl6TSvrVdvPMIDv1oLko
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iQIcBAEBCAAGBQJVu2+iAAoJELgmozMOVy/dO4cP/ijs6+8x2oJi+e1FkFc1x9Mo
86VektPjuNUNryUgRR8VY9HB6wsI28Jaw1g5WlFShOBPV+QbjEIuN5PGzAhE/vFs
vwLkujiOx3hUmoWg3YkolIkEZZijxXaVsL7WhAmk9CXh8IQzRbQ8msJbFsDxzrXZ
q9b77yXqNZvJgM7j2XoQYJCaw7UfsPQcAIdy/mPEN8gRnbxByTMiZhZHwHQxa7h5
I8Zii8kVUBA6FQBtR947Tqkp+n5A6BGIjvbDiWDZftgv8N2Pdze2tZ2ye3phuqls
438R6ZONey4PBGAawd0QLRFdF4bVsrnoXHqrb5QxCgBgeFhmQ/Oo4ykjArAM/Jpu
KyD795xgJ5BGcIjaku/YkTWOwcvAy8rNijKHwl1tPd6Rwj2P0et1IySsMC53Olz1
Nqj1coNfXUeCDWrHR4Wkt3RFFXs33KQEPZnxZZgdHkRXGNwO6CM+9IKY3UfP3Fms
swQKSWVj5es1Qfrioj56QBuagnKhwk+pG3ER9TmjOnZOCVxKW9gLCbmd2L6+IjGn
heBwNpMSogXzFxgb31b+jxYOU+7LEKzAYgwkBIQWxW48ce4VxgfjfszkjUJxofcE
tOXMWO1gNW6TIeWqKCYQN2WZs/VKegW0AsnmSIIkrqhQU2HdUOJVs03SDn1MJznM
7jEWkVkU6nRWMcQ00PvH
=ebd2
-----END PGP SIGNATURE-----

--0gmfdd7capbxLGl6TSvrVdvPMIDv1oLko--

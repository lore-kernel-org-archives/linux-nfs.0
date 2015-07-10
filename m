Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36847 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751296AbbGJWdp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 10 Jul 2015 18:33:45 -0400
Message-ID: <55A04845.7040004@redhat.com>
Date: Fri, 10 Jul 2015 18:33:41 -0400
From: Doug Ledford <dledford@redhat.com>
MIME-Version: 1.0
To: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>,
        Tom Talpey <tom@talpey.com>
CC: "'Christoph Hellwig'" <hch@infradead.org>,
        Sagi Grimberg <sagig@dev.mellanox.co.il>,
        Steve Wise <swise@opengridcomputing.com>, sagig@mellanox.com,
        ogerlitz@mellanox.com, roid@mellanox.com, linux-rdma@vger.kernel.org,
        eli@mellanox.com, target-devel@vger.kernel.org,
        linux-nfs@vger.kernel.org, trond.myklebust@primarydata.com,
        bfields@fieldses.org, Oren Duer <oren@mellanox.com>
Subject: Re: [PATCH V3 1/5] RDMA/core: Transport-independent access flags
References: <559CD174.4040901@dev.mellanox.co.il> <20150708190842.GB11740@obsidianresearch.com> <20150708203205.GA21847@infradead.org> <20150709000337.GE16812@obsidianresearch.com> <559EF332.7060103@redhat.com> <20150709225306.GA30741@obsidianresearch.com> <559FC710.1050307@talpey.com> <20150710161108.GA19042@obsidianresearch.com> <55A00754.4010009@redhat.com> <55A01225.9000000@talpey.com> <20150710195420.GA31500@obsidianresearch.com>
In-Reply-To: <20150710195420.GA31500@obsidianresearch.com>
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="LIOIQ65hM7FnSPUA7Tpp5NsoTIVrHODMD"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--LIOIQ65hM7FnSPUA7Tpp5NsoTIVrHODMD
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

On 07/10/2015 03:54 PM, Jason Gunthorpe wrote:
> On Fri, Jul 10, 2015 at 02:42:45PM -0400, Tom Talpey wrote:
>=20
>>>> For the proposed iSER patch the problem is very acute, iser makes a
>>>> single PD and phys MR at boot time for each device. This means there=

>>>> is a single machine wide unchanging rkey that allows remote physical=

>>>> memory access. An attacker only has to repeatedly open QPs to iSER a=
nd
>>>> guess rkey values until they find it. Add in likely non-crypto
>>>> randomness for rkeys, and I bet it isn't even that hard to do.
>>
>> The rkeys have a PD, wich cannot be forged, so it's not a matter of
>> attacking, but it is most definitely a system integrity risk, as I
>> mentioned earlier, a simple arithmetic offset mistake can overwrite
>> anything.
>=20
> Can you explain this conclusion?

I think Tom's comment was referring to the fact that if you have a
trusted client, then a third party attacker can't attack your rkey
because they wouldn't have a QP in your PD and so the rkey would be
invalid for them.  Your arguments have been centered around a malicious
client, his presumed a trusted client and malicious third party.


--=20
Doug Ledford <dledford@redhat.com>
              GPG KeyID: 0E572FDD



--LIOIQ65hM7FnSPUA7Tpp5NsoTIVrHODMD
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iQIcBAEBCAAGBQJVoEhFAAoJELgmozMOVy/dXnkQAKkRDHbJ25BCPPxbuUlKNb6c
MnGv38ns8OhmkB+k6d0VItIJ6MWvOiyg9zG4cN8QvkogJMON+EXptcNKX1xWXaVZ
PnX0eLUZ8KL5hJ7XUBVORzRGkvRg3ZdC53IXKy3dqT+uE0VDdNvYNqsZ6DXS5bGJ
Wb3rGe8aRSYIBf2TXakUYc+tTekXHlcfDQbyqrzEhCgYd+zvK4Xj+YI8ITPaSkN1
geki3n78oZaW7ZfWANgv6G1L4ZReQVOXogJvi4qpCGjhroTkK2iPAfT7+N0k1nsh
9QnLMUvQ2ibrfI3329Yd/9NJz44W8DxydxX1XJEzoqIV2PKST2vOQDQkwkYwK9qv
P7k0T/khacM5kofQL+LtzbHoLEb32/G+P8IZqWPl4V3nHApV9TqoaMT2Y7/GIW8Z
oVyqqPUNizVyJdt65oTg5gI+2ZbhD5sBwmzT2Aeg65tLxaMC0S0KDKBM1JCJsKSC
WKRjpPdjPhoWqpADan8e4PmOSvz17JScHK72ziYHzkLgY+YlQQxFUbJQ7ZLQJfVd
9N2Yrtq18tRAVh1A4m+7zR3yTkR+RPRLVscjzkhs9gUUuwTtIWGjAOlgBZBYdWcy
bT8Cz0LBBMkmJyBupt2vC4PNRnHaNCiEdflmdN9Ef3TlyTSQQUztViN3E7BW6RL2
qplXPGa6kwvj6Ef16kVt
=1E32
-----END PGP SIGNATURE-----

--LIOIQ65hM7FnSPUA7Tpp5NsoTIVrHODMD--

Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:40086 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751605AbdHQDYK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 16 Aug 2017 23:24:10 -0400
From: NeilBrown <neilb@suse.com>
To: Bennett Amodio <bamodio@purestorage.com>, linux-nfs@vger.kernel.org
Date: Thu, 17 Aug 2017 13:23:58 +1000
Cc: anna.schumaker@netapp.com, trond.myklebust@primarydata.com,
        Igor Ostrovsky <igor@purestorage.com>,
        Vas Chellappa <vas@purestorage.com>,
        Jui-Yu Chang <juchang@purestorage.com>
Subject: Re: [RFC v3 2/2] SUNRPC: Mask XIDs to prevent replay cache collision
In-Reply-To: <CAKk7tABaTxA102tUHEuYyC8rtbNDjzHX6MdVcCkTy_26yfVkvA@mail.gmail.com>
References: <CAKk7tABaTxA102tUHEuYyC8rtbNDjzHX6MdVcCkTy_26yfVkvA@mail.gmail.com>
Message-ID: <87pobunagh.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On Tue, Aug 15 2017, Bennett Amodio wrote:

> + xprt->xid_mask =3D 0xffffffff >> args->bitmask_len;
> + xprt->masked_id =3D args->transport_id << (32 - args->bitmask_len);

hi,
 the above isn't safe when bitmask_len is zero.
 Shifting a u32 32 bits to the left is undefined in C.

        The result is undefined if the right operand is negative, or
        greater than or equal to the number of bits in the left
        expression=E2=80=99s type.

 if (args->bitmask_len)
	xprt->masked_id =3D args->transport_id << (32 - args->bitmask_len);
 else
        xprt->masked_id =3D 0;

Thanks,
NeilBrown

> + xprt->xid =3D args->init_xid;
> +

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlmVDFAACgkQOeye3VZi
gbmdbA/9HERuobdvk3eFcztzYgAsX+9YVz+EE6ncgXh2kqZBd26z3eMISz/y/uM/
pqTHyDCQQL/mzMp5OX3f8nfflR+OGGKWc92DxEqtUCCdL+eLzCwLq+ysmIA+arXf
/fEKDcipQyK6tccLWBy4g7Z2wjW31cVV7UUQywdeab+6hoDjtxDXWDt8ZEe8EGVV
0BW/PPZY+nHM2q6gzMgBahWjvDPkOoftVg61Nf2aujWZkpWZpofaN61PxSk2A4S7
KyOQR+h67Kzu+vDI+EvbDZosnORrJrAGxLgxcLZCNETV3j2k1AZ2JfHW8KwdchiW
1v0Z1wNO/gGlYNPcENm0Gij980PMNKpiI8N2KJ7DDcKcb74XR3Ktkw4idOcGezSf
AwB8Mr7RJ7kNgzO4t50uvI0L2P2El2rPET+aXNrkReo/8k1oJ0PPfh4pXLNF2FCg
TYR5HYN/Hh6rWbXmbQIkGKlYQ3pF3pglqGczCwMigSpCCFER2s5/GHhkM06Jvhf7
5HQF3TdaMHrxT+3i2VQmnXY9GaxyBFeioQDqg1dT/ADR6WmA+GfHXzS/O0Y/kO4H
8YNpJEg4nDUs7EgaA1thX7TYD/hvJbVfAt8aVcdhWANBeIRqq3gCyUwWZs7N0SQH
LNAZK5+yT6JASZsIYDsW1ZLooBpD2u77t74fgoriqGNVfaeBTBk=
=hH96
-----END PGP SIGNATURE-----
--=-=-=--

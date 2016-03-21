Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:59948 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757342AbcCUTaC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 21 Mar 2016 15:30:02 -0400
Subject: Re: Making an interface for alternative data streams
To: Christoph Hellwig <hch@infradead.org>
References: <56F03945.40208@gentoo.org> <20160321181825.GB10892@infradead.org>
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org
From: Richard Yao <ryao@gentoo.org>
Message-ID: <56F0429D.7070708@gentoo.org>
Date: Mon, 21 Mar 2016 14:51:09 -0400
MIME-Version: 1.0
In-Reply-To: <20160321181825.GB10892@infradead.org>
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="jHKWLlFdX9CxQ2mO6bFDi4MTOtUcvh8hQ"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--jHKWLlFdX9CxQ2mO6bFDi4MTOtUcvh8hQ
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

On 03/21/2016 02:18 PM, Christoph Hellwig wrote:
> On Mon, Mar 21, 2016 at 02:11:17PM -0400, Richard Yao wrote:
>> I am thinking of implementing Solaris-style alternative data streams i=
n
>> the ZFSOnLinux driver via an ioctl and writing a compatibility shim so=

>> that software written to use O_XATTR can be trivially adapted to use t=
he
>> interface.
>=20
> Even if alternate data streams weren't braindead to start with we are
> not going to support your vioation of our copyrights Richard.  Please g=
o
> away from our mailing lists.

I have not violated your copyrights. So far, both the SFC and SFLC are
in agreement on that.


--jHKWLlFdX9CxQ2mO6bFDi4MTOtUcvh8hQ
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJW8EKjAAoJECDuEZm+6ExkFXkP/jSgnbsY5lkEsrGcniEYB4pH
YOkxzo4Ni4JHFW5koTUwHzTLY045fuT5SXVtXXprFEz+1zm9Txns8IJj2p4hir9w
0FjWq04DjhBFSP9Ke4Wvhh0Tdo59wVRnx9ogPG4dGQ8Q/80V4BqHY04EwfvVjw2Z
0pRXO9mEEof6EDwNunN9n++EUbSGB/fLlavIjNtM7prI/x4dVG6lhgwsQJuITlEQ
EHVczWiQmdBfcitef9tX/bK7636qOjdQk7bbT+U4vbPewmz0ZbxxcDoCoivkq8Vr
K4Hv3y8dZCVLV7hJm5rfjdKhmryreBT70Ekp4aCq3W85Wa80EqqaGR249AfARMLL
Zyyi5njhcIeBWI6k50QPeJc1au4TrNZK+Cj4tES8NjLmOR+6mi/znceC/IxDVaEr
PKN57gQxi1Ateb60tAvSmve0eBQVLTKGdg4i0a60QRRvAc/fiwsZbEcGV1e+owWh
8x5zBUrQ7RmMEvAUUXGbwik+btdFfPIqMPIwAg+2wsxlbK2Ibweno+Ng7/UWqiwj
zO07HE9/xWVMZVLz4Yl5F5JMy/7NK+WvKwhgkddhCX9VJ0eJ56ePKdCK/RKc0Td4
e8lxFCjFeByru2VmEWMTWfCjgNLmPcF0riAG/K6KOvyxLtTb5UK3rO45kEWd5ubZ
6NVMwFJM/Ue3QUQrXrsC
=5zM0
-----END PGP SIGNATURE-----

--jHKWLlFdX9CxQ2mO6bFDi4MTOtUcvh8hQ--

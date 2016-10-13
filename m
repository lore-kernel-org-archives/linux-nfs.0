Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:45093 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750926AbcJMWO7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 13 Oct 2016 18:14:59 -0400
From: NeilBrown <neilb@suse.com>
To: Trond Myklebust <trondmy@primarydata.com>
Date: Fri, 14 Oct 2016 08:55:17 +1100
Cc: List Linux NFS Mailing <linux-nfs@vger.kernel.org>
Subject: Re: Incorrect(?) use of open_state->stateid in pnfs
In-Reply-To: <48DEE414-C703-498E-9FAB-0C96C38F58D2@primarydata.com>
References: <87zim8zphv.fsf@notabene.neil.brown.name> <48DEE414-C703-498E-9FAB-0C96C38F58D2@primarydata.com>
Message-ID: <87vawvzzga.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On Fri, Oct 14 2016, Trond Myklebust wrote:

>> On Oct 13, 2016, at 03:18, NeilBrown <neilb@suse.com> wrote:
>>=20
>>=20
>> Suppose I open/create a file over pNFS and am given a WRITE delegation.
>> I then chmod the file (as rsync is wont to do) so the delegation is
>> immediately returned.
>> I then proceed to write, which triggers a LAYOUT_GET request.  The
>> stateid for that request it taken from state->stateid, which is still
>> the delegation stateid.  Naturally it gets NFS4ERR_BAD_STATEID.
>
> Umm=E2=80=A6 Why isn=E2=80=99t the client recovering open stateids as par=
t of the delegation return? That would appear to be the root cause problem =
here.

Ahh.. that's where it happens.  Of course.  Thanks.
I was thinking that where would be no opens to recover because the
delegation wasn't used to complete any other opens.  But there is more
to the recovery than that.

>
> Is this the latest upstream kernel?

No, it is 3.12 based.  I now see that I am just missing

Commit: 5e99b532bb95 ("nfs4: reset states to use open_stateid when returnin=
g delegation voluntarily")

Thanks!

NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIcBAEBCAAGBQJYAALFAAoJEDnsnt1WYoG5bGoP/1H7wPyvN6GcSVRMyyLDowtX
XDsPf0XDmPilrfRq3s6NlFe8Fu2UDHVYiCaZzrKJtQ8IuNP5AdPIEdtk8XQEqyu4
V16NB1i/QvsMlgMnvlVWo+MKbMfoyKDJ2tadVnMzVWg9QNNrQponb8VhboO6+ovZ
RpPJdUKbqkNJA1UhN7WfOB+CIyMAI1/CXmRrL0o+dNiSTOZpVnIUGx7vIXzybICc
W8alhs2x9eJJDQ7YH+DUDJDUUTU6eDAebmSrkDx3KrruOsFvUBKeyRgwVUmbtgh7
Q/XXBnHQ+hGX62GYMi8H/2mf0d/uoYf+tKQnM3C88lgH1jM9fOtKiOIJK85vi33L
8h1GSHcjdIDPqjbCH1PIlcz/PPtczlGr1/+0JbdCIAVen+2Zn85rTkBnaEXq6+cP
/2WPrNx6EiIdtEW0ELX0sepNp739vIZq2NEljSLWXc5qvg69b3vjZvd1jbDTvG7P
F2W/jQPy9EeNKWfH64AmMAT3lllV4ziplc2jeX6UqMmBsm0j1AYEC+OQGX9PNwoO
uALOUZETS+fX61xoCxdK91HqFkGzATXB+kxMQhqOD7OKEOFqISCSjgw8FmnF4Zv6
bw46BT45hcBFfbYSimO6wKGChOSiUVhV64idcsK6mBQVMlOtDSs/tyDRGn5q89sG
oa7yZXBJSBXVot73NcFA
=U9Bf
-----END PGP SIGNATURE-----
--=-=-=--

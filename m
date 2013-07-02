Return-Path: linux-nfs-owner@vger.kernel.org
Received: from haggis.pcug.org.au ([203.10.76.10]:53432 "EHLO
	members.tip.net.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754778Ab3GBX5Y (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 2 Jul 2013 19:57:24 -0400
Date: Wed, 3 Jul 2013 09:57:15 +1000
From: Stephen Rothwell <sfr@canb.auug.org.au>
To: David Howells <dhowells@redhat.com>
Cc: torvalds@linux-foundation.org, linux-cachefs@redhat.com,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        milosz@adfin.com
Subject: Re: [GIT PULL] Fix assorted FS-Cache issues
Message-Id: <20130703095715.8ea67921e398429fe8e8a643@canb.auug.org.au>
In-Reply-To: <20130703093815.006437fd5f18210b7729b060@canb.auug.org.au>
References: <6302.1372775256@warthog.procyon.org.uk>
	<20130703093815.006437fd5f18210b7729b060@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Wed__3_Jul_2013_09_57_15_+1000_76kV07irQKkH5Scw"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Signature=_Wed__3_Jul_2013_09_57_15_+1000_76kV07irQKkH5Scw
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, 3 Jul 2013 09:38:15 +1000 Stephen Rothwell <sfr@canb.auug.org.au> w=
rote:
>
> On Tue, 02 Jul 2013 15:27:36 +0100 David Howells <dhowells@redhat.com> wr=
ote:
> >
> > Hi Linus,
> >=20
> > The following changes since commit b973425cbb51e08301b34fecdfd476a44507=
d8cf:
> >=20
> >   Merge tag 'ext4_for_linus_stable' of git://git.kernel.org/pub/scm/lin=
ux/kernel/git/tytso/ext4 (2013-05-14 09:30:54 -0700)
> >=20
> > are available in the git repository at:
> >=20
> >=20
> >   git://git.kernel.org/pub/scm/linux/kernel/git/dhowells/linux-fs.git t=
ags/fscache-20130702
>=20
> /me wonders where this has been hiding for the last month and a half ...

Ah ha! they have been in linux-next as a different set of commits based
in the same commit and some with even the same commit date/times ...

Oh, well, at least the other set have been removed form linux-next today.

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Signature=_Wed__3_Jul_2013_09_57_15_+1000_76kV07irQKkH5Scw
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.20 (GNU/Linux)

iQIcBAEBCAAGBQJR02jgAAoJEECxmPOUX5FEntgP/1SDhXRRtZqheyZjiaH8WMKW
iRbjPjpThXFgrmNS0zfSe2DRRDSNfb0WaovN99shFkPJ+ZmNpj0ncTlS9TUysgIX
pxtymn1b9RCnymdsFzRpRISN/KLxGr7/3hV0osSei20Je2K31Z4pk2pWVyrTIlJr
iW5fbXLx/viMyKEKZOGB19MOxi4Kil73brv86FDJ7E8R8X3FWJNetik05PB7aT/7
vTFJ+Tyysv+R4uKLVgi0j+EBDH6zerZSoycXlCgZ+T1GrUBrdNd73Ixhum03maMp
65PpspF4b/oLw/Y61VdUfYeNJ7cQbzhGVIBApS+G56zMTe5BwdB4W9VTaQ+Vr16+
kAc5Q1o4yCjdmf4VbLfpfjTPVXbDMLV3iHbh5cwREin8CnKg8YPMrNHcRQVUj8wf
Q1/9tphQSzcOhzHONKGv1y7CRyNne+0l7Vf8+y6TNAyDh7JmLk6dAiRCApaIx51u
FLm0InoiXLrb28IUqOM0tS3V+nzmR16gT5wy9lHMn3JbZGtjH1g0ntFmg16d5huU
aWzc8zaPo+lsR1H6GCSn9KIhgwLwqpaODO08ejIsNsd5Wkyc7tLX2lmDsyZrFxFA
LKOEkGciZP0yLqOZVODAem2xvsawUifzjbZn/dSKApV0+Oevi7kdTNcsr8h07/k4
95A0nxfcWTyl3vSGSBrJ
=vqin
-----END PGP SIGNATURE-----

--Signature=_Wed__3_Jul_2013_09_57_15_+1000_76kV07irQKkH5Scw--

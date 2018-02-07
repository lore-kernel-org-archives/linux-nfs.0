Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:60771 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750768AbeBGGaQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 7 Feb 2018 01:30:16 -0500
From: NeilBrown <neilb@suse.com>
To: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
Date: Wed, 07 Feb 2018 17:30:08 +1100
Subject: Re: [PATCH v4 0/5] NFS basic junction support for nfs-utils
In-Reply-To: <20180129232527.10141.69789.stgit@manet.1015granger.net>
References: <20180129232527.10141.69789.stgit@manet.1015granger.net>
Message-ID: <878tc5nwgf.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Mon, Jan 29 2018, Chuck Lever wrote:

> Still UNTESTED.
>
> A while back I announced the deprecation of fedfs-utils. There were
> a handful of components in fedfs-utils that we decided to keep. One
> of those keepers was the "nfsref" command. (The other was autofs
> support for /nfs4, which I hope Ian Kent is making progress on ;-)
>
> This series introduces "nfsref" to nfs-utils, minus the overhead of
> the LDAP / FedFS machinery, and it builds support for NFS basic
> junctions into mountd, replacing the need to install a plug-in DLL
> from fedfs-utils.
>
> I didn't apply a lot of brain cells to this port, so it's perhaps a
> little larger than it needs to be. Still, it achieves a completely
> LDAP-free implementation that resides 100% in nfs-utils. I'm
> interested in comments about the approach before I do more testing
> and refinement.

It looks sensible to me, though I must confess that I haven't given much
thought to the use of junctions, and have never tried working with them.

If I understand correctly, you can already do junctions by putting
archane magic in /etc/exports, and possibly performing
  mount --bind /foo /foo
With the patch to mountd, you can put the archane magic in an
xattr on the directory, and skip the --bind mount.
Then "nfsref" is a funky tool which adds/lists/removes the archane magic
in a human-readable fashion.

That sounds like a generally sensible idea.  There seems to be rather
more code than I would expect for that functionality, but you've already
admitted that, so no surprise there.

I was rather surprised to see an rpcgen generated file without the .x.
I think I understand why that is, and that is one place that you will
probably remove a lot of unnecessary content, including the comment
about rpcgen.

So:  +1

Thanks,
NeilBrown


>
> ./configure --enable-junction --enable-caps
>
> is needed before building.
>
>
> Changes since v3:
> Broke up the first patch because it was apparently too large to
> be reflected through vger.kernel.org.
>
>
> Changes since v2:
> None.
>
>
> Changes since RFC (v1):
> Patch 2/3 in the original series added the libnfsjunct.so DLL to
> nfs-utils. Series v2 instead replaces 2/3 with a patch that puts
> support for junctions into mountd without the need for a DLL.
>
> ---
>
> Chuck Lever (5):
>       Add headers to support libjunction
>       Add infrastructure for libjunction
>       Add LDAP-free version of libjunction to nfs-utils
>       mountd: Solder in support for NFS basic junctions
>       Add LDAP-free 'nfsref' command
>
>
>  aclocal/libxml2.m4                   |   15=20
>  configure.ac                         |   17=20
>  support/Makefile.am                  |    4=20
>  support/include/Makefile.am          |    2=20
>  support/include/fedfs_admin.h        |  342 +++++++
>  support/include/junction.h           |  125 +++
>  support/junction/Makefile.am         |   34 +
>  support/junction/display.c           |  159 +++
>  support/junction/export-cache.c      |  118 +++
>  support/junction/junction-internal.h |  121 +++
>  support/junction/junction.c          |  494 +++++++++++
>  support/junction/locations.c         |  131 +++
>  support/junction/nfs.c               | 1564 ++++++++++++++++++++++++++++=
++++++
>  support/junction/path.c              |  345 ++++++++
>  support/junction/xml.c               |  401 +++++++++
>  utils/Makefile.am                    |    4=20
>  utils/mountd/Makefile.am             |    8=20
>  utils/mountd/cache.c                 |  189 ++--
>  utils/nfsref/Makefile.am             |   39 +
>  utils/nfsref/add.c                   |  271 ++++++
>  utils/nfsref/lookup.c                |  211 +++++
>  utils/nfsref/nfsref.c                |  188 ++++
>  utils/nfsref/nfsref.h                |   47 +
>  utils/nfsref/nfsref.man              |  180 ++++
>  utils/nfsref/remove.c                |  145 +++
>  25 files changed, 5050 insertions(+), 104 deletions(-)
>  create mode 100644 aclocal/libxml2.m4
>  create mode 100644 support/include/fedfs_admin.h
>  create mode 100644 support/include/junction.h
>  create mode 100644 support/junction/Makefile.am
>  create mode 100644 support/junction/display.c
>  create mode 100644 support/junction/export-cache.c
>  create mode 100644 support/junction/junction-internal.h
>  create mode 100644 support/junction/junction.c
>  create mode 100644 support/junction/locations.c
>  create mode 100644 support/junction/nfs.c
>  create mode 100644 support/junction/path.c
>  create mode 100644 support/junction/xml.c
>  create mode 100644 utils/nfsref/Makefile.am
>  create mode 100644 utils/nfsref/add.c
>  create mode 100644 utils/nfsref/lookup.c
>  create mode 100644 utils/nfsref/nfsref.c
>  create mode 100644 utils/nfsref/nfsref.h
>  create mode 100644 utils/nfsref/nfsref.man
>  create mode 100644 utils/nfsref/remove.c
>
> --
> Chuck Lever
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlp6nPAACgkQOeye3VZi
gbk6WA//T4F4tofF0+LirpZIAsuJdJZc/Z9jG8ARmvjNirEQ3aQI93Onqi+o71z8
uLyMcDau8w5nrJmf9h43JX1Fzl+P4mdhPv4JPeRKu0GrL6K0+jGO0yDmcJgkQs/G
cDlF3TMs/BzUSDRGfVphzawyPNTuTJkALVtJ01gjzq2rKrfkhcll8Kto8gDo9aIP
jCFEox9Iv0ChaWFcjR/B1pg0ySiwc7nBVu7Df/RFPlSPIgC6OaS37S33PZapTKED
0owo9/MQvktuuqHryG3HoHQDqcgyK5U9qkiCXGd0G6F7MzhvFcB/PoTv1+XsyssM
t9XVZ5FIGx9OBGserJPKazxfpmoXNydtC4/ysZPwYpJ2dGzL1oWHgCgOmgKp1TXX
pOqgsCEPCDE9rEmpnBbRmUOA0Kwc+hjX4uawIFg9e0uBNKZC2hOOG0OuujfMeXsW
ZA8/jI53oCqs0+pjMIAHYxMr3sNySIoaUufXMuttkQwitq0IJQb9EI0JARZzOOBg
3sZShc/nDcMXDt9KXK4GNZf57bl7LgM9LcJmFzhyQ2wGjnXSfZquKxah4Cs7kVGa
CpcbBDTj8Dc4UmwrZGZeS9YsVs0At4kCQADLBqO/5s3Z0hpaDishSrtE2EkWwDKM
BofmfRGuHezkDFZAdH4IrKdd4r0EfL4+mGMqOiuW85rQhm818T8=
=J+hA
-----END PGP SIGNATURE-----
--=-=-=--

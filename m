Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:60921 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750778AbeADFL2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 4 Jan 2018 00:11:28 -0500
From: NeilBrown <neilb@suse.com>
To: Andreas Radke <andreas.radke@mailbox.org>,
        Steve Dickson <SteveD@RedHat.com>
To: Jeff Layton <jlayton@kernel.org>
Date: Thu, 04 Jan 2018 16:11:19 +1100
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: ANNOUNCE: nfs-utils-2.3.1 released.
In-Reply-To: <20171221212516.031618d8@laptop64.home>
References: <1a56bb72-cc10-ba74-2b04-4df588804ef5@RedHat.com> <20171221212516.031618d8@laptop64.home>
Message-ID: <87a7xudx8o.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On Thu, Dec 21 2017, Andreas Radke wrote:

> This new version fails make check here now:
>
> nsm_client.c:147:12: warning: this statement may fall through [-Wimplicit=
-fallthrough=3D]
>     my_prog =3D atoi(optarg);
>     ~~~~~~~~^~~~~~~~~~~~~~
> nsm_client.c:148:3: note: here
>    case 'v':
>    ^~~~

What do you think Jeff, you introduced this code 8 years ago and this
switch statement has always been broken.
Does anyone use this code?  Should we fix it, it just remove it?



> make[4]: *** No rule to make target '../../support/nfs/libnfs.a',
> needed by 'nsm_client'.

This looks like a bug in automake???  ../../support/nfs/libnfs.a is
listed as _LDADD

https://www.gnu.org/software/automake/manual/html_node/Program-and-Library-=
Variables.html#index-maude_005fAR

which should add it to the 'ld' command, but I don't see that it should
be added as a dependency.

> make[4]: Target 'nsm_client' not remade because of errors.
> make[3]: *** [Makefile:565: check-am] Error 2
> make[2]: *** [Makefile:567: check] Error 2
> statdb_dump.c: In function =E2=80=98dump_host=E2=80=99:
> statdb_dump.c:38:17: warning: unused parameter =E2=80=98timestamp=E2=80=
=99 [-Wunused-parameter]
>     const time_t timestamp)
>                  ^~~~~~~~~

This arg has to be there because it is part of an external API.
As the function is passed as an arg to an extern function, gcc could
deduce that the signature cannot be changed just because the arg isn't
needed.


> statdb_dump.c: In function =E2=80=98main=E2=80=99:
> statdb_dump.c:91:10: warning: unused parameter =E2=80=98argc=E2=80=99 [-W=
unused-parameter]
>  main(int argc, char **argv)
>           ^~~~

This arg doesn't need to be used (obviously) but cannot be removed.
So this is a dumb warning too.

Maybe we should add __attribute__((unused)) ??

> make[3]: *** No rule to make target '../support/nfs/libnfs.a', needed by =
'statdb_dump'.
> make[3]: Target 'statdb_dump' not remade because of errors.
> make[2]: *** [Makefile:1028: check-am] Error 2
> make[1]: *** [Makefile:717: check-recursive] Error 1
> make[1]: Target 'check' not remade because of errors.
>

I assume you get these errors by running "make check" without first
running "make"??
If you run "make" first, the errors go away, and you are left with the
warnings.

Maybe they are worth fixing .... let's see what Jeff thinks.

NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlpNt3gACgkQOeye3VZi
gbmYJRAAjp728fSfv12y8xqrNo69Luzb/LJTe8uZkhdp77SKzh9182lXCzAHOKW5
o/RKNMU+QaIcgYUb4wgAYxpCP3o8ZbLVsCrC0YfFEShV6Efj7+deFLKdjn5YSpQz
XIGUjQedKJDfukeOzCTUxLo0RUaxkDaxHqa8VAHINY6HY/swI2CkJLGvcDdGl4GJ
jl947RpoCDm7F1QyNXcx0vN4iQxgBbhPseAGGDRgELMa1spVs9tfUUmE7dGWlDqr
NJewAdNNnRIia5+sc2BKxpwbTCNLRKDbOA8ZfeOFyLUCv6y0fJuyKKDkb/GtQm62
p0RjIxG00NQpDAj3HqdWWn67kY5iJSyfA67/lpBlL9P8RVEJ1myObHI9ngrrK3xH
AW+w7JrwCB1NYOSW5Jme/V0gOEvkGNvu5YpbJbWcvLHoFIluQqkQhdPgFLwTMAPR
YwH/izShf5rSosexeS9raOmnIj/wyl0GJg2EqKRiVyZ3++1ASJcqG7c8pGdEdeRE
sOAabX1OYaWbHhyb+fxOBHCAGav0wP+XywvhtT5ScZeLisQxY1zu6IvBQXqb8D1L
fomzTqRHbZBBjl7Fjw8+7wGrp6lexVoa3Z2V8do/Zy6HDTbPpzV0YZr5FYmetIz1
XGobfhjks226n8HUvubp2Rs+ZhhmUqy7ffWRkHoQ7lpIzttuIBo=
=umlF
-----END PGP SIGNATURE-----
--=-=-=--

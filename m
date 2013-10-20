Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:52601 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751816Ab3JTWtV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 20 Oct 2013 18:49:21 -0400
Date: Mon, 21 Oct 2013 09:49:02 +1100
From: NeilBrown <neilb@suse.de>
To: NeilBrown <neilb@suse.de>
Cc: Chuck Lever <chuck.lever@oracle.com>, Wangminlan <wangminlan@huawei.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: Different sequence of "exportfs" produce different effects on
 nfs client mounts
Message-ID: <20131021094902.616f2100@notabene.brown>
In-Reply-To: <20131018083253.40e8881e@notabene.brown>
References: <3962238FD7EA0F41B1810E7ABEAFBC314CEF9ACF@szxema505-mbs.china.huawei.com>
	<20131014174540.GA27747@fieldses.org>
	<3962238FD7EA0F41B1810E7ABEAFBC314CEF9E97@szxema505-mbs.china.huawei.com>
	<20131015154918.GA6117@fieldses.org>
	<3962238FD7EA0F41B1810E7ABEAFBC314CEF9FD9@szxema505-mbs.china.huawei.com>
	<3962238FD7EA0F41B1810E7ABEAFBC314CEFA2F5@szxema505-mbs.china.huawei.com>
	<CB4DB7B1-5EEA-47D0-9CAD-CC69AF868182@oracle.com>
	<20131018083253.40e8881e@notabene.brown>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/ZPHlgTWmbMBKG0tLhntWLTs"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/ZPHlgTWmbMBKG0tLhntWLTs
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Fri, 18 Oct 2013 08:32:53 +1100 NeilBrown <neilb@suse.de> wrote:

> On Thu, 17 Oct 2013 09:14:02 -0400 Chuck Lever <chuck.lever@oracle.com> w=
rote:
>=20
> > Hi-
> >=20
> > 281         if (ident[0] =3D=3D '\0')
> > 282                 return MCL_ANONYMOUS;
> > 283         if (ident[0] =3D=3D '@') {
> > 284 #ifndef HAVE_INNETGR
> > 285                 xlog(L_WARNING, "netgroup support not compiled in");
> > 286 #endif
> > 287                 return MCL_NETGROUP;
> > 288         }
> > 289         for (sp =3D ident; *sp; sp++) {
> > 290                 if (*sp =3D=3D '*' || *sp =3D=3D '?' || *sp =3D=3D =
'[')
> > 291                         return MCL_WILDCARD;
> > 292                 if (*sp =3D=3D '/')
> > 293                         return MCL_SUBNETWORK;
> > 294                 if (*sp =3D=3D '\\' && sp[1])
> > 295                         sp++;
> > 296         }
> >=20
> > is still in play today.  The "host_pton()" code you posted was added by=
 commit 502edf1d just after this paragraph.  But here is what that commit r=
eplaced.
> >=20
> > -       /* check for N.N.N.N */
> > -       sp =3D ident;
> > -       if(!isdigit(*sp) || strtoul(sp, &sp, 10) > 255 || *sp !=3D '.')=
 return MCL_FQDN;
> > -       sp++; if(!isdigit(*sp) || strtoul(sp, &sp, 10) > 255 || *sp !=
=3D '.') return MCL_F
> > -       sp++; if(!isdigit(*sp) || strtoul(sp, &sp, 10) > 255 || *sp !=
=3D '.') return MCL_F
> > -       sp++; if(!isdigit(*sp) || strtoul(sp, &sp, 10) > 255 || *sp !=
=3D '\0') return MCL_
> > -       /* we lie here a bit. but technically N.N.N.N =3D=3D N.N.N.N/32=
 :) */
> > -       return MCL_SUBNETWORK;
> > +
> > +       /*
> > +        * Treat unadorned IP addresses as MCL_SUBNETWORK.
> > +        * Everything else is MCL_FQDN.
> > +        */
> > +       ai =3D host_pton(ident);
> > +       if (ai !=3D NULL) {
> > +               freeaddrinfo(ai);
> > +               return MCL_SUBNETWORK;
> > +       }
> > +
> > +       return MCL_FQDN;
> >  }
> >=20
> > The replaced logic also treats IP addresses as MCL_SUBNETWORK.  That's =
from commit 54669c98 in 2005.  Neil, do you remember why this semantic chan=
ge was made?
> >=20
>=20
> See this thread:
>=20
>   http://marc.info/?t=3D110993941000003&r=3D1&w=3D2
>=20
> It was a simple (though possibly flawed) solution to clearly differentiate
> those addresses where DNS looked might be needed, and those where it was =
not.
>=20
> I may have more to say later but I have to rush off now, so thought I'd j=
ust
> post this anyway.
>=20

Unfortunately I cannot see how that change ever made any important
difference, and the email exchanges ends without resolving anything.

It could only make a difference to the number of DNS lookups if there was
somewhere a test for whether clientlist[MCL_FQDN] was NULL, but there isn't
and never was.

So it seems very likely that:

diff --git a/support/export/client.c b/support/export/client.c
index ba2db8f..adbeed8 100644
--- a/support/export/client.c
+++ b/support/export/client.c
@@ -767,15 +767,5 @@ client_gettype(char *ident)
 			sp++;
 	}
=20
-	/*
-	 * Treat unadorned IP addresses as MCL_SUBNETWORK.
-	 * Everything else is MCL_FQDN.
-	 */
-	ai =3D host_pton(ident);
-	if (ai !=3D NULL) {
-		freeaddrinfo(ai);
-		return MCL_SUBNETWORK;
-	}
-
 	return MCL_FQDN;
 }

is appropriate and may well fix the current issue.

It would be good to test how many DNS looks (hopefully none) are performed
when using a exports file that contains only IP addresses, both before and
after the patch.

NeilBrown

--Sig_/ZPHlgTWmbMBKG0tLhntWLTs
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQIVAwUBUmRd3jnsnt1WYoG5AQKW2w//Uq7olZPwvbTict0xDTL8C6sdeTGsu/Wm
1XX5rDL7ZJwVofqJxanzlPm83rKCMckzwqsdCdInWEz1gUSv/0KdrAML2+PSv5k/
12xw0EnB8UNpYFgEYWv4dVQANXl68V5uSYOC2VYzw3ArQC0LxuefeYYFaC3km6tL
hS7N3XODKdEokeuw/lxBWY8DQUIrx04NbwdVfzEqzFFt9tjyTIVPjuZ6cTZA8dSQ
BXmdX8e4Y7bRRtyzld9Bnj3AYFiAiKoX6zzoGJMiXaxNzMU8WmP+UaEWDWjhiIIU
6JINIzxxDJUubljWILCIS6UeE2h4HucMArgQMCzUPOb1VVCqXknComdSz9REgKvE
7Bo+JumamWelu2joJfp3svTgnSIFlsWfRFqFSXQwsOdEkVBpt/IhoVuIXzdyceP8
1ZpQ/m3Z/bvx5PKaut45pPFrhFeHhymzl/Fd5Th+ShkpzjnUJWTMIVuP2pNG8UhF
dH3LJeszFXrc8wWIpkBVZ6GwIDUaikTg+EYnsYNVPA9kI7Z7VjvS9DeQSglkUFMf
zmcHIAXLUA+0KOfqleA1jqvh1UYACkYpvelMs8oRUYq31n6yzkJiNcX8Uci/mgQM
eXz7a0rKKp1lmvYm0gi3hqZgILTOPwy3EUq4YQEjKfV16wg3HmlAVOnxRCxqlbTt
PJsqk7tjW5w=
=JiK0
-----END PGP SIGNATURE-----

--Sig_/ZPHlgTWmbMBKG0tLhntWLTs--

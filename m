Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:38442 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753866Ab1LWOeZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 23 Dec 2011 09:34:25 -0500
Date: Fri, 23 Dec 2011 09:34:01 -0500
From: Jeff Layton <jlayton@redhat.com>
To: Mike Frysinger <vapier@gentoo.org>
Cc: linux-nfs@vger.kernel.org, steved@redhat.com
Subject: Re: [PATCH] nfsidmap: auto disable when keyutils is not found
Message-ID: <20111223093401.52ad6812@tlielax.poochiereds.net>
In-Reply-To: <201112221120.12395.vapier@gentoo.org>
References: <1314991015-21484-1-git-send-email-vapier@gentoo.org>
	<20111222093855.40112b8c@tlielax.poochiereds.net>
	<201112221120.12395.vapier@gentoo.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/MOVgua_1bM_Z=_/SnuoIY/+"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/MOVgua_1bM_Z=_/SnuoIY/+
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Thu, 22 Dec 2011 11:20:11 -0500
Mike Frysinger <vapier@gentoo.org> wrote:

> On Thursday 22 December 2011 09:38:55 Jeff Layton wrote:
> > On Fri,  2 Sep 2011 15:16:55 -0400 Mike Frysinger wrote:
> > > --- a/aclocal/libnfsidmap.m4
> > > +++ b/aclocal/libnfsidmap.m4
> > >=20
> > > -  AC_CHECK_LIB([nfsidmap], [nfs4_owner_to_uid], [enable_nfsidmap=3Dy=
es],
> > > -               [enable_nfsidmap=3Dno])
> > > +  AC_CHECK_LIB([nfsidmap], [nfs4_owner_to_uid])
> >=20
> > The above delta in this patch has caused a build-time regression.
> >=20
> > When you eliminated the 3rd argument to AC_CHECK_LIB, this started
> > adding -lnfsidmap to $LIBS. That means that that library gets linked
> > into every binary that's being built.
> >=20
> > I haven't determined the right fix for this yet, but I think
> > libnfsidmap.m4 could use some cleanup.
>=20
> AC_CHECK_LIB([nfsidmap], [nfs4_owner_to_uid], [])
> -mike

Uhhh, no. That turns the result of this test into a noop. We might as
well remove it at that point.

Perhaps I should phrase this question differently: What is the above
test supposed to achieve? IOW, what should happen if it passes or fails?

--=20
Jeff Layton <jlayton@redhat.com>

--Sig_/MOVgua_1bM_Z=_/SnuoIY/+
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.18 (GNU/Linux)

iQIcBAEBAgAGBQJO9JFZAAoJEAAOaEEZVoIVRfoP/A4MqQAgI7r/XXHekaV48aMU
+k7NPnrDQKBklq3ajcYIi9mGAbMQqZBPJ+zxPLOEFVSD0JqYdOtF1HfcR0mYODWz
NfKZ4z4EM5TI3++YzfTelt8UBoqbY8c0UDmkPr8Pq+U1uA1Nww9yvX1V7Uj1W/90
Ou0pMuoL7Mrila1uzeZI9eMWhe6hGMLnbTgKErEyHqUidkXwFANcyYvKWtD9BZ1X
Jlua9wCy8UvDu18OyRTEBHIDLvi7ugQm5q0Ncru3qiYbgPVA2EGrVqI3d4oir6wO
UrlqubrZgK94U3at26rMU6sbK3lucjNCfNGzXmEj5F92pD3wLt2ZWvx6MxpWchtN
UwUaD18vvb/2JG3kaWurefpbmk9byJ8nWByrxi1LSu3RqTwZzIWyJNIezTd75fOh
V3tU4aybDV/adEHVdZ/94sZNaxemCOpw7d5XAi2xqPG673sjVP7efFT3lH88I6Zh
bQ+zKyFhWNZ5/S5LY5nOOo3ew6P/82M5a/9mWtxAoI4WO9vG8hxlhl1lTF3dPUzJ
36OMzKiwFJ8d6LsTz8qfTH6tvAlOM7j0asD+zDnuRKPFw+v8P0T/SqGouZ1/j1ws
S6hvw7Fh0ViSFpubaaKEOxpfAR7jt7v9b9SjYuQE27Zd1GArH5rQ24Z3xNBEIagm
QIQBC3aeQvIdR7vQnUBD
=cBu6
-----END PGP SIGNATURE-----

--Sig_/MOVgua_1bM_Z=_/SnuoIY/+--

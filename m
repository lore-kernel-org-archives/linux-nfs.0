Return-Path: linux-nfs-owner@vger.kernel.org
Received: from messinet.com ([50.196.241.75]:41425 "EHLO chicago.messinet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751234AbaBDOSM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 4 Feb 2014 09:18:12 -0500
From: Anthony Messina <amessina@messinet.com>
To: Jeff Layton <jlayton@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH/RFC: nfs-utils] Common systemd unit files for nfs-utils.
Date: Tue, 04 Feb 2014 08:18:06 -0600
Message-ID: <1704334.S536sDEhjD@linux-ws1.messinet.com>
In-Reply-To: <20140204082426.449519bd@tlielax.poochiereds.net>
References: <20140130172451.7a354ce4@notabene.brown> <1757036.O2OPYTypu1@linux-ws1.messinet.com> <20140204082426.449519bd@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="nextPart3089434.SubAYbCYQv"; micalg="pgp-sha1"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--nextPart3089434.SubAYbCYQv
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain; charset="us-ascii"

On Tuesday, February 04, 2014 08:24:26 AM Jeff Layton wrote:
> On Tue, 04 Feb 2014 06:42:12 -0600
>=20
> Anthony Messina <amessina@messinet.com> wrote:
> > On Monday, February 03, 2014 04:01:21 PM Steve Dickson wrote:
> > > This changes the current API... Today to enable/start this servic=
e=20
> > >
> > > today one does:
> > >=20
> > >   systemctl enable nfs-server
> > >   systemctl start nfs-server
> > >=20
> > >
> > > which would change to:
> > >=20
> > >   systemctl enable nfs-server.target
> > >   systemctl start nfs-server
> > >=20
> > >
> > > with the same daemons being started.
> > > This changed will cause existing scripts to fail...=20
> > > I guess I don't see the point of having a .target file.=20
> > >
> > >=20
> > >
> > > How is rpc.svcgssd enabled? Since the .service file does
> > > not have a [Install] section the systemctl enable rpc.svcgssd
> > > fails.
> > >
> > >=20
> > >
> > > Also how does gss-proxy come to play in all this? Maybe we=20
> > > just use  gss-proxy by default and retire rpc.svcgssd.
> >
> >=20
> >
> > Usually just a quite listener (end-user & small-time sysadmin) on t=
his
> > ML...>
> >=20
> >
> > +1 for gss-proxy by default (for Fedora anyway).  I've been using i=
t=20
> > throughout F19 extensively in the KRB5/NFSv4.1 environment with gre=
at
> > success.   I have nfs-secure-server.service "masked" via systemd to=

> > prevent it from being started.
> >
> >=20
> >
> > There seems to be only one strange issue I've come across with gss-=
proxy
> > vs.  rpc.svcgssd: https://fedorahosted.org/gss-proxy/ticket/98.  Th=
is is
> > with regard to how access for the "nfsnobody" user is handled.  The=

> > ticket attempts to show that with rpc.svcgssd, a host with host
> > credentials and a user without credentials can still access NFS sha=
res
> > with 0755 directories and 0644 files (via the host credentials and =
mapped
> > to the nfsnobody user).  With gss-proxy, I had to create user crede=
ntials
> > for kojibuilder@REALM because the access wasn't allowed via the nfs=
nobody
> > path.  I'm not sure if this is resolved, or by design, etc.  But it=
 is
> > the only issue I've seen with gss-proxy vs. rpc.svcgssd.
> >
> >=20
> >
> > Thanks.  -A
> >
> >=20
>=20
> Please do open a bug at bugzilla.redhat.com for that and cc me on it.=

> We really do want to ensure that these sorts of corner-cases get
> addressed.

https://bugzilla.redhat.com/show_bug.cgi?id=3D1061180

=2D-=20
Anthony - http://messinet.com - http://messinet.com/~amessina/gallery
8F89 5E72 8DF0 BCF0 10BE 9967 92DC 35DC B001 4A4E

--nextPart3089434.SubAYbCYQv
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part.
Content-Transfer-Encoding: 7Bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iEYEABECAAYFAlLw9qIACgkQktw13LABSk7SHwCg8/2pLe+O912EVRQZdM+Go/ue
aa8An0M2dhXG37J4lUjmSJ2Z7vhFwrtW
=s33U
-----END PGP SIGNATURE-----

--nextPart3089434.SubAYbCYQv--


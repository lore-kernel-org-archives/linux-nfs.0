Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp.gentoo.org ([140.211.166.183]:55059 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752488AbaHSD1z (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 18 Aug 2014 23:27:55 -0400
From: Mike Frysinger <vapier@gentoo.org>
To: NeilBrown <neilb@suse.de>
Cc: Steve Dickson <SteveD@redhat.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH nfs-utils] start-statd: clean up output when systemd is not installed
Date: Mon, 18 Aug 2014 23:28 -0400
Message-ID: <1572079.YBX0Pc28nn@vapier>
In-Reply-To: <20140819110603.38b92ecb@notabene.brown>
References: <1408286648-19031-1-git-send-email-vapier@gentoo.org> <1649346.61nAovKFdn@vapier> <20140819110603.38b92ecb@notabene.brown>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="nextPart23492895.Z588cK9pmy"; micalg="pgp-sha1"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--nextPart23492895.Z588cK9pmy
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain; charset="us-ascii"

On Tue 19 Aug 2014 11:06:03 NeilBrown wrote:
> On Mon, 18 Aug 2014 19:57:49 -0400 Mike Frysinger <vapier@gentoo.org>=
 wrote:
> > On Mon 18 Aug 2014 13:04:35 Steve Dickson wrote:
> > > On 08/17/2014 10:44 AM, Mike Frysinger wrote:
> > > > If you don't have systemd, then this script dumps:
> > > > /usr/sbin/start-statd: line 8: systemctl: command not found
> > > >=20
> > > > This isn't terribly useful since we ultimately fall back to run=
ning
> > > > the daemon ourselves, so probe for systemd's existence before w=
e try
> > > > to use it.
> > > >=20
> > > > Signed-off-by: Mike Frysinger <vapier@gentoo.org>
> > >=20
> > > Committed... but I used 'rpm -q systemd' instead of 'systemctl --=
help'
> > > to test for the existences of systemd
> > >=20
> > >  # First try systemd if it's installed.
> > >=20
> > > -if systemctl --help >/dev/null 2>&1; then
> > > +if rpm -q systemd > /dev/null 2>&1; then
> > >=20
> > >      # Quit only if the call worked.
> > >      systemctl start rpc-statd.service && exit
> >=20
> > what about all the other distros not using rpm ?  my version was di=
stro
> > agnostic.
> > -mike
>=20
> distro-agnotic is certainly important.
> I would have gone with:
>=20
> diff --git a/utils/statd/start-statd b/utils/statd/start-statd
> index dcdaf7763f18..414f73f58096 100644
> --- a/utils/statd/start-statd
> +++ b/utils/statd/start-statd
> @@ -5,7 +5,7 @@
>  # It should run statd with whatever flags are apropriate for this
>  # site.
>  PATH=3D"/sbin:/usr/sbin:/bin:/usr/bin"
> -if systemctl start rpc-statd.service
> +if systemctl start rpc-statd.service > /dev/null 2>&1
>  then :
>  else
>      exec rpc.statd --no-notify
>=20
>=20
> why call systemctl twice (once with --help and once with "start")?

because i don't think you want to silence errors from systemd when it's=
=20
actually in use.  probing with --help tells you whether it exists.
=2Dmike
--nextPart23492895.Z588cK9pmy
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part.
Content-Transfer-Encoding: 7Bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABAgAGBQJT8sRAAAoJEEFjO5/oN/WBVOMQANSeBZ6QHe39wnyN8P5PaBzf
leSbt+GJvDjSEgFHa+miFf6p7K7HCbcyIevwyKCJb3iOoAOR7txvPKPAwzg6Nceh
bG85VBTWHvxID0K208n4Hb0Ly2rEmYwjnPxK7AQyKIKdJzZOVqKB6NwPyuV5NS7b
7A/XHBH/9Q2gEz3tTmsF7Rrqtk5F+NXWg+YtbtAx7bV3pNxc251pWBkwGQO1Nfn3
vCYpdowv4OvXyZYwK25LzS7QXYz4feDf1WTWKEBeRsxasxnysyn9ykqZKbSCyIrO
vESOeZIRQdQ2HpD6zCy2b2IaMUK7lN9hBiLTKej6//VKT5AQTgc139d2aI2hp6x/
RhlBSOmJw4c4d/wRirawd04HSqbgv09pbtdStCxG+KUN6zNbazO+wRZXottSY4VO
uz1nB8ysJLwWXDb0wxtjmwWY9DdY+FWVV4GNi0/GckVVRYEq52TxyfCKcUCXOgdk
TBETXpan5Pj6HlF7X+cLj6Jx5oCvKMTyM6DI/srQvf7w1VFGpOOdm5UIWBZ/KwBL
C+zredh90/mPX6aKzYVbGZF0naeTaQnHnt47hTcyjKTl8uCiK+zyi23YPX6WzS1k
gtuMP5l3d/d04F0sqN/UAz5J+Fuz8+SILokvkYDNJkMjqcEoi6MKmsFyjkZ2nOPM
e6rwqBCFWXW2HfnfmgYN
=IS9K
-----END PGP SIGNATURE-----

--nextPart23492895.Z588cK9pmy--


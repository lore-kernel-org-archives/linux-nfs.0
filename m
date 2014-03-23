Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:49460 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751028AbaCWXpo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 23 Mar 2014 19:45:44 -0400
Date: Mon, 24 Mar 2014 10:45:35 +1100
From: NeilBrown <neilb@suse.de>
To: Steve Dickson <SteveD@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 3/6] systemd: add nfs-utils_env.sh for SUSE.
Message-ID: <20140324104535.6d35e94d@notabene.brown>
In-Reply-To: <532F32A4.1080308@RedHat.com>
References: <20140220065345.7320.49992.stgit@notabene.brown>
	<20140220065530.7320.38662.stgit@notabene.brown>
	<532F32A4.1080308@RedHat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/=Khcef_wqMLj6NMhEULzq0K"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/=Khcef_wqMLj6NMhEULzq0K
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Sun, 23 Mar 2014 15:14:44 -0400 Steve Dickson <SteveD@redhat.com> wrote:

>=20
>=20
> On 02/20/2014 01:55 AM, Neil Brown wrote:
> > This script provides the required translation for
> > sysconfig variables understood by init.d script on openSUSE.
> >=20
> > Signed-off-by: NeilBrown <neilb@suse.de>
> > ---
> >  systemd/SUSE-nfs-utils_env.sh |   62 +++++++++++++++++++++++++++++++++=
++++++++
> >  1 file changed, 62 insertions(+)
> >  create mode 100644 systemd/SUSE-nfs-utils_env.sh
> I was thinking about this one too... Yeah, I know.. I need life!! ;-)=20
>=20
> Do we really want distro specific files like this in the upstream repo?=20
> Its more of a maintenance thing than anything... If something distro=20
> specific changes, do we really need to send the change upstream and=20
> does upstream really care?=20

Probably not.  I mainly added that as an example as there seems to be some
confusion over how I imagined these things working.

I'm quite happy to not have  this upstream (I might even prefer it).

Thanks,
NeilBrown


>=20
> steved. =20
> >=20
> > diff --git a/systemd/SUSE-nfs-utils_env.sh b/systemd/SUSE-nfs-utils_env=
.sh
> > new file mode 100644
> > index 000000000000..8d6d94ed29e5
> > --- /dev/null
> > +++ b/systemd/SUSE-nfs-utils_env.sh
> > @@ -0,0 +1,62 @@
> > +#!/bin/sh
> > +
> > +# extract configuration from /etc/sysconfig/nfs-utils and write
> > +# environment to /run/sysconfig/nfs-utils to be used by systemd unit
> > +# files.
> > +# This script expect configuration as used by openSUSE-13.1 and later
> > +#
> > +
> > +nfs_config=3D/etc/sysconfig/nfs
> > +if test -r $nfs_config; then
> > +    . $nfs_config
> > +fi
> > +
> > +pipefs=3D
> > +if [ -n "$RPC_PIPEFS_DIR" -a "$RPC_PIPEFS_DIR" !=3D "/var/lib/nfs/rpc_=
pipefs" ]; then
> > +    pipefs=3D"-p /var/lib/nfs/rpc_pipefs"
> > +fi
> > +
> > +mountdport=3D
> > +if [ -n "$MOUNTD_PORT" ]; then
> > +    mountdport=3D"-p $MOUNTD_PORT"
> > +fi
> > +
> > +case $NFS_GSSD_AVOID_DNS in
> > +    [Nn]*) ignore_dns=3D-D ;;
> > +    [Yy]*) ignore_dns=3D   ;;
> > +    *    ) ignore_dns=3D-D
> > +esac
> > +
> > +version_params=3D
> > +if [ "$NFS3_SERVER_SUPPORT" =3D=3D "no" ]; then
> > +   version_params=3D"--no-nfs-version 2 --no-nfs-version 3"
> > +fi
> > +if [ "$NFS4_SUPPORT" !=3D "yes" ]; then
> > +   version_params=3D"--no-nfs-version 4"
> > +fi
> > +if [ "$NFS4_SERVER_MINOR_VERSION" !=3D "0" ]; then
> > +   version_params=3D"$VERSION_PARAMS --nfs-version 4 --nfs-version 4.$=
NFS4_SERVER_MINOR_VERSION"
> > +fi
> > +
> > +if [ "$USE_KERNEL_NFSD_NUMBER" -gt 0 ]; then
> > +    threads=3D$USE_KERNEL_NFSD_NUMBER
> > +else
> > +    threads=3D3
> > +fi
> > +
> > +case $NFS_GSSD_AVOID_DNS in
> > +    [Nn]*) ignore_dns=3D-D ;;
> > +    [Yy]*) ignore_dns=3D   ;;
> > +    *    ) ignore_dns=3D-D
> > +esac
> > +
> > +mkdir -p /run/sysconfig
> > +{
> > +echo "RPCIDMAPDARGS=3D$pipefs"
> > +echo "RPCMOUNTDARGS=3D$mountdport $MOUNTD_OPTIONS $version_parms"
> > +echo "RPCNFSDARGS=3D$NFSD_OPTIONS $version_params $threads"
> > +echo "GSSDARGS=3D$ignore_dns $GSSD_OPTIONS $pipefs"
> > +echo "SMNOTIFYARGS=3D$SM_NOTIFY_OPTIONS"
> > +echo "STATDARGS=3D$STATD_OPTIONS"
> > +echo "SVCGSSDARGS=3D$SVCGSSD_OPTIONS"
> > +} > /run/sysconfig/nfs-utils
> >=20
> >=20


--Sig_/=Khcef_wqMLj6NMhEULzq0K
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBUy9yHznsnt1WYoG5AQI+XhAAtQCRbpQhegXipgXcL6kED9LVPqAUgfB8
0naibKi8yxwSqsPmHMKcGsRtr5mmewrEDkHVbNIFzj/vtXZXRbAY7WecSp/QuBH/
Uv1ObqukMySWUTwgU12IeGBvxXX4k4i/L/0jLD4VuPeTXGya1dQbDBF0Y+08HL0E
4qKGsckiBUpe1suoUOG98U+TolBOKdzVTUkbw0AurjXl4Hs1DFke8CjcwSRcKQPn
57tHHBLbQxx+hqnvad7XLUuggOZ74Pp3BZC8qp0PY1t9qvrIx4fQZNHiUYd5e43m
3qzDLtv4BulWj0dqrNuLI//e5y6SxiwrKHH2RiG32fAWHT2J6xyzB/TpHKaI+Cfr
5Whe/4OOzrzKl9IFhKUBny0LwLMs76xc/jaGtsSO9m4JobRXnIy7Z0GFN+FZKyH4
xweLRTjHt3hhyWvjOi3m/cFrS/ZIUnmw3W1UBC1ho9fdiOys8XIMDooVwFzhUN8+
wWJUTVRKolwqdSY0U7C1+YPOVr082nWLYSeUIG4w+EcywgvkOZMngx7sQJf1vx0p
VLhc24BjXc3cEGtd1ZLhXuAY1BTpwB/p6l4TcHXMn/tCs0nMS98XaChSJ/pBvvqN
zSG+oF3StfH716v7DrZaU28+HRnXtbQWyQ0HCM6PFo4e669IqlyNKbbcTo00TfRZ
D1kCGMmouZE=
=lHxU
-----END PGP SIGNATURE-----

--Sig_/=Khcef_wqMLj6NMhEULzq0K--

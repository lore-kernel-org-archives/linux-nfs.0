Return-Path: <nfbrown@novell.com>
From: NeilBrown <nfbrown@novell.com>
To: Benjamin Coddington <bcodding@redhat.com>, steved@redhat.com
Date: Wed, 16 Mar 2016 07:59:45 +1100
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH nfs-utils] systemd: remove the nfs-config service
In-Reply-To: <dfec4f0fe32d23aff0ed608b8f2931059060479a.1457784247.git.bcodding@redhat.com>
References: <dfec4f0fe32d23aff0ed608b8f2931059060479a.1457784247.git.bcodding@redhat.com>
Message-ID: <87h9g7h2ym.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
	micalg=pgp-sha256; protocol="application/pgp-signature"
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Sat, Mar 12 2016, Benjamin Coddington wrote:

> The nfs-config service exists to translate distro-specific startup
> configuration into the command line arguments used by systemd to start nfs
> utilities.  Unfortunately, it is not clear to most users that this service
> must be recycled every time startup configurations have been modified, as
> this requirement is a change for at least one distro.
>
> We can get rid of nfs-config by generating the startup arguments in an
> ExecStartPre option for each service that needs them.  We'll also have to
> break out the EnvironmentFile into a separate file for each service to
> avoid races overwriting this file.
>
> A distro taking this change should also modify their
> /usr/lib/systemd/scripts/nfs-utils_env.sh script to include the new
> EnvironmentFile location for each service.
>
> Signed-off-by: Benjamin Coddington <bcodding@redhat.com>

I can't say I really like this, but it does make sense and solves a real
problem.
Maybe: I would never have written it myself, but I'm kind-a glad you did
:-)

Acked-by: NeilBrown <neilb@suse.com>

Thanks,
NeilBrown


> ---
>  systemd/Makefile.am              |    1 -
>  systemd/README                   |    8 +++++---
>  systemd/nfs-blkmap.service       |    4 +++-
>  systemd/nfs-idmapd.service       |    7 +++----
>  systemd/nfs-mountd.service       |    7 +++----
>  systemd/nfs-server.service       |    7 +++----
>  systemd/rpc-gssd.service         |    7 +++----
>  systemd/rpc-statd-notify.service |    7 +++----
>  systemd/rpc-statd.service        |    7 +++----
>  systemd/rpc-svcgssd.service      |    7 +++----
>  10 files changed, 29 insertions(+), 33 deletions(-)
>
> diff --git a/systemd/Makefile.am b/systemd/Makefile.am
> index 03f96e9..6f59dfc 100644
> --- a/systemd/Makefile.am
> +++ b/systemd/Makefile.am
> @@ -5,7 +5,6 @@ MAINTAINERCLEANFILES =3D Makefile.in
>  unit_files =3D  \
>      nfs-client.target \
>      \
> -    nfs-config.service \
>      nfs-mountd.service \
>      nfs-server.service \
>      nfs-utils.service \
> diff --git a/systemd/README b/systemd/README
> index bbd7790..1508ea7 100644
> --- a/systemd/README
> +++ b/systemd/README
> @@ -54,9 +54,11 @@ client and systemd cannot specify is two-pronged rever=
se dependency.
>=20=20
>  Distro specific commandline configuration can be provided by
>  installing a script /usr/lib/systemd/scripts/nfs-utils_env.sh
> -This should write /run/sysconfig/nfs-utils based on configuration
> -information such as in /etc/sysconfig/nfs or /etc/defaults/nfs.
> -It is run once by nfs-config.service.
> +It will be provided the environment variable SERVICE with the short
> +name of the service being started, and should write
> +/run/sysconfig/nfs-utils-${SERVICE} based on configuration
> +information such as in /etc/sysconfig/nfs or /etc/defaults/nfs. It
> +is run just prior to starting each service.
>=20=20
>  rpc.gssd and rpc.svcgssd are assumed to be needed if /etc/krb5.keytab
>  is present.
> diff --git a/systemd/nfs-blkmap.service b/systemd/nfs-blkmap.service
> index ddbf4e9..254b005 100644
> --- a/systemd/nfs-blkmap.service
> +++ b/systemd/nfs-blkmap.service
> @@ -10,7 +10,9 @@ PartOf=3Dnfs-utils.service
>  [Service]
>  Type=3Dforking
>  PIDFile=3D/var/run/blkmapd.pid
> -EnvironmentFile=3D-/run/sysconfig/nfs-utils
> +Environment=3D"SERVICE=3Dblkmapd"
> +EnvironmentFile=3D-/run/sysconfig/nfs-utils-blkmapd
> +ExecStartPre=3D-/usr/lib/systemd/scripts/nfs-utils_env.sh
>  ExecStart=3D/usr/sbin/blkmapd $BLKMAPDARGS
>=20=20
>  [Install]
> diff --git a/systemd/nfs-idmapd.service b/systemd/nfs-idmapd.service
> index df3dd9d..f58a58d 100644
> --- a/systemd/nfs-idmapd.service
> +++ b/systemd/nfs-idmapd.service
> @@ -6,10 +6,9 @@ After=3Dvar-lib-nfs-rpc_pipefs.mount local-fs.target
>=20=20
>  BindsTo=3Dnfs-server.service
>=20=20
> -Wants=3Dnfs-config.service
> -After=3Dnfs-config.service
> -
>  [Service]
> -EnvironmentFile=3D-/run/sysconfig/nfs-utils
> +Environment=3D"SERVICE=3Didmapd"
> +EnvironmentFile=3D-/run/sysconfig/nfs-utils-idmapd
>  Type=3Dforking
> +ExecStartPre=3D-/usr/lib/systemd/scripts/nfs-utils_env.sh
>  ExecStart=3D/usr/sbin/rpc.idmapd $RPCIDMAPDARGS
> diff --git a/systemd/nfs-mountd.service b/systemd/nfs-mountd.service
> index 8a39f3e..5392429 100644
> --- a/systemd/nfs-mountd.service
> +++ b/systemd/nfs-mountd.service
> @@ -6,10 +6,9 @@ After=3Dproc-fs-nfsd.mount
>  After=3Dnetwork.target local-fs.target
>  BindsTo=3Dnfs-server.service
>=20=20
> -Wants=3Dnfs-config.service
> -After=3Dnfs-config.service
> -
>  [Service]
> -EnvironmentFile=3D-/run/sysconfig/nfs-utils
> +Environment=3D"SERVICE=3Dmountd"
> +EnvironmentFile=3D-/run/sysconfig/nfs-utils-mountd
>  Type=3Dforking
> +ExecStartPre=3D-/usr/lib/systemd/scripts/nfs-utils_env.sh
>  ExecStart=3D/usr/sbin/rpc.mountd $RPCMOUNTDARGS
> diff --git a/systemd/nfs-server.service b/systemd/nfs-server.service
> index 317e5d6..493e41e 100644
> --- a/systemd/nfs-server.service
> +++ b/systemd/nfs-server.service
> @@ -18,14 +18,13 @@ After=3Drpc-gssd.service gssproxy.service rpc-svcgssd=
.service
>  # start/stop server before/after client
>  Before=3Dremote-fs-pre.target
>=20=20
> -Wants=3Dnfs-config.service
> -After=3Dnfs-config.service
> -
>  [Service]
> -EnvironmentFile=3D-/run/sysconfig/nfs-utils
> +Environment=3D"SERVICE=3Dnfsd"
> +EnvironmentFile=3D-/run/sysconfig/nfs-utils-nfsd
>=20=20
>  Type=3Doneshot
>  RemainAfterExit=3Dyes
> +ExecStartPre=3D-/usr/lib/systemd/scripts/nfs-utils_env.sh
>  ExecStartPre=3D/usr/sbin/exportfs -r
>  ExecStart=3D/usr/sbin/rpc.nfsd $RPCNFSDARGS
>  ExecStop=3D/usr/sbin/rpc.nfsd 0
> diff --git a/systemd/rpc-gssd.service b/systemd/rpc-gssd.service
> index d4a3819..f945661 100644
> --- a/systemd/rpc-gssd.service
> +++ b/systemd/rpc-gssd.service
> @@ -9,11 +9,10 @@ ConditionPathExists=3D/etc/krb5.keytab
>=20=20
>  PartOf=3Dnfs-utils.service
>=20=20
> -Wants=3Dnfs-config.service
> -After=3Dnfs-config.service
> -
>  [Service]
> -EnvironmentFile=3D-/run/sysconfig/nfs-utils
> +Environment=3D"SERVICE=3Dgssd"
> +EnvironmentFile=3D-/run/sysconfig/nfs-utils-gssd
>=20=20
>  Type=3Dforking
> +ExecStartPre=3D-/usr/lib/systemd/scripts/nfs-utils_env.sh
>  ExecStart=3D/usr/sbin/rpc.gssd $GSSDARGS
> diff --git a/systemd/rpc-statd-notify.service b/systemd/rpc-statd-notify.=
service
> index 89ba36c..b33c92e 100644
> --- a/systemd/rpc-statd-notify.service
> +++ b/systemd/rpc-statd-notify.service
> @@ -10,10 +10,9 @@ After=3Dnfs-server.service
>=20=20
>  PartOf=3Dnfs-utils.service
>=20=20
> -Wants=3Dnfs-config.service
> -After=3Dnfs-config.service
> -
>  [Service]
> -EnvironmentFile=3D-/run/sysconfig/nfs-utils
> +Environment=3D"SERVICE=3Dsm-notify"
> +EnvironmentFile=3D-/run/sysconfig/nfs-utils-sm-notify
>  Type=3Dforking
> +ExecStartPre=3D-/usr/lib/systemd/scripts/nfs-utils_env.sh
>  ExecStart=3D-/usr/sbin/sm-notify $SMNOTIFYARGS
> diff --git a/systemd/rpc-statd.service b/systemd/rpc-statd.service
> index f16ea42..1af3bc8 100644
> --- a/systemd/rpc-statd.service
> +++ b/systemd/rpc-statd.service
> @@ -7,11 +7,10 @@ After=3Dnetwork.target nss-lookup.target rpcbind.service
>=20=20
>  PartOf=3Dnfs-utils.service
>=20=20
> -Wants=3Dnfs-config.service
> -After=3Dnfs-config.service
> -
>  [Service]
> -EnvironmentFile=3D-/run/sysconfig/nfs-utils
> +Environment=3D"SERVICE=3Dstatd"
> +EnvironmentFile=3D-/run/sysconfig/nfs-utils-statd
>  Type=3Dforking
>  PIDFile=3D/var/run/rpc.statd.pid
> +ExecStartPre=3D-/usr/lib/systemd/scripts/nfs-utils_env.sh
>  ExecStart=3D/usr/sbin/rpc.statd --no-notify $STATDARGS
> diff --git a/systemd/rpc-svcgssd.service b/systemd/rpc-svcgssd.service
> index 41177b6..ace6ec5 100644
> --- a/systemd/rpc-svcgssd.service
> +++ b/systemd/rpc-svcgssd.service
> @@ -11,10 +11,9 @@ ConditionPathExists=3D|!/run/gssproxy.pid
>  ConditionPathExists=3D|!/proc/net/rpc/use-gss-proxy
>  ConditionPathExists=3D/etc/krb5.keytab
>=20=20
> -Wants=3Dnfs-config.service
> -After=3Dnfs-config.service
> -
>  [Service]
> -EnvironmentFile=3D-/run/sysconfig/nfs-utils
> +Environment=3D"SERVICE=3Dsvcgssd"
> +EnvironmentFile=3D-/run/sysconfig/nfs-utils-svcgssd
>  Type=3Dforking
> +ExecStartPre=3D-/usr/lib/systemd/scripts/nfs-utils_env.sh
>  ExecStart=3D/usr/sbin/rpc.svcgssd $SVCGSSDARGS
> --=20
> 1.7.1
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJW6HfBAAoJEDnsnt1WYoG5vUYP/RAoE4Fd/Xgpp/QUMLRnAJCd
A7wZyF01Kp0y4z7eiVDybDqVX1czhEB5/BAoa+91Y/AqSdd0g5TULAQbzIWB6Aej
LBSSAWMzE//BEloF5qP8yRXyV8k76rtt0i7FIAjhRfHWCUNAmDQarzhxRQVCl2NO
MFuA3xWjaJcLejpnvHFiJWZ9zPCUnM6sp5A8BL0xaKZVkPtTovUTxGEGG6lMJCs2
ShxjYFBM2aA2Ns47wt9pu0rG4+acFo9jMGUGDah4K1kB0+UOQvaqCXpW+w52eksP
r2fFt5tOLBdCCBszDmfag8RxtP6+hMM5aL1e5rGGdq27Wo/HuyS3WZz5afEtYy5s
7Ua4wFlgappih18OXpnevevABsE8PIoBhrwUhRt8seaoQqaFnYYtvfbeCRoUemXA
jt/AtjoeU+q+53gPW5CDLG+1f1AWVRtQNVPhzfeYgF+QU5HUcOW62ZbAsbJHGkgz
eRBYbVs83vt5iuAyq5cK/cSjsfAFdZCs2Sqk2yO2v1zE1aUNHDutuiOBLNXyj32R
57/l/SUci4UsLSDcJLaa/iIwPIsVHge0tJZ9tgLLUWB9XUMYpmpwhi9lAzafVFoh
o7HdZRN2+25Kz56S8MWyNS7m/jnFgsa6IfVTzuuF4YeGmEQla9TL5qzRYEgjx2Ty
I7PDv3LlIaeTwzZNwCj5
=dW/f
-----END PGP SIGNATURE-----
--=-=-=--

From: =?UTF-8?Q?An=C3=ADbal?= Monsalve Salazar <anibal@debian.org>
Subject: Bug#484861: nfs-common: rpc.statd --outgoing-port (-o) option broken
Date: Sun, 5 Oct 2008 15:51:33 +1100
Message-ID: <20081005045133.GZ26991@debianrules.debiancolombia.org>
References: <20080607015302.15770.62792.reportbug@gothic-ave.svl.ibm.com>
Reply-To: =?UTF-8?Q?An=C3=ADbal?= Monsalve Salazar <anibal@debian.org>, 484861@bugs.debian.org
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="0M7E0x35R+W+EAky"
Cc: Richard A Nelson <cowboy@debian.org>, 484861@bugs.debian.org
To: linux-nfs@vger.kernel.org
Return-path: <bounce-debian-bugs-dist=glddb-debian-bugs-dist=m.gmane.org@lists.debian.org>
Resent-Message-ID: <handler.484861.B484861.12231823709462@bugs.debian.org>
In-Reply-To: <20080607015302.15770.62792.reportbug@gothic-ave.svl.ibm.com>
List-Post: <mailto:debian-bugs-dist@lists.debian.org>
List-Help: <mailto:debian-bugs-dist-request@lists.debian.org?subject=help>
List-Subscribe: <mailto:debian-bugs-dist-request@lists.debian.org?subject=subscribe>
List-Unsubscribe: <mailto:debian-bugs-dist-request@lists.debian.org?subject=unsubscribe>
List-ID: <linux-nfs.vger.kernel.org>


--0M7E0x35R+W+EAky
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Sat, Jun 07, 2008 at 01:53:02AM +0000, Richard A Nelson wrote:
>Package: nfs-common
>Version: 1:1.1.2-4
>Severity: important
>
>In a fit of debugging spurious NFS problems I noticed this:
>
># ps auxw | grep statd
>statd     4136  0.0  0.0   2056   652 ?        Ss   Jun06   0:00
>/sbin/rpc.statd --port 32765 --outgoing-port 32766
>
># lsof | grep rpc.statd | grep :
>rpc.statd  4136       statd    5u     IPv4      10388 UDP *:920=20
>rpc.statd  4136       statd    7u     IPv4      10396 UDP *:32765=20
>rpc.statd  4136       statd    8u     IPv4      10399 TCP *:32765 (LISTEN)
>
>changing --outgoing-port to -o didn't help.
>
>This is causing issues with my firewalls

Is this a known bug in 1.1.2?

>-- System Information:
>Debian Release: 4.0
>  APT prefers testing-proposed-updates
>  APT policy: (500, 'testing-proposed-updates'), (500, 'proposed-updates'), (500, 'unstable'), (500, 'testing'), (500, 'stable')
>Architecture: i386 (i686)
>
>Kernel: Linux 2.6.25.3 (SMP w/2 CPU cores)
>Locale: LANG=3Den_US, LC_CTYPE=3Den_US (charmap=3DISO-8859-1)
>Shell: /bin/sh linked to /bin/bash
>
>Versions of packages nfs-common depends on:
>ii  adduser                     3.108        add and remove users and groups
>ii  initscripts                 2.86.ds1-59  Scripts for initializing and shutt
>ii  libc6                       2.7-12       GNU C Library: Shared libraries
>ii  libcomerr2                  1.40.8-2     common error description library
>ii  libevent1                   1.3e-3       An asynchronous event notification
>ii  libgssglue1                 0.1-2        mechanism-switch gssapi library
>ii  libkrb53                    1.6.dfsg.3-2 MIT Kerberos runtime libraries
>ii  libnfsidmap2                0.20-1       An nfs idmapping library
>ii  librpcsecgss3               0.18-1       allows secure rpc communication us
>ii  libwrap0                    7.6.q-15     Wietse Venema's TCP wrappers libra
>ii  lsb-base                    3.2-12       Linux Standard Base 3.2 init scrip
>ii  netbase                     4.32         Basic TCP/IP networking system
>ii  portmap                     6.0-5.1      RPC port mapper
>ii  ucf                         3.007        Update Configuration File: preserv
>
>nfs-common recommends no packages.
>
>-- no debconf information

--0M7E0x35R+W+EAky
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAkjoR9IACgkQgY5NIXPNpFX3cACgnjMPfBQC6U+gBy7Yyno3zejJ
kXgAn3bD37EyAj6Kjo81M6zg89Mu4Bb7
=nK1s
-----END PGP SIGNATURE-----

--0M7E0x35R+W+EAky--

Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vx0-f174.google.com ([209.85.220.174]:64770 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753687Ab1BXT6Q (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 24 Feb 2011 14:58:16 -0500
Date: Thu, 24 Feb 2011 14:57:59 -0500
From: Eric B Munson <emunson@mgebm.net>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: NFS Regression in commit 0b26a0bf6ff398
Message-ID: <20110224195759.GA2784@mgebm.net>
References: <20110216005640.GA2841@mgebm.net>
 <1297818155.10103.43.camel@heimdal.trondhjem.org>
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="T4sUOijqQbZv57TR"
In-Reply-To: <1297818155.10103.43.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

--T4sUOijqQbZv57TR
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, 15 Feb 2011, Trond Myklebust wrote:

> On Tue, 2011-02-15 at 19:56 -0500, Eric B Munson wrote:=20
> > While testing some 2.6.38 work my rsync backup script started consuming
> > large amounts of memory (all available before dying with no more availa=
ble
> > memory).  I have bisected the problem back to 0b26a0bf6ff398.  I am
> > unfamiliar with the NFS code so I don't know where to start looking for=
 a
> > possible fix.  My backups files from my home directory to an NFS mounted
> > directory.  The NFS server is a Synology DS-411+ if it matters.  Let me=
 know
> > if there is any other information I can provide.
>=20
> Exactly which 2.6.38 kernel are you running, and which NFS version?
>=20
> I'm having trouble seeing how the patch in question can be responsible
> for what you are seeing, so please could you provide more details of
> your test setup.
>=20

Trond,

I just updated to 2.6.38-rc6 and I still see the regression.  I will add so=
me
more information here that might be useful.

The entries from ps -ef:

user   3116  3096  0 14:45 pts/4    00:00:00 /bin/bash /home/emunson/bin/bu
user   3117  3116  3 14:45 pts/4    00:00:05 rsync -avz --delete --exclude=
=3D*.
user   3118  3117 26 14:45 pts/4    00:00:41 rsync -avz --delete --exclude=
=3D*.
user   3119  3118  0 14:45 pts/4    00:00:01 rsync -avz --delete --exclude=
=3D*.

strace from 3117:
user@machine:~$ sudo strace -p 3117
Process 3117 attached - interrupt to quit
select(6, [5], [], NULL, {33, 382426})  =3D 0 (Timeout)
select(6, [5], [], NULL, {60, 0})       =3D 0 (Timeout)
select(6, [5], [], NULL, {60, 0})       =3D 0 (Timeout)
select(6, [5], [], NULL, {60, 0})       =3D 0 (Timeout)
select(6, [5], [], NULL, {60, 0}

strace from 3118:
=2E..
lstat("linux-2.6/net/netfilter/xt_dscp.c", {st_mode=3DS_IFREG|0644, st_size=
=3D2890, ...}) =3D 0
lstat("linux-2.6/net/netfilter/xt_dscp.c", {st_mode=3DS_IFREG|0644, st_size=
=3D2890, ...}) =3D 0
lstat("linux-2.6/net/netfilter/xt_dscp.c", {st_mode=3DS_IFREG|0644, st_size=
=3D2890, ...}) =3D 0
lstat("linux-2.6/net/netfilter/xt_dscp.c", {st_mode=3DS_IFREG|0644, st_size=
=3D2890, ...}) =3D 0
lstat("linux-2.6/net/netfilter/xt_dscp.c", {st_mode=3DS_IFREG|0644, st_size=
=3D2890, ...}) =3D 0
lstat("linux-2.6/net/netfilter/xt_dscp.c", {st_mode=3DS_IFREG|0644, st_size=
=3D2890, ...}) =3D 0
lstat("linux-2.6/net/netfilter/xt_dscp.c", {st_mode=3DS_IFREG|0644, st_size=
=3D2890, ...}) =3D 0
lstat("linux-2.6/net/netfilter/xt_dscp.c", {st_mode=3DS_IFREG|0644, st_size=
=3D2890, ...}) =3D 0
=2E..

These stream by very quickly.

and finally from 3119:
user@machine:~$ sudo strace -p 3119
Process 3119 attached - interrupt to quit
select(5, NULL, [4], [4], {15, 621031}) =3D 0 (Timeout)
select(5, NULL, [4], [4], {60, 0})      =3D 0 (Timeout)
select(5, NULL, [4], [4], {60, 0})      =3D 0 (Timeout)
select(5, NULL, [4], [4], {60, 0})      =3D 0 (Timeout)
select(5, NULL, [4], [4], {60, 0}

Now from my /etc/fstab:

/dev/mapper/isw_gbdfddifh_Volume02 /               ext4    errors=3Dremount=
-ro 0 1
/dev/mapper/isw_gbdfddifh_Volume03 none            swap    sw              =
  0 0

#NFS
192.168.1.50:/volume1/backup    /mnt/backup     nfs     rsize=3D1048576,wsi=
ze=3D1048576,user        0 0
192.168.1.50:/volume1/data      /mnt/data       nfs     rsize=3D1048576,wsi=
ze=3D1048576,user        0 0
192.168.1.50:/volume1/music     /mp3            nfs     rsize=3D1048576,wsi=
ze=3D1048576,user        0 0
192.168.1.50:/volume1/video     /video          nfs     rsize=3D1048576,wsi=
ze=3D1048576,user        0 0

The backup script is reading from my home dir (locally mounted on partition=
 2 of a
fake raid stripe).  And writing to /mnt/backup/bert-ubuntu.

And here is the error I get when rsync finally dies:

ERROR: out of memory in flist_expand [generator]
rsync error: error allocating core memory buffers (code 22) at util.c(117) =
[generator=3D3.0.7]
rsync: connection unexpectedly closed (9324 bytes received so far) [sender]
rsync error: error in rsync protocol data stream (code 12) at io.c(601) [se=
nder=3D3.0.7]

At the point when this happens, rsync is consuming almost all of the free m=
emory on the system.

I am nost sure if there is anything else that might help, please let me kno=
w if you need more
information.

--T4sUOijqQbZv57TR
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQEcBAEBAgAGBQJNZrhHAAoJEH65iIruGRnN8XYH/jjGUx5Xr2TH4XWwrUNkx0OH
3KW9QEfxSp5Cp/1sY5HXNi2+51xcKpKuNdjKwFrAqs+kId7lCaURftLGuoomcUga
zModHveWPgeQJvCZ3kzJxUDni5R0xYNC+D83zPg56ubiu7b1HbPDDTRCXJNTN4Op
2s2x0RVkeifa18okbxHAvfaAifrsxUorXcuVWDlmST3FrHZB98vlE8cJ9Sb89p5C
nkaVkBU8O2chTaObiICpZMXboTWm4T23zRlxntE0HwpcpXdabkvtITTbMbMw3jBR
n+EnWJfxFAhdIJcj0gVjHca376lN6vJst0PCmzIjNtaa7g5YWdvFa4NguFOO8Ow=
=XEIu
-----END PGP SIGNATURE-----

--T4sUOijqQbZv57TR--

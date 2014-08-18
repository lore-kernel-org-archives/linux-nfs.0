Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp.gentoo.org ([140.211.166.183]:47418 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752272AbaHRX5u (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 18 Aug 2014 19:57:50 -0400
From: Mike Frysinger <vapier@gentoo.org>
To: Steve Dickson <SteveD@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH nfs-utils] start-statd: clean up output when systemd is not installed
Date: Mon, 18 Aug 2014 19:57:49 -0400
Message-ID: <1649346.61nAovKFdn@vapier>
In-Reply-To: <53F23223.5090904@RedHat.com>
References: <1408286648-19031-1-git-send-email-vapier@gentoo.org> <53F23223.5090904@RedHat.com>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="nextPart3009493.oXO231ee2i"; micalg="pgp-sha1"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--nextPart3009493.oXO231ee2i
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain; charset="us-ascii"

On Mon 18 Aug 2014 13:04:35 Steve Dickson wrote:
> On 08/17/2014 10:44 AM, Mike Frysinger wrote:
> > If you don't have systemd, then this script dumps:
> > /usr/sbin/start-statd: line 8: systemctl: command not found
> >=20
> > This isn't terribly useful since we ultimately fall back to running=

> > the daemon ourselves, so probe for systemd's existence before we tr=
y
> > to use it.
> >=20
> > Signed-off-by: Mike Frysinger <vapier@gentoo.org>
>=20
> Committed... but I used 'rpm -q systemd' instead of 'systemctl --help=
'
> to test for the existences of systemd
>=20
>  # First try systemd if it's installed.
> -if systemctl --help >/dev/null 2>&1; then
> +if rpm -q systemd > /dev/null 2>&1; then
>      # Quit only if the call worked.
>      systemctl start rpc-statd.service && exit

what about all the other distros not using rpm ?  my version was distro=
=20
agnostic.
=2Dmike
--nextPart3009493.oXO231ee2i
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part.
Content-Transfer-Encoding: 7Bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABAgAGBQJT8pL9AAoJEEFjO5/oN/WBZKkP/1GlM1bHRMCgEx+G2cnRh7MY
zVWgVrMv6rfbyURQnNQhDCZ8bCnEbimbS6noTEqXzlYEwS48cMpE5PohvLn1KuOd
JtlT67RqUkmePs/TIbKadmwP8DDLmVV2TEtPEtrin80kIosc2hkJyDa9XT/0z1MN
L2imrU/4Mr3w1+Jn7nvqMTTTl/HB/Yt9qni7HVmZmP5Y0+7gsmsFMdibK2Z4sa8f
lpyXuz4AA8bwft+8a8jL/SCzVjv+MrfEEQZ4H53KOdImCbK31JXQVMsUWv+AbctG
alVO3VheBmKqt1oeZe8ehFAqXPkRHYjdcJ0AB880nt3pbklbNj5EF6pDK9Y4tBAZ
yQD+6l2XM7HG9P/m2yZ9O3TbgmMjetjD6j5F0JHB0iBIyUAR9mNMtmXXLKl6sH74
wQva78Z2o+QLlVjrvtHxLwE3GUw6ML71TGu0QneLWplCy/mJUS/aMOfWSN/BUrOc
84HpK/jldzQChDlSZbavk7MoNe/9GBtXXI3sVz4Ji707KzVQ8JFjL+ZtRMWhQMHz
DOt6Yx3fy7TkapfiK4NEnWFHmG1qaorIOj2DuezPSDXiaAyZn6vU5gS8HWjrhW+2
FdmbOvX4eZhbd5ErZIuKVVbWxxmB9DOHPWhZv54L4IsZXqHMQqeEZ7GB48q9vVV+
LYA1SnTUEe6DnicNTNcG
=QfHu
-----END PGP SIGNATURE-----

--nextPart3009493.oXO231ee2i--


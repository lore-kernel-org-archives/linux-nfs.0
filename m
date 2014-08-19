Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:41420 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752351AbaHSBGO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 18 Aug 2014 21:06:14 -0400
Date: Tue, 19 Aug 2014 11:06:03 +1000
From: NeilBrown <neilb@suse.de>
To: Mike Frysinger <vapier@gentoo.org>
Cc: Steve Dickson <SteveD@redhat.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH nfs-utils] start-statd: clean up output when systemd is
 not installed
Message-ID: <20140819110603.38b92ecb@notabene.brown>
In-Reply-To: <1649346.61nAovKFdn@vapier>
References: <1408286648-19031-1-git-send-email-vapier@gentoo.org>
	<53F23223.5090904@RedHat.com>
	<1649346.61nAovKFdn@vapier>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 boundary="Sig_/VsO=T5UbBCxC_Wf3odY39vE"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/VsO=T5UbBCxC_Wf3odY39vE
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Mon, 18 Aug 2014 19:57:49 -0400 Mike Frysinger <vapier@gentoo.org> wrote:

> On Mon 18 Aug 2014 13:04:35 Steve Dickson wrote:
> > On 08/17/2014 10:44 AM, Mike Frysinger wrote:
> > > If you don't have systemd, then this script dumps:
> > > /usr/sbin/start-statd: line 8: systemctl: command not found
> > >=20
> > > This isn't terribly useful since we ultimately fall back to running
> > > the daemon ourselves, so probe for systemd's existence before we try
> > > to use it.
> > >=20
> > > Signed-off-by: Mike Frysinger <vapier@gentoo.org>
> >=20
> > Committed... but I used 'rpm -q systemd' instead of 'systemctl --help'
> > to test for the existences of systemd
> >=20
> >  # First try systemd if it's installed.
> > -if systemctl --help >/dev/null 2>&1; then
> > +if rpm -q systemd > /dev/null 2>&1; then
> >      # Quit only if the call worked.
> >      systemctl start rpc-statd.service && exit
>=20
> what about all the other distros not using rpm ?  my version was distro=20
> agnostic.
> -mike

distro-agnotic is certainly important.
I would have gone with:

diff --git a/utils/statd/start-statd b/utils/statd/start-statd
index dcdaf7763f18..414f73f58096 100644
--- a/utils/statd/start-statd
+++ b/utils/statd/start-statd
@@ -5,7 +5,7 @@
 # It should run statd with whatever flags are apropriate for this
 # site.
 PATH=3D"/sbin:/usr/sbin:/bin:/usr/bin"
-if systemctl start rpc-statd.service
+if systemctl start rpc-statd.service > /dev/null 2>&1
 then :
 else
     exec rpc.statd --no-notify


why call systemctl twice (once with --help and once with "start")?

NeilBrown

--Sig_/VsO=T5UbBCxC_Wf3odY39vE
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBU/Ki+znsnt1WYoG5AQJLpQ/9F2ZVeiLG7y3rMGmY78D0xxhWwafg0qqU
7qJgK6mYYTOXgw6LOuCCIKBuXQgBRJGMbKPVaQt3Qk31UAqCxQGA1a4K2S4K3FNY
W7cDDS1sKTEA3Pg8ImKevJlukF019MLHsSuTgA1+mfyQoW1xCZvp833f1U8Td6iQ
TjHKEmZ1+XbYLr3CF0VAhQKegR2S7GBwuTOjs/MpqSKXPib+DT3Q01AuPapZHn4q
5aFVsBYUu9wzjDJz40s0pl0OQjYhgW1kBvoJyf8Upqw+DKabSXW75TbCqOmUAKOo
/+mj6iTaXb+WnIikXTDYDAhb/Gs4FaRhavUWWAwQkMrU6zFn7sQrbYUtht+ToRcd
ehxomTXWZfo3UzprJJWCKK/znhRZFGP9rjIwvLgiiNC40+969a6CnBpPhSVQkTrg
cPjLw2s/0EkooU5H9ZA35lsUpwm6chhjQ/dBK55wyGzNUhSHM2oHRlDEuo4KS7iN
zBbr4MMX6HjFgo4jBmmqxG8FWFxpSVVUOYkWax6MpxbaaMOO8QRn1f/8L+rTyDtT
PVdWxBw4zPefKbdEbdO/plNSUl9prD+JXxiqBiLQot+2/6GlX995dhI/wWsCyyLV
7Ig/LCSpSdMrQ3sdu+el/7RSQdW1Eh8I+oN0RRO3Be1DVxN48KBaj7POifXosQFB
2Ne34AD704I=
=a511
-----END PGP SIGNATURE-----

--Sig_/VsO=T5UbBCxC_Wf3odY39vE--

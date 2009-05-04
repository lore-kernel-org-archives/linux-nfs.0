From: Mike Frysinger <vapier@gentoo.org>
Subject: Re: [patch] use ioctl.h instead of ttycom.h on Linux
Date: Mon, 4 May 2009 19:15:48 -0400
Message-ID: <200905041915.49624.vapier@gentoo.org>
References: <20090503105829.GS15802@pengutronix.de>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1330946.szBJLQ71pu";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Cc: linux-nfs@vger.kernel.org, crossdev-iOHc7L4DgpLFDiOEh+KS6A@public.gmane.org
To: Robert Schwebel <r.schwebel@pengutronix.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:34631 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753177AbZEDXPu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 4 May 2009 19:15:50 -0400
In-Reply-To: <20090503105829.GS15802@pengutronix.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--nextPart1330946.szBJLQ71pu
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

On Sunday 03 May 2009 06:58:29 Robert Schwebel wrote:
> When compiling nfs-utils-1.1.6, I get this error:
>
> arm-iwmmx-linux-gnueabi-gcc -DHAVE_CONFIG_H -I. -I../../support/include
> -isystem
> /home/rsc/svn/oselas/bsp/OSELAS.BSP-Pengutronix-AllYes-trunk/platform-phyCO
>RE-PXA270.PCM990/sysroot-target/include -isystem
> /home/rsc/svn/oselas/bsp/OSELAS.BSP-Pengutronix-AllYes-trunk/platform-phyCO
>RE-PXA270.PCM990/sysroot-target/usr/include -D_GNU_SOURCE -Wall
> -Wstrict-prototypes  -pipe -g -O2 -MT sm_inter_svc.o -MD -MP -MF
> .deps/sm_inter_svc.Tpo -c -o sm_inter_svc.o sm_inter_svc.c
> sm_inter_svc.c:10:39: error: sys/ttycom.h: No such file or directory
>
> Use sys/ioctl.h instead.

ive posted a patch or two to fix this, but cant seem to get it merged ...

i.e. your change is of course correct
-mike

--nextPart1330946.szBJLQ71pu
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.11 (GNU/Linux)

iQIcBAABAgAGBQJJ/3clAAoJEEFjO5/oN/WBWQsP/i22KNQEi406qk2HTejTVvgw
bfEyg7lZGy026Lw9STZ/+ngVN0KrNGqMfgjxp9nj66g5CFEe20MLhbuIVgw01Sns
gmYk4KnIAiMVELTje95pfnFLRl8bVBsrQw8p4AcOC50m4PlpRpDTrrJ7CY6r4eZp
D/8hgVi/Q+pIZaiLY2ZT5XPOTnQoTFcRUKTli29FN/DjW12kj0XhoW5HTXrF6TEF
D0lKQnSsN8r3PjOYREmhrgo6QL32nOCWnlBRwbI2W1NkhLIR2GX230+EacFJHbJo
NJLpfGjeMVSYzhClSlQeJfb0MUD7TlvluAE6TZ4L6r1tc9P1/efZ1gWdTa+6CHXZ
Fl2VBm3VH+HzxqwIfmbaNnmpFIBQMJl+qsdBYZJO0Wvn0XnfHZ4rnCmD0iNSokhH
hfLJKdRKT9fod3tYSTiMh7m4vXks7OW1bzaHnx1CwCLHpEK0MuviDgQJj9aRD65f
aBM2TcnbmxgsE/IdGG0ckqq1o1gZ2ENFLtwzvWofMw3mk+CWhu19a1wXFBkCmWdz
7uQyx27R1EYWWQ/cZAYLBOrzOe4Rgb32iTOFhnX2uhWvcByxX59IIzVl0WzzOwX2
5aOfiBaRIjunY2tujtsRvorAQWbfC8DZ2CvxoTu+nxcI7aQPeK6+TG3Yi06OYZT7
d0XXjK3Ua30jZRliRmeZ
=W03n
-----END PGP SIGNATURE-----

--nextPart1330946.szBJLQ71pu--

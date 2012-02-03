Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:47665 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754678Ab2BCMQj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 3 Feb 2012 07:16:39 -0500
Date: Fri, 3 Feb 2012 23:16:23 +1100
From: NeilBrown <neilb@suse.de>
To: Boaz Harrosh <bharrosh@panasas.com>
Cc: Malahal Naineni <malahal@us.ibm.com>, <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] Check for beginning '/' in the mount path
Message-ID: <20120203231623.442fefde@notabene.brown>
In-Reply-To: <4F2BC1C0.8070900@panasas.com>
References: <1328233332-26020-1-git-send-email-malahal@us.ibm.com>
	<4F2BC1C0.8070900@panasas.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/MElIXeycWSCDrtDblJ7EDaO"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/MElIXeycWSCDrtDblJ7EDaO
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Fri, 3 Feb 2012 13:15:12 +0200 Boaz Harrosh <bharrosh@panasas.com> wrote:

> On 02/03/2012 03:42 AM, Malahal Naineni wrote:
> > NFSv4 gladly accepts and mounts "hostname:path" instead of
> > "hostname:/path". This causes mount entry mistmatch between /etc/mtab
> > and /proc/mounts files. The former will have "hostname:path" but the
> > latter will have "hostname:/path". This causes umount not work at all.
> >=20
>=20
> NACK
>=20
> like it or not you are changing ABI. Bunch of systems will not work now.
>=20
> Also some other NFS servers/clients support it fine. Actually some servers
> make it a special case. (It's called mount by tag)
>=20
> The bug is else where fix it there. Either add the preceding '/' to
> /etc/mtab or remove it from /proc/mounts (I prefer the later). Or
                                            ^^^^^^^^^^^^^^^^^^
> fix umount to work with that case.

Agreed.  And while we are at it we should remove the trailing '/' too.
If you
  mount host:/path /somewhere
/proc/mounts will show
    host:/path/

which also confused mount.

NeilBrown


--Sig_/MElIXeycWSCDrtDblJ7EDaO
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.18 (GNU/Linux)

iQIVAwUBTyvQFznsnt1WYoG5AQI/WRAAqKbnQYoh6WnhfZyz2dDNWlaKvoDDLGtX
9cVenAW+CM88TFbQmEmjv6ojx7nmfJA3fMzUHzvgMmwzdmuhRptBuTPByNF2P3JJ
l5mF6BhYr2xw2aSAWs7o/1qIgSoReCNT33B+5+ILpjy52ZnvVMfLoEm2FEbrsIio
0EmPv8hsfUdB1zMOrIVVmkpm4gwfQKIGfSWGI/fq3DrHmc090Kx7KvN4ITA6eADN
NOWIiGIK3YuiLANUablBSIXXKPPlOLiQWMDpGzMnESnNQpCH1ubOF7UPoB15gFBy
1Q4fgdosWH8wWiG6ZlIBTdTJ1yAonypdssWGCsu431tJjvckwJAOVhheoRktV+bp
BjsCFZ48NJSDul+APxDxYCetR4lzCDVK2NHgViVr7FjP2GB5Q3aNW11y7bfXhm7W
mXQ9Kcz4s65m8JJ+KUFOh7SjJybCj0jncyeqU9J3c4gCTWXRku5czAbbqIMOISpN
hfn0nPAPR7ZXY0XF/021pTb9T+545yP6GXzkp0nXIsT+h8/XmQMhJ4ZyM1BXGhGv
pbiVVDDLM7o+s/L1/k1eFUQ17yvXwss7EhB4vmHpHCxpNEV5TdcrpYuE4RbbZ9S5
i7XpKzQYrOc4FCl72EFvz+LpbKZCyUdxDtwitXU89eq+F4okbc9cOCPZiDIZDAHY
KSitzQUbmmw=
=2D+J
-----END PGP SIGNATURE-----

--Sig_/MElIXeycWSCDrtDblJ7EDaO--

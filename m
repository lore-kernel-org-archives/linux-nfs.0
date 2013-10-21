Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:59713 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752490Ab3JUFF0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 21 Oct 2013 01:05:26 -0400
Date: Mon, 21 Oct 2013 16:05:14 +1100
From: NeilBrown <neilb@suse.de>
To: Bryan Schumaker <bjschuma@netapp.com>
Cc: NFS <linux-nfs@vger.kernel.org>
Subject: What is the long term fix for the idmapper key-quota problem.
Message-ID: <20131021160514.4dbcbf12@notabene.brown>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/PagMYJ6tXqHORFay5AxqAAC"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/PagMYJ6tXqHORFay5AxqAAC
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable


Hi,
 as you probably know, request_key() imposes a quota on
the number of keys that can be requested, which by default is quite low (20=
0).
When idmap exceeds this quota, request_key() returns an error and
the result is userspace sees "nobody" as the owner.

A short term fix is to fiddle some sysctl values, but I wonder if any long
term fix is being planned.

Probably the sensible thing would be for nfs-idmap to bypass the quota.
As keys are not held active for very long at a time, they should be garbage
collected in due course.
There is currently no interface to request this but I suspect one could be
added.

(I want to fixed this for openSUSE-13.1, and don't want to diverge too far
from mainline).

Thanks,
NeilBrown

--Sig_/PagMYJ6tXqHORFay5AxqAAC
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQIVAwUBUmS2Cjnsnt1WYoG5AQKtbQ/9HmQ9S53CrZYNun0bDwkHKNb/1SB0zGJD
kOvLmyMsqmlOWjlVdT6F7jRobGb66GSXb7H+1F+D9Y/DyLWnAwdDJ+FhfTalcRsS
9+fExDBh3cJ+W20f+Fkt34Zgb+9fYOg9e/muOLR/Aje1yyLmkkv0j8OWMxkd2WrM
S9mh/k8D2On/x8DMVcqfa8AhozhdOeisoP2LvMd5Jc/f9GuBl1XQ0VE7JH/6kzvI
rfSSLtB8XCPqCze1Br9epizMTNEgVMXYu0USesR9R1qbf4cGQJ8qq+q1RNpzM/56
MLJVgilSsSPZv/IDo2YmVRWUaCrA4hUiGorBqarSHVa2BylT4uKgz46hPPsAyyWi
m56B0cRoUVdDS9c6e/3bADTgUHFwuefYm4ao12GFsJzsJJa5fwlPP+KchggRvbV4
Nwi7hEDUO0He+h5XbyY4levBmYeExXtZQfxcNMuHo0zVfDmyTo0OXjvczAO7L1oh
b6OTiyhD6PKmwPaVMvMHBNourKPfMjkWU40bfhZjkPB/cx5h5me6garMgu6rd0Zf
jFjQncDuQ72Dqw4oH234hbewYRhHd2Kc4WZPSXRYYkGptpVpv4aCzjGEUGBhW3fr
QNqxeYoZ+bpvdbYWoztKerPC5p0gX8KNlK7idfEuuSE1IW0SIN8qlJOmt+lAZCDv
RnCX2jCcZcw=
=9vMo
-----END PGP SIGNATURE-----

--Sig_/PagMYJ6tXqHORFay5AxqAAC--

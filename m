Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:47005 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932087Ab2IRBzC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 17 Sep 2012 21:55:02 -0400
Received: from relay1.suse.de (unknown [195.135.220.254])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx2.suse.de (Postfix) with ESMTP id 9FB82A2FD7
	for <linux-nfs@vger.kernel.org>; Tue, 18 Sep 2012 03:55:01 +0200 (CEST)
Date: Tue, 18 Sep 2012 11:54:50 +1000
From: NeilBrown <neilb@suse.de>
To: NFS <linux-nfs@vger.kernel.org>
Subject: Should "mount -o proto=udp" be usable against an IPv6 only server?
Message-ID: <20120918115450.5c65973f@notabene.brown>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/DRKTZPHBFHoQ=G/uJi./ZH0"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/DRKTZPHBFHoQ=G/uJi./ZH0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable



It seems that with current nfs-utils, "proto=3Dudp" (either
in /etc/nfsmount.conf or on the command line) restricts the mount to using
IPv4, not IPv6.
For IPv6 you need "udp6".

This isn't made crystal clear by the documentation.  I could fix the
documentation, but first I wanted to check if this really is appropriate.
Is there a good reason for this, or should we make "udp" mean "udp4 or udp6"
and require either "udp4" or "udp6" if we want a particular IP version.

i.e. instead of treating the "proto=3D" value as a "netid", should we treat=
 it
as a "protoname" and match any "netid" in /etc/netconfig with that
"protoname"??

Thanks,
NeilBrown=20

--Sig_/DRKTZPHBFHoQ=G/uJi./ZH0
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.18 (GNU/Linux)

iQIVAwUBUFfUajnsnt1WYoG5AQINTA/9FAQygy/hWipp4CoyCR+hL6JOzmUuvrZx
qs3UVGXcsNH0QxP9Gq3DC4RnoAgfWYeecfxDh/uE88cNADv2E0LYlFpKP3TCNi4W
8Q7lKaOuC01wa6ynePsy3DAo2rqZmgmNGwL51ox0FjHMAvRAsQIDn9qt2LjJepxt
l1fMp0q2NIK9c7mwVPvVwJeSdUJpVXOuJdoDnY+L5N+9O3uAhKJ4RsVb5e8v6mHR
NL1lqRksaJkXGDwra5uIw0J+joUqmNlR/EQM1ZCaojYNWLGKknDgZeD+AtKvOVM6
kGv1ZtSIOf61pi0nCMTg+FYnwL4qwc5NN3uRvbzDd2fohOGpiYHjEwS1ePqVtv82
76B/ztG+IVQYXd5AfQV7GkSIbatbPqAG270mX2BsOxu9xUhSxh39o6LxImCr0Umz
AG32BlOyZxe0lVNHi4HdXWTZVOwRMCB5jtpV0zrH578AUTXqY7YPv4QH4QbH6tb3
kuZKty1eDXw7Mazh0h+m/Xad89ruKwyqtIFe2kOPYNgfWXr4ARZhviOkDkf+gvnG
Rvmb23OF5z/tLEakzyXmnuLXxOnUgCdvtz824/FsdHSp6Nz7+M05ugkJyFEN0OAQ
Gdld0r2phJqwfOOOoaxhJg5DB1EeR7F59IdXZPih0XK1EmaLORHg4q833XFERtHW
uM7FG+1ZYmk=
=VRue
-----END PGP SIGNATURE-----

--Sig_/DRKTZPHBFHoQ=G/uJi./ZH0--

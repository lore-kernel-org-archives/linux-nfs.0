Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:56617 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752101AbcDSXNW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 19 Apr 2016 19:13:22 -0400
From: NeilBrown <neilb@suse.com>
To: Trond Myklebust <trondmy@primarydata.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Thomas Haynes <loghyr@primarydata.com>
Date: Wed, 20 Apr 2016 09:13:09 +1000
Cc: "linux-nfs\@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: AUTH_NONE at top of SECINFO_NONAME reply.
In-Reply-To: <BCC7DC72-7B38-47C1-A26F-C52349EFD5C6@primarydata.com>
References: <87k2k1jd8d.fsf@notabene.neil.brown.name> <20160418182633.GA3193@fieldses.org> <871t61i96f.fsf@notabene.neil.brown.name> <BCC7DC72-7B38-47C1-A26F-C52349EFD5C6@primarydata.com>
Message-ID: <87fuuhyyyi.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
	micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain

On Wed, Apr 20 2016, Trond Myklebust <trondmy@primarydata.com> wrote:

> On 4/19/16, 17:24, "NeilBrown" <linux-nfs-owner@vger.kernel.org on behalf of neilb@suse.com> wrote:
>
>>I wonder if "none" means "no authentication needed" or "no access
>>given".
>
> A certain thomas@netapp.com explained the behaviour thus:
>
>  https://www.ietf.org/mail-archive/web/nfsv4/current/msg09743.html
>

Ahhh, cool.  Thanks!

NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJXFruHAAoJEDnsnt1WYoG5PXEP/iW30TdfM09Kfb/MLj8sMO3g
FSYVe10ISLnLZ6wXgJwFL9QjFCvhYm9VEtU9ka+oBarrj5qNqSPYFWyb1Q7xfoL8
KD2wS9VFknXZqJN2bp8Ayy7s78Ey+f1cCii3I6UtnkHplSNI5sDyMH12Y+/9vnWM
gq4wvxpwX4YYk7u/dLhMdztAVHKbXukni/elIEsmrLD6nj1CiuLcZWyZJ2DuVY9u
Jm+XPxePuK4erFLHZVLXCMp7fmP1WLJC+BXKh/poOyrfOrjpBL24zFSe43fqrAFV
p2KBtx/udNebVwg6e03kQbqm/RiPrEydx7qM31givDTnz0x+p6x+vWVzKXgbdbE6
ad6Ew7/mqcFX/TG3oXsVVLI0lum2ZDFP/kegnkQh/TT+VmD78MQ+HTXLgYW4aho/
VMkU7jakoxyyKr6FYROEfkfjeqZtGzaf/H/e4Kp8/TvXf/HBgCM+ZuHJtgueyV6s
n99SDgfIsaMBCU+F+LRhnTew/fqjsYbDMERHcl8kCWKTcwQ49ofKYnLq2m1uEHn6
pF43i9eJqVQMUD0dRxydrI70rp8YQUhFhlpwLtKkvObY/NtnO7OLtwK+jL3KjYqx
yQSFjczfAeoCuJjql48Syp2nirmL1huPaHeDsjMuHBJjjD2rytWcvul8p4uLH72W
A03q5OxK8GpzOYZUSVKv
=/kCy
-----END PGP SIGNATURE-----
--=-=-=--

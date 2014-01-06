Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:59149 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751718AbaAFBpo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 5 Jan 2014 20:45:44 -0500
Date: Sun, 5 Jan 2014 20:45:16 -0500
From: Jeff Layton <jlayton@redhat.com>
To: NeilBrown <neilb@suse.de>
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org,
        simo@redhat.com
Subject: Re: [RFC PATCH 1/5] sunrpc: don't wait for write before allowing
 reads from use-gss-proxy file
Message-ID: <20140105204516.51aa31ad@corrin.poochiereds.net>
In-Reply-To: <20140106093744.14fc3670@notabene.brown>
References: <1388579314-15255-1-git-send-email-jlayton@redhat.com>
	<1388579314-15255-2-git-send-email-jlayton@redhat.com>
	<20140102212149.GC28219@fieldses.org>
	<20140106093744.14fc3670@notabene.brown>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/pA.4Q8OHykHIAI/pJyKTYCf"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/pA.4Q8OHykHIAI/pJyKTYCf
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Mon, 6 Jan 2014 09:37:44 +1100
NeilBrown <neilb@suse.de> wrote:

> On Thu, 2 Jan 2014 16:21:50 -0500 "J. Bruce Fields" <bfields@fieldses.org>
> wrote:
>=20
> > On Wed, Jan 01, 2014 at 07:28:30AM -0500, Jeff Layton wrote:
> > > It doesn't make much sense to make reads from this procfile hang. As
> > > far as I can tell, only gssproxy itself will open this file and it
> > > never reads from it. Change it to just give the present setting of
> > > sn->use_gss_proxy without waiting for anything.
> >=20
> > I think my *only* reason for doing this was to give a simple way to wait
> > for gss-proxy to start (just wait for a read to return).
> >=20
> > As long as gss-proxy has some way to say "I'm up and running", and as
> > long as that comes after writing to use-gss-proxy, we're fine.
> >=20
>=20
>=20
> Only tangentially related to the above email .....
>=20
> I had a look at this new-fangled gssproxy thing and while it mostly seems
> like a good idea, I find the hard-coding of "/var/run/gssproxy.sock" in t=
he
> kernel source .... disturbing.
> You never know when some user-space might want to change that - maybe to
> "/run/gssproxy.sock" (unlikely I know - but possible).
>=20
> Probably the easiest would be to hand the path to the kernel.
>=20
> e.g. instead  of writing '1' to "use-gss-proxy", we could=20
>   echo /my/path/gss-proxy-sock > /proc/net/rpc/use-gss-proxy
>=20
> Then you could even use an 'abstract' socket name if you wanted. i.e. one
> starting with a nul and which doesn't exist anywhere in the filesystem.
> I would feel a lot more comfortable with that than with the current
> hard-coding.
>=20

I like that idea -- particularly if you keep the legacy behavior that
writing a '1' to the file makes it default to /var/run/gssproxy.sock so
we don't break compatability with older gssproxy releases.

--=20
Jeff Layton <jlayton@redhat.com>

--Sig_/pA.4Q8OHykHIAI/pJyKTYCf
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAEBAgAGBQJSygq9AAoJEAAOaEEZVoIVAAgP/ihq7yCPPySQssqHGVXvQyn+
gs8tfu87bddhUH4d7WGAM0qFms1XOodrmInkjhXiFKB/nbc/UFPE2kr53u+TmG9s
LMLVIUCCE8pVZXGw2uYwO8eDGwiHGBx5tsAoQizJWAeXwiGmZCMerngJ7B+/m/jU
vmZu+PyoF5zPuL/vrNQGwF8hrgyfL70MHVuxg8M/r55MDL/oeJiaN4SonpsvK36x
L/0lj/g7+XErj42z6l9SOGTxg1wlCvS64p8fuWgIcexnM6yQal4wwQm/ygRAHPAd
tztP4O7b8eNuUTVOJqpF2MHWQStIjtOE6P12qWmrZrZ5ubpAkxLDZMsnoHd3FqA1
60Z0WOwle6ndR3gx+W44avM4nrx3YyV0JhCLMCRCjfAcs4EkD3CgHSX9JpQ5Es/v
JmI45GURAPOcjZ78PI5EP0AoHolwDEELASWpnr2QmqaGlcS1X+gEI4teeyJqAAXS
crf7bA3TTLxtKJf6JECqqIBq5AuPHwTStLS7kH/ypOqxT6/45YwAqkYfL3r3bSK3
m5q0dcdoXkjIvD4A/DJEBkwSX5e7A+relt6gXMvxLvnSfknXuVS4oQtGDPVH/vKR
Q23S176u8GQ+EOICeQWqM4JxWppdXVcWDmtwiyLLQ7AHgILHb1ePF9GhFAATW9Up
4np1wKY4JURCDv4PqlRK
=FbRD
-----END PGP SIGNATURE-----

--Sig_/pA.4Q8OHykHIAI/pJyKTYCf--

Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:58083 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751335AbaAEWh4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 5 Jan 2014 17:37:56 -0500
Date: Mon, 6 Jan 2014 09:37:44 +1100
From: NeilBrown <neilb@suse.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Jeff Layton <jlayton@redhat.com>, linux-nfs@vger.kernel.org,
        simo@redhat.com
Subject: Re: [RFC PATCH 1/5] sunrpc: don't wait for write before allowing
 reads from use-gss-proxy file
Message-ID: <20140106093744.14fc3670@notabene.brown>
In-Reply-To: <20140102212149.GC28219@fieldses.org>
References: <1388579314-15255-1-git-send-email-jlayton@redhat.com>
	<1388579314-15255-2-git-send-email-jlayton@redhat.com>
	<20140102212149.GC28219@fieldses.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/6FKDWned7+W/iX2T=3wIz=S"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/6FKDWned7+W/iX2T=3wIz=S
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Thu, 2 Jan 2014 16:21:50 -0500 "J. Bruce Fields" <bfields@fieldses.org>
wrote:

> On Wed, Jan 01, 2014 at 07:28:30AM -0500, Jeff Layton wrote:
> > It doesn't make much sense to make reads from this procfile hang. As
> > far as I can tell, only gssproxy itself will open this file and it
> > never reads from it. Change it to just give the present setting of
> > sn->use_gss_proxy without waiting for anything.
>=20
> I think my *only* reason for doing this was to give a simple way to wait
> for gss-proxy to start (just wait for a read to return).
>=20
> As long as gss-proxy has some way to say "I'm up and running", and as
> long as that comes after writing to use-gss-proxy, we're fine.
>=20


Only tangentially related to the above email .....

I had a look at this new-fangled gssproxy thing and while it mostly seems
like a good idea, I find the hard-coding of "/var/run/gssproxy.sock" in the
kernel source .... disturbing.
You never know when some user-space might want to change that - maybe to
"/run/gssproxy.sock" (unlikely I know - but possible).

Probably the easiest would be to hand the path to the kernel.

e.g. instead  of writing '1' to "use-gss-proxy", we could=20
  echo /my/path/gss-proxy-sock > /proc/net/rpc/use-gss-proxy

Then you could even use an 'abstract' socket name if you wanted. i.e. one
starting with a nul and which doesn't exist anywhere in the filesystem.
I would feel a lot more comfortable with that than with the current
hard-coding.

NeilBrown

--Sig_/6FKDWned7+W/iX2T=3wIz=S
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBUsneuDnsnt1WYoG5AQKnAg/7B/P4J1lkaWVEUvxAfi0As6iZl879Lwyi
N4RFb5+PGZsWrsrweHF0/tiO92Odp13WyCK3q2jrqgYVy8ITJo5fNTGG0bCb2YPF
2GZTQKwfTEibogo+gGjSNmEO4AUtM9J1K+OaxJ9JQQbCrubNFoYUkUxIgKJSBWkw
OdvuMh3k0XWRtVC+SkSdfE1aRS4bABakRFvhBpuc4KEYoPXtNZA2eIHO3TaSxUtw
6HVChX6elzq9tOzPgDpEhigLwb2zO9/bHd5nxwDsw/Wk7YceqvheUopeV+pdp/KT
fREC2ACqBBUNVOOdN7FtBIP9DQlgRlTJm2eaDZvd4sWvQp/+jPt29OHST8v/wYc2
rlLhEZPUWjvub5QZOZlGXh8/p6TH3eV7+Un1i0AdLIqtc/z6H3sYzZN3tJC/PN33
AGOTC/AokCGp0oqQiLWDQcwiR5tQRQB4J7qBOgnP8lHCUZmag004YBpf9F+QiafX
GCLWFHtVqo71zjOQyNX/LtCIbl8Wo8mYyv8fmsdQMleuz/c5YlklaZVNtKZTIizt
1c5Ne+p7Q2+ttUPML+0CgO2OQI2weVJxafE0mJfNZgFnsX1g8p3nXIXGnX2q9sqL
p5t6cBt0wB4cK4AXrymKzmflfZba/zEH3mqcJ+alRXg8e7hUQUC/kecLWjECt//9
NJ9AllGq6tA=
=U/yn
-----END PGP SIGNATURE-----

--Sig_/6FKDWned7+W/iX2T=3wIz=S--

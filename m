Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:65228 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756499Ab3LaXCm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 31 Dec 2013 18:02:42 -0500
Date: Tue, 31 Dec 2013 18:02:37 -0500
From: Jeff Layton <jlayton@redhat.com>
To: NeilBrown <neilb@suse.de>
Cc: "J. Bruce Fields" <bfields@fieldses.org>, Simo Sorce <simo@redhat.com>,
        linux-nfs@vger.kernel.org
Subject: Re: should we change how the kernel detects whether gssproxy is
 running?
Message-ID: <20131231180237.3bef5e42@tlielax.poochiereds.net>
In-Reply-To: <20140101095620.0ab48051@notabene.brown>
References: <20131231073300.0e0f220a@tlielax.poochiereds.net>
	<20131231180123.GA12875@fieldses.org>
	<20140101095620.0ab48051@notabene.brown>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/OC4i.R2f9FjNtxVsrw9s0qK"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/OC4i.R2f9FjNtxVsrw9s0qK
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Wed, 1 Jan 2014 09:56:20 +1100
NeilBrown <neilb@suse.de> wrote:

> On Tue, 31 Dec 2013 13:01:23 -0500 "J. Bruce Fields" <bfields@fieldses.or=
g>
> wrote:
>=20
> > On Tue, Dec 31, 2013 at 07:33:00AM -0500, Jeff Layton wrote:
> > > I'm a bit concerned with how /proc/net/rpc/use-gss-proxy works...
> > >=20
> > > For one thing, when the kernel first boots any read against that file
> > > hangs. That's going to be extremely problematic for certain tools that
> > > scrape info out of /proc for troubleshooting purposes (e.g. Red Hat's
> > > sosreport tool).
> >=20
> > Is that the only file under /proc for which that's true?  (E.g. the rpc
> > cache channel files probably do the same, don't they?)  I was assuming
> > tools like sosreport need to work from lists of specific paths.
>=20
> The rpc cache channel files do not block on reads, so 'cat' works well on
> them.
> A process (like mountd) that wasn't to see new additions will use select =
(or
> poll) for an 'exception' condition, and then read.
>=20
> I think that it is best of all files in /proc (or /sys) would support 'ca=
t'.
> If I "tar" up "/proc" on my notebook it doesn't block ... though it does =
take
> quite a while on /proc/kcore :-)
>=20

I think we have to deal with the possibility that something will
eventually get stuck reading this file.

I can understand why you might make the kernel hang for a little while
waiting for gssproxy to start up or something. What's not clear to me
is why you'd make userland reads vs. this particular proc file hang.
What problem is fixed by making this hang?

--=20
Jeff Layton <jlayton@redhat.com>

--Sig_/OC4i.R2f9FjNtxVsrw9s0qK
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAEBAgAGBQJSw00NAAoJEAAOaEEZVoIVgF0QAJO+WLgUmmbFXg8Msg7cW3b6
zju0Rj2VTFIZFpkHUq6XgDlSWKfU18Jm1EFErLkryNw6E9Tj6s1/dYAh71Ioj6ew
G9bkiMYQL5/SngaQHlYBz8WZyImP3lqlBT7+VXUR+/1xTowmUzv348ah4kph65ok
UBh6n9RzIWrHLlczW8nNpqB6qUJ7Y82d0sgjt+udngXDv/4AQmbiKWzp7uKqYHMD
16x2pWfr8hZH/LKHAW8eoZyETrcVFbJpaP7D+Ap06QyrZeGu6WXbJ5EYcQBApvsq
UYETf2RopKN4AsyrssoexJysYXQeLKg3g2w+rP/1u1ysDaPsUfeKgygEOPjQokT1
P9t+Ze2FOZrxVmZUnVZvvteo7b6NY5jj4RJaAdJlrTr7IKDmVsI/sSikyx1C5l1E
49FJ3DUkSU4vEeKD1Dv+2P8nW13dDkQuVtrPJQl+f0F2fYU9t0l+nVkMVTvfgZFt
9Vai9g4v/uKTsAkh87NXOwqbpqhEw+Mxg/qzbYxDo/ZJn21+Pz9Dvr5QWtwdgJkd
VIyYOi51emLU0jTOuLNP+LYcGHwgN7mj9st7ReMa0TETiOMeKbFXKVgtcLJss4Ni
m9HppzvbygW7m/zYdrz84G3SukhUwEV4Ejchnq/n5nv2SIzxVs1SvmmvVzWj3/Hp
lLDnlOBrEY0lcrdUHW7f
=AVmS
-----END PGP SIGNATURE-----

--Sig_/OC4i.R2f9FjNtxVsrw9s0qK--

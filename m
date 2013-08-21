Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:49878 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751727Ab3HUCn4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 20 Aug 2013 22:43:56 -0400
Date: Wed, 21 Aug 2013 12:43:43 +1000
From: NeilBrown <neilb@suse.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Martin Hicks <mort@bork.org>, linux-nfs@vger.kernel.org
Subject: Re: server mountpoint busy after unexporting nfs4 share
Message-ID: <20130821124343.4f5462cc@notabene.brown>
In-Reply-To: <20130816211217.GB21539@fieldses.org>
References: <CAJUS3XmebzQHnQNwEYECUjYyK+nj2cVpKz_-4gmPacEWzmxEZQ@mail.gmail.com>
	<20130816211217.GB21539@fieldses.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/tnyRM3XhyoIy+Y=3MGT9M7L"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/tnyRM3XhyoIy+Y=3MGT9M7L
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Fri, 16 Aug 2013 17:12:18 -0400 "J. Bruce Fields" <bfields@fieldses.org>
wrote:

> On Thu, Aug 15, 2013 at 12:04:33PM -0400, Martin Hicks wrote:
> > I'm wondering if I'm missing something or if this is a bug.
> >=20
> > A NFS4 export has active clients.  The mount is removed from
> > /etc/exports and 'exportfs -r' is run.  Clients immediately start
> > getting 'Stale file handle' errors, but the mountpoint is still busy
> > and cannot be unmounted.  Killing off nfsd solves the problem, but is
> > undesirable for obvious reasons.
> >=20
> > On debian linux, kernel version 3.10-2-amd64,  with nfs-utils 1.2.8.
>=20
> Yeah, the clients may hold opens or locks on the filesystem and those
> don't get removed on exports -r.
>=20
> For now shutting down the server is the only solution.

How far does:
  echo /path/to/export > /proc/fs/nfsd/unlock_filesystem
get you? Or does that just drop 'lockd' locks and not NFSv4 locks?

NeilBrown


>=20
> We could possibly fix that, or provide some other way to do whatever it
> is you're trying to do, but it's likely not a small change.
>=20
> Nevertheless, for future reference it would be interesting to know what
> exactly you're trying to do.
>=20
> --b.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


--Sig_/tnyRM3XhyoIy+Y=3MGT9M7L
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQIVAwUBUhQpXznsnt1WYoG5AQJAeg//ZSL+wUWDgsv0rUS85L9qKbB7RmF06V0/
1etkg7kLrC/AmkVORSVClG+qMelVqupQxYM3TyXpc02NEsj6IPGEdNJQabRa7Jwo
weAnY2jsoPRcACSw+0Bfjd4vizuNr6gFR+dI3j9FElpCzK7J43Yc0wZ89EzSOfVx
kTymvPiQziltTvdE9ORYSTxrFdMlT+C3iTxO58FDfA0UeIPV13MACOEWM36ZSdlb
GDYIpE4FAV7q6PcNQIfooQIE0Nl9i+xZG9OQxVWWwuSM2yvEDVJk33bg8J9Xwlok
6kGMYYXuwdCSQ5Ha0VHkHlKHtgNGpbVq4oG1KCbctGa/Yo/Bec1c80dlwXoLQhLw
xFW58iwtTZhhKDtDgdXx9jchSjbn28IkZj0KEwDcSyQgMAlGNhqUGKg0AblUMkZA
+EofOHXrVkfHAjoRZkF3KW+gCTJKjwvqdJhK0q/AhBylBV2j1tZDFx5EiJzU4Izs
4Gwq94fOuf4Cem/wASeibF6mERldO1h22uPNk+rTsUiYnOGtahUt9uWbN9gW4WNZ
NJwAyW9p1WtXV2xAvHsfo6Oh+Y4NyTBT5W2JeGSfiGTRhiZQ+r4PSnZJ3CTgR2oo
JY0g5y/k9wknQ0LFiimz0IZ1kKwkWZfTZ5za/AwygNvzwuJQfro6nIe00mfrZlaj
W6ok8EKAVug=
=9qTw
-----END PGP SIGNATURE-----

--Sig_/tnyRM3XhyoIy+Y=3MGT9M7L--

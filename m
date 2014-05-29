Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:53722 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932545AbaE2VqA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 29 May 2014 17:46:00 -0400
Date: Fri, 30 May 2014 07:45:48 +1000
From: NeilBrown <neilb@suse.de>
To: riya khanna <riyakhanna1983@gmail.com>
Cc: NFS <linux-nfs@vger.kernel.org>
Subject: Re: dev over nfs
Message-ID: <20140530074548.446a3dcc@notabene.brown>
In-Reply-To: <CALRD3qKzmrvRqBabQQuvVH7jTb0mexZGw4rXVTBkYS3YRc6NtQ@mail.gmail.com>
References: <CALRD3qKzmrvRqBabQQuvVH7jTb0mexZGw4rXVTBkYS3YRc6NtQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/_Az2CWoIqjcF=sL4W_k0qd9"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/_Az2CWoIqjcF=sL4W_k0qd9
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Thu, 29 May 2014 13:53:37 -0400 riya khanna <riyakhanna1983@gmail.com>
wrote:

> Hi,
>=20
> I'm trying to access remote devices locally by mounting/exporting /dev
> nodes over NFS. However, looks like the access requests are treated local
> based on major minor numbers (e.g. "cat /mnt-dev-over-nfs/kmg" output is
> same as "cat /dev/kmsg")
>=20
> How can I change this behavior? and if it is at all feasible?

You cannot.   Things in /dev are a bit like symlinks.  They point to the re=
al
thing, but they are not the real think themselves.
The actual devices are always local to the client host.  NFS cannot provide
access to remove devices.  It can only provides the "links" which you can
follow to your local devices.

NeilBrown

--Sig_/_Az2CWoIqjcF=sL4W_k0qd9
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBU4eqjDnsnt1WYoG5AQIJwxAAiKgTLvcpR/bMRQZ149tKy0bzYZI16vDH
vYtA8DfD9InYxCmlaKyrsDzVlM94pUfeSS8B7skViVcmu2hyZwgNoVbMmrqO/X9b
Ja9OqSpuT2DxCkldfzQH0pzKWUyW96EopkB9Voa/qWdosh0/yFk1hZyhADBx7id3
kWtklSGOEBmBbPWUKP9DP66lNzG8rtC2YkCYbqY7zLvfioySOv9ou0L183PYKluD
RyeqVrdZ5AZixzlGy4L4+bInsehsCnYXIGQOWpEsVKpij26mtMrU6WK7UuJxXKxr
SeJIQ/n48lsm9HjAJwQfmfqezRaBtYbcfsWJuwn5R1lHPFOkM5/+RpakwRHQeGvC
9TnwKRFSIkuake9XDiq51XzpkxFvN9jQYZCh9iAFQFAT9F6pzNAvnxDFIMhNuBY+
BuphgomnlBOHhJwDUJzOY3Jo0+bNEkPAMJCiffYRjm2J+1+pL1uUVa2YkGHcHhgy
7KMV6fuBxxEFYkkzDk6vcgvTUYlXuYvdWoF697Oh0k38CpWLLuGKfzc7++FmiYtY
yK3q2YGFdrU2o0dLMnp37ytrJYBEQvnBMID0vSZGXj5UXMSWBN3X3lv28INMSGQr
kVNBuI4Xxuq7vDfDE3upSc6i1QHFy4oEWvBc/i5EyuPUXBKepVVP+uOzMw4+tpF/
OfwPlrFc5u4=
=Nbqc
-----END PGP SIGNATURE-----

--Sig_/_Az2CWoIqjcF=sL4W_k0qd9--

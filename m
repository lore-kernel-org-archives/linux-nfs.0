Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:38343 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752268AbaCLFnS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 12 Mar 2014 01:43:18 -0400
Date: Wed, 12 Mar 2014 16:43:09 +1100
From: NeilBrown <neilb@suse.de>
To: Steve Dickson <SteveD@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [nfs-utils RPC-PATCH 0/4] Add options to nfsd etc to avoid
 needing to write to /proc
Message-ID: <20140312164309.51eda2bb@notabene.brown>
In-Reply-To: <531DEF3A.1040401@RedHat.com>
References: <20140220063616.6548.42556.stgit@notabene.brown>
	<531B4BB7.9010303@RedHat.com>
	<20140310114717.7df5c24b@notabene.brown>
	<531DEF3A.1040401@RedHat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/89QqndQ_AETqmCb_LMJLsC7"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/89QqndQ_AETqmCb_LMJLsC7
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Mon, 10 Mar 2014 12:58:34 -0400 Steve Dickson <SteveD@redhat.com> wrote:


> >=20
> > I believe that the best was forward is to make this more standard.
> > I think the best way to do this is to teach various nfs utilities to us=
e e.g.
> >   getenv("NFS_LISTEN_TCP")
> > to get defaults for various settings before parsing command line option=
s.
> > Then whatever is used to run these utilities can
> >    source /etc/sysconfig/nfs
> > or
> >    EnvironmentFile=3D/etc/sysconfig/nfs
> > first.
> > Thus we have a ready-made configfile name, a ready-made configfile synt=
ax,
> > and just need to agree on values can be set.
> I think this is a good idea... Which would override which? The command=20
> line override the environments? What should happen if neither are set?
>=20

Commandline should definitely over-ride environment or config file.
If neither is set we get some sensible default, just as you currently do if
you do nothing.

I noticed that rpc.nfsd always explicitly sets the version.  So if I echo
something to /proc/fs/nfsd/versions and then run rpc.nfsd, the versions will
be over-written.  I suspect that is reasonable behaviour.

Should e.g. nfs4gracetime be treated the same - always explicitly set
something.  Or should we just leave it unchanged.
The former is more consistent.  The later is backward compatible.
I lean toward the later which is what the current code does, but I thought =
it
was worth mentioning in case anyone disagrees.


Thanks,
NeilBrown


--Sig_/89QqndQ_AETqmCb_LMJLsC7
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBUx/z7Tnsnt1WYoG5AQJecxAAnN7wnNkJhRXrc0+R6+rmYxJ3HFlu1HKF
fK7XvkjMo5stqqMJdsVpvFBfvBnikRav+rC9c3Lcc+FowGc+2cp9fsD9SUYDUxm0
5y8OkO98grfIl41HyR3JjeBWlD8KEUWc6t3I9YN7gtXjIBGYPrLGNvkmWdD3Yc+a
2VKrA/3FRzQdGbwAUksh3CmOd8f/99IpIey+axLzH6YzDZSpPer56ugz70elWedW
F0Dwgugh+yIHqhi+v+k0c+oRrK13W1r0ujuF6LgoTgG3YlBgzoSo8wrW8UA19Yxl
KRssL4ycpClH4qvigLONN4zfwwrRH+cw3tBL6CrlqcxHkFA6fZjWPFnkwUVecRjM
UihEJBD9BnVc9ey+HCreANh57ryGqXkvkxQAesBnRyzGVQL+d7eYkOgdQi6GMuBJ
/07HGfkNDAZJC/tKDqDtErxSTng1p28RloLKA3XGSY6CnT61W+PWj4FDW1Na2g6a
Hc8BlykM4D1LP2n8Mw+YHLfCfSBMdPVazlynruL7XPaSpAutDKFHxkqMitFFszMN
mo7OhALfqPDjeujkk8j74t/Hk1+MZo5xvbtYsBzdCBHq3AUI6qA/LoYbfhdIc4Mj
O6h6B+YkMmRqpNX/m1SyBszsmWlxQlDD99zyrTiZ/RiyRf1ffi9BlNIz8G5AwBh6
Fyl6umMzGmI=
=1Mwk
-----END PGP SIGNATURE-----

--Sig_/89QqndQ_AETqmCb_LMJLsC7--

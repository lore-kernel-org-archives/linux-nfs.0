Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:60179 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755803AbaGWHOS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 23 Jul 2014 03:14:18 -0400
Date: Wed, 23 Jul 2014 17:14:08 +1000
From: NeilBrown <neilb@suse.de>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 0/7] Add RCU-walk support to NFS.
Message-ID: <20140723171408.481387f1@notabene.brown>
In-Reply-To: <CAHQdGtSmLH6GJ6iw0dyKmpVvvvcuK9-+T2KcJu0+_S8CsgtqOA@mail.gmail.com>
References: <20140714011630.12562.1940.stgit@notabene.brown>
	<CAHQdGtS2XW=GeyxHddKKAb9a2tucO9kzxatPJ78qpMiDiOagiQ@mail.gmail.com>
	<20140714122531.13a69cc8@notabene.brown>
	<CAHQdGtSmLH6GJ6iw0dyKmpVvvvcuK9-+T2KcJu0+_S8CsgtqOA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 boundary="Sig_/SsCAFZTy0mRUIX40b/d8/=v"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/SsCAFZTy0mRUIX40b/d8/=v
Content-Type: multipart/mixed; boundary="MP_//GR6pT2=QRg3oCxXYM9m=1B"

--MP_//GR6pT2=QRg3oCxXYM9m=1B
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Sun, 13 Jul 2014 22:39:34 -0400 Trond Myklebust
<trond.myklebust@primarydata.com> wrote:

> > I'm certainly happy to try beating on it a bit hard, and can see if I c=
an get
> > access to an 80-core machine that I had a brief play with a while back =
and do
> > some more testing there.
>=20
> As I said, it's not required for merging, but would definitely be an
> interesting test in order to see how it affects NFS performance in
> general. If you have access to a good test setup with an interesting
> workload, then I'd love to see the results of a "before vs after"
> comparison using nfsometer.
>=20

I managed to get access to a big machine for a while so I ran nfsometer.
Seemed to run quite well but there are a couple of little issues I might
mention separately.
I didn't let iozone_direct complete because it was taking *forever*.

The results are at http://neil.brown.name/nfsometer_results/

I cannot find a good summary page...

I tested three kernels on the same 80-core (160 if you count hyperthreads)
machine:
   A v3.12  that was installed,
   a vanilla 3.16-rc5,
   and the 3.16-rc5 with my patches.
Some numbers look good, some look strange.
Can you (or someone) have a look?

I also ran my compile-test and graphed some results, which I attach.
This is just 3 kernels, 3.16-rc5 with and without my patches.
I tested both v3 and v4.
I ran the "make" command with "-j" values from 4 to 80 in steps of 4.
The runs lots of compiles of a trivial file but has a very long list of
include directories which are all on NFS and all empty.  So there are lots =
of
attempts to open non-existent files, and the non-existence is cached early.

As you see, with the "-rcu" very performance is enormously better.  Without
my patches, more concurrency means worse performance.

Thanks,
NeilBrown

--MP_//GR6pT2=QRg3oCxXYM9m=1B
Content-Type: image/png
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename=make-times.png

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
dGFaSDVU2BEAAAAASUVORK5CYII=

--MP_//GR6pT2=QRg3oCxXYM9m=1B--

--Sig_/SsCAFZTy0mRUIX40b/d8/=v
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBU89gwTnsnt1WYoG5AQLsuxAAj+bvYnVbedo5gT7M2KX4j5IECM1A/a7Y
wAkKbE0iASmVHdUTJlOKaQk5Gr5m5xPRTYOILf5w6d64oqwu6WX0rnx+CAoOzezR
gXmvllJro9CmJWfR1B6jJUQVlDI7WQkqFpW3oFiACunSftL6mlx1gD6qZ9ch571T
SNw54bzh/kAsp0Fg/2bhkN/iGgN6eI1I4blTBuDZrAOOkv4uErocncWN2uV4Y0Ne
ORGzbSqfsKUhPHFLHJs5dIA2J/1t9MWUIZ7Gpn0bIbg4XGiteUJGPIXoRePFWgBW
Cgwvy/2AIBxxIVZse9KjYbjziEOoMZdotmjSDTSJXK4dxkcW3bZEsMhuwmxlU7CK
uBay+qGBu8aRmfx1Q+lbTBePMKPWxf0crWxHdKBJU2X2gvQfpu0Vzr3u3XfXsKqe
EtXOt/LUmpHMCxch93xtgvUf0lNIHy5mXK4BRuE+gx5qUIhr9UmxHuosEwhI1kKS
5xYwp7/+wVQUQfx2wpVEYPhbJoI0uXX7mjMc6T2tMFBruxlgORmOq3HCXZCFy+2D
ATFoXVR3Nc9V/BoEuictCdtTU9Tl0LjGjur4kRzjeh1ES5mJ8KHk6WMg5q7WWJ/N
Y1xdKOXRUQK5JOLbgv4yoWfnsQq8KjAmP+IGBbkBOMkqHvbrmqLwcX7yi9WRmYne
sMT6YSbagtE=
=x3ye
-----END PGP SIGNATURE-----

--Sig_/SsCAFZTy0mRUIX40b/d8/=v--

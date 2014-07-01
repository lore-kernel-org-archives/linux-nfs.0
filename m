Return-Path: linux-nfs-owner@vger.kernel.org
Received: from casper.infradead.org ([85.118.1.10]:55043 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757146AbaGALHa (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 1 Jul 2014 07:07:30 -0400
Date: Tue, 1 Jul 2014 13:07:18 +0200
From: Peter Zijlstra <peterz@infradead.org>
To: Jeff Layton <jeff.layton@primarydata.com>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org,
        Ingo Molnar <mingo@redhat.com>
Subject: Re: [PATCH v3 071/114] lockdep: add lockdep_assert_not_held
Message-ID: <20140701110718.GT3213@twins.programming.kicks-ass.net>
References: <1404143423-24381-1-git-send-email-jlayton@primarydata.com>
 <1404143423-24381-72-git-send-email-jlayton@primarydata.com>
 <20140701100335.GP6758@twins.programming.kicks-ass.net>
 <20140701101108.GK3588@twins.programming.kicks-ass.net>
 <20140701064111.5fe8e555@f20.localdomain>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="xt4oM5y0t/70YhQj"
In-Reply-To: <20140701064111.5fe8e555@f20.localdomain>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--xt4oM5y0t/70YhQj
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Jul 01, 2014 at 06:41:11AM -0400, Jeff Layton wrote:
> Right -- in the case of something like atomic_dec_and_lock, we only
> take the spinlock if we think the count might go to zero. So, we might
> miss catching some places that could deadlock if the refcounts don't go
> to zero in the testing we're doing.
>=20
> might_lock may be what we need, but I don't see any callers of it,=20

might_fault()
  might_lock_read(&current->mm->mmap_sem)

I'm not sure we have others; but this is the one I remember providing
this for.

> and
> at a quick glance it doesn't appear to be disabled if debug_locks is
> false.

The whole of lockdep gets killed, and that would include the
lock_acquire/lock_release used to implement these.

--xt4oM5y0t/70YhQj
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJTspZmAAoJEHZH4aRLwOS6UZQP/RuSMlz+dc0I56olTEfxnFKK
LHKOoo7VEOSFzuHGHZXqqxG8MNSBOVI8C8+bKSl55GpzlaJoQkTr45Afpk0emnE5
+Tpx3ti4xxTYxrgGpYnB33Z9EXww5J81bnu1pHc87x1X2nubnPCTlHE8KM9Q6q2p
I1R3vR15/gsgkDxCpJtMgAn50HKOMX8yyBqaH9tRQnXxreOFL3npWngAjXqbvj5N
kfNIwyY7MBBUketsRhVa9XjMjjC6aHTf4nn9vwf6BdAeUqhcxRM1LIwuAq05czmf
hESXv0xUjsiC1Yhjcr8kBpX+/SMIgOytEkQvV749v6VxtFNaCWiDLHOsY2rAZ7EF
ys6v+yzD0MXgvSESLFMf4fuEoD7y+4BbhXqnLPeey7Ui3l9FCeUOi1mqB66tbuM6
IV+9HmGs/lbmXGla80hc0XqOX4pfK56O/MSblBAGo56uIqxeLUrgVROXGatCVDVr
0cBEoEhBaygmghyc5I0ILos+lAE8X4+IvrfbfVD2Sst/U+RGX6u4xyaSExhkbLiy
LU++xEzrC6kPGR1Yo8RZZYPV0Z34lE3BKCzyYDRUnEZSivLbaXM+I4RmfXbon0/e
JJeUvuZ/FNhFnPE14VdDj7Asvt63/JpfzK07JlA4AYHvkJWB03oQFoW91D+eDdyp
sCMSnJl7U7ZKC5Vb/Ue1
=J54h
-----END PGP SIGNATURE-----

--xt4oM5y0t/70YhQj--

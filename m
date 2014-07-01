Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:40722 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756278AbaGAKLS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 1 Jul 2014 06:11:18 -0400
Date: Tue, 1 Jul 2014 12:11:08 +0200
From: Peter Zijlstra <peterz@infradead.org>
To: Jeff Layton <jlayton@primarydata.com>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org,
        Ingo Molnar <mingo@redhat.com>
Subject: Re: [PATCH v3 071/114] lockdep: add lockdep_assert_not_held
Message-ID: <20140701101108.GK3588@twins.programming.kicks-ass.net>
References: <1404143423-24381-1-git-send-email-jlayton@primarydata.com>
 <1404143423-24381-72-git-send-email-jlayton@primarydata.com>
 <20140701100335.GP6758@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="72k7VsmfIboquFwl"
In-Reply-To: <20140701100335.GP6758@twins.programming.kicks-ass.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--72k7VsmfIboquFwl
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Jul 01, 2014 at 12:03:35PM +0200, Peter Zijlstra wrote:
> On Mon, Jun 30, 2014 at 11:49:40AM -0400, Jeff Layton wrote:
> > We currently have the ability to call lockdep_assert_held to throw a
> > warning when a spinlock isn't held in a codepath. There are also times
> > when we'd like to throw a warning when a lock is held (i.e. when there
> > is the potential for deadlock with atomic_dec_and_lock or similar).
>=20
> So I'm not getting it; if there's deadlock potential, lockdep would
> already report so, right?
>=20
> That is, lockdep is very good a yelling when you try to acquire a lock
> you're already holding.

Ah, I think I see what you're trying to do.

You're wanting to use might_lock() and might_lock_read(). Which are used
to make conditional lock acquisitions unconditional, so as to more
reliably trigger the deadlock detection.

--72k7VsmfIboquFwl
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJTsok8AAoJEHZH4aRLwOS6pHYP/0FraiTBwAS6VTWQzHSJSHZl
eaSueLoE1fpxT42m0GoxqOthkEc2T8FYEV6iqhCnjFoepiJqjy2uILjPnNGhE8wF
MvxR+mvIZLJ86sB1yG5vagbsqMhpZKr3+o66ky/c4ptuq0/5KzugPYRngZAfO3YM
mje0FpKxLE6T2ocmS+1hZPv9EdijNcbMvs0mA5RMz3zw6rtES97/n4sZD7YbqIa9
GxeT5jtPwQ2sPSxqydswodTOb9Ry+iQC7xDY4gmbMob1+iCDM+ibT8mgt30mQpEj
KVC587mneCNT3cTrhHGQ+X4jbuyescljWynlaA0MB7Q1duIKV/t9YHMSNKFv9Msy
mUWRw68PxFetzt+doeh+UfINRbA1Hol4IO90G1VIL1MHVfg3u+d747f8DrXrYOiv
fdoUtEmfu6J445/sftumsFPH5+Y4fRZxReYMwSchLVtlKoEn9/iNgIzlWkXFi/jN
a1wlod1KIsqtk3O0ngr4m4GZeYyeV3a2IxzW77owulU2yAuLnQDavHugPUds/NlY
IVIF7NLYZKHkLaGA5g5KkfWa5EjM4eYTwMj1PXp5//QDMCQdthtvSuw/cdzVxpda
iY4W8JL5yKAGCprnvTF7U3XbW1pzuz83aXKeTrJwdtpH00bDOv97L12g8ePSRo94
ZC4INRiGk36uRCRgqOfC
=qqW9
-----END PGP SIGNATURE-----

--72k7VsmfIboquFwl--

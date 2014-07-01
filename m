Return-Path: linux-nfs-owner@vger.kernel.org
Received: from casper.infradead.org ([85.118.1.10]:54790 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751273AbaGAKDs (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 1 Jul 2014 06:03:48 -0400
Date: Tue, 1 Jul 2014 12:03:35 +0200
From: Peter Zijlstra <peterz@infradead.org>
To: Jeff Layton <jlayton@primarydata.com>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org,
        Ingo Molnar <mingo@redhat.com>
Subject: Re: [PATCH v3 071/114] lockdep: add lockdep_assert_not_held
Message-ID: <20140701100335.GP6758@twins.programming.kicks-ass.net>
References: <1404143423-24381-1-git-send-email-jlayton@primarydata.com>
 <1404143423-24381-72-git-send-email-jlayton@primarydata.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="mlnxvmnLyWgus2CN"
In-Reply-To: <1404143423-24381-72-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--mlnxvmnLyWgus2CN
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Mon, Jun 30, 2014 at 11:49:40AM -0400, Jeff Layton wrote:
> We currently have the ability to call lockdep_assert_held to throw a
> warning when a spinlock isn't held in a codepath. There are also times
> when we'd like to throw a warning when a lock is held (i.e. when there
> is the potential for deadlock with atomic_dec_and_lock or similar).

So I'm not getting it; if there's deadlock potential, lockdep would
already report so, right?

That is, lockdep is very good a yelling when you try to acquire a lock
you're already holding.

--mlnxvmnLyWgus2CN
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJTsod3AAoJEHZH4aRLwOS6LIIP/078GrVs2KTf9/yRkMOJgBhu
5QpBgV+G9AQd5SKUeLkpCERwnIF0ufjIgxahDKEyyR60XakcOX70s5D0sAw0t2Ms
VQ4Fkg8bilMNrt/SUKvaD1RG3tIzaq/MZt/I/j+RU/IEvsxu+FXgxtNBu7QH2m5X
gvw3E0CEIVIB4VWDlaDjJ34LKYr6Uc075Fk0fYDRG2znhpwxxYCxFYfxRp7V09Vy
opzETSlkhjvO6c+MxfnkwvVJqWCqwg2KejbeZhgDQoqgVjHhdZgPnWva31Gz3BKV
yHfUoAO01c0g4l46usS2DKo9XaLZ5ybpd6Oko+KVDiLI5FCX3aNb8ICWtlVf2lm3
OOTGeibIyPNKZWV3kBcNfpsNa4SLGE0zVBxbNbM7D7tpM+HqnaGCuMIvpENh7Tnt
5EperNBaxD/g3WvpFWqqwPhDWMXn8p6G2kbZ+fTMkuAIW6ZgQa+jGihUbl3PdaRr
lRW7fyXWIJKm8Ge+kdWrJQLxOUR+WDzMyvmkBml+4FNCVka5uw7Du4TxO/mw2Ptk
1VICjwYo4YSTUEczSEt/glBUcfwJyIczLPQxkkPDO7Q1FR9uJtV/F1X+U6d9XZdQ
X40O5L/GSZAcuNXiRrNOMcNMnFzCaF2/tJZ4cSvaQIDqW/c4vvdsxpjpG9XQt9nh
6NVFDTvxBSF4VzLhUnvW
=pwbd
-----END PGP SIGNATURE-----

--mlnxvmnLyWgus2CN--

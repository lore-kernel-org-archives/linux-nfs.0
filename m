Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:58456 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755870Ab3J1Wf7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 28 Oct 2013 18:35:59 -0400
Date: Tue, 29 Oct 2013 09:35:47 +1100
From: NeilBrown <neilb@suse.de>
To: Steve Dickson <SteveD@redhat.com>
Cc: Tony Asleson <tasleson@redhat.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] exportfs: Return non-zero exit value on error
Message-ID: <20131029093547.1e6bff94@notabene.brown>
In-Reply-To: <52663908.1090708@RedHat.com>
References: <1380756584-13335-1-git-send-email-tasleson@redhat.com>
	<52663791.6020605@RedHat.com>
	<52663908.1090708@RedHat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/s+rDE9Z9d..EZ/JtfTtntAz"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/s+rDE9Z9d..EZ/JtfTtntAz
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Tue, 22 Oct 2013 04:36:24 -0400 Steve Dickson <SteveD@redhat.com> wrote:

>=20
>=20
> On 22/10/13 04:30, Steve Dickson wrote:
> >=20
> >=20
> > On 02/10/13 19:29, Tony Asleson wrote:
> >> To improve error handling when scripting exportfs it's useful
> >> to have non-zero exit codes when the requested operation did not
> >> succeed.
> >>
> >> This patch also returns a non-zero exit code if you request to
> >> unexport a non-existant share.
> >>
> >> Signed-off-by: Tony Asleson <tasleson@redhat.com>
> > Committed!=20
> Unfortunately I did not see Neil's patch before I committed this patch....
> So I'm going to revert this patch in favor of Neil's...=20
>=20
> steved.

Hi Steve,

it doesn't look like you achieved the result you were after.

commit 956aeff2e24304e938846f81f4b9db34cbf18a32
is Tony's original patch.
commit efe3c8d6cb4fc35909a64c0535087676a189fa5f
reverts it.

commit 232eb7ad09f9fd2ae4918699f850e4f8cadc2632
apples Tony's original patch again, but is credited
to me with my patch description.

So something is a bit messed up.
That is why my subsequent
       exportfs: report failure if asked to unexport something not exported.

didn't apply.

NeilBrown

--Sig_/s+rDE9Z9d..EZ/JtfTtntAz
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQIVAwUBUm7mwznsnt1WYoG5AQLFABAAvA2k0aMqlCm1bE+JlrMe0wTZaX6xZ5tZ
3a1HB54bwq3JOR5thWHjYPQLI038O8dW+serz2rKoKNN08oS56+m3hwqB3tr5FUP
AhQ23xXYhCo5UGwvAfYhjkkJEFjjok22R7oL5tGQfGFaXuHz9cFosqh1ziKj5bkA
7q3in2NcMckptVTHvXb4D0FFtuEqjTi8vSZ/XvrIUnkRVTgeyoOtHybKit5VlMGa
af2eZoKqWdkHfQxSWcVfZzqBKREp567NA1UNX0WVWU7cBzbC64gt66hifrd6aWmr
W25NxonEDuFnYyhhIYftKm97BteSZUnetdFsQvY126Xdt5lX/m2kLmkHSkj5HawO
C8Eks9iH4D36ej9KAn7oR/E8gz46USBZsGD5aY/sjBiuFRr1QYdFw1fXlVGQWk5B
izWiAsrAY8Evxp0CrM2iZxzUNLpgwbmiN3A5BlrNWWNVR3MbOZ8EIEHCAZM3pL4M
3rGy8PzFEzKXLq4bQ5BvYLjqTrG7mcME/V0SDedu9qBRb++3q6Xo7X+ziEAqERw7
ZCRXT/I1RN6jI7BqybDKm+Y7iqQtxHtWHzn2QhS7REo3R3tzppU/19aVL0ZkB5zF
HRS7WEL8XPFEr56l5G0eXK6u1Dt1iqdhAAn3uJ+oYL1m2bo+0z8AF6eMAX8gWXAy
Mg+QOvk0kFI=
=RlHM
-----END PGP SIGNATURE-----

--Sig_/s+rDE9Z9d..EZ/JtfTtntAz--

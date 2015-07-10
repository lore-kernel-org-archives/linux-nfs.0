Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yk0-f178.google.com ([209.85.160.178]:34741 "EHLO
	mail-yk0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932598AbbGJOj0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 10 Jul 2015 10:39:26 -0400
Received: by ykax123 with SMTP id x123so16945501yka.1
        for <linux-nfs@vger.kernel.org>; Fri, 10 Jul 2015 07:39:26 -0700 (PDT)
Date: Fri, 10 Jul 2015 10:39:14 -0400
From: Jeff Layton <jlayton@poochiereds.net>
To: William Dauchy <william@gandi.net>
Cc: Linux NFS mailing list <linux-nfs@vger.kernel.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>, jloup@gandi.net
Subject: Re: extra reference to fl->fl_file, possible regression
Message-ID: <20150710103914.78189580@tlielax.poochiereds.net>
In-Reply-To: <20150710125444.GL15144@gandi.net>
References: <20150710092910.GI15144@gandi.net>
	<20150710072438.08b3417a@tlielax.poochiereds.net>
	<20150710125444.GL15144@gandi.net>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/PnKP0Jv9UMNlzOdS+pELzop"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/PnKP0Jv9UMNlzOdS+pELzop
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Fri, 10 Jul 2015 14:54:44 +0200
William Dauchy <william@gandi.net> wrote:

> On Jul10 07:24, Jeff Layton wrote:
> > Huh. I'm stumped...
> >=20
> > These patches are pretty straightforward. We're just taking an extra
> > reference to the filp when running lock operations so that it doesn't
> > disappear before the replies can be processed (typically in the event
> > that a signal comes in while waiting on the reply). Given the odd stack
> > trace above, I have to wonder if there's some sort of memory scribble
> > going on.
>=20
> I also forgot to mention that I also had the following messgae before
> the trace:
>=20
> VFS: Close: file count is 0
>=20

Ok, that may be an important clue. From filp_close:

        if (!file_count(filp)) {
                printk(KERN_ERR "VFS: Close: file count is 0\n");
                return 0;
        }

...so looks like there could be a use-after free going on? Somehow
we're ending up with with an actual close being done after the last
reference has already been put. I'm not s

So, I suspect that the problem is with the second patch (the LOCKU
one).

I'm not sure if it's responsible for that message, but one of the
things we do in __fput() is call locks_remove_flock, which can dip down
into the NFS unlock codepath.

So if a file happened to have some flock locks on it, then we could
be taking a new reference to a file that has already had its refcount
go to zero.

I'll have to think about how best to deal with this as I totally missed
this when I did the original analysis of the bug. For now it's probably
best to revert that patch (though I think the one for the setlk is
likely OK).

Thanks,
--=20
Jeff Layton <jlayton@poochiereds.net>

--Sig_/PnKP0Jv9UMNlzOdS+pELzop
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJVn9kSAAoJEAAOaEEZVoIVa3AQAM0mWOytz5JDHVIetz/EGiWm
DxbGDEiOzzIw2tOmWqHkJInTl6Er3+csBZcJL+NApsutUsJl4dG7PazXayGKi4AO
W2DqxoX6VhyF+MzvtZVMm82XS8EoASuSy3xP8B8WXrvkFe1qoBplPRv9clOkn72E
sr56f038uSKxtqvlvO/Um4ngIs6q3aH8PeWjThHFXN3DpPerjQr4R5nqxZt+9lQY
5FbM2O4QwAyDURZJNgOz2Rc4yn+73lmZRURByi9vBZHRfgKOGrlw0JDPJFykW8Ov
ZTNL+jb/ONGyL0nw81MlDXhz60bF12JQgcp/5o0ID8TyxZ65c7mtH/mLPC5noah8
lpYH2w7VAD24ivhWPxlSTh3kVgoB74X+og8mlWgjIyfF8YStTNnaO4RzraYU7fEK
N3SWOCTgEBV0hYZwHGMe/lAULLWznVqO7L+7ymt6EmuAurajxmzd/1aFLYC5BHTY
8/dYUe/3+knCEfJyAJWKfnxmkRb695VKzwKj1Kf1q5DOd8EXhXkNVgd8mWbzDRFo
7srsJwlEMBjjHvAJFlgQNUC6gLWPi9cy3MsjwA3JA/Wi16r/g2pWviuHUERMwKev
5Y3vUo9krd7+qn1EMIqBeQ1r35VlpGDbcPf8IzXVh9HUdIOTvP2SlpL9fka0kGzF
C2OrBF8B0bEkcdUhR5oW
=qsdv
-----END PGP SIGNATURE-----

--Sig_/PnKP0Jv9UMNlzOdS+pELzop--

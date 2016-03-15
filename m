Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:39917 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755715AbcCOUhW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 15 Mar 2016 16:37:22 -0400
From: NeilBrown <neilb@suse.com>
To: "J. Bruce Fields" <bfields@fieldses.org>,
        William Dauchy <wdauchy@gmail.com>
Date: Wed, 16 Mar 2016 07:37:13 +1100
Cc: Linux NFS mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] sunrpc/cache: drop reference when sunrpc_cache_pipe_upcall() detects a race
In-Reply-To: <20160315131959.GA419@fieldses.org>
References: <87y49ylq76.fsf@notabene.neil.brown.name> <20160314203846.GA22276@fieldses.org> <CAJ75kXbNjwaf-QWQPq1=ooUxAPmA5qBEH9jGv+k92NEr-4eJXQ@mail.gmail.com> <20160315131959.GA419@fieldses.org>
Message-ID: <87vb4nh406.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
	micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, Mar 16 2016, J. Bruce Fields wrote:

> On Tue, Mar 15, 2016 at 01:43:37PM +0100, William Dauchy wrote:
>> Hello,
>>=20
>> On Mon, Mar 14, 2016 at 9:38 PM, J. Bruce Fields <bfields@fieldses.org> =
wrote:
>> > Sorry for the delay.  I agree, it seems simple enough; applying for
>> > 4.6....
>>=20
>> It it something we can consider for stable?
>
> It's an unlikely-looking race, I haven't seen it reported in the wild,
> and the consequences are just a reference-count leak (though admittedly
> those can sometimes cause crashes later--I haven't checked for that
> here).
>
> So I wasn't planning too, but any additional information's welcomed.

I agree that it isn't needed for stable - the race is tiny and the
consequence of losing the race is that entries get stuck in the cache
and possible an exported filesystem cannot be unmounted.  I don't think
that is a problem severe enough to meet the rules for -stable - though I
know the rules aren't always closely followed.

I wouldn't exactly object to it going to stable if someone wanted to
push, but I would rather it didn't appear in -stable before appearing in
a released (not -rc) kernel from Linus.

NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJW6HJ5AAoJEDnsnt1WYoG58AoQALnzoNaftT4lYAg0QwRdEAzW
zLKkFntKERmfLP6eyBlgMrKrOix9duXe8FZGBAup3KUPFTrcT4dLyEfXmMnA8n+f
z1Lmyeo69y3ZKCCR4g4FRdcnqJxZsZi5wlIboU0dQ0RdDDOVAr4g0liJW6Xj+bG9
+vzFt8JecYbFEJseZ1c+4geISqenW8frx0H3KADmyA2qW0/2/2q5s2dsjU9sg9VJ
3/Lwignw0efD6AYSZwt1QHpkQ3oJLp1egjRH56mcKBdv4byRiGgR27yg8CCaYCKS
9v+ngj8T/QT/JJt49IZhrKEdbpXY+81zsKmL/kAV9QGJRXgL7yNU5faJ2Z6NEQjY
PxHyRJusunMHUytlt4AmU/BEdwqFCioHyBk1q28HzR3Fm1Z/SOqoEe2ztsuyL9/f
TnC7WhyG1EsVEjE3Gnr9Po97khDQrgQFgFjXe2uvDS1VHMbIcSk3OeanB4olmEf9
nwD4kdrcdkYwrdszxIyvw8v8IyEcdZ1JlEK2yJ95X5kH4b0Uzhi8A6ghKdOt0nyN
f8AsfPozlRVlKRyy3gSX7XhFRTmDySFdgI6jXnwjqXzJhyHgKSj4Cb5cxH4/iQ4F
qBkyMBdrOTxL3JzJMr2nqefJYPjLurwttuDEVoHXTvQ0JVBznXXfmSC1zXXlzKNY
zhLZaxjgGb+nfuiN4JOL
=CHwc
-----END PGP SIGNATURE-----
--=-=-=--

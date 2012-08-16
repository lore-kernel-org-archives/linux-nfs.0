Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:50085 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932621Ab2HPVGF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 16 Aug 2012 17:06:05 -0400
Date: Fri, 17 Aug 2012 07:05:51 +1000
From: NeilBrown <neilb@suse.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: "ZUIDAM, Hans" <Hans.Zuidam@philips.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "DE WITTE, PETER" <PETER.DE.WITTE@philips.com>
Subject: Re: Linux NFS and cached properties
Message-ID: <20120817070551.6cfc1346@notabene.brown>
In-Reply-To: <20120816191018.GA4385@fieldses.org>
References: <D307B3AC0BCD4C419E6B8FA6A2720A9C0C3B2F@011-DB3MPN1-001.MGDPHG.emi.philips.com>
	<20120724143748.GC8570@fieldses.org>
	<D307B3AC0BCD4C419E6B8FA6A2720A9C18ABBA@011-DB3MPN1-001.MGDPHG.emi.philips.com>
	<20120726223607.GA28982@fieldses.org>
	<20120731150801.0a4b557b@notabene.brown>
	<20120731122546.GA26737@fieldses.org>
	<20120802100405.4dfc3169@notabene.brown>
	<20120816191018.GA4385@fieldses.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/S1lvezM2b8p6_3qfpsG/Dqn"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/S1lvezM2b8p6_3qfpsG/Dqn
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Thu, 16 Aug 2012 15:10:18 -0400 "J. Bruce Fields" <bfields@fieldses.org>
wrote:

> On Thu, Aug 02, 2012 at 10:04:05AM +1000, NeilBrown wrote:
> > I never liked that fact that stopping the last thread did something ext=
ra.
> > So when I added the ability to control the number of threads via sysfs =
I made
>=20
> (You meant nfsd, not sysfs, right?  Or is there some interface I'm
> overlooking?)

Right.

>=20
> > sure that it *only* controlled the number of threads.  However I kept t=
he
> > legacy behaviour that sending SIGKILL to the nfsd threads would also un=
export
> > things.  Obviously I should have documented this better.
> >=20
> > The more I think out it, the more I'd really like to go back to that.  =
It
> > really is the *right* thing to do.
> ...
> > > > 1/ iterate through all no-sleeping threads setting a flag an increa=
sing a
> > > > counter.
> > > > 2/ when a thread completes current request, if test_and_clear the f=
lag, it
> > > > atomic_dec_and_test the counter and then wakes up some wait_queue_h=
ead.
> > > > 3/ 'flush'ing thread waits on the waut_queue_head for the counter t=
o be 0.
> > > >=20
> > > > If you don't hate it I could possibly even provide some code.
>=20
> By the way, are you still looking into one of those approaches?

Not yet.  Other things got in the way.

I made a note to remind me when room appears in my schedule. :-)

NeilBrown

--Sig_/S1lvezM2b8p6_3qfpsG/Dqn
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.18 (GNU/Linux)

iQIVAwUBUC1grznsnt1WYoG5AQLIiRAAndd23v1EROMn7Y0uGI/gm1AspkS2/mAZ
nRgUEmb4BYpXZhJ1Dh1DhSWot9CIByjiEAnk3BsbTIfAql9/CYh98WnJWWW4wvqr
to+BcVonIv1QT7LcDKc4d+MWGQsZWQTrk7ZA7SR5IXvKE8vWVN0Piyeaq4KHCAsw
4NTe0e/1EpUjpkmONOj4TtxxKexOqDhM1NlD7cbBlDIT0NPDJWBPLPF+U4I28jjb
uiQE1SazZVYzWSLURodKUT8uL2+p94I4MAxtrjG6QJlWWMa7K/doNfj69KqlFMkm
/Eg9yRGEJfnOl1NzJ4u1IZPCHbcaDQg/qF1E8B1lSjtEKQcFbuyyfAw9rDxq4V8h
gw9vcUJh0R/TcUivKfgEBWH5E4N6du6lTafcOjRbuRFdgIl1IRbSIkk3yd0TeYYv
xSKD6IqE7+FxmBaK5Es6lh/lyPcuHTV+E1r+O3lhI5FoYtmI1TbmHNM+s58ZZxcD
WtNygzXmWvcTRzd0H94sr1LXhB+LnbGijFpIE0q5on91PS1GJuvVacMTXOit/ZJp
TYa+1FGyGogNYs1kUWEmpyVKbotsw+Aoba68mnWSxRRT9wlKuoluYCbbHSOD7RcU
L3qDfu2ie8s5cKotPqoCJqKDSteq8B7YC4ISB+NVXTVg3aBBeJslfXtkkfpZQZdi
seiKU0EErgA=
=AV2a
-----END PGP SIGNATURE-----

--Sig_/S1lvezM2b8p6_3qfpsG/Dqn--

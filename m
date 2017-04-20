Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:33714 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S944611AbdDTWMG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 20 Apr 2017 18:12:06 -0400
From: NeilBrown <neilb@suse.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Date: Fri, 21 Apr 2017 08:11:59 +1000
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsd: check for oversized NFSv2/v3 arguments
In-Reply-To: <20170420213014.GA6993@fieldses.org>
References: <20170414150440.GA5362@fieldses.org> <20170414150940.GB5362@fieldses.org> <87h91mtvdb.fsf@notabene.neil.brown.name> <20170418171351.GF6208@fieldses.org> <20170420161935.GB4782@fieldses.org> <20170420213014.GA6993@fieldses.org>
Message-ID: <87efwmsp8w.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Thu, Apr 20 2017, J. Bruce Fields wrote:

> On Thu, Apr 20, 2017 at 12:19:35PM -0400, J. Bruce Fields wrote:
>> On Tue, Apr 18, 2017 at 01:13:51PM -0400, J. Bruce Fields wrote:
>> > On Tue, Apr 18, 2017 at 10:25:20AM +1000, NeilBrown wrote:
>> > >  I can't say that I like this patch at all.
>> > >=20
>> > > The problem is that:
>> > >=20
>> > > 	pages =3D size / PAGE_SIZE + 1; /* extra page as we hold both reque=
st and reply.
>> > > 				       * We assume one is at most one page
>> > > 				       */
>> > >=20
>> > > this assumption is never verified.
>> > > To my mind, the "obvious" way to verify this assumption is that an
>> > > attempt to generate a multi-page reply should fail if there was a
>> > > multi-page request.
>> >=20
>> > A third option, by the way, which Ari Kauppi argued for, is adding a
>> > null check each time we increment rq_next_page, since we seem to arran=
ge
>> > for the page array to always be NULL-terminated.
>> >=20
>> > > Failing if there was a little bit of extra noise at the end of the
>> > > request seems harsher than necessary, and could result in a regressi=
on.
>> >=20
>> > You're worrying there might be a weird old client out there somewhere?
>> > I guess it seems like a small enough risk to me.  I'm more worried the
>> > extra garbage might violate assumptions elsewhere in the code.
>> >=20
>> > But, this looks good too:
>>=20
>> But, I'm not too happy about putting that NFSv2/v3-specific check in
>> common rpc code.  Also, I think this check comes too late for some of
>> the damage.

Too late?  It is earlier than anything else.

>>=20
>> I may go with some variation on Ari's idea, let me give it a try....
>
> In the read case, I think Ari's approach wouldn't catch the error until
> nfsd_direct_splice_actor(), which doesn't actually look capable of
> handling errors.  Maybe that should be fixed.  Or maybe read just needs
> some more checks.  Ugh.

By the time you get to nfsd_read(), the 'struct kvec' should be set up
and valid.  So we need checks is e.g. nfs3svc_decode_readargs(), but not
deeper.

NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlj5Mi8ACgkQOeye3VZi
gbk5SA/+MupzTbawy+KM0+MC16TdtbRZ5WvVyzf6L2iS0/bcp30QzLO6HAM4usOe
rqi5nkUIzyVe/erwo/Y8fTFTyH44IeUitCqQFTDFkEbX4qUKAI0m45NCVqMOyVcd
dbb81IXNVxuv5XmLsAy+N5R8VP5f81S4g7LXXyL3r4M+14p121gjy8KGxhGgD4ly
WyqGHx348rPphEKn4s5tSPxzd5wnU3U7lnyrTg250zxe/mMZkD2I/h9kRXq7LXvE
jhkspvivbI96yhqfGmnJvy3WjmdVLNt6EN4q7YKHnGf4yyA8NiyB4NMn8xZVY0Lu
EGB044TwRuXYjf/jipxjepAlmxZDU/Xrpzl3iHkP2Duf4yQCBebpFsGiPo6DjNEM
PNTfIAjRxRJaTmHOyw5kjl4/leeGBtkg5gE+McZsDXbP7IR5xoe3rNRbRhGs3pmd
9z46BwTHqlmt3GJ6LgWxRlfMuXKf+++zXPkDv+Mvmsi1UTsLkZEOYOkI0kFfXgMy
JjGvrrth6OTgwW5dMK9gP75LlH/U1TtcWQV/nBNygfM40v4mLUtokfCFHokYCWNw
SfV9/yh5fQhpxPGoxdw2f0yR9Kp0+3SLvMy/71UyTgAHE8Oa84lEgNiCi2ML40Wx
Bnal3mpxqI9xENFp/09saqUYcvrNuG/d2g3im5tBFY0VGQNCvkI=
=O17d
-----END PGP SIGNATURE-----
--=-=-=--

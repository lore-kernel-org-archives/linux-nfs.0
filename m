Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:55264 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S940630AbdDTA5T (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 19 Apr 2017 20:57:19 -0400
From: NeilBrown <neilb@suse.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Date: Thu, 20 Apr 2017 10:57:10 +1000
Cc: linux-nfs@vger.kernel.org, Neil Brown <neilb@suse.de>
Subject: Re: [PATCH] nfsd: check for oversized NFSv2/v3 arguments
In-Reply-To: <20170419004405.GA13002@fieldses.org>
References: <20170414150440.GA5362@fieldses.org> <20170414150940.GB5362@fieldses.org> <87h91mtvdb.fsf@notabene.neil.brown.name> <20170418171351.GF6208@fieldses.org> <878tmxtfne.fsf@notabene.neil.brown.name> <20170419004405.GA13002@fieldses.org>
Message-ID: <87y3uvsxp5.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Tue, Apr 18 2017, J. Bruce Fields wrote:

> On Wed, Apr 19, 2017 at 10:17:09AM +1000, NeilBrown wrote:
>> On Tue, Apr 18 2017, J. Bruce Fields wrote:
>>=20
>> > On Tue, Apr 18, 2017 at 10:25:20AM +1000, NeilBrown wrote:
>> >>  I can't say that I like this patch at all.
>> >>=20
>> >> The problem is that:
>> >>=20
>> >> 	pages =3D size / PAGE_SIZE + 1; /* extra page as we hold both reques=
t and reply.
>> >> 				       * We assume one is at most one page
>> >> 				       */
>> >>=20
>> >> this assumption is never verified.
>> >> To my mind, the "obvious" way to verify this assumption is that an
>> >> attempt to generate a multi-page reply should fail if there was a
>> >> multi-page request.
>> >
>> > A third option, by the way, which Ari Kauppi argued for, is adding a
>> > null check each time we increment rq_next_page, since we seem to arran=
ge
>> > for the page array to always be NULL-terminated.
>>=20
>> Not a bad idea.   That is what nfsaclsvc_encode_getaclres() and
>> nfs3svc_encode_getaclres do.
>> Hmm... your change to xdr_argsize_check will break
>> nfsaclsvc_decode_setaclargs(), won't it?  It performs the check before
>> the final nfsacl_decode().
>
> Ugh, I forget that I don't run any tests for NFSv3 ACLs.  Well, that
> would be easy enough to fix....
>
>> >> I haven't tested this at all and haven't even convinced myself that
>> >> it covers every case (though I cannot immediately think of any likely
>> >> corners).
>> >>=20
>> >> Does it address your test case?
>> >
>> > I'll check, it probably does.
>> >
>> > We'd need to limit the test to v2/v3.
>>=20
>> Why?  Does v4 allocate extra pages?  Or is it more careful about using
>> them?
>> v4 does need something different, as pc_xdrressize is always zero..
>
> NFSv4 compounds just don't have that limitation.  You can read and write
> in the same compound if you want.  (Why you'd want to, I've no idea.)

I realise NFSv4 compounds don't have that limitation.
I wondered what code in the NFSv4 server ensures that we don't try to use
more memory than was allocated.

I notice lots of calls to xdr_reserve_space() in nfs4xdr.c.  Many of them
trigger nfserr_resource when xdr_reserve_space() returns NULL.
But not all.
nfsd4_encode_readv() just pops up a warning.  Once.  Then will
(eventually) de-reference the NULL pointer and crash.
So presumably it really cannot happen (should be a BUG_ON anyway)?
So why can this not happen?
I see that nfsd4_encode_read() limits the size of the read to
  xdr->buf->buflen - xdr->buf->len
and nfsd4_encode_readdir() does a similar thing when computing
bytes_left.

So, it is more careful about using the allocated pages than v2/3 is.

Thanks,
NeilBrown

>
> (In fact, I think at least in the version >=3D4.1 case we should probably
> only be placing limits on argument and reply sizes individually, so our
> current implementation (which also places limits on the sum of the two)
> is probably wrong.  This doesn't keep me up at night.)
>
> --b.

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlj4B2cACgkQOeye3VZi
gbnkYg//dglvJPVaOm90x5urkgzEZjUUaI2kdwCD72I3TQQAa5CaRjs4KB/YFZRp
4nt0aqqPl2SlwoLOum/wZ37Ng6wHBS/ZgELFhSEBdA4rTTYVx0kWvqBspckHcdlc
W+u3joqN/YE8Pe9lRTlGFpEiECfJ4dXNpYBmo5Bk+kgLOdFTacUWvMP+F9x7yz1D
eFp5gSRGTfJfKaaVTWIwj9mgA72SsSU0Iins6q93efWiuEwHCSP9bZnuTjxGqW7P
SMQu0BZRheivuE8rGYxAcB2+idxCOC1zNxUvl1qq+M6V+60YBW6oV1CcHdLulOXm
lYF4ozHKqJI0bKHTEq0LndupKXMPa3E0CABHw6QdTDiBgUFzc8gSjdrk2ndsjtaP
6P4g0x0bABCAI3/tu2tMB1Id6Hk/rGazvhWruqQdYuMAQiD591WOPiMu99iVmrJf
nyRQXfrdIxe5BEwGcbeU5CgoE/xDfwjDWoSdjDRaia9Gd4qwtYjP/t72FnNRBgv2
zFxJwV8hdKY+h6kKwUxusMMmtDOAvX7dr/T/kriLZ1Wcmyb/oXK0FkNOU4mlt4b/
T22Ai8qn9Wxgw0AEtbD8ieNHM+3pE7VPMeFetpqIbE65Uls0kGd43CUFL6zkIbHI
NH/ySgAo3s8s/wtJO+yz/SgkJnhUO18bToF0vUYVFEN5SwXax6o=
=Foow
-----END PGP SIGNATURE-----
--=-=-=--

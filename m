Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:46986 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965194AbbEMA4M (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 12 May 2015 20:56:12 -0400
Date: Wed, 13 May 2015 10:56:04 +1000
From: NeilBrown <neilb@suse.de>
To: Shaohua Li <shli@kernel.org>
Cc: linux-raid@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 7/7] md/raid5: fix handling of degraded stripes in
 batches.
Message-ID: <20150513105604.55ac700a@notabene.brown>
In-Reply-To: <20150508191223.GA116778@kernel.org>
References: <20150508085345.19179.8866.stgit@notabene.brown>
	<20150508085612.19179.92120.stgit@notabene.brown>
	<20150508191223.GA116778@kernel.org>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 boundary="Sig_/9Y0wdredF1_E+9pUGcz3deW"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/9Y0wdredF1_E+9pUGcz3deW
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Fri, 8 May 2015 12:12:23 -0700 Shaohua Li <shli@kernel.org> wrote:

> On Fri, May 08, 2015 at 06:56:12PM +1000, NeilBrown wrote:
> > There is no need for special handling of stripe-batches when the array
> > is degraded.
> >=20
> > There may be if there is a failure in the batch, but STRIPE_DEGRADED
> > does not imply an error.
> >=20
> > So don't set STRIPE_BATCH_ERR in ops_run_io just because the array is
> > degraded.
> > This actually causes a bug: the STRIPE_DEGRADED flag gets cleared in
> > check_break_stripe_batch_list() and so the bitmap bit gets cleared
> > when it shouldn't.
> >=20
> > So in check_break_stripe_batch_list(), split the batch up completely -
> > again STRIPE_DEGRADED isn't meaningful.
> >=20
> > Also don't set STRIPE_BATCH_ERR when there is a write error to a
> > replacement device.  This simply removes the replacement device and
> > requires no extra handling.
> >=20
> > Signed-off-by: NeilBrown <neilb@suse.de>
> > ---
> >  drivers/md/raid5.c |   17 +++--------------
> >  1 file changed, 3 insertions(+), 14 deletions(-)
> >=20
> > diff --git a/drivers/md/raid5.c b/drivers/md/raid5.c
> > index 3873eaa6fa2e..1ba97fdc6df1 100644
> > --- a/drivers/md/raid5.c
> > +++ b/drivers/md/raid5.c
> > @@ -1078,9 +1078,6 @@ again:
> >  			pr_debug("skip op %ld on disc %d for sector %llu\n",
> >  				bi->bi_rw, i, (unsigned long long)sh->sector);
> >  			clear_bit(R5_LOCKED, &sh->dev[i].flags);
> > -			if (sh->batch_head)
> > -				set_bit(STRIPE_BATCH_ERR,
> > -					&sh->batch_head->state);
> >  			set_bit(STRIPE_HANDLE, &sh->state);
> >  		}
>=20
> Patches look good to me. I had a question here. Is it possible some strip=
es in
> a batch become degraded here but some not? Seems possible, then the batch
> should be splitted too.

Why?

I don't really understand the purpose of splitting up the batch.
The only possible error handling on a full-stripe write is:
 - fail a device, or
 - record a bad-block.

The first case affects all stripes in a batch equally so there is no need to
split it up.
The second case it is probably best to record the bad blocks while iterating
through the batch in handle_stripe_clean_event().

What exactly do you expect to happen after the stripes in a batch after they
have been split up?

Thanks,
NeilBrown

--Sig_/9Y0wdredF1_E+9pUGcz3deW
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUBVVKhJDnsnt1WYoG5AQIZ0BAAgP1Pmkoanw90j9714cc/B7NFvkLx7PC6
ddMnj8xmsTthdsTgdKCqAugi6FhBzmRTazDN9IHDMXQIT37ZBlxjd5w25yM3ohXQ
aIODlzqkRMfbCgH7PR+lYkkKJ+Ut6eJ7Ik5K/DKjPDiljAj4sqdVmpoy/EIpVuod
7dguOmzB7BsucgxlNYU2WyMZA1Fb2nD4zJ+oOhy5+QpOrIuCuUAqJPUNRrsseLWf
Y+tByYAoDZ6f2SmIUYUawD/kKs6KPZiFvy4cD3gvtBB4/BrZla6eitMnzJEbjmxu
Tx08DWMAzqWHuiKzUudu5+/VWKAsw+t0fkVYVMi8t5GuZrLenU7sE2VTsPt1qSMr
vCVBsRKu6B4Rbht+g0SOnOqruDFrC9JpSdm4KMV4MVaN6D3yPVYC0cpLXCFq/4mR
Nd4Jyh6Dczuvw+JDbcIoXWXz8YGteHdg99DEn2dCO1WHmKR0mLLOJog5zQFGhQ5T
yzaAM/U6tw2GsH9qJaw3ZalaTD1NJXjkfw2ANQceNkkmLZ8TogzLfW/51N+Rc67L
wzIwVAqauLnDIn4NPbKmumLtAJTXMynhJQseIn9qSDkUCkI7vwX+614/T0LVFO+Z
Nkghs1MSlLhZVv871Pu39uZCd3EyJ5kQy4bbzAf+Oh6vK5UcVxeVawFjchLwJibI
ixg0I8IbjBQ=
=et1C
-----END PGP SIGNATURE-----

--Sig_/9Y0wdredF1_E+9pUGcz3deW--

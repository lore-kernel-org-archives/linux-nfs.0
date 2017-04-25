Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:44074 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S979904AbdDYDAZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 24 Apr 2017 23:00:25 -0400
From: NeilBrown <neilb@suse.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Date: Tue, 25 Apr 2017 13:00:16 +1000
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsd: check for oversized NFSv2/v3 arguments
In-Reply-To: <20170424211920.GA1585@fieldses.org>
References: <20170414150440.GA5362@fieldses.org> <20170414150940.GB5362@fieldses.org> <87h91mtvdb.fsf@notabene.neil.brown.name> <20170418171351.GF6208@fieldses.org> <20170420161935.GB4782@fieldses.org> <20170421211253.GE19775@fieldses.org> <87vapurci7.fsf@notabene.neil.brown.name> <20170424140642.GB30046@fieldses.org> <20170424211920.GA1585@fieldses.org>
Message-ID: <87r30hp4xr.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On Mon, Apr 24 2017, J. Bruce Fields wrote:

> On Mon, Apr 24, 2017 at 10:06:42AM -0400, J. Bruce Fields wrote:
>> On Mon, Apr 24, 2017 at 08:21:36AM +1000, NeilBrown wrote:
>> > I like this.  I think this should be the basis of what goes to -stable,
>> > and other improvements should stay in mainline.
>> >=20
>> > The only change I would suggest would be to be explicit about where the
>> > nfsacl protocol fits with this.
>>=20
>> Oh, good point, I'd forgotten nfsd_dispatch handles multiple protocols!
>
> That was getting to be kind of a pile of conditions for one "if", and
> the comments were getting a little long-winded, so I split it out, but
> otherwise it's the same idea.
>
> --b.
>
> commit 43e06bcafea8
> Author: J. Bruce Fields <bfields@redhat.com>
> Date:   Fri Apr 21 16:10:18 2017 -0400
>
>     nfsd: check for oversized NFSv2/v3 arguments
>=20=20=20=20=20
>     A client can append random data to the end of an NFSv2 or NFSv3 RPC c=
all
>     without our complaining; we'll just stop parsing at the end of the
>     expected data and ignore the rest.
>=20=20=20=20=20
>     Encoded arguments and replies are stored together in an array of page=
s,
>     and if a call is too large it could leave inadequate space for the
>     reply.  This is normally OK because NFS RPC's typically have either
>     short arguments and long replies (like READ) or long arguments and sh=
ort
>     replies (like WRITE).  But a client that sends an incorrectly long re=
ply
>     can violate those assumptions.  This was observed to cause crashes.
>=20=20=20=20=20
>     Also, several operations increment rq_next_page in the decode routine
>     before checking the argument size, which can leave rq_next_page point=
ing
>     well past the end of the page array, causing trouble later in
>     svc_free_pages.
>=20=20=20=20=20
>     So, following a suggestion from Neil Brown, add a central check to
>     enforce our expectation that no NFSv2/v3 call has both a large call a=
nd
>     a large reply.
>=20=20=20=20=20
>     As followup we may also want to rewrite the encoding routines to check
>     more carefully that they aren't running off the end of the page array.
>=20=20=20=20=20
>     We may also consider rejecting calls that have any extra garbage
>     appended.  That would be safer, and within our rights by spec, but gi=
ven
>     the age of our server and the NFS protocol, and the fact that we've
>     never enforced this before, we may need to balance that against the
>     possibility of breaking some oddball client.
>=20=20=20=20=20
>     Reported-by: Tuomas Haanp=C3=A4=C3=A4 <thaan@synopsys.com>
>     Reported-by: Ari Kauppi <ari@synopsys.com>
>     Cc: stable@vger.kernel.org
>     Signed-off-by: J. Bruce Fields <bfields@redhat.com>
>
> diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
> index 31e1f9593457..59979f0bbd4b 100644
> --- a/fs/nfsd/nfssvc.c
> +++ b/fs/nfsd/nfssvc.c
> @@ -747,6 +747,37 @@ static __be32 map_new_errors(u32 vers, __be32 nfserr)
>  	return nfserr;
>  }
>=20=20
> +/*
> + * A write procedure can have a large argument, and a read procedure can
> + * have a large reply, but no NFSv2 or NFSv3 procedure has argument and
> + * reply that can both be larger than a page.  The xdr code has taken
> + * advantage of this assumption to be a sloppy about bounds checking in
> + * some cases.  Pending a rewrite of the NFSv2/v3 xdr code to fix that
> + * problem, we enforce these assumptions here:
> + */
> +static bool nfs_request_too_big(struct svc_rqst *rqstp,
> +				struct svc_procedure *proc)
> +{
> +	/*
> +	 * The ACL code has more careful bounds-checking and is not
> +	 * susceptible to this problem:
> +	 */
> +	if (rqstp->rq_prog !=3D NFS_PROGRAM)
> +		return false;
> +	/*
> +	 * Ditto NFSv4 (which can in theory have argument and reply both
> +	 * more than a page):
> +	 */
> +	if (rqstp->rq_vers >=3D 4)
> +		return false;
> +	/* The reply will be small, we're OK: */
> +	if (proc->pc_xdrressize > 0 &&
> +	    proc->pc_xdrressize < XDR_QUADLEN(PAGE_SIZE))
> +		return false;
> +
> +	return rqstp->rq_arg.len > PAGE_SIZE;
> +}
> +
>  int
>  nfsd_dispatch(struct svc_rqst *rqstp, __be32 *statp)
>  {
> @@ -759,6 +790,11 @@ nfsd_dispatch(struct svc_rqst *rqstp, __be32 *statp)
>  				rqstp->rq_vers, rqstp->rq_proc);
>  	proc =3D rqstp->rq_procinfo;
>=20=20
> +	if (nfs_request_too_big(rqstp, proc)) {
> +		dprintk("nfsd: NFSv%d argument too large\n", rqstp->rq_vers);
> +		*statp =3D rpc_garbage_args;
> +		return 1;
> +	}
>  	/*
>  	 * Give the xdr decoder a chance to change this if it wants
>  	 * (necessary in the NFSv4.0 compound case)

Yes, that's much nicer :-)
Reviewed-by: NeilBrown <neilb@suse.com>

Thanks,
NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlj+u8AACgkQOeye3VZi
gbnZ8g//Y9P949/l2U+sQOvR+9ogdiEn/j02SBaEBj6DRpjHFGZvmo1j1Suk/+rS
tJJHr2sVQkIoETbSJXAz9SfsxrkNwZd7P5c9boutOJHk+jbihsPIW2xAIKBB5YMI
Ifpkady6BalWC9rTBEgnZQooMaSZU8DnO/2+P5Lq9AaYYdhpO5QL+89M3JdNslV6
pPgneFDHbAy2dt/EJsIVlHgl+Zc/Di0N6isUPcKumnWXclkzNZCokyq5MzUithuO
9mBFnuHEz60z+T9hL1LbSHEQPJKzYO16+xqv15AiJgMlEW4K97CwDY3hlyw9fIE5
gO7GXCNCXp02OaYputHgjOkN2CbuBvEqO3D9Qw5QxUkd8NV/cj/ADkJdTQelKFDQ
4lYVGnTII29dUDk/DGJ7lNVf7JrVr6Xbk6a/n+brXFEd1b243KTPIoUNaN/368Ic
wLpLl2/zZVFCSbMa68O94qxyOuCyQ4DdyXAMaplJ2iYBt/mhZexQTc0JUCdDhrUU
LTphLOXjnJkYWyhPNBUsEvK5J+QxBKuaPTgOo0S47y62uhhbrRl3i0YHrkgYRWgb
gBgGYp7c5XadM6ZHa5l1aaaP8DGBj7sxy9uJTBMGiEmxhrevBP5h3Sy2DWVlfH5V
OgRhFwtphvueUTv2ArgjJJK+IkqbPL6FRUUYrHssiLt6gwFVZu4=
=RNxl
-----END PGP SIGNATURE-----
--=-=-=--

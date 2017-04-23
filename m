Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:60938 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1046209AbdDWWVp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sun, 23 Apr 2017 18:21:45 -0400
From: NeilBrown <neilb@suse.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Date: Mon, 24 Apr 2017 08:21:36 +1000
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsd: check for oversized NFSv2/v3 arguments
In-Reply-To: <20170421211253.GE19775@fieldses.org>
References: <20170414150440.GA5362@fieldses.org> <20170414150940.GB5362@fieldses.org> <87h91mtvdb.fsf@notabene.neil.brown.name> <20170418171351.GF6208@fieldses.org> <20170420161935.GB4782@fieldses.org> <20170421211253.GE19775@fieldses.org>
Message-ID: <87vapurci7.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Fri, Apr 21 2017, J. Bruce Fields wrote:

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
>> common rpc code.
>
> Well, but it should work just as well in nfsd_dispatch, I think?
> (Untested).  So, maybe that's simplest as a first step:
>
> diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
> index 31e1f9593457..b6298d30a01f 100644
> --- a/fs/nfsd/nfssvc.c
> +++ b/fs/nfsd/nfssvc.c
> @@ -759,6 +759,22 @@ nfsd_dispatch(struct svc_rqst *rqstp, __be32 *statp)
>  				rqstp->rq_vers, rqstp->rq_proc);
>  	proc =3D rqstp->rq_procinfo;
>=20=20
> +	if (rqstp->rq_vers < 4 &&
> +	    (proc->pc_xdrressize =3D=3D 0
> +			|| proc->pc_xdrressize > XDR_QUADLEN(PAGE_SIZE))
> +		&& rqstp->rq_arg.len > PAGE_SIZE) {
> +		/*
> +		 * NFSv2 and v3 assume that an operation may have either a
> +		 * large argument, or a large reply, but never both.
> +		 *
> +		 * NFSv4 may handle compounds with both argument and
> +		 * reply larger than a reply; it has more xdr careful
> +		 * xdr decoding which can handle such calls safely.
> +		 */
> +		dprintk("nfsd: NFSv%d argument too large\n", rqstp->rq_vers);
> +		*statp =3D rpc_garbage_args;
> +		return 1;
> +	}
>  	/*
>  	 * Give the xdr decoder a chance to change this if it wants
>  	 * (necessary in the NFSv4.0 compound case)

I like this.  I think this should be the basis of what goes to -stable,
and other improvements should stay in mainline.

The only change I would suggest would be to be explicit about where the
nfsacl protocol fits with this.

We could change "rqstp->rq_vers < 4" to
 "rqstp->rq_prog =3D=3D NFS_PROGRAM && rqstp->rq_vers < 4"
or we could change the text:
 NFSv2 and v3 assume ...
to
 NFSv2 and v3, along with NFSASL, assume ...

and possibly change "rqstp->rq_vers < 4" to "!nfsd_v4client(rqstp)".

I believe none of this applies to lockd as none of that code ever looks
beyond a single page.

Thanks,
NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlj9KPAACgkQOeye3VZi
gblklA//bhFClNAxi2y94dndpjslsavxqvDtTJ9GuBJH0FWpV8KHwM5Y2OBBycvc
pTdUQZQ3ZnmKG2BU1+ImDiA4dU096x0/1fCPD3Smt4W2IqfB2UvDGUKEoT6KwG26
CsKDfUsQhJaRNCG28KQuukPrJn+sXbWWiZ0rzormqoSWyHVbPPFD527waemdtb3W
Mjbc4GnTKBiaG/bqhQZKj2IC1SDn9m7ByqpGQqFznT1iaxwtfbraQIQQD7GudMlv
Hb6filw6WNvER4C4u8OVKhGM+oBmBtv733OxB4C/s6oxro5UqAnjHqRe0s3c/Rh0
zQIfyxUOq48UMBrjNgEftjEHQLXigfyLtksHrgXq7Qfqp8qrroINRT1zXgu3bsT2
X/JhfxkfLFIvOieWkeGRWHvX0QXbvgNBGnpIlhXP1hUimO4GXofUT8ap91X8S0Jh
Roh3LSdE/9+5E96H/EdibEDxlOEW9o2aLUih0H+I7ufWIuftUIVpxNFwazrj5nXC
X12Z302Si1f5gOQbkmUSxvHmlkgivz35GSZNRjfXdHSdgY/IOz4GD+wl4cQr8Q/A
uYQH/xr8693SZWAiqfeZ3gGOmIEu24L9q5Yh13DfF4VUleQvo7oMSv9ag/RKlcNU
YciwtxetJ16N+2tKNd2HenK7M0YCFErh7iixJ3jon3gBHVFG91E=
=alAG
-----END PGP SIGNATURE-----
--=-=-=--

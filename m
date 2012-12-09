Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:55371 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751321Ab2LIXh3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 9 Dec 2012 18:37:29 -0500
Date: Mon, 10 Dec 2012 10:37:15 +1100
From: NeilBrown <neilb@suse.de>
To: "J.Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] - avoid permission checks on EXCLUSIVE_CREATE replay
Message-ID: <20121210103715.6b0be8c5@notabene.brown>
In-Reply-To: <20121207225036.GA4078@fieldses.org>
References: <20100422101042.226f71d6@notabene.brown>
	<20100422162533.GH5926@fieldses.org>
	<20100423071631.27ff3a5a@notabene.brown>
	<20100422211801.GF10302@fieldses.org>
	<20121207225036.GA4078@fieldses.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/nex_kJxhWcTXtIjmvLQz=l8"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/nex_kJxhWcTXtIjmvLQz=l8
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Fri, 7 Dec 2012 17:50:36 -0500 "J.Bruce Fields" <bfields@fieldses.org>
wrote:

> On Thu, Apr 22, 2010 at 05:18:01PM -0400, J.Bruce Fields wrote:
> > On Fri, Apr 23, 2010 at 07:16:31AM +1000, Neil Brown wrote:
> > > On Thu, 22 Apr 2010 12:25:33 -0400
>
> Always fun to reply on 2-year-old threads:

So *that* is why I don't delete old email.  It means that when I get
replies two years later, they get added to the right thread and I have all
the right context.  Now I can stop feeling guilty about it - thanks.

>=20
> > > "J.Bruce Fields" <bfields@fieldses.org> wrote:
> > >=20
> > > > On Thu, Apr 22, 2010 at 10:10:42AM +1000, Neil Brown wrote:
> > > > >=20
> > > > > With NFSv4, if we create a file then open it we explicit avoid ch=
ecking the
> > > > > permissions on the file during the open because the fact that we =
created it
> > > > > ensures we should be allow to open it (the create and the open sh=
ould appear
> > > > > to be a single operation).
> > > > >=20
> > > > > However if the reply to an EXCLUSIVE create gets lots and the cli=
ent resends
> > > > > the create, the current code will perform the permission check - =
because it
> > > > > doesn't realise that it did the open already..
> > > > >=20
> > > > > This patch should fix this.
> > > >=20
> > > > Thanks, but: hm, does this leave a loophole for a clever attacker?
> > > > They'll still have to get past the initial
> > > >=20
> > > > 	fh_verify(rqstp, fhp, S_IFDIR, NFSD_MAY_CREATE)
> > > >=20
> > > > but that just checks the parent directory; if the existing file is
> > > > actually owned by someone else, do we allow an open that we shouldn=
't?
> > > >=20
> > > > Maybe when "created" is set we should keep the permission check but=
 add
> > > > NFSD_ALLOW_OWNER_OVERRIDE?
> > > >=20
> > >=20
> > > I think that is possibly a good idea.  However......
> > >=20
> > > commit 81ac95c5569d7a60ab5db6c1ccec56c12b3ebcb5
> > > Author: J. Bruce Fields <bfields@fieldses.org>
> > > Date:   Wed Nov 8 17:44:40 2006 -0800
> > >=20
> > >     [PATCH] nfsd4: fix open-create permissions
> > >    =20
> > >     In the case where an open creates the file, we shouldn't be reche=
cking
> > >     permissions to open the file; the open succeeds regardless of wha=
t the new
> > >     file's mode bits say.
> > >    =20
> > >     This patch fixes the problem, but only by introducing yet another=
 parameter
> > >     to nfsd_create_v3.  This is ugly.  This will be fixed by later pa=
tches.
> > >    =20
> > >=20
> > > I wouldn't want to get in the way of these 'later patches' that might=
 be
> > > going to remove the 'created' flag from nfsd_create_v3 :-)
> >=20
> > Har.  I was optimistic.
> >=20
> > That code *is* really hairy.  I'll take another look.
>=20
> Well, it remains as ugly as ever, but pynfs just reminded me that I'd
> forgotten that the original bug still needed fixing!
>=20
> Version I plan to merge follows.


Patch looks good to me.
Thanks!

NeilBrown





>=20
> commit 1895f5075c59f6a7b5e4c3a59ffe108e881f69d4
> Author: Neil Brown <neilb@suse.de>
> Date:   Fri Dec 7 15:40:55 2012 -0500
>=20
>     nfsd: avoid permission checks on EXCLUSIVE_CREATE replay
>    =20
>     With NFSv4, if we create a file then open it we explicit avoid checki=
ng
>     the permissions on the file during the open because the fact that we
>     created it ensures we should be allow to open it (the create and the
>     open should appear to be a single operation).
>    =20
>     However if the reply to an EXCLUSIVE create gets lots and the client
>     resends the create, the current code will perform the permission chec=
k -
>     because it doesn't realise that it did the open already..
>    =20
>     This patch should fix this.
>    =20
>     Note that I haven't actually seen this cause a problem.  I was just
>     looking at the code trying to figure out a different EXCLUSIVE open
>     related issue, and this looked wrong.
>    =20
>     Cc: stable@kernel.org
>     Signed-off-by: NeilBrown <neilb@suse.de>
>     [bfields: use OWNER_OVERRIDE and update for 4.1]
>     Signed-off-by: J. Bruce Fields <bfields@redhat.com>
>=20
> diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
> index 85a6915..beaa99f 100644
> --- a/fs/nfsd/nfs4proc.c
> +++ b/fs/nfsd/nfs4proc.c
> @@ -195,6 +195,7 @@ static __be32
>  do_open_lookup(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct=
 nfsd4_open *open)
>  {
>  	struct svc_fh *resfh;
> +	int accmode;
>  	__be32 status;
> =20
>  	resfh =3D kmalloc(sizeof(struct svc_fh), GFP_KERNEL);
> @@ -254,9 +255,10 @@ do_open_lookup(struct svc_rqst *rqstp, struct svc_fh=
 *current_fh, struct nfsd4_o
>  	/* set reply cache */
>  	fh_copy_shallow(&open->op_openowner->oo_owner.so_replay.rp_openfh,
>  			&resfh->fh_handle);
> -	if (!open->op_created)
> -		status =3D do_open_permission(rqstp, resfh, open,
> -					    NFSD_MAY_NOP);
> +	accmode =3D NFSD_MAY_NOP;
> +	if (open->op_created)
> +		accmode |=3D NFSD_MAY_OWNER_OVERRIDE;
> +	status =3D do_open_permission(rqstp, resfh, open, accmode);
>  	set_change_info(&open->op_cinfo, current_fh);
>  	fh_dup2(current_fh, resfh);
>  out:
> diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
> index b584205..0ef9b6b 100644
> --- a/fs/nfsd/vfs.c
> +++ b/fs/nfsd/vfs.c
> @@ -1471,13 +1471,19 @@ do_nfsd_create(struct svc_rqst *rqstp, struct svc=
_fh *fhp,
>  		case NFS3_CREATE_EXCLUSIVE:
>  			if (   dchild->d_inode->i_mtime.tv_sec =3D=3D v_mtime
>  			    && dchild->d_inode->i_atime.tv_sec =3D=3D v_atime
> -			    && dchild->d_inode->i_size  =3D=3D 0 )
> +			    && dchild->d_inode->i_size  =3D=3D 0 ) {
> +				if (created)
> +					*created =3D 1;
>  				break;
> +			}
>  		case NFS4_CREATE_EXCLUSIVE4_1:
>  			if (   dchild->d_inode->i_mtime.tv_sec =3D=3D v_mtime
>  			    && dchild->d_inode->i_atime.tv_sec =3D=3D v_atime
> -			    && dchild->d_inode->i_size  =3D=3D 0 )
> +			    && dchild->d_inode->i_size  =3D=3D 0 ) {
> +				if (created)
> +					*created =3D 1;
>  				goto set_attr;
> +			}
>  			 /* fallthru */
>  		case NFS3_CREATE_GUARDED:
>  			err =3D nfserr_exist;


--Sig_/nex_kJxhWcTXtIjmvLQz=l8
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQIVAwUBUMUgqznsnt1WYoG5AQI7bQ//Te7KfzBbFOGB1GAzCGKg5MglCJnK4ukC
5+xQA4OsFVachRt+dskGCQXOCqjp0mt1R8wm6PXZcKcy24aQHqiMu6yRO86YIzGs
/vpFSr4R91f+9MsWl3LMYXj3RAlLWVfCELMUKdMskxWzOPx+qWmfgptFGHnxHmWA
9DChUP3pKaR89GaqJK+TuGY7MdG3IPltXJpud9T6bPU27scPCZtiz1TWVNfoYOnB
iOZOaoLszBiI0j+fmYUiSKs3XZdRQjCOdqlqrn5kApLcqpuDHaYiRdQmisR3EM/K
OTfqOZGN21h1xM43emgUwIwSWWv9L+hHpzwZ+qhc4WUIY5eDIt1ZFltrM7AeQkyD
ZUBFYHa8aTOPTD9f/dGH1lqHkvHKaBwmkksnMRFpoDP0dt9TC35LG/SmVqojiOez
qp9TIG22W476XzYr/IhGKNRI3alqySaqhf46qQBLb+1xb/XWwSmzmQMpsN0uimAs
jgBWp3AxmoF73Qpo22kXDqUd0t4eXNMXK7spjGo36lM1q+/ZQ5J2hccWvcHRp9bZ
i0ZelNFUwHqkAW9ZGaI05nTY1x+eLLFicTsr59U/XQ5qvXTSvTuY2lRyFckmZnx/
uweQezUFWrRM6z3rgTNx3qmtZrstt+mE0mEOOysEfipe1CWoD/6zGmD6WjEE1t/x
0hbUAr7mq3U=
=ds4k
-----END PGP SIGNATURE-----

--Sig_/nex_kJxhWcTXtIjmvLQz=l8--

Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:60826 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755706AbbEUXBf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 21 May 2015 19:01:35 -0400
Date: Fri, 22 May 2015 09:01:27 +1000
From: NeilBrown <neilb@suse.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: NFS <linux-nfs@vger.kernel.org>
Subject: Re: Does NFSv4 need to call inode_permission on every write???
Message-ID: <20150522090127.1571fcb7@notabene.brown>
In-Reply-To: <20150521130735.GA27065@fieldses.org>
References: <20150521144029.57f1b33f@notabene.brown>
	<20150521130735.GA27065@fieldses.org>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 boundary="Sig_/Sj1wL4A/hruwTrBEyMad_f5"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/Sj1wL4A/hruwTrBEyMad_f5
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Thu, 21 May 2015 09:07:35 -0400 "J. Bruce Fields" <bfields@fieldses.org>
wrote:

> On Thu, May 21, 2015 at 02:40:29PM +1000, NeilBrown wrote:
> >=20
> >=20
> > Apologies if this has been answered before, however...
> >=20
> > In nfsd_write() we have:
> >=20
> > 	if (file) {
> > 		err =3D nfsd_permission(rqstp, fhp->fh_export, fhp->fh_dentry,
> > 				NFSD_MAY_WRITE|NFSD_MAY_OWNER_OVERRIDE);
> > 		if (err)
> > 			goto out;
> > 		err =3D nfsd_vfs_write(rqstp, fhp, file, offset, vec, vlen, cnt,
> > 				stablep);
> > 	} else {
> >=20
> > So if a 'file' is already available - because the request came via NFSv=
4 and
> > there was a valid state id, and a 'struct file' was associated with that
> > state - we still call nfsd_permission().
> >=20
> > Is that really needed?  The permission check will have been performed a=
t open
> > - it shouldn't be needed again now.
> >=20
> > With NFSv3 we have to check permission at each IO, and this is slightly
> > different from POSIX semantics.  We shouldn't have to with NFSv4... sho=
uld we?
> >=20
> > The particular issue that brought this to my attention is that "chattr =
+i" -
> > to make a file immutable - is not supposed to affect current opens, only
> > future opens.  But a current open over NFSv4 is affected.
> >=20
> > Is there some reason that we cannot just remove that nfsd_permission() =
check?
>=20
> The only proof that this write is part of the open is a stateid provided
> as part of the write arguments.  Anyone could sniff or guess that
> stateid.

But a stateid is tied to a clientid and the clientid is tied to server
credentials....??

I guess it is harder than I at first imagined.

>=20
> We could try to make that work by checking the stateid against the
> principal from the rpc header.  Unfortunately that turns out to be more
> complicated than "is this the same principal as did the open"; among
> other things I think it's possible the stateid resulted from opens done
> by different principals, so we'd need to keep a list.  If we added that
> kind of check, could we drop the per-operation check?  It's not obvious
> to me.

Delegations would certainly make that interesting.  Who exactly does
authentic writes when a delegation is flushed ... I don't remember.

Sounds like this belongs in the too-hard basket.

Thanks,
NeilBrown


--Sig_/Sj1wL4A/hruwTrBEyMad_f5
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUBVV5jxznsnt1WYoG5AQLYMw/+IQRhDD9XkFyFR+rBUmf7po7oQoxdsy3b
O+ukjwbJp+YEjqU4zxaQ7PF+NeYY68gT5gUDE4n5vyaYunS1EV2DOC3s9TiHbFbp
r41eWtTN9ZhVy+1mPsAdC98PuOrG2gppANTIo3jW0lvkgUX70WBGqtjE3VEqUBa+
P0gsddRojjyLa/MvYUiKQ1zrtat2yVJSgvV7Qk9REd3QyqbC8LmWcleTOXgMLf9O
5elfqpA/biv7yXBEIbVcEs4CJkFNvEALbUk3wx6/ow/HCN1zTD7BsQE8HB46YDw4
lcheKTroXQ566DX3Gdm3P9DNnZlZymB8rkz/C1ELwGlQ2B7YJzUvLeaul6T65rV/
LjLDVmr5jhtlaGolpNBF2YAKQ8yIts+aYFzJguknHw9vK3sD3EqpV87bC8wHVLJ8
bA9gbsdV42Xizs/8Ty5Cmrbly5FBHu5nwFizyBn5NYxnckytcJU8FW16nX7+P9dg
UN88mdALYYSkTCmouRaHBSGbPm9Ao3vOrEtJMLiolcqSPs1BnQtkqQiwQ1JyXVm2
0hVIMzcuvn2s2UsD1Yus+nowblNPVyfzkO3o4HNMfSvaE+YlXQLmLmfyeSTLrXuR
Wsg0lcGIoss0mXgYitlFRVPp+kebSERZzIK573EkkgkqRBs23MoaKK4aAqly+c1+
JB0pVD8vvIg=
=S9t2
-----END PGP SIGNATURE-----

--Sig_/Sj1wL4A/hruwTrBEyMad_f5--

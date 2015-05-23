Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f174.google.com ([209.85.220.174]:33591 "EHLO
	mail-qk0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757736AbbEWNhX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 23 May 2015 09:37:23 -0400
Received: by qkgv12 with SMTP id v12so33232821qkg.0
        for <linux-nfs@vger.kernel.org>; Sat, 23 May 2015 06:37:22 -0700 (PDT)
Date: Sat, 23 May 2015 09:37:12 -0400
From: Jeff Layton <jlayton@poochiereds.net>
To: NeilBrown <neilb@suse.de>
Cc: "J. Bruce Fields" <bfields@fieldses.org>, NFS <linux-nfs@vger.kernel.org>
Subject: Re: Does NFSv4 need to call inode_permission on every write???
Message-ID: <20150523093712.1a115b17@tlielax.poochiereds.net>
In-Reply-To: <20150521144029.57f1b33f@notabene.brown>
References: <20150521144029.57f1b33f@notabene.brown>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/BqZYQpmB7IFsjkmfIo4MHJA"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/BqZYQpmB7IFsjkmfIo4MHJA
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Thu, 21 May 2015 14:40:29 +1000
NeilBrown <neilb@suse.de> wrote:

>=20
>=20
> Apologies if this has been answered before, however...
>=20
> In nfsd_write() we have:
>=20
> 	if (file) {
> 		err =3D nfsd_permission(rqstp, fhp->fh_export, fhp->fh_dentry,
> 				NFSD_MAY_WRITE|NFSD_MAY_OWNER_OVERRIDE);
> 		if (err)
> 			goto out;
> 		err =3D nfsd_vfs_write(rqstp, fhp, file, offset, vec, vlen, cnt,
> 				stablep);
> 	} else {
>=20
> So if a 'file' is already available - because the request came via NFSv4 =
and
> there was a valid state id, and a 'struct file' was associated with that
> state - we still call nfsd_permission().
>=20
> Is that really needed?  The permission check will have been performed at =
open
> - it shouldn't be needed again now.
>=20
> With NFSv3 we have to check permission at each IO, and this is slightly
> different from POSIX semantics.  We shouldn't have to with NFSv4... shoul=
d we?
>=20
> The particular issue that brought this to my attention is that "chattr +i=
" -
> to make a file immutable - is not supposed to affect current opens, only
> future opens.  But a current open over NFSv4 is affected.
>=20
> Is there some reason that we cannot just remove that nfsd_permission() ch=
eck?
>=20

AIUI (maybe wrong), the stateid is mainly provided in WRITE for ordering
purposes (in case of another OPEN or OPEN_DOWNGRADE, or some locking is
also going on). From RFC5661:

   Except when special stateids are used, the stateid value for a WRITE
   request represents a value returned from a previous byte-range LOCK
   or OPEN request or the stateid associated with a delegation.  The
   stateid identifies the associated owners if any and is used by the
   server to verify that the associated locks are still valid (e.g.,
   have not been revoked).

That last bit is the significant part here...

The actual info for the write itself is supposed to be given in other
fields.

While, it probably is a good idea for the server to verify that the
current_fh and the fh associated with the stateid actually match, you
can't really do that with the creds.

In short, READs and WRITEs are really still quite NFSv3-like in NFSv4...

--=20
Jeff Layton <jlayton@poochiereds.net>

--Sig_/BqZYQpmB7IFsjkmfIo4MHJA
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJVYIKJAAoJEAAOaEEZVoIVgpkP/RWWe/sT2bBUFgn07c/dP6f3
LK4dKG6bcA/RK4gf+Zu+Ht0yNS4TemKSdGz2MtxZU3WxHLZC/ZlTxTaWXSWq2w9t
YSGVczVQZZVYUoyejkv9GqKOnjZqZ39bjH50UqXDk7q4vXbUzTA2mui02lhIH7qo
R4pFM9uY69X029PJXXnz1nm/R6pDXFaTwor5jxsBbK+zuG59RRdjJD8I6T2+i0gO
cthPZxZnY51vqVW5gxuIWbxH7dpMZ61gHg8tnLWX3rQLTiOy5JpDzTTbS6RDbqRE
JiEQ9ZF9aBjUG3q/rTz7AclsvdV6O8wAu43PPfb7/FCkK+XV5FBS0WoPL9wMYf9u
Dn755Sp3b/oE745CkkywBSKjvL7YdO4uzK5MH8DonRYECFn8BjJSRtLj64Lv0OeY
ce2GMu0FDuoxwZGOkYw7TYtaAEyfuoTRMdo8NHq2uZhzDvM9/FHlpRRywHKTpcJl
/UcpR4WR8hWrpErv4qdMRNjmR7ZxwzNGEj3hibqmCJ0U11a2yPYUazpAm03tbY4/
p8fGqIVj8c1InsfGHyX5BF6+ujAZ5xl6HXj7Ex5r0DXgi8XSfjiZpXnjKh/ZEav8
4xFZmaWk1DHBU+ExItUjN+CkRi1WPdFt80hvef93jX4+3LTW4uTOFGCZHgl7j3N7
gDv5lfZbiF71y1SC7ZEy
=T8Ui
-----END PGP SIGNATURE-----

--Sig_/BqZYQpmB7IFsjkmfIo4MHJA--

Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:39327 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753145AbbBXVoP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 24 Feb 2015 16:44:15 -0500
Date: Wed, 25 Feb 2015 08:44:06 +1100
From: NeilBrown <neilb@suse.de>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs@vger.kernel.org, Nix <nix@esperi.org.uk>
Subject: Re: [PATCH 1/3] NFS: Don't invalidate a submounted dentry in
 nfs_prime_dcache()
Message-ID: <20150225084406.6d27969b@notabene.brown>
In-Reply-To: <1424736897-95767-1-git-send-email-trond.myklebust@primarydata.com>
References: <1424736897-95767-1-git-send-email-trond.myklebust@primarydata.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 boundary="Sig_/GBASwkpflLa3tto9=REtFub"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/GBASwkpflLa3tto9=REtFub
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Mon, 23 Feb 2015 19:14:55 -0500 Trond Myklebust
<trond.myklebust@primarydata.com> wrote:

> If we're traversing a directory which contains a submounted filesystem,
> or one that has a referral, the NFS server that is processing the READDIR
> request will often return information for the underlying (mounted-on)
> directory. It may, or may not, also return filehandle information.
>=20
> If this happens, and the lookup in nfs_prime_dcache() returns the
> dentry for the submounted directory, the filehandle comparison will
> fail, and we call d_invalidate(). Post-commit 8ed936b5671bf
> ("vfs: Lazily remove mounts on unlinked files and directories."), this
> means the entire subtree is unmounted.
>=20
> The following minimal patch addresses this problem by punting on
> the invalidation if there is a submount.
>=20
> Kudos to Neil Brown <neilb@suse.de> for having tracked down this
> issue (see link).
>=20
> Reported-by: Nix <nix@esperi.org.uk>
> Link: http://lkml.kernel.org/r/87iofju9ht.fsf@spindle.srvr.nix
> Cc: stable@vger.kernel.org # 3.18+
> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> ---
>  fs/nfs/dir.c | 4 ++++
>  1 file changed, 4 insertions(+)
>=20
> diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
> index 9b0c55cb2a2e..0da617a61c0b 100644
> --- a/fs/nfs/dir.c
> +++ b/fs/nfs/dir.c
> @@ -479,6 +479,10 @@ void nfs_prime_dcache(struct dentry *parent, struct =
nfs_entry *entry)
> =20
>  	dentry =3D d_lookup(parent, &filename);
>  	if (dentry !=3D NULL) {
> +		/* Is there a mountpoint here? If so, just exit */
> +		if (!nfs_fsid_equal(&NFS_SB(dentry->d_sb)->fsid,
> +					&entry->fattr->fsid))
> +			goto out;

Surely we should  only consider fattr->fsid if NFS_ATTR_FATTR_FSID is set.
In the case of the Linux NFSv3 server, if this were a mountpoint on the
server, then NFS_ATTR_FATTR_FSID will not be set (as the server returns
neither postop attrs nor filehandle).

I realise that this issue is addressed in the subsequent patch (3/3), but
that isn't tagged for -stable, and this is.

NeilBrown



>  		if (nfs_same_file(dentry, entry)) {
>  			nfs_set_verifier(dentry, nfs_save_change_attribute(dir));
>  			status =3D nfs_refresh_inode(dentry->d_inode, entry->fattr);


--Sig_/GBASwkpflLa3tto9=REtFub
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUBVOzwpjnsnt1WYoG5AQJ74RAAs8mdkGERDS77CskjSjTWrJsMQnL9s2Zr
9Z1uZA3N/iBLbsXgnCKar/i3vFQlu316wi0AzT2M1xh0IlJ0zX2rzo6k1nuPcvFx
VCRTxVJBCJc0EZh172aJVMiEzleuK0KE/LP+I+5U9Vaj6Gpb1UQJ3zJv+xe/ZjjU
NXMGWRR+pXquP49KSCAYR/5ee29qzqPNWjLLcwsqZfHVt97IxyOb4TuJZTRzrhoY
Y8WZzS3gmPwrC8RPIrDo3grfk8zokS+NW0Hv7JCIyZNhieQh6aVece2KNtxqzQ45
J9eTy9PpxvSEDoWii7PK6e/X6DPhK39EVYEJBcOsttLjiwqa+fPAHs5hTNYKgkjK
z/y+BH6MfeWQFClDkFk0FikklWkNXLhhWU/agxcKttpZjo/uOX9mbQfKLyVg/2nr
GB+QX1ofYASb3F0TCUD+CUKkPuoSbQDsrqmgW7aYey8Al9k6WjMW9hT0tBG3IL65
fr/PfolNAl4EBi65PTJ1sDhCKRRwsRDVuLhDcPh8NS+8gzSgIw8fobCQVXxs8Fqm
45h43ECKx0p6fLQy0aAFWRnd1PQT21s9Twj4eSN9lmDSCuALfCSLRuc/HGTvBArd
BWOPQhXvG6KTgXha8S4cWTIJIW93ZXk/v317/1jVBY5KpRP91YP9TaMpGdb6PaVz
39nI7SeHZz0=
=FqqI
-----END PGP SIGNATURE-----

--Sig_/GBASwkpflLa3tto9=REtFub--

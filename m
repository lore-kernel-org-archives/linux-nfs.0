Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:48908 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751243Ab3J0HE2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 27 Oct 2013 03:04:28 -0400
Date: Sun, 27 Oct 2013 18:04:09 +1100
From: NeilBrown <neilb@suse.de>
To: "J. Bruce Fields" <bfields@redhat.com>
Cc: linux-fsdevel@vger.kernel.org, Christoph Hellwig <hch@infradead.org>,
        Al Viro <viro@ZenIV.linux.org.uk>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 4/8] exportfs: stop retrying once we race with
 rename/remove
Message-ID: <20131027180409.66037e01@notabene.brown>
In-Reply-To: <1382733005-6006-5-git-send-email-bfields@redhat.com>
References: <1382733005-6006-1-git-send-email-bfields@redhat.com>
	<1382733005-6006-5-git-send-email-bfields@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/3M+pT_nof6vqlRx_Q.3lSU/"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/3M+pT_nof6vqlRx_Q.3lSU/
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Fri, 25 Oct 2013 16:30:01 -0400 "J. Bruce Fields" <bfields@redhat.com>
wrote:

> From: "J. Bruce Fields" <bfields@redhat.com>
>=20
> There are two places here where we could race with a rename or remove:
>=20
> 	- We could find the parent, but then be removed or renamed away
> 	  from that parent directory before finding our name in that
> 	  directory.
> 	- We could find the parent, and find our name in that parent,
> 	  but then be renamed or removed before we look ourselves up by
> 	  that name in that parent.
>=20
> In both cases the concurrent rename or remove will take care of
> reconnecting the directory that we're currently examining.  Our target
> directory should then also be connected.  Check this and clear
> DISCONNECTED in these cases instead of looping around again.
>=20
> Note: we *do* need to check that this actually happened if we want to be
> robust in the face of corrupted filesystems: a corrupted filesystem
> could just return a completely wrong parent, and we want to fail with an
> error in that case before starting to clear DISCONNECTED on
> non-DISCONNECTED filesystems.
>=20
> Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> ---
>  fs/exportfs/expfs.c |   45 ++++++++++++++++++++++++++++++++++++++++-----
>  1 file changed, 40 insertions(+), 5 deletions(-)
>=20
> diff --git a/fs/exportfs/expfs.c b/fs/exportfs/expfs.c
> index c65b748..6b5ddd5 100644
> --- a/fs/exportfs/expfs.c
> +++ b/fs/exportfs/expfs.c
> @@ -90,6 +90,23 @@ find_disconnected_root(struct dentry *dentry)
>  	return dentry;
>  }
> =20
> +static bool dentry_connected(struct dentry *dentry)
> +{
> +	dget(dentry);
> +	while (dentry->d_flags & DCACHE_DISCONNECTED) {
> +		struct dentry *parent =3D dget_parent(dentry);
> +
> +		dput(dentry);
> +		if (IS_ROOT(dentry)) {
> +			dput(parent);
> +			return false;
> +		}
> +		dentry =3D parent;
> +	}
> +	dput(dentry);
> +	return true;
> +}

This looks remarkably similar to find_disconnected_root().

static bool dentry_connected(struct dentry *dentry)
{
	return !IS_ROOT(find_disconnected_root(dentry));
}

??
....

> +
>  static void clear_disconnected(struct dentry *dentry)
>  {
>  	dget(dentry);
> @@ -189,9 +206,9 @@ reconnect_path(struct vfsmount *mnt, struct dentry *t=
arget_dir, char *nbuf)
>  				dput(pd);
>  				if (err =3D=3D -ENOENT)
>  					/* some race between get_parent and
> -					 * get_name?  just try again
> +					 * get_name?
>  					 */
> -					continue;
> +					goto out_reconnected;
>  				break;
>  			}
>  			dprintk("%s: found name: %s\n", __func__, nbuf);
> @@ -211,12 +228,12 @@ reconnect_path(struct vfsmount *mnt, struct dentry =
*target_dir, char *nbuf)
>  			 * hopefully, npd =3D=3D pd, though it isn't really
>  			 * a problem if it isn't
>  			 */
> +			dput(npd);
> +			dput(ppd);
>  			if (npd =3D=3D pd)
>  				noprogress =3D 0;
>  			else
> -				printk("%s: npd !=3D pd\n", __func__);
> -			dput(npd);
> -			dput(ppd);
> +				goto out_reconnected;
>  			if (IS_ROOT(pd)) {
>  				/* something went wrong, we have to give up */
>  				dput(pd);
> @@ -234,6 +251,24 @@ reconnect_path(struct vfsmount *mnt, struct dentry *=
target_dir, char *nbuf)
>  	}
> =20
>  	return 0;
> +out_reconnected:
> +	/*
> +	 * Someone must have renamed our entry into another parent, in
> +	 * which case it has been reconnected by the rename.
> +	 *
> +	 * Or someone removed it entirely, in which case filehandle
> +	 * lookup will succeed but the directory is now IS_DEAD and
> +	 * subsequent operations on it will fail.
> +	 *
> +	 * Alternatively, maybe there was no race at all, and the
> +	 * filesystem is just corrupt and gave us a parent that doesn't
> +	 * actually contain any entry pointing to this inode.  So,
> +	 * double check that this worked and return -ESTALE if not:
> +	 */
> +	if (!dentry_connected(target_dir))
> +		return -ESTALE;
> +	clear_disconnected(target_dir);

... or just open-code it.  Then this becomes:

  if (!IS_ROOT(find_disconnected_root(target_dir))) {
         clear_disconnected(target_dir);
         return 0;
  }
  return -ESTALE;

which is pleasing similar to the (new) code higher up:

		struct dentry *pd =3D find_disconnected_root(target_dir);

		if (!IS_ROOT(pd)) {
			/* must have found a connected parent - great */
			clear_disconnected(target_dir);
                ....


Just a thought,
NeilBrown


> +	return 0;
>  }
> =20
>  struct getdents_callback {


--Sig_/3M+pT_nof6vqlRx_Q.3lSU/
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQIVAwUBUmy66Tnsnt1WYoG5AQLwcA/9Hy3XqTHQQjmsH6C/4+DyWdzbM4FGoN/s
ooPITgSysu77UwshNHOaej+i+y+rFUzqgTY6PuzBnmYjQCYb4AAojpuUycIGEWam
ih45cwi96jn41HpWfvUOrabnt0WK40FE/0Oaw9kQEvM0Ujv8BqW1UPrJ7Qw7MeDm
OnGGphmw2TPcAwBkzJTD0VGynN5tw0Hd49kJJ0DLMRqaVbgLnXacbocMXdGDkSVT
aEUzMb6K2s4n/2q638RKwsL4WBP7IK4LzknW1cziEn/w1OQtqtuL2ZoMpF7LE5oh
a0PtpEhuJVnlhC9PKsHw+kRFrl3XKlL1tpSpQteTXMMJJaG8+cy7oYzImr083Jmy
it/n135vaKvfdVDrGgauK5D8FmLzIAKrS8+Vhfrqg2VwpqfuFWCR0xjb+SbWxHnR
16+x2PdKsHyTPQvYeS2RaMr6TwdC548vqSct+J5EBr1SWz5/ZGLuLVgBUK+Yzl/7
7qjwURKhvMUHy4zw4Nk7A76TBqvF3ObIEKVuUQxqnXLsYBJqHwXrfv155ELVT0Aa
KDuHCskjatw1jMqOECFWZSmM3HcmqlLsMLJSzKCEjLDrWbm8uChNiN/kkwIwj1q2
JNWR6tUanYN8Ir4zmhFzgIFP7QDvYfGbgcouElPO9haI6gJNaJdQdIRwgerU7G0B
jCzmSq9bDIk=
=8sEf
-----END PGP SIGNATURE-----

--Sig_/3M+pT_nof6vqlRx_Q.3lSU/--

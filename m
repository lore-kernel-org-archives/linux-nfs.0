Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:34292 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754349AbcGUVZT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 21 Jul 2016 17:25:19 -0400
From: NeilBrown <neilb@suse.com>
To: Trond Myklebust <trondmy@primarydata.com>
Date: Fri, 22 Jul 2016 07:25:11 +1000
Cc: Olaf Kirch <OKir@suse.com>, NFS List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] NFS: flush data when locking a file to ensure cache coherence for mmap.
In-Reply-To: <871t4fosvh.fsf@notabene.neil.brown.name>
References: <871t4fosvh.fsf@notabene.neil.brown.name>
Message-ID: <877fce8z0o.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="=-=-="
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain


PING .... any comments on this patch, or the problem it tries to
address?

Thanks,
NeilBrown



--=-=-=
Content-Type: multipart/signed; boundary="==-=-=";
	micalg=pgp-sha256; protocol="application/pgp-signature"

--==-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Fri, Jun 03 2016, NeilBrown wrote:

> When a byte range lock (or flock) is taken out on an NFS file, the
> validity of the cached data is checked and the inode is marked
> NFS_INODE_INVALID_DATA.  However the cached data isn't flushed from
> the page cache.
>
> This is sufficient for future read() requests or mmap() requests as
> they call nfs_revalidate_mapping() which performs the flush if
> necessary.
>
> However an existing mapping is not affected.  Accessing data through
> that mapping will continue to return old data even though the inode is
> marked NFS_INODE_INVALID_DATA.
>
> This can easily be confirmed using the 'nfs' tool in
>   git://github.com/okirch/twopence-nfs.git
> and running
>
>    nfs coherence FILENAME
> on one client, and
>    nfs coherence -r FILENAME
> on another client.
>
> It appears that prior to Linux 2.6.0 this worked correctly.
>
> However commit:
>
> http://git.kernel.org/cgit/linux/kernel/git/history/history.git/commit/?i=
d=3Dca9268fe3ddd075714005adecd4afbd7f9ab87d0
>
> removed the call to inode_invalidate_pages() from nfs_zap_caches().  I
> haven't tested this code, but inspection suggests that prior to this
> commit, file locking would invalidate all inode pages.
>
> This patch adds a call to nfs_revalidate_mapping_protected() after a
> successful SETLK so that invalid data is flushed.  With this patch the
> above test passes.
>
> Cc: Olaf Kirch <okir@suse.com>
> Signed-off-by: NeilBrown <neilb@suse.com>
> ---
>  fs/nfs/file.c | 1 +
>  1 file changed, 1 insertion(+)
>
> diff --git a/fs/nfs/file.c b/fs/nfs/file.c
> index 717a8d6af52d..781cc6c9c60b 100644
> --- a/fs/nfs/file.c
> +++ b/fs/nfs/file.c
> @@ -822,6 +822,7 @@ do_setlk(struct file *filp, int cmd, struct file_lock=
 *fl, int is_local)
>  			__nfs_revalidate_inode(NFS_SERVER(inode), inode);
>  		else
>  			nfs_zap_caches(inode);
> +		nfs_revalidate_mapping_protected(inode, filp->f_mapping);
>  	}
>  out:
>  	return status;
> --=20
> 2.8.3

--==-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJXkT23AAoJEDnsnt1WYoG5nbIP/0gy2FR7lhpKpMHaMUrZR1UY
VZeEs1tUVCEbhD2Kj9hhSYTdO94+BG+HlWabpa/JHzGJT3p97ljrZ+AL4d5uPWtX
z1NprnO0HNacQdIhJtV4GC+/vXe+OqgUlHIMHYydRYR4rBqGC+hDvjdCDdP6YPFR
jcIZi/BKd/t4g5jzwcMyve5OB5qbzyPKZWCoIkFGgHwFxlO25rn+qac0ZezEHqHY
Ly5Ze68bxcARNF8AjRgxBXwq8iZfD4iZ8XmlOKo25l7qIAmBNPVfoinFAkGuiLvf
eYBVG4n8Ssrjb8rZ+SwpQzadehdnpA9H82qSbvE8eUHlwbiTWSbURKhYxRvJPvWF
KKJzGpHGOaHKK5wHhDkU3+eEAmsEw059lHw0U2P6qlkPEPGI2aeNL3bUyokaHlCO
bHRJFwS9lNW8TvR1Siq+X4PhobDqO3f+6zirxzIS6tXZynpwq9asR2/6clt5uc6/
l30U7wdX/4klVn+M5+QK3na37ktaIAwTnf1KPICORYLcKWPDiObs/VK4Nipnq52X
Szc5KQLfe1NknclI2oXDBRtL/N3yWY7N32AMU+LM7TShYzROozY+ArAxLbkvy7qk
rKNd5dRX3qNl2p9BdnxxN9XVaGir6MXC+PIhh0ctVmEfkNbiltC//pbGy4SD3RsQ
Lg8X9KHoVnNZLN4C0iqv
=ya+x
-----END PGP SIGNATURE-----
--==-=-=--

--=-=-=--

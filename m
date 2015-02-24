Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:39412 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751840AbbBXVqc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 24 Feb 2015 16:46:32 -0500
Date: Wed, 25 Feb 2015 08:46:23 +1100
From: NeilBrown <neilb@suse.de>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs@vger.kernel.org, Nix <nix@esperi.org.uk>
Subject: Re: [PATCH 2/3] NFSv3: Use the readdir fileid as the
 mounted-on-fileid
Message-ID: <20150225084623.7f97e1b6@notabene.brown>
In-Reply-To: <1424736897-95767-2-git-send-email-trond.myklebust@primarydata.com>
References: <1424736897-95767-1-git-send-email-trond.myklebust@primarydata.com>
	<1424736897-95767-2-git-send-email-trond.myklebust@primarydata.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 boundary="Sig_/03YvgNWfv0MVG492_gn8K.z"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/03YvgNWfv0MVG492_gn8K.z
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Mon, 23 Feb 2015 19:14:56 -0500 Trond Myklebust
<trond.myklebust@primarydata.com> wrote:

> When we call readdirplus, set the fileid normally returned by readdir
> as the mounted-on-fileid, since that is commonly the case if there is
> a mountpoint. To ensure that we get it right, we only set the flag if
> the readdir fileid differs from the one returned in the readdirplus
> attributes.
>=20
> This again means that we can avoid the issues described in commit
> 2ef47eb1aee17 ("NFS: Fix use of nfs_attr_use_mounted_on_fileid()"),
> which only fixed NFSv4.
>=20
> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> ---
>  fs/nfs/nfs3xdr.c | 5 +++++
>  1 file changed, 5 insertions(+)
>=20
> diff --git a/fs/nfs/nfs3xdr.c b/fs/nfs/nfs3xdr.c
> index 2a932fdc57cb..53852a4bd88b 100644
> --- a/fs/nfs/nfs3xdr.c
> +++ b/fs/nfs/nfs3xdr.c
> @@ -1987,6 +1987,11 @@ int nfs3_decode_dirent(struct xdr_stream *xdr, str=
uct nfs_entry *entry,
>  		if (entry->fattr->valid & NFS_ATTR_FATTR_V3)
>  			entry->d_type =3D nfs_umode_to_dtype(entry->fattr->mode);
> =20
> +		if (entry->fattr->fileid !=3D entry->ino) {
> +			entry->fattr->mounted_on_fileid =3D entry->ino;
> +			entry->fattr->valid |=3D NFS_ATTR_FATTR_MOUNTED_ON_FILEID;
> +		}
> +
>  		/* In fact, a post_op_fh3: */
>  		p =3D xdr_inline_decode(xdr, 4);
>  		if (unlikely(p =3D=3D NULL))


I like this!

  Reviewed-by: NeilBrown <neilb@suse.de>

if you like.


Thanks,
NeilBrown

--Sig_/03YvgNWfv0MVG492_gn8K.z
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUBVOzxMDnsnt1WYoG5AQIn7Q/9Hw4XaRl2lyS59ssEpvEd5SJxORJBqzUY
V6hN5N1UwiNGEcyLoHJsNGg9zKuSgjWM6OvXV0P588VTv/CD9me3GCBIGseRN+R7
+3OH5HF13umRdALIo56YiuGEzT8eCHrnSxbFwFtrsCkqxIDKHpFOc97aAhQ6tWNZ
jSpuI+fyG3b4zq867kuacjsvMBx4jk/sZGvPkblsLeG82yypFLSlMc1jferQsZZ9
B3hlhLjk7T3Y2kURusKPZxcQ3zT73FqmicjQdxJuK+RUlzMGlT8imV68dhC2aTXp
TI3r6lmKfl8DPotpr9/aUrPjEw7WRs5XVPXJUczQWrg2+L6Q4OktK6SfGHpDr3TD
xCvKjRb1GN989qmFzfw496H9r6MmD5em7jxDAqCjivKPXES5IlkA+YQCMT2ST2pF
Xzes10ScOcGxHfdewW1lWqJfTWaoF7c4s4RWMIJcikTAA1Vbbbga+kmdvUhnA3Pr
g7wJOySurlXQ+pAbrUe77pyRK5npY3jSoYRktGDp+7jBS/IJ0QPhRwuHSHM09yHT
6Dw0VXj9fnpt96y5przKnNRC7IPH/3vmIfH6cX1f03+/sT0WHCOY0xrYzGfzlc9j
BSwitVgHG44pdPjRn88qxSJ3uixogP84fOjCjF0XMYKiXFajZk0+52gpAtFkJatB
YzdcaZf0Lrc=
=VFhh
-----END PGP SIGNATURE-----

--Sig_/03YvgNWfv0MVG492_gn8K.z--

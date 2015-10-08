Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from victor.provo.novell.com ([137.65.250.26]:51546 "EHLO
	prv3-mh.provo.novell.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751020AbbJHDI0 (ORCPT
	<rfc822;groupwise-linux-nfs@vger.kernel.org:0:0>);
	Wed, 7 Oct 2015 23:08:26 -0400
From: Neil Brown <nfbrown@novell.com>
To: Anna Schumaker <Anna.Schumaker@netapp.com>, linux-nfs@vger.kernel.org,
        linux-btrfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-api@vger.kernel.org, zab@zabbo.net, viro@zeniv.linux.org.uk,
        clm@fb.com, darrick.wong@oracle.com, mtk.manpages@gmail.com,
        andros@netapp.com, hch@infradead.org
Date: Thu, 08 Oct 2015 12:40:10 +1100
Subject: Re: [PATCH v5 8/9] vfs: Add vfs_copy_file_range() support for pagecache copies
In-Reply-To: <1443634014-3026-9-git-send-email-Anna.Schumaker@Netapp.com>
References: <1443634014-3026-1-git-send-email-Anna.Schumaker@Netapp.com> <1443634014-3026-9-git-send-email-Anna.Schumaker@Netapp.com>
Message-ID: <87vbai6sud.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
	micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

Anna Schumaker <Anna.Schumaker@netapp.com> writes:

> @@ -1338,34 +1362,26 @@ ssize_t vfs_copy_file_range(struct file *file_in,=
 loff_t pos_in,
>  			    struct file *file_out, loff_t pos_out,
>  			    size_t len, unsigned int flags)
>  {
> -	struct inode *inode_in;
> -	struct inode *inode_out;
>  	ssize_t ret;
>=20=20
> -	if (flags)
> +	/* Flags should only be used exclusively. */
> +	if ((flags & COPY_FR_COPY) && (flags & ~COPY_FR_COPY))
> +		return -EINVAL;
> +	if ((flags & COPY_FR_REFLINK) && (flags & ~COPY_FR_REFLINK))
> +		return -EINVAL;
> +	if ((flags & COPY_FR_DEDUP) && (flags & ~COPY_FR_DEDUP))
>  		return -EINVAL;
>=20=20

Do you also need:

   if (flags & ~(COPY_FR_COPY | COPY_FR_REFLINK | COPY_FR_DEDUP))
   	return -EINVAL;

so that future user-space can test if the kernel supports new flags?

NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJWFcl6AAoJEDnsnt1WYoG5P6kP/Ar/5g4WWXmAZ9AjYLbMSCy6
0/4TQMm//fk6OYyECgBoTfXLbWpQHTzFEgDFJLbc3w1FyqUsBWntfIFHbOYa1JNI
4jLgwe2bSxHalaCknAvsvvxPSd63FO56eJbIg8ggfIo0HD0OwHTU/nimhnmAIYoK
wdDxQJYOeZEJBmXg7bgNCYHH768EQlpnKoBsFNywpzlT55M4vEgZYUSYezFuTjoO
x2HkaHa9fjo2mkvJRTl3iyaGdkiqxThyIvSZvJY/fvUK8mmDgeKKhYBaEaGtMhq+
WQiNmBvtSgVBsKXv/vhCPM/4yPpn5WiYy+p7mwgKj8VhsO99fnRvLvf6DZsBpuiX
7lyc8DkX8wJhfg+i0GQTv4TWbiSjbmbq6Bi6v2V260She35VzyAGhRrgqEnAP1jn
tP3dW6abkGpcjm/iTb7urQuVE0jhFlKuLuY68yqd5JlWqLlKorMdQ+QKFogIO3/E
oSCNtZd8lq5gzy559hF5YGsWFr96vPyxuNixm2XwhDqlRDLs7xBfXjrEH1ygDvbL
xzXbvUHPrqDG4jCnStjrSmsChR4zjfk62/KNhzEQG89cB1+0PfzcRLG3be8CfyJK
DyiPYP7gVGozOnKdKSwYIPh9EgEVuFWMVOw86dYkzkPWDSFYJA4W6BjvhEt+otdW
eB49c5VVEl1RUREEAMbv
=YGNk
-----END PGP SIGNATURE-----
--=-=-=--

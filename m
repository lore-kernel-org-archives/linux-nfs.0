Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:50493 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754148Ab3KECkN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 4 Nov 2013 21:40:13 -0500
Date: Tue, 5 Nov 2013 13:39:59 +1100
From: NeilBrown <neilb@suse.de>
To: Jeff Layton <jlayton@redhat.com>
Cc: viro@ZenIV.linux.org.uk, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        chutzpah@gentoo.org, liguangc@cn.ibm.com
Subject: Re: [PATCH] [RFC] vfs: don't revalidate dentries that serve as
 mountpoints
Message-ID: <20131105133959.5be7c728@notabene.brown>
In-Reply-To: <1383614186-8039-1-git-send-email-jlayton@redhat.com>
References: <1383614186-8039-1-git-send-email-jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/ohWK6fgkFxnbDM6JDmMBcxR"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/ohWK6fgkFxnbDM6JDmMBcxR
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Mon,  4 Nov 2013 20:16:26 -0500 Jeff Layton <jlayton@redhat.com> wrote:

> We had a couple of reports of people that are mounting NFS filesystems,
> and then bind mounting certain local files onto dentries in that nfs
> mount (sort of like a poor-man's unionmount).
>=20
> This all works well until the dentry serving as the mountpoint fails
> d_revalidate. The dentry will end up being invalidated which makes the
> bind mount unreachable via pathwalk.
>=20
> It doesn't make much sense to me to allow dentries to serve as
> mountpoints to end up invalidated, so there's no real point in
> attempting to d_revalidate them at all.
>=20
> Reported-by: Patrick McLean <chutzpah@gentoo.org>
> Reported-by: Guang Cheng Li <liguangc@cn.ibm.com>
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
> ---
>  fs/namei.c | 3 +++
>  1 file changed, 3 insertions(+)
>=20
> diff --git a/fs/namei.c b/fs/namei.c
> index caa2805..5b10ad0 100644
> --- a/fs/namei.c
> +++ b/fs/namei.c
> @@ -585,6 +585,9 @@ drop_root_mnt:
> =20
>  static inline int d_revalidate(struct dentry *dentry, unsigned int flags)
>  {
> +	/* dentries that serve as mountpoints are always considered valid */
> +	if (d_mountpoint(dentry))
> +		return 1;
>  	return dentry->d_op->d_revalidate(dentry, flags);
>  }
> =20

Makes sense to me. But what about the parent or grandparent of the mountpoi=
nt?

Presumably we don't want to invalidate them either, and I don't think
d_mountpoint() returns true for those, does it?

NeilBrown

--Sig_/ohWK6fgkFxnbDM6JDmMBcxR
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQIVAwUBUnhafznsnt1WYoG5AQI/fg/+I44pFQXLRzZ9X9fKgnECyiFpE08OfiWX
B0GQzqYe7OyzH7aLDus53eEC+8NVqt05VpVMzdQalAT00fTEp//87VHV9FYBsxag
bHJlbeTC0s1MSGf8FfDtODpkPalJtArHZIXXCeK/a8e9fTQJD7Uqo0WQcmli0toj
HLfFwX+C1OiU2I/AHTDzflfpmEEYfl1a6+NKryb//RpHh+oe47FhK5CtLgzSHPba
Q5zHph5xf2eJ7/An3BJDM794PK53ixArfoPLnf460PGJ2n5Zj/9pbgGq1QDcQZS2
/LoAj7yj9tAGZrVrdn6Vdx0Lg1o+QcidTs2EMA7n7cSMCpau1hisRQyqEG/BCOFa
sh5L6tv9SgtXXLhf1cD0oqo3juLS/AomDhAjj5bqUwPfskVCyemObJGE3uWt90+8
fE4jBEl2Qkpl9tDS5Lb/v0tSsqLm+7shvR5gb/Em3PrM2L60grc6DiRryEoPrMef
Ui5S4MN9eYsLlg4lAqD2hKI0txOoeT6SKpt1xPk8dMju3FYyDX8sFD3rr98PeNc3
CHyoHAknl9jH9xIy7kvFVU40eEj2Dmb8v6nUWpj2pANjzWdkVeGDzo4A+LLYyVsF
H4MxD9NNBMKgVjZPpYzBxnNJNvuWDdLbjZ987Vd3x5ZMTNlD0V6i98DjVmhV+LZp
/KxdGwW5p9I=
=0pVE
-----END PGP SIGNATURE-----

--Sig_/ohWK6fgkFxnbDM6JDmMBcxR--

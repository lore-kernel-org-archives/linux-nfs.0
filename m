Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:54676 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751759AbdBXBRZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 23 Feb 2017 20:17:25 -0500
From: NeilBrown <neilb@suse.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>, steved@redhat.com
Date: Fri, 24 Feb 2017 12:17:03 +1100
Cc: linux-nfs@vger.kernel.org, bfields@fieldses.org
Subject: Re: [PATCH 2/2] nfsd: Change the default to enable all minor versions unless told otherwise
In-Reply-To: <20170224003344.113724-3-trond.myklebust@primarydata.com>
References: <20170224003344.113724-1-trond.myklebust@primarydata.com> <20170224003344.113724-2-trond.myklebust@primarydata.com> <20170224003344.113724-3-trond.myklebust@primarydata.com>
Message-ID: <87ino0qtf4.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Thu, Feb 23 2017, Trond Myklebust wrote:

> Instead of letting the kernel decide, default to enabling all versions,
> and let the user be more specifc in /etc/nfs.conf or on the command line.

What is your rationale for this?
I think there is value in allowing the kernel to support a version while
disabling it by default.  This allows it to be used for experimentation,
without much risk of it being used in production until it is deemed to
be really ready.

I like the rest of the patch set, and withdraw my comments about the
earlier patch set which were due to a hasty misunderstanding.

Thanks,
NeilBrown


>
> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> ---
>  utils/nfsd/nfsd.c | 11 +++++------
>  1 file changed, 5 insertions(+), 6 deletions(-)
>
> diff --git a/utils/nfsd/nfsd.c b/utils/nfsd/nfsd.c
> index 1708521ab286..9735e65466fa 100644
> --- a/utils/nfsd/nfsd.c
> +++ b/utils/nfsd/nfsd.c
> @@ -107,13 +107,12 @@ main(int argc, char **argv)
>  	}
>=20=20
>  	nfssvc_get_minormask(&minormask);
> -	/* We assume the kernel will default all minor versions to 'on',
> -	 * and allow the config file to disable some.
> +	/* We default all minor versions to 'on', and allow the config
> +	 * file to disable some.
>  	 */
> -	if (NFSCTL_VERISSET(versbits, 4)) {
> -		NFSCTL_MINORSET(minorversset, 0);
> -		NFSCTL_MINORSET(minorvers, 0);
> -	}
> +	if (NFSCTL_VERISSET(versbits, 4))
> +		minorversset =3D minorvers =3D minormask;
> +
>  	for (i =3D 1; i <=3D NFS4_MAXMINOR; i++) {
>  		char tag[20];
>  		sprintf(tag, "vers4.%d", i);
> --=20
> 2.9.3

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAliviY8ACgkQOeye3VZi
gbmbug/9Haf5SvmVczap3IY83TvEO+40zAArT9Ft7r4t/d86syXK0BGG5HLmhrof
4OqXjz560B0lzSWeAXUJRCMK9g8DCHBL71QA6KaV5oPyOjm87c3msq4e6wmpNpfv
yW1lWvYDoboToIwfsX9Z5apkrgY+3toWhAXwIkPwdFMdQ+wbqB40t9LwfwpdOiWj
f88ATY6dB+8JlUvVurP7rPtFY5eRSxQnh2f7tx2iRcnwnfL9YT2nbvzVnCODl71B
BY9DwAylZtZWhe+Nfn/DdNA0scy8Ys2CfM9mTajueFQlQVRz6v6EFo0gsf537QuT
sCVLImgq3d7Uwq5bNZpJn6s9GsYM9ZHjhFxn/Eex9fz+dr5jXVPWBk3OFYxmUrU0
/Sy8W296J///0TaU6Bus+nZY0ZMbh72p1GdajbQ0P+I8P4T7NuSnBbpnoIl1IC+g
+StMuQ7BvzZYIc1gyr4jop5CJN/13sbb+o7p1SSxuwYX3AbuPb/FOglNeGSh1Ttv
nLFwtjcDVZfaNiDHYQwhhHcqb8DJXM8cBh9jEuywj0q9NJNkPxZlgsCEwQU5vxYT
4MvxCwAoSA2t7cbCalu9Nu1576RDXP+l2u7d+fydFwgXsXgEA5yrcA3M4QkbpVd4
In/9+5g+8NrvBTF+XqwNFiitkqgJ5cnzCt992Bijyu2EhJPh3bA=
=nQaB
-----END PGP SIGNATURE-----
--=-=-=--

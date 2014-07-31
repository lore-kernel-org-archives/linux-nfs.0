Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:48000 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755314AbaGaBae (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 30 Jul 2014 21:30:34 -0400
Date: Thu, 31 Jul 2014 11:30:22 +1000
From: NeilBrown <neilb@suse.de>
To: Natanael Copa <natanael.copa@gmail.com>
Cc: linux-nfs@vger.kernel.org, Natanael Copa <ncopa@alpinelinux.org>
Subject: Re: [PATCH 04/11] exportfs: define _GNU_SOURCE for stat64
Message-ID: <20140731113022.22afdefc@notabene.brown>
In-Reply-To: <1406719399-1735-5-git-send-email-ncopa@alpinelinux.org>
References: <1406719399-1735-1-git-send-email-ncopa@alpinelinux.org>
	<1406719399-1735-5-git-send-email-ncopa@alpinelinux.org>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 boundary="Sig_/mJGz+m/rcgHK6ygCdy8Cmi5"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/mJGz+m/rcgHK6ygCdy8Cmi5
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Wed, 30 Jul 2014 13:23:12 +0200 Natanael Copa <natanael.copa@gmail.com>
wrote:

> Signed-off-by: Natanael Copa <ncopa@alpinelinux.org>
> ---
>  utils/exportfs/exportfs.c | 4 ++++
>  1 file changed, 4 insertions(+)
>=20
> diff --git a/utils/exportfs/exportfs.c b/utils/exportfs/exportfs.c
> index bf07555..7ab93d1 100644
> --- a/utils/exportfs/exportfs.c
> +++ b/utils/exportfs/exportfs.c
> @@ -12,6 +12,10 @@
>  #include <config.h>
>  #endif
> =20
> +#ifndef _GNU_SOURCE
> +#define _GNU_SOURCE
> +#endif
> +
>  #include <sys/types.h>
>  #include <sys/stat.h>
>  #include <sys/vfs.h>

These all look really sensible!

One small suggestion: it would be really nice to see a comment in the code
explaining why _GNU_SOURCE is needed.  I suspect such comments get out of
date quickly, so maybe it wouldn't end up be all that useful.  But having a
comment is still, in my opinion, more useful than not.

Thanks,
NeilBrown


--Sig_/mJGz+m/rcgHK6ygCdy8Cmi5
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBU9mcLjnsnt1WYoG5AQJb8BAAh4jKNg0A+ic9BgQRNpHVShW7L0Waoji0
8zH4EvB9Trlubko71KL/5WzPkIJtmuaNRan5B46qThkzvtHOdpDj9vofyzI2oWOa
2oyyzmKNOUlHlsdwxiiXWrFOMXEAgiu/ls/T1pIJ1BU1858SBdJDl0Ixc3MamZRb
siXd8v5dbtr5+qmBkWt5dJO6BlNimKWLqcOFdU+HKvEzrhrKZMmu894vs6QM5ds9
OoeEyx6Y/D5oct3JA0f4fdRpgXf3TGWryG8KgeaxsPNE1uZoLLeWTP011JwMOJgN
SANHOlKZkL6VMN2OKP8/HwDV0C1oDG/YokTQ4ASkPNhozHKYSafb0mkkTQw3g+ph
xJHSf4yE0vzRctiKua6lz1goALoW68UOjhV8bRVp2UhpV3O8kdnBQXA+ylPXie9o
fh2TntlHv3o823K9Tf6puW4JAgWXMlUaBWPo1rRxMno1mvExqWEwK43gjGFtXRl+
uAudWnFIEEPRKKKRNmVxliTVMreyz03RMHG03jnKq8jTDvIO1Iog+kyK97YnrnSj
/+Za6d9Nm0lbCcIFHUOTqGAlEW5nTztLxTbMm5uqIx6PUQKwNsi3ZvzUQrT+N1Fo
SvmB7AU2J6AYjSU/Cy0iatKPE15m565Bw24O1+A3YjAbFdJ62YFW2In9Fw151+Gt
1xej1X2zqGE=
=/vu6
-----END PGP SIGNATURE-----

--Sig_/mJGz+m/rcgHK6ygCdy8Cmi5--

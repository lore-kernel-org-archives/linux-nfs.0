Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:35678 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750732AbbJOGjy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 15 Oct 2015 02:39:54 -0400
From: Neil Brown <neilb@suse.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Date: Thu, 15 Oct 2015 17:39:47 +1100
Cc: Olaf Kirch <okir@suse.de>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH/RFC] sunrpc/cache: make cache flushing more reliable.
In-Reply-To: <87fv1cwsln.fsf@notabene.neil.brown.name>
References: <87fv1cwsln.fsf@notabene.neil.brown.name>
Message-ID: <87a8rkws7g.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
	micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


Sorry.. I didn't refresh before posting....

> @@ -487,10 +496,13 @@ EXPORT_SYMBOL_GPL(cache_flush);
>=20=20
>  void cache_purge(struct cache_detail *detail)
>  {
> -	detail->flush_time =3D LONG_MAX;
> +	time_t now =3D seconds_since_boot();
> +	if (detail->flush_time >=3D now)
> +		now =3D detail->flush_time + 1;
> +	/* 'now' is the maximum value any 'last_refresh' can have */
> +	detail->flush_time =3D now + 1;

This should not have the '+ 1'.

>  	detail->nextcheck =3D seconds_since_boot();
>  	cache_flush();
> -	detail->flush_time =3D 1;
>  }
>  EXPORT_SYMBOL_GPL(cache_purge);
>=20=20
> @@ -1447,8 +1460,22 @@ static ssize_t write_flush(struct file *file, cons=
t char __user *buf,
>  		return -EINVAL;
>=20=20
>  	bp =3D tbuf;
> -	cd->flush_time =3D get_expiry(&bp);
> -	cd->nextcheck =3D seconds_since_boot();
> +	then =3D get_expiry(&bp);
> +	now =3D seconds_since_boot();
> +	cd->nextcheck =3D now;
> +	/* Can only set flush_time to 1 second beyond "now", or
> +	 * possibly 1 second beyond flushtime.  This is because
> +	 * flush_time never goes backwards so it mustn't get too far
> +	 * ahead of time.
> +	 */
> +	if (then >=3D now) {
> +		/* Want to flush everything, so behave like cache_purge() */
> +		if (cd->flush_time >=3D now)
> +			now =3D cd->flush_time + 1;
> +		then =3D now + 1;

Nor should.

I'll resend it people are otherwise happy.

NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJWH0ozAAoJEDnsnt1WYoG5+GcP/3suSY1UzY3GlU/mnZfKPFBH
kaKjzs7uYDhTTBJNlllTTXO82v/pKk9ynt7Xfeifia40wexDeu0/pWGjtmVy4cxE
sZgk0ARuqLyj13SLZvzHbtHgZTzOkZZSwkBZImbnyoQcMebMdgEj0glWno6InmE9
El8GliTJO/HdMu5gvv6RBdPDafGc09QIyy3ugHjfPMuyNt79qDUv/sM+PxgLiFiI
4awneivh3Bgx41zRk2CGpM+SS8VikIFOEepqjOCdFvcLoitxNRLQAeeN8+ir3oAD
NVguqekzN2HZcju/BI+zTG21FnTQVkAQXaOoFDd0DszadpfTUz2eKa+Obm+zldzm
agD1JmduXs9BZH5jnDfg8IkzOmNTUsEUpuFy9lMguzbWhmGvOa/zNgrWHayHdofW
EBBbCczOC4BF3aKERoa8S1hhclXCBR4EIrDnaS9x4fFz/2ZZ8AllfeJLaECN9E49
jeHE5xWF8iN7LyMLlswFya23A3dl3AHNZz7NEH5YMPp6EAI3hRsuCALQJA/Fo0mK
964YCdh13XrfvRqFSW5M+gyhYbjVmsMqRZQ1lfnB5ZbD3ZE1+dNYlxoSUH8LfauH
9J4fEFqDIaoPThOuXjmCnPFmofxUqS1lDnUGq///GFASsc3phDPeKvEkqzniWOXL
VmRZiKs9TRrfN0lbYM2E
=Q6Us
-----END PGP SIGNATURE-----
--=-=-=--

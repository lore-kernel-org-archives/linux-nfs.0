Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:54407 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750995AbbEHCDX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 7 May 2015 22:03:23 -0400
Date: Thu, 7 May 2015 22:03:22 -0400
From: Mike Frysinger <vapier@gentoo.org>
To: Steve Dickson <SteveD@redhat.com>
Cc: Thorsten Kukuk <kukuk@suse.de>, libtirpc-devel@lists.sourceforge.net,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH V2] Fix Build w/gssapi disabled
Message-ID: <20150508020322.GF30924@vapier>
References: <1430983149-22199-1-git-send-email-vapier@gentoo.org>
 <20150507115248.GA20243@suse.de>
 <554B86E2.8090908@RedHat.com>
 <20150507163326.GA6156@suse.de>
 <554B98E9.4040601@RedHat.com>
 <20150507181206.GA7810@suse.de>
 <554BC53C.5080807@RedHat.com>
 <554BC730.3000004@RedHat.com>
 <554BC9F3.6020005@RedHat.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="8JAmzYDSl0Sjbh5d"
In-Reply-To: <554BC9F3.6020005@RedHat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--8JAmzYDSl0Sjbh5d
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline

On 07 May 2015 16:24, Steve Dickson wrote:
> --- /dev/null
> +++ b/tirpc/tirpc-features.h.in
> @@ -0,0 +1,10 @@
> +#ifndef _TIRPC_FEATURES_H
> +#define _TIRPC_FEATURES_H
> +
> +/* Define to 1 if DES authentication is enabled */
> +#undef HAVE_AUTHDES
> +
> +/* Define to 1 if GSSAPI is enabled */
> +#undef HAVE_GSSAPI
> +
> +#endif /* _TIRPC_FEATURES_H */

it is dangerous to export raw HAVE_xxx defines -- it can break packages that
use autotools themselves.  they need an appropriate prefix like RPC_xxx or
TIRPC_xxx.
-mike

--8JAmzYDSl0Sjbh5d
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJVTBlqAAoJEEFjO5/oN/WBOIUP/RSBfDz5JPqdiTel7uXONTf8
O85z7mftzu/SFE25whVuhZKM5/jsmU92kp1DwzAZsZ/61M662TjHe6dUe6ygglwH
OOBsouPlBjD6vtEZE5vLug4t7JK0oSa6OuCeJxfn38mN9a2+KGnVyRu0EE+ReecI
UM7BhiF6Tcy26WqFW9NjcCxpZWpgTdNJHXblM0u/WZRWjdelmZ+iopMFVKosgX1H
HrXWlJZNrcLn+Y76lCpH69ZvxsUhLG2SEg/Zypj+jp6C62dHZ6caHhLntUjwz0yN
DEdMxUQcXQO6DfoQTrWb8rkMLBqf6lCvR2WoiD5zuS19734wwBC12azzWhqlnCAp
uSvv4Pqq8vbBuiSA4wcCGPnFnXbP1otfag56txYcvdjZZUthH9dWNw2VLDr8n8n0
mgmaMqQLDDXPk5Rw6MH6WxVCLLbUDZFU8mYNGnZn8TL3EJpC+qy/W+Ed92utiwVG
klyisbt5EvRoLzWgpO7GTc29Wox4yWf9LbR4og6PifSeBogVjt2gDnG7I7Mlkq80
gdrKIj44VhZ/cqnpRHqkQVj+5eerq8QEB5PnoGygGPMI5FBDrAOznWaqy3lMqWBB
K18AvkOV4KjXR/7m7iZhyGZY6s8sjK33/VjXxOok3k1Rbx1LUjidEUNkKpJlpVr1
vEX9zzoX1AqXmhFfya3M
=q/LY
-----END PGP SIGNATURE-----

--8JAmzYDSl0Sjbh5d--

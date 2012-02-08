Return-Path: linux-nfs-owner@vger.kernel.org
Received: from lennier.cc.vt.edu ([198.82.162.213]:42788 "EHLO
	lennier.cc.vt.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757796Ab2BHXyM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 8 Feb 2012 18:54:12 -0500
To: David Howells <dhowells@redhat.com>
Cc: jmorris@namei.org, keyrings@linux-nfs.org, linux-nfs@vger.kernel.org,
        linux-security-module@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-api@vger.kernel.org,
        libc-alpha@sourceware.org
Subject: Re: [PATCH 1/2] Define ENOAUTHSERVICE to indicate "Authentication service unavailable"
In-Reply-To: Your message of "Wed, 08 Feb 2012 12:29:05 GMT."
             <20120208122905.8902.65762.stgit@warthog.procyon.org.uk>
From: Valdis.Kletnieks@vt.edu
References: <20120208122905.8902.65762.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1328745230_2846P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Date: Wed, 08 Feb 2012 18:53:50 -0500
Message-ID: <22934.1328745230@turing-police.cc.vt.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--==_Exmh_1328745230_2846P
Content-Type: text/plain; charset=us-ascii

On Wed, 08 Feb 2012 12:29:05 GMT, David Howells said:

> +#define	ENOAUTHSERVICE	139	/* Authentication service not available */
>
>  #define EHWPOISON	139	/* Memory page has hardware error */

Was this an intentional overload of 139 (and so on for other archs)?
Just checking - I'm sure if it goes in like this, we'll see a patch to "fix" the
collision for 3.16.0 or so... ;)

--==_Exmh_1328745230_2846P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)
Comment: Exmh version 2.5 07/13/2001

iQIVAwUBTzMLDgdmEQWDXROgAQLo8w/9GSAkuhd+TKRP7GBY/vtnzb8/kyvEnJ5M
kXAsV/k12ZKsyRo+qat0scVkIIVR+siFVQMBMAOE4r4Y14CGYMInhrpsNLa0vhqK
GdS5+GNIAbHj8PBJSYxxHffiQisePTTbAppzW68to/jRe3eYcWQdlJgcjdOMYSKJ
TxLJi7R36FNZAMW5C6VjrEZcWym+LOizeSuX0a4hGMkWbo1D6YO/bsqI0703fhh3
+q3n6KLZahVNZQ4zNDtIuznUgm/SEWnz5kyZF+Lj0pCxCC/00Qtl0d47YGQ8Bfcr
6v+v2loI96oHJypLbPOoovwqpPV5YUoiaLS+aKFyEcMb+Soa8kSpPSkb+lkQZ/eK
FTkdLuRFQ4cK9Dk1mqFa94x7XsVv6FfXt4NUKuWSm2cqEzUbdEbmXsdwT69oMcYV
aYd//3xYcjtcwDi+lovc7THYIj2UJYtZVxIeZpitxISMdAJ+gZEYzmgDKF+O4IDj
DYdnO8PVMfdosULrhP5GpYtjYJ0vL/HSNXSkGtJ/OWIlBIBFl2yXtOpzkjqndtBE
WBmmfQHvSNjYU5Ab/udNYNoT4+rEKkkBLTtbWwFvgNPiiE5PLYLrUrdyqz4Y6KAb
B9OkVk4AWq0UlCeNCl2onHKdsT61rfImD8wygJyJ2oau7TWw4itQE2LV/pLQY68T
HrD/BwmIDcY=
=h9rq
-----END PGP SIGNATURE-----

--==_Exmh_1328745230_2846P--


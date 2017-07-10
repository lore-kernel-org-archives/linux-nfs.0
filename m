Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55382 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754859AbdGJSFb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 10 Jul 2017 14:05:31 -0400
Date: Mon, 10 Jul 2017 19:05:28 +0100
From: Stefan Hajnoczi <stefanha@redhat.com>
To: Abbas Naderi <abiusx@google.com>
Cc: linux-nfs@vger.kernel.org,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@redhat.com>,
        Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH v3 14/14] SUNRPC: add AF_VSOCK support to auth.unix.ip
Message-ID: <20170710180528.GU14195@stefanha-x1.localdomain>
References: <20170630132352.32133-1-stefanha@redhat.com>
 <20170630132352.32133-15-stefanha@redhat.com>
 <19D7C0EF-17AB-43AD-ADFF-19D1DBC73F37@google.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="CYcXvPfqKSDi0QhV"
In-Reply-To: <19D7C0EF-17AB-43AD-ADFF-19D1DBC73F37@google.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--CYcXvPfqKSDi0QhV
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Jul 06, 2017 at 11:46:05AM -0700, Abbas Naderi wrote:
> Without CONFIG_SUNRPC_BACKCHANNEL, many things such as =E2=80=9Csvc_vsock=
_bc_class=E2=80=9D are undefined, and then used throughout the code.
> Most of the =E2=80=9CCONFIG_SUNRPC_XPRT_VSOCK=E2=80=9D guards in sunrpc/s=
vcsock.c should also be guarded by CONFIG_SUNRPC_BACKCHANNEL.

Thanks, Abbas!  Will fix in v4.

Stefan

--CYcXvPfqKSDi0QhV
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBAgAGBQJZY8HoAAoJEJykq7OBq3PIvJ4H/0AMd2ffOqr7RbHrbQUH0u1U
08RlJbaKGIwqTTO2lbRZ6i19mMHmrrEKz3jCXxPmEs0cmN3FYI8AnsAg/cOWd8C9
sckKfJX55lWnhL1kT8S+jseCK8mQYm8UBoEVphT0spv2hHqHBEE8o235izcCk9ac
9QR/SDBobVawc/La8qgLBaU0fg9eQ1h/0H8iflUUdx0VJ6bqCEybeWw1l0sz+H83
+D/1fJ5xasZwq2KFNLOQovb5XzXIrEJhi2vQMxzQEY1kjfLIv33xX129/5Z1uVZf
NMgvkhOd1yjD5FSEOB+joKmjXm1qHMR3nTplHdNKAjpKXZDVlZTJrZZiZJHs+Sk=
=SmN/
-----END PGP SIGNATURE-----

--CYcXvPfqKSDi0QhV--

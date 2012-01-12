Return-Path: linux-nfs-owner@vger.kernel.org
Received: from rcsinet15.oracle.com ([148.87.113.117]:23052 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755369Ab2ALVbN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 12 Jan 2012 16:31:13 -0500
Date: Fri, 13 Jan 2012 00:32:10 +0300
From: Dan Carpenter <dan.carpenter@oracle.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
        "David S. Miller" <davem@davemloft.net>, linux-nfs@vger.kernel.org,
        netdev@vger.kernel.org, kernel-janitors@vger.kernel.org,
        Tom Tucker <tom@opengridcomputing.com>
Subject: Re: [patch] svcrdma: endian bug in send_write_chunks()
Message-ID: <20120112213210.GR3644@mwanda>
References: <20120112064722.GB2408@elgon.mountain>
 <20120112162141.GC6563@fieldses.org>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="tV/+6PImfyFtriLg"
In-Reply-To: <20120112162141.GC6563@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--tV/+6PImfyFtriLg
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Jan 12, 2012 at 11:21:41AM -0500, J. Bruce Fields wrote:
> On Thu, Jan 12, 2012 at 09:47:22AM +0300, Dan Carpenter wrote:
> > Sparse complains because arg_ch->rs_length is declared as network
> > endian but we're treating it as CPU endian.
>=20
> This looks like it would actually change behavior on a little endian
> architecture, so how did this work before?
>=20
> >From some quick grepping, I see assignments both of the form
>=20
> 	...rs_length =3D ntohl(...)
>=20
> and
>=20
> 	...rs_length =3D htonl(...)
>=20
> but only see one declaration for a field named rs_length.
>=20
> So my best guess would be that the code is ugly but working as is, and
> needs cleanup by someone who knows how this field was intended to be
> used.

Gar.  Sorry for that.  I knew it changed the behavior, and I tried
to see how the original code worked, but I didn't read carefully
enough.  I'll try be more careful next time.

Thanks for catching that.

regards,
dan carpenter


--tV/+6PImfyFtriLg
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBAgAGBQJPD1FZAAoJEOnZkXI/YHqRqNIP/jVgLACKLIo0C/UI9DKry7yq
Oso3ovMFytlficXKQWowc1yNg9bPf1Y9RBKuI6ia7eKS2FP188cpWRPOy9mYIXMY
Pt001iQ3eEGQERhC2LQ1VBO995we38wKNEWVxrYPIYll5bcYiVyWZ62R9G05/heo
3k0bAVeM1RQaLlzXTGrWdQgU8Vf0XYRYLk529N/xtgfY/bKWlbm4zjxKHBwM+Bic
K5mh8yyorcQmCYUt02tkLfiaQcXZzzz+BU59WhzcX0I8TrZYVY/XtxNmXl/zKd7+
O3woiKTOu7jseYNLY1r8R3OjcnlTvvfQU7Zd9lg+xckW+0XArQWTFK7XyGqnEZd0
FnW9kdgyCCbw1/hzra93vARHwgPHoy4DHXqLIesXiq77zabYbdodsbhr1jdcG0bF
KvFwQEAYCXCp7u64qOToW0lVLuKKBwzcEt8MYBLT4RsL2cFr5wmgKbfkPCrUR12A
B6EJnGijYf7HLlr7XWPUQ8j8APuQpQOPat4XZ4dVrK/drRFDAr80AXhBFxlAgko7
bEsoy1pbAbGCzJhrtimo8MrTYv8z397yrJcq78VeAylRm2PkatY0Sir8frXqXXew
Ik1H9VT9FlQhlQM1HjrQABPUez6pYfC50vzwh5/hkzqjA882cPUv9sGHhGTDhOeS
FjaNbBW6NGfCYnOtw92z
=Y2lf
-----END PGP SIGNATURE-----

--tV/+6PImfyFtriLg--

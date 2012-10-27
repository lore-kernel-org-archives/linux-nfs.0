Return-Path: linux-nfs-owner@vger.kernel.org
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:60704 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752369Ab2J0Xdb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 27 Oct 2012 19:33:31 -0400
Message-ID: <1351380808.21585.16.camel@deadeye.wl.decadent.org.uk>
Subject: Re: [PATCH] SUNRPC: Fix a UDP transport regression
From: Ben Hutchings <ben@decadent.org.uk>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: stable@vger.kernel.org, linux-nfs@vger.kernel.org,
        Bryan Schumaker <bjschuma@netapp.com>
Date: Sun, 28 Oct 2012 00:33:28 +0100
In-Reply-To: <1350925018-12926-1-git-send-email-Trond.Myklebust@netapp.com>
References: <1350925018-12926-1-git-send-email-Trond.Myklebust@netapp.com>
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-QGz8IYjDTmbUGmY1GWAv"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--=-QGz8IYjDTmbUGmY1GWAv
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2012-10-22 at 12:56 -0400, Trond Myklebust wrote:
> commit f39c1bfb5a03e2d255451bff05be0d7255298fa4 and

You were too late to stop me applying the above to 3.2.30...

> commit 84e28a307e376f271505af65a7b7e212dd6f61f4 upstream.
[...]

so I had to cherry-pick this separately, with the obvious context
adjustment.

Ben.

--=20
Ben Hutchings
Reality is just a crutch for people who can't handle science fiction.

--=-QGz8IYjDTmbUGmY1GWAv
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIVAwUAUIxvSOe/yOyVhhEJAQp0iw//XmgH2M1jU/2D7Rejxw2xJVG/GpqR0370
DkcBH8dHIA8D/hPI73sFpccYzPjVW5BkcUJn5+opPoLylojeANY/baWal0qHjmrW
uSriJHhbB6qelohwD0nGE+5k0s0ky5zs8uA8mAkg3P854w6SReF0JRmXLHjGlBBl
zdCmRN4Wn7hKBDldaQ/+uGDjtISTJiWcbmhiyowimxl2EqJH+EOWbaISfHphsylO
QoE/wuWlT8EHUEm46CUFBzbXqdu39lKA8qMGm4KMMGgdQ6xAS5r6q1jgIh9tE+T/
AbPZ/+eX5Rs9NjKL5XWXeu3vLq9nTkpi2A2Edmh5YQap/EH3x/sAmHHkPlO9+aGS
gjrF8zkrfmZfxB25CLenSvs9MmqYLJ9xVaZT8+eQzLO/celde4h8bc7iGe1DK2m7
IPqzopNtzxl7g9pSwrBovFF8z9dZPG9pN/v0xCQGSkFWsp6gKPa72wOE06Y57CoF
YAbMK4+8nxLNf2dBxj6UD5NNlCznfcnWtrC6j5FIoLSPLZqQuAby53filnrL6zMI
hbcjjnudgITDABEnNDlQ+u1jzy007mjcDBcOAGxOdXmKH0GiZ/LP0hthxFiwPVjb
PNAGp7JY29U0tQog838oLdaoWXZvTaNfCB/6muvXuxydjMGykezxNBYIHbAKsrc0
n/qViWQ75xc=
=UM7M
-----END PGP SIGNATURE-----

--=-QGz8IYjDTmbUGmY1GWAv--

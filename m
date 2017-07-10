Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from [209.132.183.28] ([209.132.183.28]:35136 "EHLO mx1.redhat.com"
        rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
        id S932095AbdGJSkB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 10 Jul 2017 14:40:01 -0400
Date: Mon, 10 Jul 2017 19:39:30 +0100
From: Stefan Hajnoczi <stefanha@redhat.com>
To: Steve Dickson <SteveD@RedHat.com>
Cc: linux-nfs@vger.kernel.org, Jeff Layton <jlayton@redhat.com>,
        Abbas Naderi <abiusx@google.com>
Subject: Re: [PATCH nfs-utils v2 11/12] nfsd: add --vsock (-v) option to nfsd
Message-ID: <20170710183930.GY14195@stefanha-x1.localdomain>
References: <20170630132120.31578-1-stefanha@redhat.com>
 <20170630132120.31578-12-stefanha@redhat.com>
 <99deb619-7e39-6689-79b3-2e7d252145b0@RedHat.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="FvpZCdL3V2P9482l"
In-Reply-To: <99deb619-7e39-6689-79b3-2e7d252145b0@RedHat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--FvpZCdL3V2P9482l
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Jun 30, 2017 at 11:25:31AM -0400, Steve Dickson wrote:
> On 06/30/2017 09:21 AM, Stefan Hajnoczi wrote:
> > The following command-line serves NFSv4.1 over AF_VSOCK:
> >=20
> >   nfsd -TU -N3 -V4.1 -v 2049
> So this specifying no-tcp, no-udp (which is no longer needed since=20
> udp is off by default), no-v3, only-v4.1, vsock listiner,
> and you are missing a -p because I don't think you want to
> start up 2049 process.=20

-v takes an argument (the AF_VSOCK port number to listen on), so the
2049 is consumed and not interpreted as the number of processes.

> How does this work with the standard NFS server? Are the
> co-compatible?

I'll test tcp + vsock in a single nfsd and make sure it works for the
next revision of this patch series.  Nothing in the kernel or nfs-utils
code intentionally prevents them from being used at the same time.  My
intention is that /etc/exports dictates which exports are visible over
TCP, vsock, or both.

> Also the --vsock needs to be documented. Also can the
> --vsock flag just mean all of these specifics... Meaning
> so they don't have to be specified on the command line?

Thanks, will document the --vsock <port> option.

--FvpZCdL3V2P9482l
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBAgAGBQJZY8niAAoJEJykq7OBq3PIJmIIAIxr12b200JO9oBUfT7ywYDD
p9Zv6fX7ev89KJLmcwRgYKOOmI1IPlpFx36JnPc0AEe54FiByJAJ4ZM0/WsBGaAM
9qgTESPYxyp6uK7yI6j5Ucwj7mmPq/TuyQDeSzxgf/+B+0UTljNLCb/f4cKfkknP
mP8aPQjaen8dtiSCqMUkQ5te8897TANLR8/IX8fAiE9QRd+kR7yszoJVPbCTFjwZ
MSuYdW0pVa5GtXdOA98q9sWbL8W02NWyQusKvhXcCoVKX7Vtd2v5gkPqofBdbTh1
5x3c4Lo9Tp4VhwyzmAd1scTcSF8aeWOxAYVVVGjyhXZBqbuvjmmisFmsm7/waYA=
=/R7/
-----END PGP SIGNATURE-----

--FvpZCdL3V2P9482l--

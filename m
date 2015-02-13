Return-Path: linux-nfs-owner@vger.kernel.org
Received: from ozlabs.org ([103.22.144.67]:44707 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751241AbbBMCiR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 12 Feb 2015 21:38:17 -0500
Date: Fri, 13 Feb 2015 13:38:11 +1100
From: Stephen Rothwell <sfr@canb.auug.org.au>
To: Dave Chinner <david@fromorbit.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jeff.layton@primarydata.com>,
        Christoph Hellwig <hch@lst.de>, Jeff Layton <jlayton@primarydata.com>,
        linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        xfs@oss.sgi.com
Subject: Re: [PATCH 19/20] xfs: implement pNFS export operations
Message-ID: <20150213133811.5c3b9f49@canb.auug.org.au>
In-Reply-To: <20150213015422.GE12722@dastard>
References: <20150205004758.GO4251@dastard>
	<20150205070858.GA593@lst.de>
	<20150205135756.GA6386@lst.de>
	<20150206222047.GM12722@dastard>
	<20150206224258.GJ29783@fieldses.org>
	<20150208133435.GA27081@lst.de>
	<20150208090942.51e99687@tlielax.poochiereds.net>
	<20150209201154.GA27746@fieldses.org>
	<20150210000423.GY12722@dastard>
	<20150213011130.GA6808@fieldses.org>
	<20150213015422.GE12722@dastard>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/72iLWnDTYf9Pc=xJPr1Q12+"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/72iLWnDTYf9Pc=xJPr1Q12+
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi Dave,

On Fri, 13 Feb 2015 12:54:22 +1100 Dave Chinner <david@fromorbit.com> wrote:
>
> Thanks Bruce. I might have to build a merged tree because one of the
> changes from the review modified a header file introduced in the NFS
> tree.
>=20
> I'll see how it goes, and see if I can avoid doing something that
> will make Linus yell at me :P

If its a syntactic conflict with an obvious resolution, just leave it
(or maybe mention it in the pull request).  It gives him something to
do so he feels useful. :-)

/me notes that I did not see a conflict while merging the xfs tree in
linux-next today ...

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Sig_/72iLWnDTYf9Pc=xJPr1Q12+
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJU3WOYAAoJEMDTa8Ir7ZwVNrMP/1MGyDeHamIa2ByYrBlsbCoS
bq9BV7bEw5lXMK4pklOHwDtJmsPs/ozuCZ4Yc65UkEbE3f228ZyMXNVODcrJBtTc
66xfJpFhx9P7Stk/ViDLv3GPPwS3iW93Ru/62dNhy81NGRXznY1YQ8quzX8H/nmD
JxACRPsDtLnUCFIskpxc9WYBAgP9hbU2UfBD+ryfOf11GNcW8FC5IFfxaWK/D/or
6nyRCJ0KeVmEy/zIQ6TT32I/RIe78VPKJ3fuY+wAOiWzv4fUI9uP7W0i1rfZYb6Z
+aQ+E4GTp5WUmI2vGf7hnbZTdEmaXzP+PFnz2bMSCUr/FLiOiJS1kiDqVZQaZjgQ
ItHInE1emxenhVaHsqSCQ6LEl0auAgqKfw27A3Po4xYX0ZTIUQGaA1cZtwxv79bz
CNVK2Puy3GIRiu4G2HQqjkvFu3FXdwSUEnm6y+6xpDEi7oUaJJJy9szLP9rTeBYq
0odtBEn2m88EUME/hJskO3OwIrMPPCyP0/cOfaJIoEWvHMMxttmqbGnAF7Cq/mrr
1X8xdh+3pwfMyqolqiU3ZiU4hM12dmj4jFoLdIfSCPSZxup795FEUcbb1KTam+/P
irnAfzhr0+E5caWYfurlB8RHxF6+2w3CCwnB15nmW6GHb6m/Y3U4eIRV72GgOzg4
ZMI7g9jls6pXGv7rvYge
=uaiD
-----END PGP SIGNATURE-----

--Sig_/72iLWnDTYf9Pc=xJPr1Q12+--

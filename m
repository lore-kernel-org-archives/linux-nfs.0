Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail4.gandi.net ([217.70.183.210]:45996 "EHLO mail4.gandi.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759828Ab3ICUoi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 3 Sep 2013 16:44:38 -0400
Date: Tue, 3 Sep 2013 22:44:31 +0200
From: William Dauchy <william@gandi.net>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: William Dauchy <wdauchy@gmail.com>,
        Linux NFS mailing list <linux-nfs@vger.kernel.org>,
        "Adamson, Andy" <William.Adamson@netapp.com>,
        William Dauchy <william@gandi.net>
Subject: Re: [PATCH v2] NFS: Ensure that rmdir() waits for sillyrenames to
 complete
Message-ID: <20130903204431.GF22430@gandi.net>
References: <1378145871-30071-1-git-send-email-Trond.Myklebust@netapp.com>
 <CAJ75kXbRgsYVRNobCmjeL-t+AJproq8jAxXkbkk9DxGnE9eYhQ@mail.gmail.com>
 <1378234234.6410.36.camel@leira.trondhjem.org>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="65ImJOski3p8EhYV"
In-Reply-To: <1378234234.6410.36.camel@leira.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--65ImJOski3p8EhYV
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Sep03 18:50, Myklebust, Trond wrote:
> Thanks again for testing! Does the following fixup on top of the 'v2'
> patch also help?
> --- a/fs/nfs/unlink.c
> +++ b/fs/nfs/unlink.c
> @@ -211,7 +211,7 @@ void nfs_wait_on_sillyrename(struct dentry *dentry)
>  {
>  	struct nfs_inode *nfsi =3D NFS_I(dentry->d_inode);
> =20
> -	wait_event(nfsi->waitqueue, atomic_read(&nfsi->silly_count) =3D=3D 1);
> +	wait_event(nfsi->waitqueue, atomic_read(&nfsi->silly_count) <=3D 1);
>  }
> =20
>  void nfs_block_sillyrename(struct dentry *dentry)

hmmm I just realized your v2 version had `=3D=3D 1`; in fact I tested your =
v1
with `=3D=3D 0`. Let me some time to retest the v2.

Thanks,

--=20
William

--65ImJOski3p8EhYV
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iEYEARECAAYFAlImSi8ACgkQ1I6eqOUidQEmoACgrt4hE37tbHU42u9QIwbVdcAg
oHYAniuPXxXtJ1rrRiVRjcXVcmqLzBND
=YkAk
-----END PGP SIGNATURE-----

--65ImJOski3p8EhYV--

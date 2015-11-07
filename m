Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail4.gandi.net ([217.70.183.210]:56551 "EHLO gandi.net"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751163AbbKGIlx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 7 Nov 2015 03:41:53 -0500
Date: Sat, 7 Nov 2015 09:41:50 +0100
From: William Dauchy <william@gandi.net>
To: William Dauchy <william@gandi.net>
Cc: Linux NFS mailing list <linux-nfs@vger.kernel.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: Re: strange behavior with nfsv3 using linux v4.1
Message-ID: <20151107084150.GI12546@gandi.net>
References: <20151106225715.GH12546@gandi.net>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="Li7ckgedzMh1NgdW"
In-Reply-To: <20151106225715.GH12546@gandi.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--Li7ckgedzMh1NgdW
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Nov06 23:57, William Dauchy wrote:
> I am seeing strange behaviors with a single nfsv3 mount on linux
> v4.1.x. I first started to see two kworker in D state while I was not
> doing anything. The server is an opensolaris nfs server.

forgot to mention this nfsv3 mount is a using CONFIG_ROOT_NFS
it's a read only mount point

the client seems to be looping on revalidation.
--=20
William

--Li7ckgedzMh1NgdW
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlY9uU4ACgkQ1I6eqOUidQGCxwCgk4WhOYrY0GQFuB+lbzxDh6/7
Q04An2ACGoXiVfykSZj0Wnqg/pHXEQdk
=zxwn
-----END PGP SIGNATURE-----

--Li7ckgedzMh1NgdW--

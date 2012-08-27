Return-Path: linux-nfs-owner@vger.kernel.org
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:39008 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754443Ab2H0Ve5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 27 Aug 2012 17:34:57 -0400
Message-ID: <1346103286.20840.59.camel@deadeye.wl.decadent.org.uk>
Subject: Re: [PATCH] NFS: Fix Oopses in nfs_lookup_revalidate and
 nfs4_lookup_revalidate
From: Ben Hutchings <ben@decadent.org.uk>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: Greg KH <gregkh@linuxfoundation.org>,
        "stable@vger.kernel.org" <stable@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Date: Mon, 27 Aug 2012 14:34:46 -0700
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA908F6E388@SACEXCMBX04-PRD.hq.netapp.com>
References: <1345666097-14815-1-git-send-email-Trond.Myklebust@netapp.com>
	 <20120827200949.GA4732@kroah.com>
	 <4FA345DA4F4AE44899BD2B03EEEC2FA908F6E388@SACEXCMBX04-PRD.hq.netapp.com>
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-LMb84OwrZBHFyX+2UwtM"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--=-LMb84OwrZBHFyX+2UwtM
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2012-08-27 at 20:16 +0000, Myklebust, Trond wrote:
> On Mon, 2012-08-27 at 13:09 -0700, Greg KH wrote:
> > On Wed, Aug 22, 2012 at 04:08:17PM -0400, Trond Myklebust wrote:
> > > Fix the following Oops in 3.5.1:
[...]
> > > This Oops affects 3.5 kernels and older, and is due to lookup_one_len=
()
> > > calling down to the dentry revalidation code with a NULL pointer
> > > to struct nameidata.
> > >=20
> > > It is fixed upstream by commit 0b728e1911c (stop passing nameidata *
> > > to ->d_revalidate())
> >=20
> > So this is just a nfs-only backport of the larger patch 0b728e1911c,
> > right?  Should we also do this for other filesystems as well?  Or just
> > backport the whole commit?
>=20
> The larger patch involves a VFS api change (the atomic open code) which
> has a bunch of pre- and post-requirements. I'd assume that is a too
> large change for stable. I think that the smaller per-filesystem changes
> are probably more appropriate. The list of filesystems that care are
> likely to be small. Off the top of my head, I can only think of NFS,
> CIFS, FUSE and possibly ceph.

What is the earliest version that needs this fix?

Ben.

--=20
Ben Hutchings
One of the nice things about standards is that there are so many of them.

--=-LMb84OwrZBHFyX+2UwtM
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIVAwUAUDvn9ue/yOyVhhEJAQrvmw//cUsRuWeMbVN+YIqsTx4JXDK+S/4BGIyP
s98ldeAvMCCMuJtj6cccSqemOFtn7tpomOenof9rl2q9uA2DTifZRY8+U6o644Nn
QZ7Qa2C65lZb8JZRB55Dw2EKAqyEL8pscCEqJRl3W2x8QvUWRDcc6mGP6aBT0PCN
d8I2k7AhINu4vXptWr+3HbGNwUAz2VkzZ5nROhCp0JjH+iz97viEZD6h8z1INx6g
mDepdlJZF2FcUF6oDFjnD8UUxPQI7hXRx3K7gJWE0Z3soJQ7RfUZS9R+H+FwVDx6
XJJiTV4RGkeHJfra85hBURB3xwlQPac3IHM1dv+uwr4QL6rw3FYlT7GuR0ZV9rxs
kjCMmM199t/mkXtbzkxhUj+8eIvQtXCkXnlxMeVM/RyUB8RBlhTDXvEm9ZuHNlUX
T0oaIqUgosc4bzixADKNyGxTXDYtKOGfs3qkPlf/FqsQJ9kYTdXwRciEvFVIg9Zy
NsSGKEy1i7tY55Xq8XimPFUVliiyorXf/W1JmncGvmLTTh+wU9gA8MwPqXkckJty
41X453dgL30/+iMbNX2dV6uvPkWG4G7P2gyxz+NtVxxWXV6pDYSpMji0z1buQwdY
6uMOObBk45CQNR8m4vsZQ+0fTIjLG2fG7QgufLC4DH2WV5PdJNS4/2115SH3xnHC
z8XZ2JuGFOA=
=J28w
-----END PGP SIGNATURE-----

--=-LMb84OwrZBHFyX+2UwtM--

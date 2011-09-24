Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mo-p05-ob.rzone.de ([81.169.146.180]:65021 "EHLO
	mo-p05-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752310Ab1IXSsI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 24 Sep 2011 14:48:08 -0400
Message-ID: <4E7E2314.6000101@samba.org>
Date: Sat, 24 Sep 2011 20:36:04 +0200
From: "Stefan (metze) Metzmacher" <metze@samba.org>
To: "J. Bruce Fields" <bfields@redhat.com>
CC: linux-fsdevel@vger.kernel.org, Mimi Zohar <zohar@linux.vnet.ibm.com>,
        linux-nfs@vger.kernel.org, samba-technical@lists.samba.org,
        Al Viro <viro@zeniv.linux.org.uk>
Subject: Re: breaking leases on metadata changes
References: <1316617097-21384-1-git-send-email-bfields@redhat.com>
In-Reply-To: <1316617097-21384-1-git-send-email-bfields@redhat.com>
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig64E7B1A07379637C0B6E9895"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

--------------enig64E7B1A07379637C0B6E9895
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

Hi Bruce,

> So there's this longstanding problem that read leases should really be
> broken on anything that changes an inode's metadata or any change to th=
e
> set of links pointing to the inode.
>=20
> (Cc'ing samba-technical for confirmation of that statement from Samba's=

> point of view....)
>=20
> So we need mutual exclusion between read leases and link, unlink,
> rename, etc.

As far as I know oplocks in SMB only care about content
and attribute only opens (without the READ/WRITE access bits) doesn't
break oplocks.

So changing the modification time of a file should not break the oplock.

I think link and rename doesn't break oplocks, while unlink would.

But Samba requirements may change for SMB 2.2 support with directory leas=
es.
We're currently exploring what the details are.

metze



--------------enig64E7B1A07379637C0B6E9895
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAk5+IxcACgkQm70gjA5TCD/JcQCcCBrrmWswINMLG8YXe5fqtgEW
E+YAn0nFHDJxGLmCu0oOygJIuYdGJx06
=Ycyo
-----END PGP SIGNATURE-----

--------------enig64E7B1A07379637C0B6E9895--

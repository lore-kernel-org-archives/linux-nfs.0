Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:45737 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753429AbaI2Bfa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 28 Sep 2014 21:35:30 -0400
Date: Mon, 29 Sep 2014 11:35:19 +1000
From: NeilBrown <neilb@suse.de>
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: Jeff Layton <jeff.layton@primarydata.com>,
        Christoph Hellwig <hch@infradead.org>, linux-nfs@vger.kernel.org
Subject: Re: kernel BUG in fs/dcache.c running nfs
Message-ID: <20140929113519.30292efb@notabene.brown>
In-Reply-To: <20140926230801.GR7996@ZenIV.linux.org.uk>
References: <20140908144525.GB19811@infradead.org>
	<20140909105918.59477ee3@tlielax.poochiereds.net>
	<20140909154211.GA6614@infradead.org>
	<20140909121244.610f297d@tlielax.poochiereds.net>
	<20140909121546.3981121b@tlielax.poochiereds.net>
	<20140909135006.2b956f47@tlielax.poochiereds.net>
	<20140910135739.2b897d94@notabene.brown>
	<20140926230801.GR7996@ZenIV.linux.org.uk>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 boundary="Sig_/okPWW2P7xFj7/y.FNs2LWWX"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/okPWW2P7xFj7/y.FNs2LWWX
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Sat, 27 Sep 2014 00:08:01 +0100 Al Viro <viro@ZenIV.linux.org.uk> wrote:

> On Wed, Sep 10, 2014 at 01:57:39PM +1000, NeilBrown wrote:
>=20
> > The d_drop();d_add(); pattern is used a number of times in NFS, but wha=
t I
> > didn't notice before is that it is only used if ->d_inode is NULL.
>=20
> And the point of that "pattern" would be...?  If dentry is already negati=
ve
> and hashed, it does nothing whatsoever.  If it is negative and unhashed,
> d_drop() is a no-op, obviously.  And if it's positive, we get a nice
> shiny oops.
>=20
> Where are we doing anything of that sort, anyway?  I see a bloody odd
> instance in nfs_atomic_open() and that's it.  Note that nfs_instantiate()
> is different (and not necessary nice - that d_drop() in case when this
> sucker is called from mkdir() is asking for races with mount()).  How
> do we get a positive hashed dentry there, anyway?

Apart from nfs_atomic_open() and  nfs_instantiate(), the main one is
in _nfs4_open_and_get_state:
		/* FIXME: Is this d_drop() ever needed? */
		d_drop(dentry);
		dentry =3D d_add_unique(dentry, igrab(state->inode));
   maybe you can answer the question in the comment

nfs_link also has

	d_drop(dentry);
	error =3D NFS_PROTO(dir)->link(inode, dir, &dentry->d_name);
	if (error =3D=3D 0) {
		ihold(inode);
		d_add(dentry, inode);
	}

which is similar.

Thanks,
NeilBrown

--Sig_/okPWW2P7xFj7/y.FNs2LWWX
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBVCi3Vznsnt1WYoG5AQI7uBAAi4ZPTXJ5bHQXx5seGdUnJ0zN+nYtN0Yf
8b32RI84rNJ9BE1Xg0FP8RF4+DvtKFuCvicjK31Gddd89ndwkpGQkTPoJnz6uc7o
xmu5rrO6NTYzXHzr7BVP/nw4N1ZSVZmPiciG6dGaeuiVGKaW/SgDxEIyVJw3HbLm
zeghivSlz7RGC7kaY3oyZ9RIZGG9w6tbY5wFVuJ7fLTTlDTyJBMFRMwwlQkynkgB
LU7QOoPT137UBzdVGLEDNsH22TiMXmCUOcg80GfdVlKvDLo+akJb91j1oAM+pef9
3AfnNxOcaC7abXFYnsFw+pnRhDlinraXGUOlfFDt7pgupRE9Dl36gwz9n2VyGN+z
DXMenuKjVgUWPtAxul0duOb7RCBknxJW1z6+BpE3Kz71RMJ6jMWDfLlJZcRyJD7W
rrSttKHtckeybiPo5W1QSsNabYwvTHTdl/N9CvWddI0Id0+uIrfbYd8phEW1mIgC
WPobQyliwu8N+KUw6cMosBTbRhGWt3p2QTbOaECzxJ9fcZt1zRnzxUCS62M21vVu
gFvK4JGQuuSMYPqk/UPs+I43h4g4macRQBCC7XtLFsWtjWr4eOslCwnZUzfdyaS9
2n7YQCWBkaLLHqiVv6z6lcUBDgRjl/IhI3BiviMcM79yukibqRvCBX8ELUiuOBVl
R8c947HyYBE=
=Oh1o
-----END PGP SIGNATURE-----

--Sig_/okPWW2P7xFj7/y.FNs2LWWX--

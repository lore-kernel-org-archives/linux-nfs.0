Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:53390 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755068Ab3BRXPI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 18 Feb 2013 18:15:08 -0500
Date: Tue, 19 Feb 2013 10:14:50 +1100
From: NeilBrown <neilb@suse.de>
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: Jeff Layton <jlayton@redhat.com>,
        "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        NFS <linux-nfs@vger.kernel.org>,
        Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: More fun with unmounting ESTALE directories.
Message-ID: <20130219101450.42c1752c@notabene.brown>
In-Reply-To: <20130218201502.GH4503@ZenIV.linux.org.uk>
References: <20130212113813.427b8e05@notabene.brown>
	<20130214104230.013b7f71@tlielax.poochiereds.net>
	<20130218132509.0ce779de@notabene.brown>
	<20130218184609.GF4503@ZenIV.linux.org.uk>
	<20130218144655.42b3f3e3@tlielax.poochiereds.net>
	<20130218201502.GH4503@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/qkMxurlR7pPPJsoo4WgiOBB"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/qkMxurlR7pPPJsoo4WgiOBB
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Mon, 18 Feb 2013 20:15:02 +0000 Al Viro <viro@ZenIV.linux.org.uk> wrote:

> On Mon, Feb 18, 2013 at 02:46:55PM -0500, Jeff Layton wrote:
>=20
> > Ok, that helps. In that case, this patch might be a reasonable
> > forward-port of the one Neil sent earlier today. Note that this doesn't
> > really do anything for the umount problem, but it does seem to fix the
> > testcase for the problem I've been looking at.
> >=20
> > Thoughts?
>=20
> If we really go for "in this case revalidate should be weaker", we might
> as well introduce a separate method for it.
>=20
> As it is, we have several callers of ->d_revalidate(); this one (in
> complete_walk(), only for FS_REVAL_DOT filesystems) and ones in
> lookup_dcache() and lookup_fast() (in both cases we have and want the
> name to match).  There are only two fs with FS_REVAL_DOT present - nfs
> and 9p.  *IF* we want to make ->d_revalidate() on NFS behave differently
> in complete_walk() case, it would argue for just splitting the method
> in two, replacing FS_REVAL_DOT with "dentry has this method" and probably
> taking a good look at what 9p needs in the same case.

Sounds good to me.

Reminds me that we used to have an i_op->revalidate() method for revalidati=
ng
just the inode (not the dentry).  It called nfs_revalidate_inode() for NFS.

We lost it over a decade ago:

commit cc41b90f8a9ad3cd85a39dd4fcc71f965a675b0e
Author: Alexander Viro <viro@math.psu.edu>
Date:   Tue May 21 21:12:46 2002 -0700

    [PATCH] kill ->i_op->revalidate()
   =20
    kill ->i_op->revalidate()



:-)

(this doesn't help my umount problem though)

NeilBrown

--Sig_/qkMxurlR7pPPJsoo4WgiOBB
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQIVAwUBUSK16jnsnt1WYoG5AQL9eQ//W8rmtREndS+fovoj5deApTfyIa/7KFgU
kPqAucmfR5rZUjsRKnSjdMa+d6AH0Od6ww3vlBj0H5neqgN4BNNnxhUoQa9fA/u8
I4qBnpBhbsrctuLBDEbKlRXrcNCQvfGwaKY+Ha67a4OOkfyieSC9nkVhSn75XhSD
Rs0mFl9eKlFeiyHtIUP/K3K6Q7cE85v6ynUeR7zEwlSoEVGAtiUpYX8o7j0kUviY
s9gGbxURk8PV/+hS+YC3G1m0CBKQA1s9tzYv/b5Jx6Os8TU+YjUA6E9qMVjo10xc
jIxWwuIwgEh/pjDJl14S9glugVDxrtMvsnzfON+S6I+T9Mo8VQN5a7As5mG1Hi8T
kQY2ny2Oyus+Z4jZcPNFds0CdblHFH+EaYzCsCfIbIdbkpBDUOXMxUVbMFxRSmRA
AGhyUoeSyOclGz/xR+IBs4aJy9Pjb2FoeymYzlOsie+FRWg+D8PC4WEoqJaIhaTw
LJkADo/ZWEHzA7iN0Z3Pixmk/zAfVjIZTWlo1m01Xbqtv2XrLXZ/dOQtHjjEmG9J
Y9lNx+PevB9MBZTPhG39pb4+lpmGq6vVH8HD0mB7vzy5vx8XrKu2lskrn9Y66VBh
8aJzo+pEtnK4QXuf1Bz8CNfpP4Hm/Otp1lEaItCVyoVPLyMTJ2n28QxvW8tLa7BW
BakPY0NopH8=
=JDtL
-----END PGP SIGNATURE-----

--Sig_/qkMxurlR7pPPJsoo4WgiOBB--

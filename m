Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:56754 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751903Ab2J2X2P (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 29 Oct 2012 19:28:15 -0400
Date: Tue, 30 Oct 2012 10:28:33 +1100
From: NeilBrown <neilb@suse.de>
To: "J. Bruce Fields" <bfields@redhat.com>
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        Peter Staubach <pstaubach@exagrid.com>
Subject: Re: [PATCH 0/2] fix nfsd stable write implementation
Message-ID: <20121030102833.306e833a@notabene.brown>
In-Reply-To: <1351285617-20450-1-git-send-email-bfields@redhat.com>
References: <1351285617-20450-1-git-send-email-bfields@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/Naj0.z9RNwrfSqR+Euo/DOm"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/Naj0.z9RNwrfSqR+Euo/DOm
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Fri, 26 Oct 2012 17:06:55 -0400 "J. Bruce Fields" <bfields@redhat.com>
wrote:

> From: "J. Bruce Fields" <bfields@redhat.com>
>=20
> Peter pointed out to me that the nfs server is implementing stable
> writes by setting the O_SYNC flag.  I can't see why we couldn't write
> and then sync instead, but I don't know this stuff as well as I should;
> does the following look reasonable to people?

Bruce changed the code to implement stable writes by calling
vfs_fsync_range().  I can't see why we couldn't use O_SYNC instead.

It seems like you are making a change just for the sake of making a change.
Is there some reason that you think a separate 'sync' is more efficient than
using O_SYNC ?

As a general principle, I think it is best to give the file system as much
information as possible to that it can make whatever optimisation decisions
that it wants to.

Setting O_SYNC gives the filesystem more information than not, because it
allows it to change the behaviour of the 'write' request... though I don't
know if any filesystem actually uses the information.

Why the change?

NeilBrown

>=20
> --b.
>=20
> J. Bruce Fields (2):
>   nfsd: assume writeable exportabled filesystems have f_sync
>   nfsd: use vfs_fsync_range(), not O_SYNC, for stable writes
>=20
>  fs/nfsd/vfs.c |   26 ++++++--------------------
>  1 file changed, 6 insertions(+), 20 deletions(-)
>=20


--Sig_/Naj0.z9RNwrfSqR+Euo/DOm
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.18 (GNU/Linux)

iQIVAwUBUI8RITnsnt1WYoG5AQLVkg//TWTS5EYEIf/CeFBOnBYg6eLC8xJgOKZY
xYJWho7FVs+WP2l5d7RitaYXlXUTrrMkrfvUPHTQFGs1Tfu5g8Zzpr+cnGR9oX+I
421a54L95xxDPooDFhryC6saJQchUpm14Zdy0fE0uKgf0l9pK2pIAFZodBDkxTfv
81C3oaoHos+SdquxCBRubYfUGoKXaGhVTpZy7VPyEOKaD0xPzD1kYhWlrV/YQVZi
bQW3G+o+nCRVxvkz0fF1bN5ZAXKfDQ6Hazy/ExXb/fKV+CLkU6ZXSXRujHwiwO05
v/kLyqMKxb7zRodr6phRi+S2wM/288BCvPId5gkwsc3c+aVbMZdeHdT+2t0MHdsG
zvTOKStf2dSwccjnP2PlyTFdkVqu2YhJ8rZilAzRnP5cF9mrirljAg4wV24EiddT
PyI6yXO8WBT97Bri3a1/j8MA/Oci4Zsq3kCNRBzZc+UughomRO0AjaUn5w1KzhxG
BtxMji1xtuY20gUmAGOop1ype99DzQsqOlXSABJb03xE4wSG17nd6rOXYXfslsm8
bCOgDAY5DB0V9eJrXkHx/B8AnCRpvhKiYp9tQpmQYloDIX0c1vDuwLVZTTM85LE2
0lKqirg3JzQYYmG1mN5iPf4VaPigyH0Znzs6Wx/xky1oBSsoBRND/AZarA6snTs1
rd/HxDlUp98=
=RRzh
-----END PGP SIGNATURE-----

--Sig_/Naj0.z9RNwrfSqR+Euo/DOm--

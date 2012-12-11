Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:38359 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753784Ab2LKWxR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 11 Dec 2012 17:53:17 -0500
Date: Wed, 12 Dec 2012 09:53:04 +1100
From: NeilBrown <neilb@suse.de>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: NFS <linux-nfs@vger.kernel.org>
Subject: Re: NFS regression - EIO is returned instead of ENOSPC
Message-ID: <20121212095304.368c9708@notabene.brown>
In-Reply-To: <20121212092813.23afbc5f@notabene.brown>
References: <20121212092813.23afbc5f@notabene.brown>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/jP_6mJlCAv8rHPfuNWH8bxC"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/jP_6mJlCAv8rHPfuNWH8bxC
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Wed, 12 Dec 2012 09:28:13 +1100 NeilBrown <neilb@suse.de> wrote:

>=20
> Hi Trond et al,
>  we seem to have a regression introduced by=20
>=20
> commit 7b281ee026552f10862b617a2a51acf49c829554
>     NFS: fsync() must exit with an error if page writeback failed
>=20
> which has found it's way (in different form into -stable releases).

Bit of a clarification here.  It didn't get into -stable, but we have the b=
ug
in our 3.0 based SLES11-SP2 through a different route (I assumed it came
through stable but was being too hasty).

The bug first arrived in v3.1-rc1

commit 02c24a82187d5a628c68edfe71ae60dc135cd178
    fs: push i_mutex and filemap_write_and_wait down into ->fsync() handlers


was fixed by me in v3.3-rc1

commit 2edb6bc3852c681c0d948245bd55108dc6407604
    NFS - fix recent breakage to NFS error handling.

the code was then messed up a bit by=20

commit a5c58892b427a2752e3ec44b0aad4ce9221dc63b
    NFS: Create a v4-specific fsync function
in v3.6-rc1

and that mess was fixed by=20

commit 7b281ee026552f10862b617a2a51acf49c829554
    NFS: fsync() must exit with an error if page writeback failed

which re-introduced the original problem in v3.6-rc6.

That first patch has been backported to SLES11 so now I'm fixing the bug
again and finding it in mainline again :-)

NeilBrown





--Sig_/jP_6mJlCAv8rHPfuNWH8bxC
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQIVAwUBUMe5UDnsnt1WYoG5AQJ0WBAArXXJbB+xlVL12pIqW2Vk4+Nw9nwby0pT
d3ip4BBWTN4pbQfyjlInArHTICiSub6+Nx3tpx4NJvuNTTnH7Mgi3fhzJ0bggRW5
QvQSxW2NN2wQlaVMB4uo6TehMjG9iyoC3XwGT5iUSbCAQlL0CaNYTH+pcNWyXVEL
qGnED1l6ONyBSZbGr1FRkzgiAGZKASmlhiAnjwjvR19I2VoYLW1FBMzDudP4h34r
lP2NWW29jMHsng3X3T/TE3dL4vgCfLG5wCFIagchzBwkAsDf6CJ8ndZ3WTqz8uea
iI1LN9OYJnD8PunDXT6PLdcdHN8E7zo3E/28x84IMQrMhrCWQtWaFFI/uK2Bh0yt
olMGaQ79CMTb5+wKy3OMwEa5r5Y3H+wxMa2s6xWudTri5alVUsyGwNNqtlSUPAZ6
LQFMJa++nk6fnaSmjNPvLFr65Z4yKLelVBBFmsq/yB1oHZPDfPsenL36hJO2qU2F
MwfZWwj419FsIv1eXETi0t9TgtIWkYotvThoVKQoizOjrkGzRaTRPOJyRVZ+SNsk
/Tw862IQPn3xNJIDMz5pQ4w20zgyaDp37E1uHhi8gupsbyIRb13HbrTfE55Z3xzJ
Z017exr6WsLrnrlmJ0Ph6DDqYhn71qa0TmtdWWWCuBivZCMSxopgLt0gqZFdW8CK
lSXoxckB3V4=
=0DBh
-----END PGP SIGNATURE-----

--Sig_/jP_6mJlCAv8rHPfuNWH8bxC--

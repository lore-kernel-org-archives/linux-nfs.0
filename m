Return-Path: linux-nfs-owner@vger.kernel.org
Received: from ozlabs.org ([103.22.144.67]:51828 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751357AbbBLWhx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 12 Feb 2015 17:37:53 -0500
Date: Fri, 13 Feb 2015 09:37:46 +1100
From: Stephen Rothwell <sfr@canb.auug.org.au>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Jens Axboe <axboe@fb.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [GIT PULL] Backing device changes for 3.20
Message-ID: <20150213093746.1507f01e@canb.auug.org.au>
In-Reply-To: <CA+55aFxnisiCLB0pHWU7dmzXWBG16gPB9cEycGRUgB+RcbJGnA@mail.gmail.com>
References: <20150212203832.GA24835@kernel.dk>
	<CA+55aFxnisiCLB0pHWU7dmzXWBG16gPB9cEycGRUgB+RcbJGnA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/Ab5Ury3K1Eh+u6ir8PX_G.4"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/Ab5Ury3K1Eh+u6ir8PX_G.4
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi All,

On Thu, 12 Feb 2015 14:05:00 -0800 Linus Torvalds <torvalds@linux-foundatio=
n.org> wrote:
>
> On Thu, Feb 12, 2015 at 12:38 PM, Jens Axboe <axboe@fb.com> wrote:
> >
> > This pull request contains a cleanup of how the backing device is
> > handled, in preparation for a rework of the life time rules. In this
> > part, the most important change is to split the unrelated nommu mmap
> > flags from it, but also removing a backing_dev_info pointer from the
> > address_space (and inode), and a cleanup of other various minor bits.
>=20
> Ugh, so this has a semantic conflict with the NFS client, that has
> this particular code:
>=20
>         if (!cinfo->dreq) {
>                 inc_zone_page_state(req->wb_page, NR_UNSTABLE_NFS);
> -               inc_bdi_stat(page_file_mapping(req->wb_page)->backing_dev=
_info,
> +
> inc_bdi_stat(inode_to_bdi(page_file_mapping(req->wb_page)->host),
>                              BDI_RECLAIMABLE);
>                 __mark_inode_dirty(req->wb_context->dentry->d_inode,
>                                    I_DIRTY_DATASYNC);
>         }
>=20
> duplicated several times, and now one more time in the new
> fs/nfs/flexfilelayout/flexfilelayout.c file.

Sometime I wonder why I bother pointing these things out in
linux-next :-(  Ah, well.

(Trond did mention it in his pull request, but it wasn't a problem
then.)

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Sig_/Ab5Ury3K1Eh+u6ir8PX_G.4
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJU3Ss/AAoJEMDTa8Ir7ZwV2ZAQAJHn1p1JuRvdfH2a9opPBz0O
R3ElQL2vfVb/xStautTVIABIA/XRG0ECcXkm1DlZOBvqRgjMwylrm5rFRkrJY6k1
pRxDFpNTkE9x/S5Ugmr5XwRaui0Qr8zO3UbcTZ2xRNZZVDDtXhv1fdnn90q98/KL
jAAeF0mw5PMRTYGMD/VSSsKz3Q09dEQoS/9opgiawRFGfu3XtEG0rizq68XtfyHB
wbnQDxlCmQOUO7uWozsjzFWEed3sHs4+C+tu1+nxmrrs0FHNsKRQxySWJjTnxlV2
eQeZScdRM5L6loc07N630N1HW79WqvGVsVZPVMVZKwYk9K9jFen1V8krhm4smohD
/XcmXNqXc8KdVDrC8eiLAmOeo4GH30hsjJgzs7uX4yYnnprXvXsxC8exaacg73I4
Xqx2p6bNAanfS/n30SpfmkvGpnn8DdxZ9C0UBhbLfzj0F/BYmEZVz60pMZAhh76V
7xVtne/RhxrkJCXkCVhksGxlg10TEkzyHcB6oIV0VJ4FL3PXbH2TDdr1tLULemRR
LOfCJjlT8t+b6udcW7XqYW9wOMRytDzww3GlNESL+plrJvhSvYCw2f3HpTA2YcTe
F/tZe0RUwxYkKMMQY17JMOEOLwbN0RulJmLaZ40/3dttAvlQ6hc9YdRqEdQjXGnk
KwLGPD+z4sfGau2OR1ir
=Eylk
-----END PGP SIGNATURE-----

--Sig_/Ab5Ury3K1Eh+u6ir8PX_G.4--

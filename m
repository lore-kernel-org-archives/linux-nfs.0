Return-Path: linux-nfs-owner@vger.kernel.org
Received: from ozlabs.org ([103.22.144.67]:40725 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754630AbaHLW2f (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 12 Aug 2014 18:28:35 -0400
Date: Wed, 13 Aug 2014 08:28:27 +1000
From: Stephen Rothwell <sfr@canb.auug.org.au>
To: Jeff Layton <jlayton@primarydata.com>
Cc: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH 0/5] locks: move most locks_release_private calls
 outside of i_lock
Message-ID: <20140813082827.1097c3ad@canb.auug.org.au>
In-Reply-To: <1407854893-2698-1-git-send-email-jlayton@primarydata.com>
References: <1407854893-2698-1-git-send-email-jlayton@primarydata.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/kE9c5iQLQE.k2/XeWc._pcT"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/kE9c5iQLQE.k2/XeWc._pcT
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi Jeff,

On Tue, 12 Aug 2014 10:48:08 -0400 Jeff Layton <jlayton@primarydata.com> wr=
ote:
>
> Absent any objections, I'll plan to merge these for 3.18.

This means that this patch set should *not* be in linux-next until after
(at least) v3.17-rc1 is released ...  This s reinforced by the lack of
Acked-by, Reviewed-by and Tested-by tags ... (the addition of which would p=
resumably require the rebase (or rewrite) of a published git tree.)

/me suspects that many people do not read his daily release notes :-(
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Sig_/kE9c5iQLQE.k2/XeWc._pcT
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJT6pUQAAoJEMDTa8Ir7ZwVTisQAIxg+9qTRROcI90xF8edNQ/L
pcpNey/kXd7AFpqvdcPmRjb8wWzZhPhWn7Gz9wQgC6UKQy7UG0T47eeInZvxX8mp
IgyR7DRhnuW7yTZdyqbOSYX+563ayw3H2BGRPImjZTOt5NL/Xll7FWusN2GI2Ses
9CfpuQ7umojSZX2lmB/V46FZ4QvvamDlJf7ybpoid+CxVWVy2zKbeQzilCNNneTv
1fyZGVVVPFfe5y6rN5vFLIMhrCkwPBjg9nSPCFLmTBE+D6541Q7z5wdc8Y1wyVGI
OMrORVjFV9sQd1qdvA5+dt1vZZzQ/WtYYX5mGUBzpV9uzlHVYxke9esL0bVRdAA1
o966aVugwQrqU0oc5zBpjf4GGy3/RTtvQgQ0FBnLLJRzUxjXuKiIxSGStP6u6E4I
9Ntd5dkL7YYzKyWg+59h2giVBZrmQxIlmtiwSf0JJRboynaoDObJQ3i79AbfT2IQ
9nlOa8TZCiRDUmiBOXXY0jz9jo6AlRZDiWKH961oUCBm6uf+38tr8zbAV6lyzSlS
rvZ6DQaniMUmHjCvIfbe9TIa9L/muNBjP93GVMMoM2t8RVp+6LEvPOlvbB/oo6AV
p/2gj1fDVSP5tSVRmFi6xWqf9F7oa0rI1Y1TU4F8frSn9r+y/JiycERJa3esL7Q1
4dXiD2vYBJT904Tkb3rv
=GIIv
-----END PGP SIGNATURE-----

--Sig_/kE9c5iQLQE.k2/XeWc._pcT--

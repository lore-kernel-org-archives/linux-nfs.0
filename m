Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:39106 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755083AbbBPD5y (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 15 Feb 2015 22:57:54 -0500
Date: Mon, 16 Feb 2015 14:57:46 +1100
From: NeilBrown <neilb@suse.de>
To: Nix <nix@esperi.org.uk>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        NFS list <linux-nfs@vger.kernel.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: Re: what on earth is going on here? paths above mountpoints turn
 into "(unreachable)"
Message-ID: <20150216145746.68809c0f@notabene.brown>
In-Reply-To: <20150216134628.773e3347@notabene.brown>
References: <87iofju9ht.fsf@spindle.srvr.nix>
	<20150203195333.GQ22301@fieldses.org>
	<87egq6lqdj.fsf@spindle.srvr.nix>
	<87r3u58df2.fsf@spindle.srvr.nix>
	<20150205112641.60340f71@notabene.brown>
	<87zj8l7j3z.fsf@spindle.srvr.nix>
	<20150210183200.GB11226@fieldses.org>
	<87vbj4ljjn.fsf@spindle.srvr.nix>
	<20150216134628.773e3347@notabene.brown>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 boundary="Sig_/pQ74ObJ6KVEvHWTIR_qHM/d"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/pQ74ObJ6KVEvHWTIR_qHM/d
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Mon, 16 Feb 2015 13:46:28 +1100 NeilBrown <neilb@suse.de> wrote:

>=20
> Anyway, please try:
>=20
> diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
> index 9b0c55cb2a2e..a460669dc395 100644
> --- a/fs/nfs/dir.c
> +++ b/fs/nfs/dir.c
> @@ -541,7 +541,7 @@ int nfs_readdir_page_filler(nfs_readdir_descriptor_t =
*desc, struct nfs_entry *en
> =20
>  		count++;
> =20
> -		if (desc->plus !=3D 0)
> +		if (desc->plus !=3D 0 && entry->fh.size)
>  			nfs_prime_dcache(desc->file->f_path.dentry, entry);
> =20
>  		status =3D nfs_readdir_add_to_array(entry, page);
>=20
>=20
> which you might have to apply by hand.
>=20
> Thanks,
> NeilBrown


Make that "entry->fh->size", not "entry->fh.size" :-(

NeilBrown

--Sig_/pQ74ObJ6KVEvHWTIR_qHM/d
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUBVOFqujnsnt1WYoG5AQICkBAAlseiZIDGdrWmxWPpq51Gu6hv/fmiBFRf
L/9bonDMaYAHFSHdpxd5311oyZLhg5vxO7sDxAp/KsBWUjcOJRArfKopWvF7abT5
hVcEA+7SLOr6HyiD4BI9kqLj9eYyK2PbwquhyhwYWcE77RIhO/U0wqyGq6oxdV5L
8N5NeJAI1LnIHJMLKrrXv19LakVLgsN/LY8sYZMbMvfBlrIMQcXi486NxtMmwve2
NOyLZyqQwLlr9oBlvXNtX43RJoCuhWHT0Of9m361oOgmpSWh1B9X+fkPufHGwwHI
p++OBx68Y7Qqf0c/DdeqpWwWuv0CgmwPmfLNqb4OUPc/vf2RxWu+HyQ7sRI4wdi2
vTwvm/OySiuSwpp+ncqguUgtANOkXQHI4F9xXj+sP2L5rSAJKg2deW3zKmk6ZMCE
VBYS2oUnRGGN4RoVxMZuv9woe4P0/LFX6fqZD1TXHEKHkT4s6ZtM0jIHoDJn0nHF
JaOQqn7OxaXTIFWkTmxwkloPCKpcGzLGcC7eABNGkpydW3wT0kcWj/AR5huvATmQ
IGjQOqgTbU1Yd42ouVHfddS7h99x8JX46LJEtqbXRMdBV8sDcioKV/yoXdwsEFfA
ic766pov/SfwODpWAmUynimeUO+SPJN1w+oCldOismwuwsVlwdOFWtFQE0iQTGg0
vZ64Pebf0OI=
=dpCJ
-----END PGP SIGNATURE-----

--Sig_/pQ74ObJ6KVEvHWTIR_qHM/d--

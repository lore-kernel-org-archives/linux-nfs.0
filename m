Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from prv3-mh.provo.novell.com ([137.65.250.26]:56733 "EHLO
	prv3-mh.provo.novell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750864AbcEIFDq (ORCPT
	<rfc822;groupwise-linux-nfs@vger.kernel.org:0:0>);
	Mon, 9 May 2016 01:03:46 -0400
From: NeilBrown <nfbrown@novell.com>
To: Al Viro <viro@ZenIV.linux.org.uk>
Date: Mon, 09 May 2016 15:03:23 +1000
Cc: Richard Weinberger <richard@nod.at>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        "linux-mtd\@lists.infradead.org" <linux-mtd@lists.infradead.org>,
        Artem Bityutskiy <dedekind1@gmail.com>,
        Christoph Hellwig <hch@infradead.org>,
        NFS List <linux-nfs@vger.kernel.org>
Subject: Re: Reconsidering exportable UBIFS
In-Reply-To: <20160508232533.GH2694@ZenIV.linux.org.uk>
References: <5702E7F5.1050807@nod.at> <871t5curbl.fsf@notabene.neil.brown.name> <20160508232533.GH2694@ZenIV.linux.org.uk>
Message-ID: <87y47ju8kk.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
	micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Mon, May 09 2016, Al Viro wrote:

> On Mon, May 09, 2016 at 08:18:22AM +1000, NeilBrown wrote:
>
>> Not puppies, just kittens.
>>=20
>> If you don't provide these functions, then exporting with
>> "subtree_check" won't work.  That is no great loss except that people
>> might find the failure confusing.
>
> 	OK, a client sends you a RENAME.  With fhandles of both parents +
> old and new names in those.  Your task, should you choose to accept it, is
> to figure out whether we should fail with nfserr_inval due to an attempt
> to make a directory its own descendent.  Without being able to locate all
> ancestors of a directory.

You are right, sorry.  I was thinking that get_parent() was for finding
the parent of a non-directory, but it is for directories.  It does the
equivalent of lookup("..").  So if you have a ".." link or something
like it, it should be easy.  If you don't, it won't be easy at all.

Thanks,
NeilBrown


>
> 	You are fond of complaining about the checks that could've been left
> to server not getting skipped on the client.  Now you want to skip them on
> the server side as well?  Can't have it both ways...
>
> 	Seriously, it really doesn't work.  You can't do directory
> modifications without having found the chain of ancestors.  No ->get_pare=
nt()
> is OK _only_ for something like tmpfs, where we have the full chains of
> ancestors towards root all the time.  For UBIFS it's obviously not true.
> Not unless you suck the entire directory tree in memory at the mount time.

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJXMBobAAoJEDnsnt1WYoG5/6oQAMRpQHhVIzr1Ab2vzZEe37Gf
pWLfLjpierucBfQ5Hy3E9jrHEp5by1hZ4vXcgkGYpTmMcEFVy/0iJnbZkM8yiy8B
f+72ldKqG//iDAII3f3WRUS0kNXrUQn0dCfoOMwlWtNOo2lREzV+Q3Z5YTg5mu7R
MIPgIOx67YdxPSxB2Ic3o3A0H7qVFbWNAaa0/DrVRHkXWmjt+wk4FfCb0UlAJoCF
rabgA7eAlEa8VuM85KXBcrlD7uhCN5zVqkGNj6+FGCPevLEjAMDWBniOVgS58ysZ
08OGWuqBVcUAFoqCpShY+yqEHTn3NsDih7QjcelTaTd7s3Etw3SoZxpTbEXFK6lY
A+yZe4UwuAUnIT8YXM+74Ymv0IKPzEX2czXOjPS+fH+7chJqHdlYgoRo7ZMjoRUP
SiKRiDJ6HRZsIVv0z7U6YMHOwj4wBq0Nmim1EP7NTWfppMT4Fr7WGV5vNPEaOdMu
Ha+t3TxSh2yTsHK1+C1PL2eJGK+g9A8AC4Mqh5XWcb1tB4eIfUjr/dA4FTMPU3/4
TGne8TO0ucYrF6spxOujOTvsP8MdnWoCLHICuxQe6qWFNLCLHux1BiGOiOqpZUlH
xdRwEGTALBh74+s5vUJs8SPiOuxGOXzqbUWrHK9vUufHNx5KzOpmKVaErdae0Ioo
usEFKGbo1w+g32OLmnuC
=vzTa
-----END PGP SIGNATURE-----
--=-=-=--

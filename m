Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:43298 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932299AbaE3WOS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 30 May 2014 18:14:18 -0400
Date: Sat, 31 May 2014 08:13:58 +1000
From: NeilBrown <neilb@suse.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        NFS <linux-nfs@vger.kernel.org>
Subject: Re: Live lock in silly-rename.
Message-ID: <20140531081358.62ae69b3@notabene.brown>
In-Reply-To: <20140530215522.GA27615@fieldses.org>
References: <20140529164521.02324559@notabene.brown>
	<CAHQdGtTtU9_zBcfzRb_wmEf7XaX9rNg-_Q85ZLX9BYax14D2Gg@mail.gmail.com>
	<20140530075135.753fb7ed@notabene.brown>
	<20140530004423.GA13746@fieldses.org>
	<20140530134442.5a8e5983@notabene.brown>
	<20140530215522.GA27615@fieldses.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/xiEES2jkTcON8n+0aOjqQVi"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/xiEES2jkTcON8n+0aOjqQVi
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Fri, 30 May 2014 17:55:23 -0400 "J. Bruce Fields" <bfields@fieldses.org>
wrote:

> On Fri, May 30, 2014 at 01:44:42PM +1000, NeilBrown wrote:
> > On Thu, 29 May 2014 20:44:23 -0400 "J. Bruce Fields" <bfields@fieldses.=
org>
> > wrote:
> >=20
> > > Yes, it's a known server bug.
> > >=20
> > > As a first attempt I was thinking of just sticking a timestamp in str=
uct
> > > inode to record the time of the most recent conflicting access and de=
ny
> > > delegations if the timestamp is too recent, for some definition of too
> > > recent.
> > >=20
> >=20
> > Hmmm... I'll have a look next week and see what I can come up with.
>=20
> Thanks!
>=20
> If we didn't think it was worth another struct inode field, we could
> probably get away with global state.  Even just refusing to give out any
> delegations for a few seconds after any delegation break would be enough
> to fix this bug.
>=20
> Or you could make it a little less harsh with a small hash table: "don't
> give out a delegation on any inode whose inode number hashes to X for a
> few seconds."

I was thinking of using a bloom filter - or possibly two.
- avoid handing out delegations if either bloom filter reports a match
- when reclaiming a delegation add the inode to the second bloom filter
- every so-often zero-out the older filter and swap them.

Might be a bit of overkill, but I won't know until I implement it.

NeilBrown

>=20
> As long as the delegations can be turned down at the whim of the server,
> we've got a lot of leeway.
>=20
> --b.


--Sig_/xiEES2jkTcON8n+0aOjqQVi
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBU4kCrDnsnt1WYoG5AQJ/OA/9FDPkBLolGLWhAf7SrfdprYk0RwcWJKCf
Jl516bFAE99TjmbaLdSqOZRIBfrLAitiMJWO5apUGNHEQ+F6IawvCUaLtVnCmMUI
k3gPfNE80q1EVHtIv9sNkmFh/dO+JcJKN2vKJ1wNtQBMdq1GNE041SXsn+mTWehI
cROjn+9siUMHerCzDe+aVf2xBQAvMwI00RqsyGqONlcbYTDejJYcOq/Rcr2x2kpA
UGpjqDoOPnt4l9Z48WATs0awRj26pT449mbD20RiUXDFP4AnNI5pHw1bpDR6iD0V
6CM1sIEIzTk65E+rt+vF3aZ4SVyXUQdUScW3wJcNGupiMtxe1b6/Y7T8VQhYYNnA
YLDo7IQDtsST7lILgFQqise2F2J+3C4AL//uap9OM3Yc9r9aZ5U3mPKUZO7JJ+TJ
hntSup70PWy/4h3XWe9NpI0jAA5HKM50VP5E96puAIXT5EaGwfuibEt7scv63Sqw
a78VLI8nxYWkIJodMhxq1qJ+ue7jvCnpPRGif6SFTgxYjSBuOczeM9kGHGrd8+3J
yE5CYqMk7NYh51MOLteWH5G1PYrkrjJHRavmnwwNpRqV0J5yZvzR9ghpgYOU78Dc
PCs5eL/TIwdnYNJ+lr4jNpoBvAHORBMNtjJcmwpfmUacV29L7/7p7VuBR6gI+MGz
XKrTm0x8yGk=
=UxkA
-----END PGP SIGNATURE-----

--Sig_/xiEES2jkTcON8n+0aOjqQVi--

Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:47136 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753422Ab2IRCEb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 17 Sep 2012 22:04:31 -0400
Date: Tue, 18 Sep 2012 12:04:17 +1000
From: NeilBrown <neilb@suse.de>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: What is NFSv4 READDIR doesn't return a filehandle....
Message-ID: <20120918120417.4251733d@notabene.brown>
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA908FC54E3@SACEXCMBX04-PRD.hq.netapp.com>
References: <20120917090537.20e38026@notabene.brown>
	<4FA345DA4F4AE44899BD2B03EEEC2FA908FC54E3@SACEXCMBX04-PRD.hq.netapp.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/W20.gbaw.Bs6L.LDUuU2haK"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/W20.gbaw.Bs6L.LDUuU2haK
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Mon, 17 Sep 2012 12:51:33 +0000 "Myklebust, Trond"
<Trond.Myklebust@netapp.com> wrote:

> > -----Original Message-----
> > From: linux-nfs-owner@vger.kernel.org [mailto:linux-nfs-
> > owner@vger.kernel.org] On Behalf Of NeilBrown
> > Sent: Sunday, September 16, 2012 7:06 PM
> > To: linux-nfs@vger.kernel.org
> > Subject: What is NFSv4 READDIR doesn't return a filehandle....
> >=20
> >=20
> > In NFSv4, the server can report which attributes it chose to return in a
> > READDIR reply.
> >=20
> > A customer has come across a server which does not return the filehandle
> > information (is that allowed?).
>=20
> The filehandle attribute is a mandatory attribute according to RFC3530, s=
o I believe that the answer is "no".
>=20
> > A consequence of this is that Linux/NFS gets confused.
> > nfs_readdir_page_filler calls nfs_prime_dcache() (because it was a read=
dir
> > plus request that was sent) and nfs_prime_dcache goes ahead and creates
> > an inode based on the filehandle that it has.
> > However decode_attr_filehandle() had happily decoded nothing as the
> > FATTR4_WORD0_FILEHANDLE bit wasn't set.
> > So the inode gets created with a zero-length filehandle and when this g=
ets
> > sent back to the server to act on the inode, it gets NFS4ERR_BADHANDLE =
to
> > the PUTFH op.
> >=20
> > So should nfs_prime_dcache() abort if the filehandle doesn't exist (pat=
ch
> > below) or should nfs_fhget() return an error if the filehandle is empty?
> >=20
> > Or maybe this behaviour should be detected and readdir should be disabl=
ed
> > for that server?
> >=20
>=20
> I don't want to have to code the client to deal with broken servers. If w=
e start down that path, then we'll end up doing nothing else.
>=20
> I can, however, see a case for extending the "nordirplus" mount option to=
 cover NFSv4. Currently it only acts on NFSv3 mounts...
>=20
>

Thanks Trond.
I'm happy with this position - less work for me :-)

As it happens, nordirplus *does* work for NFSv4 and customer had already
found that this is a successful work around.  They didn't want to have to u=
se
it though.  I've pointed out that is really isn't our problem.

Just a thought: while coping with broken servers would not be a good path to
follow, detecting protocol violations and reporting an error might be...
should the NFS client treat a missing filehandle and a malformed reply?


Thanks,
NeilBrown

--Sig_/W20.gbaw.Bs6L.LDUuU2haK
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.18 (GNU/Linux)

iQIVAwUBUFfWojnsnt1WYoG5AQKnhA//UJq/i9ZsfIxytYBQ+J35MN8CR3sYm/zY
B81eXJKtwFD2ZWg/DdBNxTfBIREfgfKR3PxHgDV+J7sORVyhAytJZzuY/yjgbBxX
YSDdcbNxCtgD0xvtH6D7I1sMXkkiBjLQlvkSAtm04X0Eg17MR2C+Gty1vJDemJbl
3/7Rmb/UsG6pQceogVzpCGsJsz2diWX9SlNQ3sCb0vM03cakhURkFmUacvPdtI1Z
T/H2AC/K7VOtxoagZE5im29fxDrfyw8tAqbdX9fWDfQ5EKDkWnsB046ne/gkVYI+
0A9/wfRTJMe1mtoyxUIOSNG18u1giVf8ZYGyklsJIsApbhVsfmXKJnzz45ue5r1p
oyk0lwKumdoln9mhqMgy2GNqvRQI9RlZLedCrVtx0k+RAvkYNLXzaGdxrJXPCw+3
G3GsDWNZ+JHTT46bdviVTrQI2FMtPUFrlSwPQ8WY4EhAus6li+UVp5DFVlmyPkYK
7ux8nCk/vfUN+SCDXUvZpsA5LkRyrxo40cFr+2Vku9Ngiu6CHMeFi+aqdQPg8lnv
0bWTaAghUaskcPWwyVFhapa/sE6dF1vmFAfL2ScsGVYHiUUAEQxt29wADcq6KeII
VKVaPHkK4ePOVvWTbxpg4/cGDSWUQG4EUbKHAGqVW0nxDj3lrstH2kBQIpK4qPBJ
iQcYUOBnZUU=
=O8dV
-----END PGP SIGNATURE-----

--Sig_/W20.gbaw.Bs6L.LDUuU2haK--

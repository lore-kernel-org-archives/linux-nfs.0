Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:54581 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750715AbbEDELz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 4 May 2015 00:11:55 -0400
Date: Mon, 4 May 2015 14:11:44 +1000
From: NeilBrown <neilb@suse.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Al Viro <viro@ZenIV.linux.org.uk>, Kinglong Mee <kinglongmee@gmail.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH RFC] NFSD: fix cannot umounting mount points under
 pseudo root
Message-ID: <20150504141144.24fdb67e@notabene.brown>
In-Reply-To: <20150503003743.GA30574@fieldses.org>
References: <20150429191934.GA23980@fieldses.org>
	<20150430075225.21a71056@notabene.brown>
	<20150430213602.GB9509@fieldses.org>
	<20150501115326.51f5613a@notabene.brown>
	<20150501020324.GP889@ZenIV.linux.org.uk>
	<20150501122333.1476c999@notabene.brown>
	<20150501022939.GQ889@ZenIV.linux.org.uk>
	<20150501130826.40721dd0@notabene.brown>
	<20150501132953.GA2583@fieldses.org>
	<20150503091653.35169382@notabene.brown>
	<20150503003743.GA30574@fieldses.org>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 boundary="Sig_/4NuCcTfOT3b3Mm7ZK=6=zXU"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/4NuCcTfOT3b3Mm7ZK=6=zXU
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Sat, 2 May 2015 20:37:43 -0400 "J. Bruce Fields" <bfields@fieldses.org>
wrote:

> On Sun, May 03, 2015 at 09:16:53AM +1000, NeilBrown wrote:
> > On Fri, 1 May 2015 09:29:53 -0400 "J. Bruce Fields" <bfields@fieldses.o=
rg>
> > wrote:
> >=20
> > > On Fri, May 01, 2015 at 01:08:26PM +1000, NeilBrown wrote:
> > > > On Fri, 1 May 2015 03:29:40 +0100 Al Viro <viro@ZenIV.linux.org.uk>=
 wrote:
> > > >=20
> > > > > On Fri, May 01, 2015 at 12:23:33PM +1000, NeilBrown wrote:
> > > > > > > What kind of consistency warranties do callers expect, BTW?  =
You do realize
> > > > > > > that between iterate_dir() and callbacks an entry might have =
been removed
> > > > > > > and/or replaced?
> > > > > >=20
> > > > > > For READDIR_PLUS, lookup_one_len is called on each name and it =
requires
> > > > > > i_mutex, so the code currently holds i_mutex over the whole seq=
uence.
> > > > > > This is triggering a deadlock.
> > > > >=20
> > > > > Yes, I've seen the context.  However, you are _not_ holding it be=
tween
> > > > > actual iterate_dir() and those callbacks, which opens a window wh=
en
> > > > > directory might have been changed.
> > > > >=20
> > > > > Again, what kind of consistency is expected by callers?  Are they=
 ready to
> > > > > cope with "there's no such entry anymore" or "inumber is nothing =
like
> > > > > what we'd put in ->ino, since it's no the same object" or "->d_ty=
pe is
> > > > > completely unrelated to what we'd found, since the damn thing had=
 been
> > > > > removed and created from scratch"?
> > > >=20
> > > > Ah, sorry.
> > > >=20
> > > > Yes, the callers are prepared for "there's no such entry anymore".
> > > > They don't use d_type, so don't care if it might be meaningless.
> > > > NFSv4 doesn't use ino either, but NFSv3 does and isn't properly cau=
tious
> > > > about ino changing.
> > > >=20
> > > > In nfs3xdr, we should probably pass 'ino' to encode_entryplus_bagga=
ge() and
> > > > thence to compose_entry_fh() and it should report failure if
> > > > dchild->d_inode->i_ino doesn't match.
> > >=20
> > > Just to make sure I understand the concern..... So it shouldn't really
> > > be a problem if readdir and lookup find different objects for the same
> > > name, the problem is just when we mix attributes from the two objects,
> > > right?  Looks like the v3 code could return an inode number derived f=
rom
> > > the readdir and a filehandle from the lookup, which is a problem.  The
> > > v4 code will get everything from the result of the lookup, which shou=
ld
> > > be OK.
> >=20
> > That agrees with my understanding, yes.
> >=20
> > I did wonder for a little while about the possibility of a directory
> > containing both 'a' and 'b', and NFSv4 doing the readdir and the stat o=
f 'a',
> > and the a "mv a b" happening before the stat of 'b'.
> >=20
> > Then the readdir response will show both 'a' and 'b' referring to the s=
ame
> > object with a link count of 1.
> >=20
> > I can't quite decide if that is a problem or not.
>=20
> My understanding is that that's completely normal behavior for lots of
> filesystems.
>=20
> Googling around....  Here's Ted on the question:
>=20
> 	http://yarchive.net/comp/linux/readdir_nonatomicity.html
>=20
> 	In some cases it won't even just get lost, but the old and new
> 	name can both be returned.  For example, if you assume the use
> 	of a simple non-tree, linked-list implementation of a directory,
> 	such can be found in Solaris's ufs, BSD 4.3's FFS, Linux's ext2
> 	and minix filesystems, and many others, and you have a fully
> 	tightly packed directory (i.e., no gaps), with the directory
> 	entry "foo" at the beginning of the file, and readdir() has
> 	already returned the first "foo" entry when some other
> 	application renames it "Supercalifragilisticexpialidocious", the
> 	new name will not fit in the old name's directory location, so
> 	it will be placed at the end of the directory --- where it will
> 	be returned by readdir() a second time.
>=20
> 	This is not a bug; the POSIX specification explicitly allows
> 	this behavior.  If a filename is renamed during a readdir()
> 	session of a directory, it is undefined where that neither,
> 	either, or both of the new and old filenames will be returned.
>=20

I think that is a slightly different situation to the one I was imagining.
Ted's observation here is completely about readdir results.

A NFS READDIR_PLUS result can be used to satisfy subsequence stat() request=
s.
I don't think it would ever be correct to=20
  stat('a')
  stat('b')
  stat('a')

and get exactly the same stat info in every case, including inode number and
ctime and link count of '1'.
If those stats were served from the READDIRPLUS results that I described
above, that is exactly what you would get.
I'm not sure if the  post-op attributes would be enough to tell the client =
it
needs to do a GETATTR again straight away to verify things.

But if the attr info stays cached (which is kind-of the point of
READDIR_PLUS), this is a very different circumstance than the one Ted
described.

Still not sure how important it is, but I like the NFSv3 option of just not
returning attributes if we aren't certain of them.

An option for NFSv4 might be to abort/retry the readdir op if the directory
has changed at all(?).

NeilBrown

--Sig_/4NuCcTfOT3b3Mm7ZK=6=zXU
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUBVUbxgTnsnt1WYoG5AQLotRAAwt/5zsJQvSY8yyAA1LceTPQlenRTVogg
tO1yO7NXAgYXLoglVfrfjx5ArMvxK2EvWBpcqF7qMbeCuRnzpHgKj4SkaSde2rYF
TP42EMx+p3I4/MQyA6drT7DzXL8v2GSgPQnEsjd/AzRZ+hnTp3XIktiFOrN4rgOq
dZtMfCLItqqz/Eanz6tM+xJ2nucavmO5PNIExtfjJZWAEITM1igTeh3nDjvxY87J
NSoCPXHOfX7mgds6o8pbuJvgXDcIWcXxNMlBbB6CsfP4HFVnKPrZK4KFV+O1ixgi
1ZeXv1hlSdqA2Sg1hLyrvZ6FVAm/uNfgarK1iva/udHXxPHVWaTwrG675UU4oXJA
Cb20E8k3ZtMmRr8NokJZ2VP9/8Of5GTGZtNGYjEpDbjot21fJgUF/c1lqOZcMKii
SUKBqdf072DSGJw8KlaMyWtdlXlcXb4DfTIs4CaQgSCdx57aIE4lu3Uu8ByXO1oL
yKQH7OI+8Ph2PWpYI4J4TccaTpr1677StmtD7/ybQAf39cyoVbKP9tPcsNNkcQ79
vEkgsa2pLokt2lElkKrz7r0RSuGf+7jkAVAc/CKFdMb787k8so61WBGEQS3DNAhS
UcVvsD3n4jqdHrNvsfW4TLp2AF8ajpyn/smpzOAUP5GzJQUAccgH8ILi7z9oJmbO
ReuZr0UvAGs=
=xZsa
-----END PGP SIGNATURE-----

--Sig_/4NuCcTfOT3b3Mm7ZK=6=zXU--

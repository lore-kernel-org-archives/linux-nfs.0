Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:47614 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753315Ab3IJEmV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 10 Sep 2013 00:42:21 -0400
Date: Tue, 10 Sep 2013 14:42:09 +1000
From: NeilBrown <neilb@suse.de>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: NFS <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH/RFC] make nfs_flush_incompatible more forgiving.
Message-ID: <20130910144209.21361396@notabene.brown>
In-Reply-To: <1378351073.30440.14.camel@leira.trondhjem.org>
References: <20130904113632.1a1eb337@notabene.brown>
	<1378305214.3527.10.camel@leira.trondhjem.org>
	<20130905092947.248a80e6@notabene.brown>
	<1378351073.30440.14.camel@leira.trondhjem.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/ZvPddlDXM8sBEQ60I4cHzGg"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/ZvPddlDXM8sBEQ60I4cHzGg
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Thu, 5 Sep 2013 03:17:54 +0000 "Myklebust, Trond"
<Trond.Myklebust@netapp.com> wrote:

> On Thu, 2013-09-05 at 09:29 +1000, NeilBrown wrote:
> > On Wed, 4 Sep 2013 14:33:35 +0000 "Myklebust, Trond"
> > <Trond.Myklebust@netapp.com> wrote:
> >=20
> > > On Wed, 2013-09-04 at 11:36 +1000, NeilBrown wrote:
> > > > Hi,
> > > >  we have a customer who has noticed a significant regression in NFS
> > > >  performance between SLES10 (2.6.16+) and SLES11 (3.0+).
> > > >=20
> > > >  The use case involves two different processes on the same client m=
mapping a
> > > >  file and making changes.
> > > >=20
> > > >  In 2.6.16, all these changes would be cached on the client until a=
 flush or
> > > >  close or other normal process flushed the changes out - much the s=
ame as if
> > > >  just one process was accessing the file.
> > > >=20
> > > >  In 3.0 the file is flushed out every time a different process perf=
orms an
> > > >  update. So if they interleave accesses, you get a flush-to-the-ser=
ver on
> > > >  every access.
> > > >=20
> > > >  This is caused by nfs_flush_incompatible.  It deems access through=
 different
> > > >  file descriptors to be incompatible.  However I don't think this is
> > > >  justified.  Accessed using different credentials can reasonably be=
 seen as
> > > >  incompatible(*), but if two processes with identical credentials o=
pen the
> > > >  same file there there should be not need to differentiate between =
them.
> > > >=20
> > > >  The patch below changes the test in nfs_flush_incompatible to just=
 test the
> > > >  credentials (and the dentry, though that might be superfluous - it=
 seems
> > > >  safer).
> > > >=20
> > > > (*) In this specific customer's case the process do currently have =
slightly
> > > >  different credentials.  In one, the primary gid is included in the=
 list of
> > > >  auxiliary gids.  In the other the primary gid is excluded.  This i=
s enough
> > > >  to make the credentials appear different so this patch doesn't hel=
p in that
> > > >  case.  They are looking at being more consistent in their setgroup=
s usage
> > > >  but it would help them if we only actually compared the credential=
s that
> > > >  were important.  In this case there is no important difference.
> > > >  Would it make sense to treat a more broad credential as compatible=
 with a
> > > >  more narrow credential?  So a write from a process with a given
> > > >  uid,gid,grouplist could ultimately be sent to the server with same=
 uid/gid,
> > > >  but a subset of the group list?
> > > > =20
> > > >=20
> > > >  Thoughts?
> > > >=20
> > > > Thanks,
> > > > NeilBrown
> > > >=20
> > > >=20
> > > > diff --git a/fs/nfs/write.c b/fs/nfs/write.c
> > > > index 7816801..b0d4e47 100644
> > > > --- a/fs/nfs/write.c
> > > > +++ b/fs/nfs/write.c
> > > > @@ -860,7 +860,12 @@ int nfs_flush_incompatible(struct file *file, =
struct page *page)
> > > >  		if (req =3D=3D NULL)
> > > >  			return 0;
> > > >  		l_ctx =3D req->wb_lock_context;
> > > > -		do_flush =3D req->wb_page !=3D page || req->wb_context !=3D ctx;
> > > > +		do_flush =3D req->wb_page !=3D page;
> > > > +		if (req->wb_context !=3D ctx) {
> > > > +			do_flush |=3D
> > > > +				req->wb_context->dentry !=3D ctx->dentry ||
> > > > +				req->wb_context->cred !=3D ctx->cred;
> > > > +		}
> > > >  		if (l_ctx) {
> > > >  			do_flush |=3D l_ctx->lockowner.l_owner !=3D current->files
> > > >  				|| l_ctx->lockowner.l_pid !=3D current->tgid;
> > >=20
> > > Hi Neil,
> > >=20
> > > Won't this cause any write errors to be propagated to the wrong proce=
ss?
> >=20
> > I'm not sure what this means.
> >=20
> > For a local filesystem, the only error that isn't synchronous is EIO an=
d an
> > application can only be sure of getting that if it uses 'fsync'.  An
> > application can get EIO from fsync even if it didn't write to the page =
which
> > is causing the problem.  All apps should be able to see the EIO if they
> > bother to fsync.
>=20
> You are describing a consequence of the complete and utter brokenness of
> the block layer. The block layer doesn't track who wrote what into the
> page cache, and so it just passes any write errors to whichever process
> that first calls filemap_check_errors() for that file.

I would have said "pragmatic design" rather than "complete ... brokenness".

If a write has failed then the file is corrupt and every writer deserves to
know.
If multiple processes try to fsync the same file, pages that fail for one
process will likely fail for the next process so each should get told of the
failure.

(actually... I wonder if I'm missing something.  If you have a Dirty page
which results in an Error every time it is written, is there any way for
it to be removed from the page cache, or will it remain there causing every
'fsync' on the file to try to write the same page and get an error?)

>=20
> In NFS, we use the nfs_open_context to track exactly who wrote what, and
> use that to notify the specific process that wrote the data that failed.

While this could be seen as an improvement, the extra guarantees are only
available on NFS, so apps are not likely to depend on them, so the extra va=
lue
doesn't actually help anyone - does it?

And it has a clear cost: two processes on the one machine can suffer
significantly degraded performance.
Is the theoretical improvement in semantics worth that cost.

>=20
> > For NFS, EDQUOT and ENOSPC are also asynchronous, and they can also com=
e in
> > through close().  I think every app should still see every error whethe=
r  it
> > dirtied the page which triggered the error or not.
>=20
> With this patch, we can end up writing the data using the wrong
> nfs_open_context, in which case the errors will get reported to the
> process that actually owns that nfs_open_context.
>=20

I see yes.  I would want the error to be returned to whoever instigated the
'flush', not whoever issues the 'write'.

Thanks,
NeilBrown

--Sig_/ZvPddlDXM8sBEQ60I4cHzGg
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQIVAwUBUi6jIjnsnt1WYoG5AQIJTRAAhviTy1/pt0TgHXuskLhohxoyDF5YV0bK
8fkrud7qO4CRBEIBwEOJdU9dSDMNLOugg4pQwKBdIMEnDWZI7he5x9GXU1tAZetn
9xdGrwundVhVj1yS3xPyl4uhytq1obMrfj0epH5SwpzQdBmO0Lq4KwVYmtGnuYoY
qLeBjL1xKU8j+xdUldafDyUyk6kr/I9qhNQ1HWcGDkgPYlNB6qnRKE9X9+8Wve5o
icUCdtpyOZzRBvVLFKQEt4oNcR8DO5M2gghH5sLlPw8BMua999viC9eHBVTyY8i7
TcLqnW08GvvuOIfSU7u4roSiM7y8RoeaFuzxw9aAiFnIyQfPFETur2uDTk1mx6pD
flM9vSCVvnr+L1Fd1gZQxWrdQLh29z9rwj3w/KU2P5TTOziLUw4ZWo486EtnuKxf
/sig2vKSJlOPdOkVExKEz/GuTi3qpSnSq1OmaVc6+IWIuDeZEXp1Ybw3PN5zDZeV
W38WPNIJ3xlD6eyg4pqquxv5gdNQ+Jtct7M35MkQyrmyhdb44Jw9rCYmHSie8xBF
8J6VjNDjeB5tEhFTbcOXG59DNmiRUBR6w3BQrPFEivCfo+Wjz2XRX6ghMkLVLkiP
1Ubjsue2rd1ZynC5rcL+HIYIBQ0rdsUATfqMmc6dPvAzOVLF7vuiCuL106AY6upj
HGTBYg+iZeA=
=EsUs
-----END PGP SIGNATURE-----

--Sig_/ZvPddlDXM8sBEQ60I4cHzGg--

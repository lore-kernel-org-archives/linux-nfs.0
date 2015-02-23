Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:48475 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751883AbbBWDFl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 22 Feb 2015 22:05:41 -0500
Date: Mon, 23 Feb 2015 14:05:26 +1100
From: NeilBrown <neilb@suse.de>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Nix <nix@esperi.org.uk>, "J. Bruce Fields" <bfields@fieldses.org>,
        NFS list <linux-nfs@vger.kernel.org>
Subject: Re: what on earth is going on here? paths above mountpoints turn
 into "(unreachable)"
Message-ID: <20150223140526.3328468e@notabene.brown>
In-Reply-To: <CAHQdGtTxrL1Mbh=FpYgEE3vKWKM+puQc6G62gTgmscjC0qYm9A@mail.gmail.com>
References: <87iofju9ht.fsf@spindle.srvr.nix>
	<20150203195333.GQ22301@fieldses.org>
	<87egq6lqdj.fsf@spindle.srvr.nix>
	<87r3u58df2.fsf@spindle.srvr.nix>
	<20150205112641.60340f71@notabene.brown>
	<87zj8l7j3z.fsf@spindle.srvr.nix>
	<20150210183200.GB11226@fieldses.org>
	<87vbj4ljjn.fsf@spindle.srvr.nix>
	<20150216134628.773e3347@notabene.brown>
	<CAHQdGtRZP2wYeLozY5pzrD-GALKqV8g1tjV2orotZuTcug2v3A@mail.gmail.com>
	<20150216155429.46cfbab7@notabene.brown>
	<1424643211.4278.10.camel@primarydata.com>
	<20150223094747.040ce304@notabene.brown>
	<CAHQdGtTxrL1Mbh=FpYgEE3vKWKM+puQc6G62gTgmscjC0qYm9A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 boundary="Sig_/ti_dcwdZ+iGajGO9QH1veEw"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/ti_dcwdZ+iGajGO9QH1veEw
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Sun, 22 Feb 2015 21:05:12 -0500 Trond Myklebust
<trond.myklebust@primarydata.com> wrote:

> On Sun, Feb 22, 2015 at 5:47 PM, NeilBrown <neilb@suse.de> wrote:
> > On Sun, 22 Feb 2015 17:13:31 -0500 Trond Myklebust
> > <trond.myklebust@primarydata.com> wrote:
> >
> >> On Mon, 2015-02-16 at 15:54 +1100, NeilBrown wrote:
> >> > On Sun, 15 Feb 2015 23:28:12 -0500 Trond Myklebust
> >> > <trond.myklebust@primarydata.com> wrote:
> >> >
> >> > > On Sun, Feb 15, 2015 at 9:46 PM, NeilBrown <neilb@suse.de> wrote:
> >> > > > On Sat, 14 Feb 2015 13:17:00 +0000 Nix <nix@esperi.org.uk> wrote:
> >> > > >
> >> > > >> On 10 Feb 2015, J. Bruce Fields outgrape:
> >> > > >>
> >> > > >> > It might be interesting to see output from
> >> > > >> >
> >> > > >> >     rpc.debug -m rpc -s cache
> >> > > >> >     cat /proc/net/rpc/nfsd.export/content
> >> > > >> >     cat /proc/net/rpc/nfsd.fh/content
> >> > > >> >
> >> > > >> > especially after the problem manifests.
> >> > > >>
> >> > > >> So the mount has vanished again. I couldn't make it happen with
> >> > > >> nordirplus in the mount options, so that might provide you with=
 a clue.
> >> > > >
> >> > > > Yup.  It does.
> >> > > >
> >> > > > There is definitely something wrong in nfs_prime_dcache.  I cann=
ot quite
> >> > > > trace through from cause to effect, but maybe I don't need to.
> >> > > >
> >> > > > Can you try the following patch and see if that makes the proble=
m disappear?
> >> > > >
> >> > > > When you perform a READDIRPLUS request on a directory that conta=
ins
> >> > > > mountpoints, the the Linux NFS server doesn't return a file-hand=
le for
> >> > > > those names which are mountpoints (because doing so is a bit tri=
cky).
> >> > > >
> >> > > > nfs3_decode_dirent notices and decodes as a filehandle with zero=
 length.
> >> > > >
> >> > > > The "nfs_same_file()" check in nfs_prime_dcache() determines tha=
t isn't
> >> > > > the same as the filehandle it has, and tries to invalidate it an=
d make a new
> >> > > > one.
> >> > > >
> >> > > > The invalidation should fail (probably does).
> >> > > > The creating of a new one ... might succeed.  Beyond that, it al=
l gets a bit
> >> > > > hazy.
> >> > > >
> >> > > > Anyway, please try:
> >> > > >
> >> > > > diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
> >> > > > index 9b0c55cb2a2e..a460669dc395 100644
> >> > > > --- a/fs/nfs/dir.c
> >> > > > +++ b/fs/nfs/dir.c
> >> > > > @@ -541,7 +541,7 @@ int nfs_readdir_page_filler(nfs_readdir_desc=
riptor_t *desc, struct nfs_entry *en
> >> > > >
> >> > > >                 count++;
> >> > > >
> >> > > > -               if (desc->plus !=3D 0)
> >> > > > +               if (desc->plus !=3D 0 && entry->fh.size)
> >> > > >                         nfs_prime_dcache(desc->file->f_path.dent=
ry, entry);
> >> > > >
> >> > > >                 status =3D nfs_readdir_add_to_array(entry, page);
> >> > > >
> >> > > >
> >> > > > which you might have to apply by hand.
> >> > >
> >> > > Doesn't that check ultimately belong in nfs_fget()? It would seem =
to
> >> > > apply to all filehandles, irrespective of provenance.
> >> > >
> >> >
> >> > Maybe.  Though I think it also needs to be before nfs_prime_dcache()=
 tries to
> >> > valid the dentry it found.
> >> > e.g.
> >> >
> >> >  if (dentry !=3D NULL) {
> >> >     if (entry->fh->size =3D=3D 0)
> >> >        goto out;
> >> >     else if (nfs_same_file(..)) {
> >> >     ....
> >> >     else {
> >> >         d_invalidate();
> >> >         ...
> >> >     }
> >> >   }
> >> >
> >> > ??
> >> >
> >> > I'd really like to understand what is actually happening though.
> >> > d_invalidate() shouldn't effect an unmount.
> >> >
> >> > Maybe the dentry that gets mounted on is the one with the all-zero f=
h...
> >>
> >> Commit 8ed936b5671bf (v3.18+) changes d_invalidate() to unmount the
> >> subtree on a directory being invalidated.
> >>
> >> I disagree that the problem here is the zero length filehandle. It is
> >> rather that we need to accommodate situations where the server is
> >> setting us up for a submount or a NFSv4 referral.
> >
> > I don't understand how you can view the treatment of a non-existent
> > filehandle as though it were a real filehandle as anything other than a=
 bug.
>=20
> I see it as a case of "I can't return a filehandle, because you're not
> supposed to ever see this inode".

According to rfc1813, READDIRPLUS returns the filehandles in a "post_of_fh3"
structure which can optionally contain a filehandle.
The text says:
   One of the principles of this revision of the NFS protocol is to
   return the real value from the indicated operation and not an
   error from an incidental operation. The post_op_fh3 structure
   was designed to allow the server to recover from errors
   encountered while constructing a file handle.

which suggests that the absence of a filehandle could possibly be interpret=
ed
as an error having occurred, but it doesn't allow the client to guess
what that error might have been.
It certainly doesn't allow the client to deduce "you're not supposed to ever
see this inode".


>=20
> IOW: it is literally the case that the client is supposed to create a
> proxy inode because this is supposed to be a mountpoint.

This may be valid in the specific case that we are talking to a Linux NFSv3
server (of a certain vintage).  It isn't generally valid.


>=20
> > I certainly agree that there may be other issues with this code.  It is
> > unlikely to handle volatile filehandles well, and as you say, referrals=
 may
> > well be an issue too.
> >
> > But surely if the server didn't return a valid filehandle, then it is w=
rong
> > to pretend that "all-zeros" is a valid filehandle.  That is what the cu=
rrent
> > code does.
>=20
> As long as we have a valid mounted-on-fileid or a valid fileid, then
> we can still discriminate. That is also what the current code does.
> The only really broken case is if the server returns no filehandle or
> fileid. AFAICS we should be handling that case correctly too in
> nfs_refresh_inode().

When nfs_same_file() returns 'true', I agree that nfs_refresh_inode() does
the correct thing.
When nfs_same_file() returns 'false', (e.g. the server returns no
filehandle), then we don't even get to nfs_refresh_inode().

When readdirplus returns the expected filehandle and/or  fileid, we should
clearly refresh the cached attributed.  When it returns clearly different
information it is reasonable to discard the cached information.
When it explicitly returns no information - there is nothing that can be
assumed.


>=20
> >> In that situation, it is perfectly OK for nfs_prime_dcache() to create
> >> an entry for the mounted-on file. It's just not OK for it to invalidate
> >> the dentry if the submount was already performed.
> >>
> >> So how about the following alternative patch?
> >>
> >> 8<----------------------------------------------------------------
> >> >From 1c8194f2147c10fc7a142eda4f6d7f35ae1f7d4f Mon Sep 17 00:00:00 2001
> >> From: Trond Myklebust <trond.myklebust@primarydata.com>
> >> Date: Sun, 22 Feb 2015 16:35:36 -0500
> >> Subject: [PATCH] NFS: Don't invalidate a submounted dentry in
> >>  nfs_prime_dcache()
> >>
> >> If we're traversing a directory which contains a submounted filesystem,
> >> or one that has a referral, the NFS server that is processing the READ=
DIR
> >> request will often return information for the underlying (mounted-on)
> >> directory. It may, or may not, also return filehandle information.
> >>
> >> If this happens, and the lookup in nfs_prime_dcache() returns the
> >> dentry for the submounted directory, the filehandle comparison will
> >> fail, and we call d_invalidate(). Post-commit 8ed936b5671bf
> >> ("vfs: Lazily remove mounts on unlinked files and directories."), this
> >> means the entire subtree is unmounted.
> >>
> >> The following minimal patch addresses this problem by punting on
> >> the invalidation if there is a submount.
> >>
> >> Cudos to Neil Brown <neilb@suse.de> for having tracked down this
> >> issue (see link).
> >>
> >> Reported-by: Nix <nix@esperi.org.uk>
> >> Link: http://lkml.kernel.org/r/87iofju9ht.fsf@spindle.srvr.nix
> >> Fixes: d39ab9de3b80 ("NFS: re-add readdir plus")
> >> Cc: stable@vger.kernel.org # 2.6.27+
> >> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> >> ---
> >>  fs/nfs/dir.c | 8 ++++----
> >>  1 file changed, 4 insertions(+), 4 deletions(-)
> >>
> >> diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
> >> index 43e29e3e3697..c35ff07b7345 100644
> >> --- a/fs/nfs/dir.c
> >> +++ b/fs/nfs/dir.c
> >> @@ -485,10 +485,10 @@ void nfs_prime_dcache(struct dentry *parent, str=
uct nfs_entry *entry)
> >>                       if (!status)
> >>                               nfs_setsecurity(dentry->d_inode, entry->=
fattr, entry->label);
> >>                       goto out;
> >> -             } else {
> >> -                     d_invalidate(dentry);
> >> -                     dput(dentry);
> >> -             }
> >> +             } else if (IS_ROOT(dentry))
> >> +                     goto out;
> >> +             d_invalidate(dentry);
> >> +             dput(dentry);
> >
> > The 'dentry' in this case was obtained via d_lookup() which doesn't fol=
low
> > mount points.  So there is no chance that IS_ROOT(dentry).
> > d_mountpoint(dentry) might be a more interesting test.
> >
> > However d_invalidate will unmount any subtree further down.
> > So if I have /a/b/c/d all via NFS, and  'd' is a mountpoint, then if th=
e NFS
> > server returns a new filehandle for 'b', 'd' will get unmounted.  Neith=
er
> > 'IS_ROOT' nor 'd_mountpoint' will guard against that.
> >
> > I'm not really sure what we do want here.  The old behaviour of d_inval=
idate,
> > where it failed if anything was mounted, seemed like a reasonable sort =
of
> > behaviour.  But we don't have that available any more.
>=20
> If the mounted-on-fileid has changed, then we _should_ invalidate.

I can't argue with that.
However as "nfs_same_file()" doesn't check the fileid, I'm not sure how
relevant it is.
Maybe nfs_same_file() should compare the fileid - providing the
fileattributes are included in the READDIRPLUS reply.  comparing the
entry->ino fileid might not work reliably.

Thanks,
NeilBrown

--Sig_/ti_dcwdZ+iGajGO9QH1veEw
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIUAwUBVOqY9jnsnt1WYoG5AQKT/w/4hXbyjITYYQRyTIKKrgOMZmUY7m4K/mJr
GJVoQlHv4XGzfEiQXgiqFv/b22LgmyJ5jmv+kjBnd7FHdBBDvpvR5jpr7jWuTEKS
jG7ckepR+Ks/Vpl4Z5E4r5aRmNpkNmBvso/lPm4zMzrN/u/cY72rWG1pygMFytQM
/Hr4BPd1cWzkrAkJ6/+CYIEgI9oUsKx58mxqGXVkKnoy1P2HmvN1+3SnNg1ODp93
9rJtNZLV4/yi/iRIHgmFkpIMpH3UFTaMlQi6fcY7adpEv3qFr0w799PiVDHRDNXa
mnctH8bcbr3+UC7VhirvpQGAGiv+bqf87kzcNLAOLda0rzSihSaKNvGuXytoeiAc
q+QkzEJOHUSqil4dqRkAvU0Y0ZPqHro0OmlSXgkL320iA4l81/8ocKiBeLeepAMl
SsRHjafb1BvfQXmX8HHonzXQjpBHmCbixaAHAuhythrwg1STqO6VBzacQsFkQrti
0+ezc0atJdap85XdH8ze6XuZzSeYdmZnSLZoQ0PGXQS1KcepY8zkiJu4jJwEIrgC
neabx5vc+N0Jb1w8tntUVLlSwfNJ+rdPLVEODS5X0aMwjzbxSb0amCuapzVUxGfG
Tcp5kuP6y7l44cXSuFobhQreUq6pvWEMMLU+eBEdlvybOJb4xjS+2Boiz3+52QQz
9ijiODBqKw==
=u+I5
-----END PGP SIGNATURE-----

--Sig_/ti_dcwdZ+iGajGO9QH1veEw--

Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:41337 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752027AbbBVWr4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 22 Feb 2015 17:47:56 -0500
Date: Mon, 23 Feb 2015 09:47:47 +1100
From: NeilBrown <neilb@suse.de>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Nix <nix@esperi.org.uk>, "J. Bruce Fields" <bfields@fieldses.org>,
        NFS list <linux-nfs@vger.kernel.org>
Subject: Re: what on earth is going on here? paths above mountpoints turn
 into "(unreachable)"
Message-ID: <20150223094747.040ce304@notabene.brown>
In-Reply-To: <1424643211.4278.10.camel@primarydata.com>
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
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 boundary="Sig_/xIQCAb30Y8rwN7+f2F6pTtl"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/xIQCAb30Y8rwN7+f2F6pTtl
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Sun, 22 Feb 2015 17:13:31 -0500 Trond Myklebust
<trond.myklebust@primarydata.com> wrote:

> On Mon, 2015-02-16 at 15:54 +1100, NeilBrown wrote:
> > On Sun, 15 Feb 2015 23:28:12 -0500 Trond Myklebust
> > <trond.myklebust@primarydata.com> wrote:
> >=20
> > > On Sun, Feb 15, 2015 at 9:46 PM, NeilBrown <neilb@suse.de> wrote:
> > > > On Sat, 14 Feb 2015 13:17:00 +0000 Nix <nix@esperi.org.uk> wrote:
> > > >
> > > >> On 10 Feb 2015, J. Bruce Fields outgrape:
> > > >>
> > > >> > It might be interesting to see output from
> > > >> >
> > > >> >     rpc.debug -m rpc -s cache
> > > >> >     cat /proc/net/rpc/nfsd.export/content
> > > >> >     cat /proc/net/rpc/nfsd.fh/content
> > > >> >
> > > >> > especially after the problem manifests.
> > > >>
> > > >> So the mount has vanished again. I couldn't make it happen with
> > > >> nordirplus in the mount options, so that might provide you with a =
clue.
> > > >
> > > > Yup.  It does.
> > > >
> > > > There is definitely something wrong in nfs_prime_dcache.  I cannot =
quite
> > > > trace through from cause to effect, but maybe I don't need to.
> > > >
> > > > Can you try the following patch and see if that makes the problem d=
isappear?
> > > >
> > > > When you perform a READDIRPLUS request on a directory that contains
> > > > mountpoints, the the Linux NFS server doesn't return a file-handle =
for
> > > > those names which are mountpoints (because doing so is a bit tricky=
).
> > > >
> > > > nfs3_decode_dirent notices and decodes as a filehandle with zero le=
ngth.
> > > >
> > > > The "nfs_same_file()" check in nfs_prime_dcache() determines that i=
sn't
> > > > the same as the filehandle it has, and tries to invalidate it and m=
ake a new
> > > > one.
> > > >
> > > > The invalidation should fail (probably does).
> > > > The creating of a new one ... might succeed.  Beyond that, it all g=
ets a bit
> > > > hazy.
> > > >
> > > > Anyway, please try:
> > > >
> > > > diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
> > > > index 9b0c55cb2a2e..a460669dc395 100644
> > > > --- a/fs/nfs/dir.c
> > > > +++ b/fs/nfs/dir.c
> > > > @@ -541,7 +541,7 @@ int nfs_readdir_page_filler(nfs_readdir_descrip=
tor_t *desc, struct nfs_entry *en
> > > >
> > > >                 count++;
> > > >
> > > > -               if (desc->plus !=3D 0)
> > > > +               if (desc->plus !=3D 0 && entry->fh.size)
> > > >                         nfs_prime_dcache(desc->file->f_path.dentry,=
 entry);
> > > >
> > > >                 status =3D nfs_readdir_add_to_array(entry, page);
> > > >
> > > >
> > > > which you might have to apply by hand.
> > >=20
> > > Doesn't that check ultimately belong in nfs_fget()? It would seem to
> > > apply to all filehandles, irrespective of provenance.
> > >=20
> >=20
> > Maybe.  Though I think it also needs to be before nfs_prime_dcache() tr=
ies to
> > valid the dentry it found.
> > e.g.
> >=20
> >  if (dentry !=3D NULL) {
> >     if (entry->fh->size =3D=3D 0)
> >        goto out;
> >     else if (nfs_same_file(..)) {
> > 	....
> >     else {
> >         d_invalidate();
> >         ...
> >     }
> >   }
> >=20
> > ??
> >=20
> > I'd really like to understand what is actually happening though.
> > d_invalidate() shouldn't effect an unmount.
> >=20
> > Maybe the dentry that gets mounted on is the one with the all-zero fh...
>=20
> Commit 8ed936b5671bf (v3.18+) changes d_invalidate() to unmount the
> subtree on a directory being invalidated.
>=20
> I disagree that the problem here is the zero length filehandle. It is
> rather that we need to accommodate situations where the server is
> setting us up for a submount or a NFSv4 referral.

I don't understand how you can view the treatment of a non-existent
filehandle as though it were a real filehandle as anything other than a bug.

I certainly agree that there may be other issues with this code.  It is
unlikely to handle volatile filehandles well, and as you say, referrals may
well be an issue too.

But surely if the server didn't return a valid filehandle, then it is wrong
to pretend that "all-zeros" is a valid filehandle.  That is what the current
code does.


> In that situation, it is perfectly OK for nfs_prime_dcache() to create
> an entry for the mounted-on file. It's just not OK for it to invalidate
> the dentry if the submount was already performed.
>=20
> So how about the following alternative patch?
>=20
> 8<----------------------------------------------------------------
> >From 1c8194f2147c10fc7a142eda4f6d7f35ae1f7d4f Mon Sep 17 00:00:00 2001
> From: Trond Myklebust <trond.myklebust@primarydata.com>
> Date: Sun, 22 Feb 2015 16:35:36 -0500
> Subject: [PATCH] NFS: Don't invalidate a submounted dentry in
>  nfs_prime_dcache()
>=20
> If we're traversing a directory which contains a submounted filesystem,
> or one that has a referral, the NFS server that is processing the READDIR
> request will often return information for the underlying (mounted-on)
> directory. It may, or may not, also return filehandle information.
>=20
> If this happens, and the lookup in nfs_prime_dcache() returns the
> dentry for the submounted directory, the filehandle comparison will
> fail, and we call d_invalidate(). Post-commit 8ed936b5671bf
> ("vfs: Lazily remove mounts on unlinked files and directories."), this
> means the entire subtree is unmounted.
>=20
> The following minimal patch addresses this problem by punting on
> the invalidation if there is a submount.
>=20
> Cudos to Neil Brown <neilb@suse.de> for having tracked down this
> issue (see link).
>=20
> Reported-by: Nix <nix@esperi.org.uk>
> Link: http://lkml.kernel.org/r/87iofju9ht.fsf@spindle.srvr.nix
> Fixes: d39ab9de3b80 ("NFS: re-add readdir plus")
> Cc: stable@vger.kernel.org # 2.6.27+
> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> ---
>  fs/nfs/dir.c | 8 ++++----
>  1 file changed, 4 insertions(+), 4 deletions(-)
>=20
> diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
> index 43e29e3e3697..c35ff07b7345 100644
> --- a/fs/nfs/dir.c
> +++ b/fs/nfs/dir.c
> @@ -485,10 +485,10 @@ void nfs_prime_dcache(struct dentry *parent, struct=
 nfs_entry *entry)
>  			if (!status)
>  				nfs_setsecurity(dentry->d_inode, entry->fattr, entry->label);
>  			goto out;
> -		} else {
> -			d_invalidate(dentry);
> -			dput(dentry);
> -		}
> +		} else if (IS_ROOT(dentry))
> +			goto out;
> +		d_invalidate(dentry);
> +		dput(dentry);

The 'dentry' in this case was obtained via d_lookup() which doesn't follow
mount points.  So there is no chance that IS_ROOT(dentry).
d_mountpoint(dentry) might be a more interesting test.

However d_invalidate will unmount any subtree further down.
So if I have /a/b/c/d all via NFS, and  'd' is a mountpoint, then if the NFS
server returns a new filehandle for 'b', 'd' will get unmounted.  Neither
'IS_ROOT' nor 'd_mountpoint' will guard against that.

I'm not really sure what we do want here.  The old behaviour of d_invalidat=
e,
where it failed if anything was mounted, seemed like a reasonable sort of
behaviour.  But we don't have that available any more.

NeilBrown

--Sig_/xIQCAb30Y8rwN7+f2F6pTtl
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUBVOpckznsnt1WYoG5AQIlvRAAiSccUWQCQPMQoq118tQqTcE0BCNt/I+h
/EaOP53MDi74wX4TypaScbqNqdcG/409wLCxggpOyOvyqmPam74EMQ7Xuf+yKnIS
uEE0nMO6cFBw9Ca+HdF0lAC31e0wggCCxqw/jJhs4TUkPTAc3AIBGllm4gb22SZa
ByhmS8YZjiN+v1f5w7+aV1iLhOlb0vSIwnnKnJMhbBXw5LUBiVTiHscYWzSN3r9F
vrpMznIxS3MllNJOGmVxtIv9bDs8c9fWRWN/YDqFAXddlbbjmw6LOPdmSSOD4mXf
hdUCEgu2IKurZxxQC2HZ6CBie687fU1u0JbcARs5Arj0uXRnxS/hJ0ZxAEGTyNLp
8sPnjDH7nG9rwhnj5Ssm7S6mFqQPwEj8gmqhamOqrQ39u2z6FAwE6+LasoT7hUx7
9O163sS8W50VsCK2m8glxBt1lTxXgDt8JYDwhDLK2hNcSksjU7YAmCROoaQFU/O6
AyZkv6LdQlu0IwemNr7nLi0HdggbJkt16IBc9yVHrxhW04qmAoIGPvnzoChOcIra
blFu3HM/It4eSfHbK/ejVkDgpbB5xqh/EJ/4eL3u8Y3j3Q/A8cO86kXWzm0GO7gV
edfGLsfA6OoKQLQ/Vs1/BlodIO/fnALhmBqWFlq2uqvVLzxVvco+x8ykh10pRMnu
btFCuaJFoY8=
=UDVK
-----END PGP SIGNATURE-----

--Sig_/xIQCAb30Y8rwN7+f2F6pTtl--

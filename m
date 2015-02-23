Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f177.google.com ([209.85.213.177]:47031 "EHLO
	mail-ig0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752072AbbBWCd3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 22 Feb 2015 21:33:29 -0500
Received: by mail-ig0-f177.google.com with SMTP id z20so15134774igj.4
        for <linux-nfs@vger.kernel.org>; Sun, 22 Feb 2015 18:33:28 -0800 (PST)
Message-ID: <1424658805.4278.13.camel@primarydata.com>
Subject: Re: what on earth is going on here? paths above mountpoints turn
 into "(unreachable)"
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: NeilBrown <neilb@suse.de>
Cc: Nix <nix@esperi.org.uk>, "J. Bruce Fields" <bfields@fieldses.org>,
        NFS list <linux-nfs@vger.kernel.org>
Date: Sun, 22 Feb 2015 21:33:25 -0500
In-Reply-To: <CAHQdGtTxrL1Mbh=FpYgEE3vKWKM+puQc6G62gTgmscjC0qYm9A@mail.gmail.com>
References: <87iofju9ht.fsf@spindle.srvr.nix>
	 <20150203195333.GQ22301@fieldses.org> <87egq6lqdj.fsf@spindle.srvr.nix>
	 <87r3u58df2.fsf@spindle.srvr.nix> <20150205112641.60340f71@notabene.brown>
	 <87zj8l7j3z.fsf@spindle.srvr.nix> <20150210183200.GB11226@fieldses.org>
	 <87vbj4ljjn.fsf@spindle.srvr.nix> <20150216134628.773e3347@notabene.brown>
	 <CAHQdGtRZP2wYeLozY5pzrD-GALKqV8g1tjV2orotZuTcug2v3A@mail.gmail.com>
	 <20150216155429.46cfbab7@notabene.brown>
	 <1424643211.4278.10.camel@primarydata.com>
	 <20150223094747.040ce304@notabene.brown>
	 <CAHQdGtTxrL1Mbh=FpYgEE3vKWKM+puQc6G62gTgmscjC0qYm9A@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, 2015-02-22 at 21:05 -0500, Trond Myklebust wrote:
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
> >> > > >> nordirplus in the mount options, so that might provide you with a clue.
> >> > > >
> >> > > > Yup.  It does.
> >> > > >
> >> > > > There is definitely something wrong in nfs_prime_dcache.  I cannot quite
> >> > > > trace through from cause to effect, but maybe I don't need to.
> >> > > >
> >> > > > Can you try the following patch and see if that makes the problem disappear?
> >> > > >
> >> > > > When you perform a READDIRPLUS request on a directory that contains
> >> > > > mountpoints, the the Linux NFS server doesn't return a file-handle for
> >> > > > those names which are mountpoints (because doing so is a bit tricky).
> >> > > >
> >> > > > nfs3_decode_dirent notices and decodes as a filehandle with zero length.
> >> > > >
> >> > > > The "nfs_same_file()" check in nfs_prime_dcache() determines that isn't
> >> > > > the same as the filehandle it has, and tries to invalidate it and make a new
> >> > > > one.
> >> > > >
> >> > > > The invalidation should fail (probably does).
> >> > > > The creating of a new one ... might succeed.  Beyond that, it all gets a bit
> >> > > > hazy.
> >> > > >
> >> > > > Anyway, please try:
> >> > > >
> >> > > > diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
> >> > > > index 9b0c55cb2a2e..a460669dc395 100644
> >> > > > --- a/fs/nfs/dir.c
> >> > > > +++ b/fs/nfs/dir.c
> >> > > > @@ -541,7 +541,7 @@ int nfs_readdir_page_filler(nfs_readdir_descriptor_t *desc, struct nfs_entry *en
> >> > > >
> >> > > >                 count++;
> >> > > >
> >> > > > -               if (desc->plus != 0)
> >> > > > +               if (desc->plus != 0 && entry->fh.size)
> >> > > >                         nfs_prime_dcache(desc->file->f_path.dentry, entry);
> >> > > >
> >> > > >                 status = nfs_readdir_add_to_array(entry, page);
> >> > > >
> >> > > >
> >> > > > which you might have to apply by hand.
> >> > >
> >> > > Doesn't that check ultimately belong in nfs_fget()? It would seem to
> >> > > apply to all filehandles, irrespective of provenance.
> >> > >
> >> >
> >> > Maybe.  Though I think it also needs to be before nfs_prime_dcache() tries to
> >> > valid the dentry it found.
> >> > e.g.
> >> >
> >> >  if (dentry != NULL) {
> >> >     if (entry->fh->size == 0)
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
> >> > Maybe the dentry that gets mounted on is the one with the all-zero fh...
> >>
> >> Commit 8ed936b5671bf (v3.18+) changes d_invalidate() to unmount the
> >> subtree on a directory being invalidated.
> >>
> >> I disagree that the problem here is the zero length filehandle. It is
> >> rather that we need to accommodate situations where the server is
> >> setting us up for a submount or a NFSv4 referral.
> >
> > I don't understand how you can view the treatment of a non-existent
> > filehandle as though it were a real filehandle as anything other than a bug.
> 
> I see it as a case of "I can't return a filehandle, because you're not
> supposed to ever see this inode".
> 
> IOW: it is literally the case that the client is supposed to create a
> proxy inode because this is supposed to be a mountpoint.
> 
> > I certainly agree that there may be other issues with this code.  It is
> > unlikely to handle volatile filehandles well, and as you say, referrals may
> > well be an issue too.
> >
> > But surely if the server didn't return a valid filehandle, then it is wrong
> > to pretend that "all-zeros" is a valid filehandle.  That is what the current
> > code does.
> 
> As long as we have a valid mounted-on-fileid or a valid fileid, then
> we can still discriminate. That is also what the current code does.
> The only really broken case is if the server returns no filehandle or
> fileid. AFAICS we should be handling that case correctly too in
> nfs_refresh_inode().
> 
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
> >> or one that has a referral, the NFS server that is processing the READDIR
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
> >> @@ -485,10 +485,10 @@ void nfs_prime_dcache(struct dentry *parent, struct nfs_entry *entry)
> >>                       if (!status)
> >>                               nfs_setsecurity(dentry->d_inode, entry->fattr, entry->label);
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
> > The 'dentry' in this case was obtained via d_lookup() which doesn't follow
> > mount points.  So there is no chance that IS_ROOT(dentry).
> > d_mountpoint(dentry) might be a more interesting test.
> >
> > However d_invalidate will unmount any subtree further down.
> > So if I have /a/b/c/d all via NFS, and  'd' is a mountpoint, then if the NFS
> > server returns a new filehandle for 'b', 'd' will get unmounted.  Neither
> > 'IS_ROOT' nor 'd_mountpoint' will guard against that.
> >
> > I'm not really sure what we do want here.  The old behaviour of d_invalidate,
> > where it failed if anything was mounted, seemed like a reasonable sort of
> > behaviour.  But we don't have that available any more.
> 
> If the mounted-on-fileid has changed, then we _should_ invalidate.

IOW: the following should be overkill. If it isn't working, then I'd
definitely want to see some wireshark traces before accepting any
patches.

8<-------------------------------------------------------
>From 1a5eaa9ece7924bd605377445583e2e345e79c74 Mon Sep 17 00:00:00 2001
From: Trond Myklebust <trond.myklebust@primarydata.com>
Date: Sun, 22 Feb 2015 16:35:36 -0500
Subject: [PATCH] NFS: Don't invalidate a submounted dentry in
 nfs_prime_dcache()

If we're traversing a directory which contains a submounted filesystem,
or one that has a referral, the NFS server that is processing the READDIR
request will often return information for the underlying (mounted-on)
directory. It may, or may not, also return filehandle information.

If this happens, and the lookup in nfs_prime_dcache() returns the
dentry for the submounted directory, the filehandle comparison will
fail, and we call d_invalidate(). Post-commit 8ed936b5671bf
("vfs: Lazily remove mounts on unlinked files and directories."), this
means the entire subtree is unmounted.

The following minimal patch addresses this problem by punting on
the invalidation if there is a submount.

Cudos to Neil Brown <neilb@suse.de> for having tracked down this
issue (see link).

Reported-by: Nix <nix@esperi.org.uk>
Link: http://lkml.kernel.org/r/87iofju9ht.fsf@spindle.srvr.nix
Fixes: d39ab9de3b80 ("NFS: re-add readdir plus")
Cc: stable@vger.kernel.org # 2.6.27+
Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/dir.c | 10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 9b0c55cb2a2e..1e80dc1716b1 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -485,10 +485,14 @@ void nfs_prime_dcache(struct dentry *parent, struct nfs_entry *entry)
 			if (!status)
 				nfs_setsecurity(dentry->d_inode, entry->fattr, entry->label);
 			goto out;
-		} else {
-			d_invalidate(dentry);
-			dput(dentry);
 		}
+		/* Is this a submount? If so, ignore. */
+		if (IS_ROOT(dentry) ||
+		    !nfs_fsid_equal(&NFS_SB(dentry->d_sb)->fsid,
+					&entry->fattr->fsid))
+			goto out;
+		d_invalidate(dentry);
+		dput(dentry);
 	}
 
 	dentry = d_alloc(parent, &filename);
-- 
2.1.0




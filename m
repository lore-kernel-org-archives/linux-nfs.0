Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:1483 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753223Ab3BRXRo convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 18 Feb 2013 18:17:44 -0500
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: NeilBrown <neilb@suse.de>
CC: Al Viro <viro@ZenIV.linux.org.uk>, Jeff Layton <jlayton@redhat.com>,
        NFS <linux-nfs@vger.kernel.org>,
        Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: More fun with unmounting ESTALE directories.
Date: Mon, 18 Feb 2013 23:17:42 +0000
Message-ID: <4FA345DA4F4AE44899BD2B03EEEC2FA9235D18CC@SACEXCMBX04-PRD.hq.netapp.com>
References: <20130212113813.427b8e05@notabene.brown>
	 <20130214104230.013b7f71@tlielax.poochiereds.net>
	 <20130218132509.0ce779de@notabene.brown>
	 <20130218184609.GF4503@ZenIV.linux.org.uk>
	 <20130219101031.123b1eb0@notabene.brown>
In-Reply-To: <20130219101031.123b1eb0@notabene.brown>
Content-Type: text/plain; charset=US-ASCII
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2013-02-19 at 10:10 +1100, NeilBrown wrote:
> On Mon, 18 Feb 2013 18:46:09 +0000 Al Viro <viro@ZenIV.linux.org.uk> wrote:
> 
> > On Mon, Feb 18, 2013 at 01:25:09PM +1100, NeilBrown wrote:
> > 
> > > I would be really nice if sys_unmount used a LOOKUP_MOUNTPOINT flag that
> > > works a bit like LOOKUP_PARENT and LOOKUP_NOFOLLOW in that it skips the very
> > > last step and returns the mounted-on directory, not the mountpoint that is
> > > mounted there - or at least makes sure not revalidate happens on that final
> > > mounted directory.
> > 
> > I don't think LOOKUP_MOUNTPOINT is a good idea.  For one thing, we have
> > fairly few places that might want it, all of them in core VFS.  Might as
> > well provide a separate function for them, a-la path_lookupat() vs.
> > path_openat().
> > 
> > For another, we need to decide what to do with a really nasty corner case:
> > 	a/b is a mountpoint, with c/d bound on it.
> > 	c/d is a symlink to c/e
> > 	c/e is a mountpoint
> > What should umount("a/b", 0) do?  There are two possibilities - removing
> > vfsmount on top of a/b or one on top of c/e...
> > 
> > We have the latter semantics; _that_ is what this GETATTR is about.  It's
> > a fairly obscure corner case - the question is not even whether to follow
> > symlinks, it's whether to follow _mounts_ on the last component.  Hell
> > knows; I'm seriously tempted to change it "don't follow mounts" and see if
> > anyone complains.  The only case when behaviour would change would be
> > a symlink mounted somewhere (note that this is _not_ something that can easily
> > happen; e.g. mount --bind does follow symlinks) and umount(2) given the
> > path resolving to the mountpoint of that symlink.
> 
> Thinking about this some more, I now realise that my LOOKUP_MOUNTPOINT idea
> was too simplistic and missed the real point.
> 
> The real point is that for unmount, we want to resolve the the path without
> any reference to any filesystem at all - the lookup should be handled
> entirely by the dcache.
> Any mountpoint is pinned in the dcache, and consequently any ancestor of any
> mount point also is.  So the dcache will lead us to the dentry that we want.
> 
> And the dentry is *all* we want.  It doesn't really matter what the inode is
> like, or whether the filesystem thinks that the inode or name still exist.
> All we need to do is find a dentry that must be  in the cache, and detach the
> mount that is there.
> 
> Whether that is achieved by a LOOKUP_ flag or a separate lookup function
> doesn't matter much to me.
> 
> I suspect we need to allow for passing a symlink to unmount, and the symlink
> might not be in cache, so we cannot insist uniformly on only using the dcache.
> However if a name is in the cache, and the cached data suggests that it is a
> directory, then we should trust that and avoid referring to the filesystem.
> 
> umount is really quite unique in this.  All other times we lookup a path we
> want to use the thing we found.  With umount, we want to stop using it.
> 
> ???

Add a umountat() syscall so that you can supply a file descriptor? :-)

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:35594 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964795Ab2B2XKh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 29 Feb 2012 18:10:37 -0500
Date: Wed, 29 Feb 2012 18:10:30 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: NeilBrown <neilb@suse.de>
Cc: Al Viro <viro@ZenIV.linux.org.uk>, Nick Piggin <npiggin@gmail.com>,
        Nick Piggin <npiggin@kernel.dk>, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH] fs/dcache: allow __d_obtain_alias() to return unhashed
 dentries
Message-ID: <20120229231030.GC6506@fieldses.org>
References: <AANLkTikL2CDSWQJ1QH_Y4G-j70Vd=VesNMMnYTmMGHC9@mail.gmail.com>
 <20110118220817.GF10903@fieldses.org>
 <20110308181320.GA15566@fieldses.org>
 <20110310105821.GE22723@ZenIV.linux.org.uk>
 <20110311150749.2fa2be66@notabene.brown>
 <20120214170300.GA4309@fieldses.org>
 <20120215165633.GE12490@fieldses.org>
 <20120216140603.08cb4900@notabene.brown>
 <20120216223011.GA23997@fieldses.org>
 <20120220135537.3078e20b@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120220135537.3078e20b@notabene.brown>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Feb 20, 2012 at 01:55:37PM +1100, NeilBrown wrote:
> On Thu, 16 Feb 2012 17:30:11 -0500 "J. Bruce Fields" <bfields@fieldses.org>
> wrote:
> 
> > On Thu, Feb 16, 2012 at 02:06:03PM +1100, NeilBrown wrote:
> > > I was going ask how you managed to get an 'unhashed' dentry which was not
> > > DISCONNECTED, and belonged to a directory that could be the subject of
> > > d_splice_alias (that implies it has a name).
> > > 
> > > The bug sounds like a race between lookup and rmdir, which should be
> > > prevented by i_mutex.
> > > 
> > > I think that using __d_find_any_alias would just be papering over the
> > > problem, and would trigger a BUG_ON when it returned a non-DISCONNECTED alias.
> > 
> > Looking through the latest upstream code, I can't come up with another
> > obvious reproducer.
> > 
> > But I also can't see the code making any particular effort to ensure
> > that dentries are removed from inode's alias lists at the same time
> > they're unhashed.
> > 
> > E.g., trace up through the callers of d_drop/__d_drop and try to
> > convince yourselves that they all end up removing the dentry from the
> > alias list.
> > 
> > Can you see any reason why the following would actually create a
> > problem?
> 
> No, I don't think that would cause problems, so it is probably a good clean
> up and as Peng says it means we can remove the want_discon arg as well.
> 
> However I cannot help thinking that something else must be going wrong before
> we get to this point.
> When you rmdir a directory it must be empty and it will never be linked again.
> So how does 'lookup' find the inode and want to attach a dentry to it?
> 
> So I still think this is just papering over some other problem.
> 
> I think that looking at when aliases are removed is missing the point.
> 
> A directory can only have one name so it can only have one dentry.
> If that dentry gets unhashed, that is because the directory was deleted.

Wait, what other reasons could cause them to get unhashed?:

Just grepping for callers of d_drop....

On a distributed filesystem, we may unhash an in-use dentry if it no
longer seems to be valid.  Can something like this happen?

	- nfsd holds a filehandle for directory a/b
	- a/b is renamed to c/d by some other host using this
	  filesystem.
	- filesystem looks up a/b, finds it no longer there, unhashes
	  it.
	- a lookup for c/d later adds a new dentry.

And then we have two dentries?

And of course we unhash dentries when they're not in use, just to free
memory.  I think that case is OK.

--b.

> So
> now it must have zero names.  So there is no way that lookup can possibly
> find it, so there is no way that d_splice_alias can be asked to attach an
> alias to it.

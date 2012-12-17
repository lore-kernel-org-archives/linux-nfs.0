Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:5379 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752687Ab2LQPYe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 17 Dec 2012 10:24:34 -0500
Date: Mon, 17 Dec 2012 10:23:48 -0500
From: Jeff Layton <jlayton@redhat.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: Al Viro <viro@ZenIV.linux.org.uk>, Ricky Ng-Adam <rngadam@lophilo.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "neilb@suse.de" <neilb@suse.de>
Subject: Re: WARNING: at linux/fs/inode.c:280 drop_nlink
Message-ID: <20121217102348.4fffa38c@tlielax.poochiereds.net>
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA91194763C@sacexcmbx05-prd.hq.netapp.com>
References: <CAOAMTYQ_9bPjCtobC9kfUJrgiT8hx7FsMXoi5ZgWo+P1qjDb0g@mail.gmail.com>
	<20121112095255.5c7babcc@tlielax.poochiereds.net>
	<20121213063147.44b1cf73@tlielax.poochiereds.net>
	<4FA345DA4F4AE44899BD2B03EEEC2FA91192A83F@SACEXCMBX04-PRD.hq.netapp.com>
	<20121213210753.GQ4939@ZenIV.linux.org.uk>
	<4FA345DA4F4AE44899BD2B03EEEC2FA91192CBB6@SACEXCMBX04-PRD.hq.netapp.com>
	<20121213220636.4c70ec28@corrin.poochiereds.net>
	<4FA345DA4F4AE44899BD2B03EEEC2FA91192D34B@SACEXCMBX04-PRD.hq.netapp.com>
	<20121214075138.7ab828da@tlielax.poochiereds.net>
	<4FA345DA4F4AE44899BD2B03EEEC2FA91192E5BE@SACEXCMBX04-PRD.hq.netapp.com>
	<20121217080802.5168393a@tlielax.poochiereds.net>
	<4FA345DA4F4AE44899BD2B03EEEC2FA91194763C@sacexcmbx05-prd.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 17 Dec 2012 15:14:29 +0000
"Myklebust, Trond" <Trond.Myklebust@netapp.com> wrote:

> On Mon, 2012-12-17 at 08:08 -0500, Jeff Layton wrote:
> > On Fri, 14 Dec 2012 18:22:27 +0000
> > "Myklebust, Trond" <Trond.Myklebust@netapp.com> wrote:
> > 
> > > On Fri, 2012-12-14 at 07:51 -0500, Jeff Layton wrote:
> > > > OTOH, there is at least a minor problem here with letting i_nlink
> > > > underflow. When we finally get around to iput_final, generic_drop_inode
> > > > is going to return false and we're going to end up with the inode
> > > > lingering in the cache longer than it really should. Presumably memory
> > > > pressure will eventually push it out, but it would be better not to
> > > > have to wait for that.
> > > 
> > > As I said, the whole nlink test thing is a heuristic on NFS. Just
> > > because we think we've successfully sent a REMOVE to the server, it
> > > doesn't mean that file has actually been deleted. REMOVE refers to the
> > > file by name, so there is plenty of opportunity for the server to play
> > > tricks on us. I'm assuming that is what is happening in your Fedora bug
> > > reports.
> > > 
> > > As far as we're concerned, the only reliable indicator that a file has
> > > been deleted is when the server starts replying ESTALE to that
> > > filehandle.
> > > 
> > > > I'll also note that we call nfs_drop_nlink to decrement i_nlink
> > > > everywhere else aside from this call site. What makes nfs_dentry_iput
> > > > special in this regard?
> > > 
> > > nfs_dentry_iput() is not special, but the test in nfs_drop_nlink() is.
> > > If we're not able to track inode->i_nlink, then why is forcing an inode
> > > eviction more correct than not doing so?
> > > 
> > 
> > The patchset you sent after the above seems basically correct to me,
> > but since you asked...
> > 
> > It's hard to generalize on server behavior, but if a server sends us an
> > attributes with i_nlink == 0, it seems unlikely to go positive again.
> > For most servers, that means that the inode is now unreachable via
> > LOOKUP. Therefore, once d_iput is called we won't have a way to get to
> > the inode again. Forcing it out of the cache seems like the right
> > thing to do in that case.
> 
> We don't know what the server's idea of inode->i_nlink is. The REMOVE
> operation doesn't return any information about the target inode, so we
> were just manipulating our cached values.
> 

Neil's reproducer is somewhat synthetic, since it involves removing
files that have been sillyrenamed. I tend to think that most
applications don't do that however...

My assumption on this problem (maybe a wrong one) is that this usually
happens when we have an out-of-order attribute update that raced in
while we're processing the REMOVE.

IOW, we have a race where the REMOVE got processed on the server before
(e.g.) a GETATTR, but the client processed the replies in opposite
order, for whatever reason.

> > A negative i_nlink OTOH makes no sense at all. If our actions are going
> > to make that happen then we ought to take steps to prevent it.
> 
> We now only manipulate the cached value if we want the VFS to forget the
> inode. Otherwise, we just mark the inode attributes for revalidation.
> 

Right. That seems reasonable.

-- 
Jeff Layton <jlayton@redhat.com>

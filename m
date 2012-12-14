Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:17753 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755295Ab2LNMwZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 14 Dec 2012 07:52:25 -0500
Date: Fri, 14 Dec 2012 07:51:38 -0500
From: Jeff Layton <jlayton@redhat.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: Al Viro <viro@ZenIV.linux.org.uk>, Ricky Ng-Adam <rngadam@lophilo.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "neilb@suse.de" <neilb@suse.de>
Subject: Re: WARNING: at linux/fs/inode.c:280 drop_nlink
Message-ID: <20121214075138.7ab828da@tlielax.poochiereds.net>
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA91192D34B@SACEXCMBX04-PRD.hq.netapp.com>
References: <CAOAMTYQ_9bPjCtobC9kfUJrgiT8hx7FsMXoi5ZgWo+P1qjDb0g@mail.gmail.com>
	<20121112095255.5c7babcc@tlielax.poochiereds.net>
	<20121213063147.44b1cf73@tlielax.poochiereds.net>
	<4FA345DA4F4AE44899BD2B03EEEC2FA91192A83F@SACEXCMBX04-PRD.hq.netapp.com>
	<20121213210753.GQ4939@ZenIV.linux.org.uk>
	<4FA345DA4F4AE44899BD2B03EEEC2FA91192CBB6@SACEXCMBX04-PRD.hq.netapp.com>
	<20121213220636.4c70ec28@corrin.poochiereds.net>
	<4FA345DA4F4AE44899BD2B03EEEC2FA91192D34B@SACEXCMBX04-PRD.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 14 Dec 2012 03:22:20 +0000
"Myklebust, Trond" <Trond.Myklebust@netapp.com> wrote:

> On Thu, 2012-12-13 at 22:06 -0500, Jeff Layton wrote:
> > On Thu, 13 Dec 2012 21:22:26 +0000
> > "Myklebust, Trond" <Trond.Myklebust@netapp.com> wrote:
> > 
> > > On Thu, 2012-12-13 at 21:07 +0000, Al Viro wrote:
> > > > On Thu, Dec 13, 2012 at 02:45:18PM +0000, Myklebust, Trond wrote:
> > > > 
> > > > > You mean aside from the fact that sb->s_remove_count remains a racy
> > > > > piece of crap that serves no good purpose for NFS, and yet will continue
> > > > > to give us grief?
> > > > 
> > > > As opposed to scanning the list of opened files?
> > > 
> > > For what information? sb->s_remove_count tells you nothing new about the
> > > state of the NFS filesystem.
> > > 
> > > This whole "check for nlink == 0" thing is at best a heuristic, since
> > > the file may persist or disappear on the server independently of
> > > whatever we may think about the value of inode->i_nlink. Setting sirens
> > > to blare and angels to sing when we get it wrong (as we often do) is
> > > just pointless...
> > > 
> > 
> > So...why do drop_nlink at all in NFS (or other similar filesystems like
> > CIFS)? In principle, it seems like we ought to just mark the attribute
> > cache invalid and assume that we'll pick up the nlink change when we
> > next attempt to revalidate the inode.
> > 
> > On that next attempt, we might find it stale, but that's something we
> > already have to deal with.
> 
> At this point, I don't care. My argument is that I haven't seen a SINGLE
> instance where this warning has led to the discovery of a positive case.
> Every single stack dump that I've seen so far has been a false negative,
> which, as far as I'm concerned, should be considered a regression.
> 
> Forgive me for being pissed off...
> 

I can understand that. We are getting TONS of these reports in Fedora.
Just yesterday Nick Bowler re-reported it on the linux-nfs ml. I
wouldn't mind seeing these warnings go away, or at least have some
mechanism for filesystems to opt out of them.

OTOH, there is at least a minor problem here with letting i_nlink
underflow. When we finally get around to iput_final, generic_drop_inode
is going to return false and we're going to end up with the inode
lingering in the cache longer than it really should. Presumably memory
pressure will eventually push it out, but it would be better not to
have to wait for that.

I'll also note that we call nfs_drop_nlink to decrement i_nlink
everywhere else aside from this call site. What makes nfs_dentry_iput
special in this regard?

-- 
Jeff Layton <jlayton@redhat.com>

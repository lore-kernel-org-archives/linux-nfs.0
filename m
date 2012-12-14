Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:14687 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755621Ab2LNDHY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 13 Dec 2012 22:07:24 -0500
Date: Thu, 13 Dec 2012 22:06:36 -0500
From: Jeff Layton <jlayton@redhat.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: Al Viro <viro@ZenIV.linux.org.uk>, Ricky Ng-Adam <rngadam@lophilo.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "neilb@suse.de" <neilb@suse.de>
Subject: Re: WARNING: at linux/fs/inode.c:280 drop_nlink
Message-ID: <20121213220636.4c70ec28@corrin.poochiereds.net>
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA91192CBB6@SACEXCMBX04-PRD.hq.netapp.com>
References: <CAOAMTYQ_9bPjCtobC9kfUJrgiT8hx7FsMXoi5ZgWo+P1qjDb0g@mail.gmail.com>
	<20121112095255.5c7babcc@tlielax.poochiereds.net>
	<20121213063147.44b1cf73@tlielax.poochiereds.net>
	<4FA345DA4F4AE44899BD2B03EEEC2FA91192A83F@SACEXCMBX04-PRD.hq.netapp.com>
	<20121213210753.GQ4939@ZenIV.linux.org.uk>
	<4FA345DA4F4AE44899BD2B03EEEC2FA91192CBB6@SACEXCMBX04-PRD.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 13 Dec 2012 21:22:26 +0000
"Myklebust, Trond" <Trond.Myklebust@netapp.com> wrote:

> On Thu, 2012-12-13 at 21:07 +0000, Al Viro wrote:
> > On Thu, Dec 13, 2012 at 02:45:18PM +0000, Myklebust, Trond wrote:
> > 
> > > You mean aside from the fact that sb->s_remove_count remains a racy
> > > piece of crap that serves no good purpose for NFS, and yet will continue
> > > to give us grief?
> > 
> > As opposed to scanning the list of opened files?
> 
> For what information? sb->s_remove_count tells you nothing new about the
> state of the NFS filesystem.
> 
> This whole "check for nlink == 0" thing is at best a heuristic, since
> the file may persist or disappear on the server independently of
> whatever we may think about the value of inode->i_nlink. Setting sirens
> to blare and angels to sing when we get it wrong (as we often do) is
> just pointless...
> 

So...why do drop_nlink at all in NFS (or other similar filesystems like
CIFS)? In principle, it seems like we ought to just mark the attribute
cache invalid and assume that we'll pick up the nlink change when we
next attempt to revalidate the inode.

On that next attempt, we might find it stale, but that's something we
already have to deal with.

-- 
Jeff Layton <jlayton@redhat.com>

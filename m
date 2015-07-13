Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:33594 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751113AbbGMGCw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 13 Jul 2015 02:02:52 -0400
Date: Mon, 13 Jul 2015 16:02:43 +1000
From: NeilBrown <neilb@suse.com>
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: Kinglong Mee <kinglongmee@gmail.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        linux-fsdevel@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: Re: [PATCH 10/10 v7] nfsd: Allows user un-mounting filesystem where
 nfsd exports base on
Message-ID: <20150713160243.6173a214@noble>
In-Reply-To: <20150713152133.571e0cb7@noble>
References: <55A11010.6050005@gmail.com>
	<55A111A8.2040701@gmail.com>
	<20150713133934.6a4ef77d@noble>
	<20150713142059.493a790e@noble>
	<20150713044553.GN17109@ZenIV.linux.org.uk>
	<20150713152133.571e0cb7@noble>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 13 Jul 2015 15:21:33 +1000 NeilBrown <neilb@suse.com> wrote:

> On Mon, 13 Jul 2015 05:45:53 +0100 Al Viro <viro@ZenIV.linux.org.uk>
> wrote:
> 
> > On Mon, Jul 13, 2015 at 02:20:59PM +1000, NeilBrown wrote:
> > 
> > > Actually, with that change to pin_kill, this side of things becomes
> > > really easy.
> > > All expXXX_pin_kill needs to do is call your new cache_delete_entry.
> > > If that doesn't cause the entry to be put, then something else has a
> > > temporary reference which will be put soon.  In any case, pin_kill()
> > > will wait long enough, but not indefinitely.
> > > No need for kref_get_unless_zero() or any of that.
> > 
> > No.  You are seriously misunderstanding what ->kill() is for and what the
> > existing instances are doing.  Again, there is no promise whatsoever that
> > the object containing fs_pin instance will *survive* past ->kill().
> > At all.
> 
> Ah... I missed that rcu_read_unlock happened before ->kill.  Sorry
> about that.
> 
> It still seems like the waiting that pin_kill does is exactly what we
> need.
> 
> I'll think about it some more.
> 

Ok....

A key issue is that the code currently assumes that the only way a
'pin' is removed is by the pinned thing calling pin_kill().

The problem is that we want the pinning thing to be able to remove
itself.

I think that means we need a variant of pin_remove() which reports if
pin->done was 0 or -1.
If it was 0, then ->kill hasn't been called, and it won't be.  So the
caller is free to clean up how it likes (providing RCU is used for
freeing).
If it was -1, then ->kill has been called and is expected to clean up -
the caller should assume that has already happened.


So path_put_unpin() needs to call pin_remove_and_test() (or whatever it
is called) and return the value.

Then expXXX_put() calls path_put_unpin and only calls kfree_rcu() if
->done was previously 0.

expXXX_pin_kill() calls cache_delete_entry, and then calls pin_kill()
This recursive call to pin_kill() will wait until expXXX_put() has
called pin_remove_and_test() and then returns.
At this point there are no references to the cache entry except the one
that expXXX_pin_kill() holds.  So it can call kfree_rcu().


Would that work?
Are you happy with pin_remove() returning a status?

Thanks,
NeilBrown

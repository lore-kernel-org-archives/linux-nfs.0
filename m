Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:35031 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751028AbbGMGcL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 13 Jul 2015 02:32:11 -0400
Date: Mon, 13 Jul 2015 16:32:01 +1000
From: NeilBrown <neilb@suse.com>
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: Kinglong Mee <kinglongmee@gmail.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        linux-fsdevel@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: Re: [PATCH 10/10 v7] nfsd: Allows user un-mounting filesystem where
 nfsd exports base on
Message-ID: <20150713163201.0e5eaf23@noble>
In-Reply-To: <20150713060802.GP17109@ZenIV.linux.org.uk>
References: <55A11010.6050005@gmail.com>
	<55A111A8.2040701@gmail.com>
	<20150713133934.6a4ef77d@noble>
	<20150713142059.493a790e@noble>
	<20150713044553.GN17109@ZenIV.linux.org.uk>
	<20150713152133.571e0cb7@noble>
	<20150713160243.6173a214@noble>
	<20150713060802.GP17109@ZenIV.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 13 Jul 2015 07:08:02 +0100 Al Viro <viro@ZenIV.linux.org.uk>
wrote:

> On Mon, Jul 13, 2015 at 04:02:43PM +1000, NeilBrown wrote:
> 
> > I think that means we need a variant of pin_remove() which reports if
> > pin->done was 0 or -1.
> > If it was 0, then ->kill hasn't been called, and it won't be.  So the
> > caller is free to clean up how it likes (providing RCU is used for
> > freeing).
> 
> Grr...  What will umount(2) wait for if it comes during your cleanup?
> You are putting them in the wrong order - pin_remove() is "I'm *DONE*
> killing that sucker, nothing to wait for", not "move along, don't wait
> for me, I've taken over killing it off".

pin_remove() disconnects the pinning thing (sunrpc cache entry in this
case) from the pinned thing (vfsmnt in this case).
After it has run the pinned thing can do whatever it likes without any
reference to the pinning thing, and the pinning thing just needs to wait
an RCU grace period, and then can do whatever it likes.

The "cleanup" is, in this case, just a call to rcu_kfree().  There is
no need for umount(2) to wait for it.


Certainly any state that the pinning structure has that relates to the
pinned structure must be cleaned up before calling pin_remove, so for
example dput() must be called on path.dentry *before* pin_remove is
called on path.mnt.  But other parts of the pinning structure can be
handled as its owner chooses.

NeilBrown

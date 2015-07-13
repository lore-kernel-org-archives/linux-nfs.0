Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:58778 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750988AbbGMGn5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Jul 2015 02:43:57 -0400
Date: Mon, 13 Jul 2015 07:43:53 +0100
From: Al Viro <viro@ZenIV.linux.org.uk>
To: NeilBrown <neilb@suse.com>
Cc: Kinglong Mee <kinglongmee@gmail.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        linux-fsdevel@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: Re: [PATCH 10/10 v7] nfsd: Allows user un-mounting filesystem where
 nfsd exports base on
Message-ID: <20150713064353.GQ17109@ZenIV.linux.org.uk>
References: <55A11010.6050005@gmail.com>
 <55A111A8.2040701@gmail.com>
 <20150713133934.6a4ef77d@noble>
 <20150713142059.493a790e@noble>
 <20150713044553.GN17109@ZenIV.linux.org.uk>
 <20150713152133.571e0cb7@noble>
 <20150713160243.6173a214@noble>
 <20150713060802.GP17109@ZenIV.linux.org.uk>
 <20150713163201.0e5eaf23@noble>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150713163201.0e5eaf23@noble>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jul 13, 2015 at 04:32:01PM +1000, NeilBrown wrote:
> pin_remove() disconnects the pinning thing (sunrpc cache entry in this
> case) from the pinned thing (vfsmnt in this case).
> After it has run the pinned thing can do whatever it likes without any
> reference to the pinning thing, and the pinning thing just needs to wait
> an RCU grace period, and then can do whatever it likes.
> 
> The "cleanup" is, in this case, just a call to rcu_kfree().  There is
> no need for umount(2) to wait for it.
> 
> 
> Certainly any state that the pinning structure has that relates to the
> pinned structure must be cleaned up before calling pin_remove, so for
> example dput() must be called on path.dentry *before* pin_remove is
> called on path.mnt.  But other parts of the pinning structure can be
> handled as its owner chooses.

Then what's the difference between that and what's getting done in ->kill()
triggered by cleanup_mnt()?

In any case, you have two possibilities - explicit unexport triggering that
dput(), etc. and umount(2) triggering the same.  Whoever comes second gets
to wait until it's done.  So why not make the point where we commit to
unexporting the sucker the place where we do pin_kill()?  And have ->kill()
of that thing prevent appearance of new entries, then wait for them to run
down.  Which is precisely the same thing you want to happen on umount...

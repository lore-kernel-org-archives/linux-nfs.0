Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:60345 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750724AbbGMFVr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 13 Jul 2015 01:21:47 -0400
Date: Mon, 13 Jul 2015 15:21:33 +1000
From: NeilBrown <neilb@suse.com>
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: Kinglong Mee <kinglongmee@gmail.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        linux-fsdevel@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: Re: [PATCH 10/10 v7] nfsd: Allows user un-mounting filesystem where
 nfsd exports base on
Message-ID: <20150713152133.571e0cb7@noble>
In-Reply-To: <20150713044553.GN17109@ZenIV.linux.org.uk>
References: <55A11010.6050005@gmail.com>
	<55A111A8.2040701@gmail.com>
	<20150713133934.6a4ef77d@noble>
	<20150713142059.493a790e@noble>
	<20150713044553.GN17109@ZenIV.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 13 Jul 2015 05:45:53 +0100 Al Viro <viro@ZenIV.linux.org.uk>
wrote:

> On Mon, Jul 13, 2015 at 02:20:59PM +1000, NeilBrown wrote:
> 
> > Actually, with that change to pin_kill, this side of things becomes
> > really easy.
> > All expXXX_pin_kill needs to do is call your new cache_delete_entry.
> > If that doesn't cause the entry to be put, then something else has a
> > temporary reference which will be put soon.  In any case, pin_kill()
> > will wait long enough, but not indefinitely.
> > No need for kref_get_unless_zero() or any of that.
> 
> No.  You are seriously misunderstanding what ->kill() is for and what the
> existing instances are doing.  Again, there is no promise whatsoever that
> the object containing fs_pin instance will *survive* past ->kill().
> At all.

Ah... I missed that rcu_read_unlock happened before ->kill.  Sorry
about that.

It still seems like the waiting that pin_kill does is exactly what we
need.

I'll think about it some more.

Thanks,
NeilBrown


> 
> RTFS, please.  What is sorely missing in this recurring patchset is a clear
> description of lifetime rules and ordering (who waits for whom and how long).
> For all the objects involved.


Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cam-admin0.cambridge.arm.com ([217.140.96.50]:50739 "EHLO
	cam-admin0.cambridge.arm.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932113AbaIWN7e (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 23 Sep 2014 09:59:34 -0400
Date: Tue, 23 Sep 2014 14:59:38 +0100
From: Will Deacon <will.deacon@arm.com>
To: Weston Andros Adamson <dros@primarydata.com>
Cc: Peng Tao <tao.peng@primarydata.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        linux-nfs list <linux-nfs@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: WARNING at fs/nfs/write.c:743 nfs_inode_remove_request with -rc6
Message-ID: <20140923135938.GB28608@arm.com>
References: <20140923130352.GK26472@arm.com>
 <2A327753-3E60-46AC-8220-3FF0FF61F08F@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <2A327753-3E60-46AC-8220-3FF0FF61F08F@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Sep 23, 2014 at 02:33:06PM +0100, Weston Andros Adamson wrote:
> On Sep 23, 2014, at 9:03 AM, Will Deacon <will.deacon@arm.com> wrote:
> > I've been running into the following warning on an arm64 system running
> > 3.17-rc6 with 64k pages. I've been unable to reproduce with a smaller page
> > size (4k).
> > 
> > I don't yet have a concrete reproducer, but I've seen it hit a few times
> > today just running a machine with an NFS root filesystem and using ssh.
> > The warning seems to happen in parallel on the two CPUs, but I'm pretty
> > confident that our test_and_clear_bit implementation has the relevant
> > atomic instructions and memory barriers.
> > 
> > Any ideas?
> 
> So it looks like we’re either calling nfs_inode_remove_request twice on a request,
> or somehow not grabbing the inode reference for some request that is in the async
> write path. It’s interesting that these come in pairs - that has to mean something!

Indeed. I have 6 CPUs on this system too, so it's not a per-cpu thing.

> Any more info on how to reproduce this would be really great. Unfortunately I don’t
> have access to an arm64 system.

I've not spotted a pattern other than using 64k pages, yet. If I manage to
get a reproducer, I'll let you know.

> If it’s possible, could we get a packet trace around when this happens? This is pure
> speculation, but this might have something to do the resend path - a commit fails
> and all the requests on the commit list have to be resent.

Sure, once I can reproduce it reliably, then I'll try to do that.

> Have you noticed any side effects from this? That WARN_ON_ONCE was added
> to sanity test the new page group code and we need to fix this, but I’m wondering
> if anything “bad” happens…

I've not noticed anything. In fact, this happened during an LTP run and I
didn't see any regressions in the test results.

Will

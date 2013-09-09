Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:5759 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754860Ab3IISVM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 9 Sep 2013 14:21:12 -0400
Date: Mon, 9 Sep 2013 14:21:08 -0400
From: Jeff Layton <jlayton@redhat.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: Quentin Barnes <qbarnes@gmail.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: nfs-backed mmap file results in 1000s of WRITEs per second
Message-ID: <20130909142108.51b4cf79@tlielax.poochiereds.net>
In-Reply-To: <1378748866.11732.2.camel@leira.trondhjem.org>
References: <20130905162110.GA17920@gmail.com>
	<20130905170303.GB17330@us.ibm.com>
	<20130905191139.GA20830@gmail.com>
	<1378411320.5450.27.camel@leira.trondhjem.org>
	<20130905213649.GA21944@gmail.com>
	<1378418243.5450.29.camel@leira.trondhjem.org>
	<20130905223420.GA23192@gmail.com>
	<20130906093636.6818e7b2@corrin.poochiereds.net>
	<CAKjHkpBW+LWKuKuHnUfKNxwDZeX3SOFKv_jYeNGF8ezdAnKnvg@mail.gmail.com>
	<20130909090424.1a780b49@tlielax.poochiereds.net>
	<20130909173209.GA28353@gmail.com>
	<1378748866.11732.2.camel@leira.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 9 Sep 2013 17:47:48 +0000
"Myklebust, Trond" <Trond.Myklebust@netapp.com> wrote:

> On Mon, 2013-09-09 at 12:32 -0500, Quentin Barnes wrote:
> > On Mon, Sep 09, 2013 at 09:04:24AM -0400, Jeff Layton wrote:
> > > On Fri, 6 Sep 2013 11:48:45 -0500
> > > Quentin Barnes <qbarnes@gmail.com> wrote:
> > > 
> > > > Jeff, can your try out my test program in the base note on your
> > > > RHEL5.9 or later RHEL5.x kernels?
> > > > 
> > > > I reverified that running the test on a 2.6.18-348.16.1.el5 x86_64
> > > > kernel (latest released RHEL5.9) does not show the problem for me.
> > > > Based on what you and Trond have said in this thread though, I'm
> > > > really curious why it doesn't have the problem.
> > > 
> > > I can confirm what you see on RHEL5. One difference is that RHEL5's
> > > page_mkwrite handler does not do wait_on_page_writeback. That was added
> > > as part of the stable pages work that went in a while back, so that may 
> > > be the main difference. Adding that in doesn't seem to materially
> > > change things though.
> > 
> > Good to know you confirmed the behavior I saw on RHEL5 (just so that
> > I know it's not some random variable in play I had overlooked).
> > 
> > > In any case, what I see is that the initial program just ends up with a
> > > two calls to nfs_vm_page_mkwrite(). They both push out a WRITE and then
> > > things settle down (likely because the page is still marked dirty).
> > > 
> > > Eventually, another write occurs and the dirty page gets pushed out to
> > > the server in a small flurry of WRITEs to the same range.Then, things
> > > settle down again until there's another small flurry of activity.
> > > 
> > > My suspicion is that there is a race condition involved here, but I'm
> > > unclear on where it is. I'm not 100% convinced this is a bug, but page
> > > fault semantics aren't my strong suit.
> > 
> > As a test on RHEL6, I made a trivial systemtap script for kprobing
> > nfs_vm_page_mkwrite() and nfs_flush_incompatible().  I wanted to
> > make sure this bug was limited to just the nfs module and was not a
> > result of some mm behavior change.
> > 
> > With the bug unfixed running the test program, nfs_vm_page_mkwrite()
> > and nfs_flush_incompatible() are called repeatedly at a very high rate
> > (hence all the WRITEs).
> > 
> > After Trond's patch, the two functions are called just at the
> > program's initialization and then called only every 30 seconds or
> > so.
> > 
> > It looks like to me from the code flow that there must be something
> > nfs_wb_page() does that resets the need for mm to keeping reinvoking
> > nfs_vm_page_mkwrite().  I didn't look any deeper than that though
> > for now.  Maybe a race in how nfs_wb_page() updates status you're
> > thinking of?
> 
> In RHEL-5, nfs_wb_page() is just a wrapper to nfs_sync_inode_wait(),
> which does _not_ call clear_page_dirty_for_io() (and hence does not call
> page_mkclean()).
> 
> That would explain it...
> 

Thanks Trond, that does explain it.

FWIW, at this point in the RHEL5 lifecycle I'd be disinclined to make
any changes to that code without some strong justification. Backporting
Trond's recent patch for RHEL6 and making sure that RHEL7 has it sounds
quite reasonable though.

-- 
Jeff Layton <jlayton@redhat.com>

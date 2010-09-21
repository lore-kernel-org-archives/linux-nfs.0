Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:35449 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755237Ab0IUU7n (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 21 Sep 2010 16:59:43 -0400
Date: Tue, 21 Sep 2010 16:58:13 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Cc: Jeff Layton <jlayton@redhat.com>, linux-nfs@vger.kernel.org
Subject: Re: [bfields@pop.test.fieldses.org: all f08d6374 Merge branch
 'nfs-for-next' into linux-next results]
Message-ID: <20100921205813.GC10570@fieldses.org>
References: <20100919184549.GD32071@fieldses.org>
 <20100920130106.GB4580@fieldses.org>
 <20100920131025.GC4580@fieldses.org>
 <1285091815.30222.19.camel@heimdal.trondhjem.org>
 <20100921111657.330e7838@corrin.poochiereds.net>
 <20100921192005.GC4385@fieldses.org>
 <1285097787.30222.24.camel@heimdal.trondhjem.org>
 <1285099232.30222.25.camel@heimdal.trondhjem.org>
 <20100921202411.GA10570@fieldses.org>
 <1285101981.30222.27.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1285101981.30222.27.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, Sep 21, 2010 at 04:46:21PM -0400, Trond Myklebust wrote:
> On Tue, 2010-09-21 at 16:24 -0400, J. Bruce Fields wrote:
> > On Tue, Sep 21, 2010 at 04:00:32PM -0400, Trond Myklebust wrote:
> > > On Tue, 2010-09-21 at 15:36 -0400, Trond Myklebust wrote:
> > > > On Tue, 2010-09-21 at 15:20 -0400, J. Bruce Fields wrote:
> > > > > All I need to do is mount nfs4.1 and run cthon -s.  The last output I
> > > > > see from the test is:
> > > > > 
> > > > > check for proper open/unlink operation
> > > > > nfsjunk files before unlink:
> > > > >   
> > > > 
> > > > Oh... I bet I see what it is.
> > > > 
> > > > It's that damned res->sr_slotid = NFS4_MAX_SLOT_TABLE and related
> > > > initialisation junk that's biting us in the arse again...
> > > > 
> > > > I'll fix it...
> > > 
> > > Does this work?
> > 
> > Yup.
> 
> It seems to fix things for me too... Once you mentioned NFSv4.1 it was
> easy to reproduce the bug.

OK, good.  I've a slight fear I may have volunteered as Mr. Upstream NFS
QA, which I didn't really intend, though of course I want to see stuff
caught sooner rather than later....

Anyway, I should have noticed which test it failed on sooner.

--b.

> 
> OK. I'll merge these into nfs-for-2.6.37...
> 
> Cheers
>   Trond
> 

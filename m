Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:57582 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755813Ab0IWR36 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 23 Sep 2010 13:29:58 -0400
Subject: Re: [bfields@pop.test.fieldses.org: all f08d6374 Merge branch
 'nfs-for-next' into linux-next results]
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Benny Halevy <bhalevy@panasas.com>
Cc: Jeff Layton <jlayton@redhat.com>, "J. Bruce Fields" <bfields@fieldses.org>,
        linux-nfs@vger.kernel.org
In-Reply-To: <4C9B8C72.2020405@panasas.com>
References: <20100918171546.GA9859@fieldses.org>
	 <1284831680.2787.1.camel@heimdal.trondhjem.org>
	 <20100919184549.GD32071@fieldses.org>	<20100920130106.GB4580@fieldses.org>
	 <20100920131025.GC4580@fieldses.org>
	 <1285091815.30222.19.camel@heimdal.trondhjem.org>
	 <20100921111657.330e7838@corrin.poochiereds.net>
	 <20100921192005.GC4385@fieldses.org>
	 <1285097787.30222.24.camel@heimdal.trondhjem.org>
	 <1285099232.30222.25.camel@heimdal.trondhjem.org>
	 <20100921202411.GA10570@fieldses.org>
	 <1285101981.30222.27.camel@heimdal.trondhjem.org>
	 <20100921145823.2ec2a81c@corrin.poochiereds.net>
	 <4C9B8C72.2020405@panasas.com>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 23 Sep 2010 13:29:41 -0400
Message-ID: <1285262981.14171.6.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, 2010-09-23 at 19:20 +0200, Benny Halevy wrote:
> On 2010-09-21 23:58, Jeff Layton wrote:
> > On Tue, 21 Sep 2010 16:46:21 -0400
> > Trond Myklebust <trond.myklebust@fys.uio.no> wrote:
> > 
> >> On Tue, 2010-09-21 at 16:24 -0400, J. Bruce Fields wrote:
> >>> On Tue, Sep 21, 2010 at 04:00:32PM -0400, Trond Myklebust wrote:
> >>>> On Tue, 2010-09-21 at 15:36 -0400, Trond Myklebust wrote:
> >>>>> On Tue, 2010-09-21 at 15:20 -0400, J. Bruce Fields wrote:
> >>>>>> All I need to do is mount nfs4.1 and run cthon -s.  The last output I
> >>>>>> see from the test is:
> >>>>>>
> >>>>>> check for proper open/unlink operation
> >>>>>> nfsjunk files before unlink:
> >>>>>>   
> >>>>>
> >>>>> Oh... I bet I see what it is.
> >>>>>
> >>>>> It's that damned res->sr_slotid = NFS4_MAX_SLOT_TABLE and related
> >>>>> initialisation junk that's biting us in the arse again...
> >>>>>
> >>>>> I'll fix it...
> >>>>
> >>>> Does this work?
> >>>
> >>> Yup.
> >>
> >> It seems to fix things for me too... Once you mentioned NFSv4.1 it was
> >> easy to reproduce the bug.
> >>
> >> OK. I'll merge these into nfs-for-2.6.37...
> > 
> > Thanks for fixing it. I should have mentioned that the 4.1 parts were
> > written using the "cargo-cult" programming method of copying what
> > unlink does, and that they needed careful review. Mea culpa!
> > 
> 
> I still hate it that the sr_slotid requires explicit, non-trivial initialization.
> Once upon a time, the equivalent of sr_slotid used to be a pointer to
> struct slot.  Using a pointer, implicitly initialized to NULL is significantly
> more straight forward as in the patch below.
> (passes cthon tests over your nfs-for-2.6.37 branch + the patch I
> sent earlier that fixes __put_nfs_open_context. w/o it I readily reproduce the
> crash reported on this thread)
> 
> From 50221fb5bd8fbd46f6cabe1fc795db7efc71bff7 Mon Sep 17 00:00:00 2001
> From: Benny Halevy <bhalevy@panasas.com>
> Date: Thu, 23 Sep 2010 19:08:21 +0200
> Subject: [PATCH] NFSv4.1: keep seq_res.sr_slot as pointer rather than an index
> 
> Having to explicitly initialize sr_slotid to NFS4_MAX_SLOT_TABLE
> resulted in numerous bugs.  Keeping the current slot as a pointer
> to the slot table is more straight forward and robust as it's
> implicitly set up to NULL wherever the seq_res member is initialized
> to zeroes.
> 
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>

Looks fine to me, and I prefer this approach to the one we have today. 

Note, however, that I've already applied commit
d688e11007419fd060ae74d8d952a5c4ece735aa (NFSv4.1: Fix the slotid
initialisation in nfs_async_rename()) to the nfs-for-2.6.37 branch.

Are people happy with me rebasing nfs-for-2.6.37 to remove the above
commit, and apply this one instead?

Cheers
  Trond

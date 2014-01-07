Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:42376 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752049AbaAGSL0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 7 Jan 2014 13:11:26 -0500
Date: Tue, 7 Jan 2014 13:11:22 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Anna Schumaker <Anna.Schumaker@netapp.com>
Cc: Trond.Myklebust@primarydata.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 0/3] READ_PLUS rough draft
Message-ID: <20140107181122.GA15463@fieldses.org>
References: <1389045433-22990-1-git-send-email-Anna.Schumaker@netapp.com>
 <20140106223201.GA3342@fieldses.org>
 <52CC123C.7000806@netapp.com>
 <20140107145633.GC3342@fieldses.org>
 <52CC1F86.1040408@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <52CC1F86.1040408@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jan 07, 2014 at 10:38:46AM -0500, Anna Schumaker wrote:
> On 01/07/2014 09:56 AM, J. Bruce Fields wrote:
> > On Tue, Jan 07, 2014 at 09:42:04AM -0500, Anna Schumaker wrote:
> >> On 01/06/2014 05:32 PM, J. Bruce Fields wrote:
> >>> On Mon, Jan 06, 2014 at 04:57:10PM -0500, Anna Schumaker wrote:
> >>>> These patches are my initial implementation of READ_PLUS.  I still have a
> >>>> few issues to work out before they can be applied, but I wanted to submit
> >>>> them anyway to get feedback before going much further.  These patches were
> >>>> developed on top of my earlier SEEK and WRITE_PLUS patches, and probably
> >>>> won't apply cleanly without them (I am willing to reorder things if necessary!).
> >>>>
> >>>> On the server side, I handle the cases where a file is 100% hole, 100% data
> >>>> or hole followed by data.  Any holes after a data segment will be expanded
> >>>> to zeros on the wire.
> >>>
> >>> I assume that for "a file" I should read "the requested range of the
> >>> file"?
> >>
> >> Yes.
> >>
> >>>
> >>> hole+data+hole should also be doable, shouldn't it?  I'd think the real
> >>> problem would be multiple data extents.
> >>
> >> It might be, but I haven't tried it yet.  I can soon!
> >>
> >>>
> >>>> This is due to a limitation in the the NFSD
> >>>> encode-to-page function that will adjust pointers to point to the xdr tail
> >>>> after reading a file to the "pages" section.  Bruce, do you have any
> >>>> suggestions here?
> >>>
> >>> The server xdr encoding needs a rewrite.  I'll see if I can ignore you
> >>> all and put my head down and get a version of that posted this week.
> >>
> >> :)
> >>
> >>>
> >>> That should make it easier to return all the data, though it will turn
> >>> off zero-copy in the case of multiple data extents.
> >>>
> >>> If we want READ_PLUS to support zero copy in the case of multiple
> >>> extents then I think we need a new data structure to represent the
> >>> resulting rpc reply.  An xdr buf only knows how to insert one array of
> >>> pages in the middle of the data.  Maybe a list of xdr bufs?
> >>>
> >>> But that's an annoying job and possibly a premature optimization.
> >>>
> >>> It might be useful to first understand the typical distribution of holes
> >>> in a file and how likely various workloads are to produce reads with
> >>> multiple holes in the middle.
> >>
> >> I already have a few performance numbers, but nothing that can be trusted due to the number of debugging printk()s I used to make sure the client decoded everything correctly.  My plan is to collect the following information using:  v4.0, v4.1, v4.2 (SEEK), v4.2 (SEEK + WRITE_PLUS), and v4.2 (SEEK + WRITE_PLUS + READ_PLUS).
> > 
> > What's the workload and hardware setup?
> 
> I was going to run filebench tests (fileserver, mongo, varmail) between two VMs.  I only have the one laptop with me today, so I can't test between two real machines without asking for a volunteer from Workantile.  I am planning to kill Firefox and Thunderbird before running anything!

That doesn't seem like an interesting test.

Running some generic filesystem benchmarks sounds like a fine idea.  If
nothing else to check for regressions.  But if we want to figure out
whether it helps where it's supposed to then I think we need to think
about what it's meant to do (reduce bandwidth use transferring sparse
files, I guess.  Maybe something copying VM images would be
interesting??)

--b.

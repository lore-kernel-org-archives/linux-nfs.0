Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:14773 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751429Ab1JaX3p convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 31 Oct 2011 19:29:45 -0400
Subject: Re: [PATCH 1/8] pnfs-obj: Remove redundant EOF from
 objlayout_io_state
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Boaz Harrosh <bharrosh@panasas.com>
Cc: Brent Welch <welch@panasas.com>, NFS list <linux-nfs@vger.kernel.org>,
        open-osd <osd-dev@open-osd.org>
Date: Mon, 31 Oct 2011 19:29:28 -0400
In-Reply-To: <4EAF2521.2010204@panasas.com>
References: <4EAF146D.5060507@panasas.com>
	  <1320097506-734-1-git-send-email-bharrosh@panasas.com>
	 <1320099857.10028.6.camel@lade.trondhjem.org>
	 <4EAF2521.2010204@panasas.com>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <1320103768.10028.25.camel@lade.trondhjem.org>
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2011-10-31 at 15:45 -0700, Boaz Harrosh wrote: 
> On 10/31/2011 03:24 PM, Trond Myklebust wrote:
> > On Mon, 2011-10-31 at 14:45 -0700, Boaz Harrosh wrote: 
> >> The EOF calculation was done on .read_pagelist(), cached
> >> in objlayout_io_state->eof, and set in objlayout_read_done()
> >> into nfs_read_data->res.eof.
> >>
> >> So set it directly into nfs_read_data->res.eof and avoid
> >> the extra member.
> >>
> >> This is a slight behaviour change because before eof was
> >> *not* set on an error update at objlayout_read_done(). But
> >> is that a problem? Is Generic layer so sensitive that it
> >> will miss the error IO if eof was set? From my testing
> >> I did not see such a problem.
> > 
> > That would probably be because the object layout will be recalled if the
> > file size changes on the server. If that is not the case, then you do
> > need eof detection...
> > 
> 
> OK Fair enough you mean from the time I opened the file to the
> actual read arriving.
> 
> I have a question? What happens if the file-size on the server
> changed together with the changed-attribute, After the file was
> opened but before the actual read, does it get picked up by the
> client, and reflected in i_size_read() ?

Usually not, and this is why we have the eof mechanism. There are all
sorts of creepy things that can happen in the case where close-to-open
cache consistency is violated...

> Anyway as you said. On any system-wide file-truncate in Objects
> the layout is recalled, so we should be safe, here.
> 
> >> Which brings me to a more abstract problem. Why does the
> >> LAYOUT driver needs to do this eof calculation? .i.e we
> >> are inspecting generic i_size_read() and if spanned by
> >> offset + count which is received from generic layer we set
> >> eof. It looks like all this can/should be done in generic
> >> layer and not at LD. Where does NFS and files-LD do it?
> >> It looks like it can be promoted.
> > 
> > No it can't. The eof flag is returned as part of the READ4resok
> > structure (i.e. it is part of the READ return value) on both
> > read-through-mds and files-type layout reads. Basically, it allows the
> > server to tell you _why_ it returned a short read.
> > 
> 
> In files-type reads in a "condense" layout. You should be careful
> because in striping it is common place to have eof on some DSs because
> of file holes even though there are more bits higher on in the file
> at other DSs. You should check to return back only the answer from the
> highest logical read DS. (Or I'm wrong in my interpretation?)

In the close-to-open cache consistency, O_DIRECT database, or file
locking cases, then either the data has been committed, the file size
extended and the DSes updated, or our client must know that the server
has incomplete information because it is holding cached writes or
layoutcommits that extend the file. In either case, the meaning of the
eofs should be obvious.

Benny's old pet project of making 'tail -f' work on a log file that is
being extended by someone else is, OTOH, subject to screwiness. However
that case can be screwy on ordinary read-through-MDS too.

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com


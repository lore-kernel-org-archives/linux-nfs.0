Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:60196 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932820Ab3GVTni (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 22 Jul 2013 15:43:38 -0400
Date: Mon, 22 Jul 2013 15:43:31 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Bryan Schumaker <bjschuma@netapp.com>
Cc: Trond.Myklebust@netapp.com, linux-nfs@vger.kernel.org
Subject: Re: [RFC 4/5] NFSD: Defer copying
Message-ID: <20130722194331.GF10109@fieldses.org>
References: <1374267830-30154-1-git-send-email-bjschuma@netapp.com>
 <1374267830-30154-5-git-send-email-bjschuma@netapp.com>
 <20130722185002.GB10109@fieldses.org>
 <51ED8549.3040308@netapp.com>
 <20130722193000.GD10109@fieldses.org>
 <51ED89DC.7050406@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <51ED89DC.7050406@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jul 22, 2013 at 03:37:00PM -0400, Bryan Schumaker wrote:
> On 07/22/2013 03:30 PM, J. Bruce Fields wrote:
> > On Mon, Jul 22, 2013 at 03:17:29PM -0400, Bryan Schumaker wrote:
> >> On 07/22/2013 02:50 PM, J. Bruce Fields wrote:
> >>> On Fri, Jul 19, 2013 at 05:03:49PM -0400, bjschuma@netapp.com wrote:
> >>>> From: Bryan Schumaker <bjschuma@netapp.com>
> >>>>
> >>>> Rather than performing the copy right away, schedule it to run later and
> >>>> reply to the client.  Later, send a callback to notify the client that
> >>>> the copy has finished.
> >>>
> >>> I believe you need to implement the referring triple support described
> >>> in http://tools.ietf.org/html/rfc5661#section-2.10.6.3 to fix the race
> >>> described in
> >>> http://tools.ietf.org/html/draft-ietf-nfsv4-minorversion2-19#section-15.1.3
> >>> .
> >>
> >> I'll re-read and re-write.
> >>
> >>>
> >>> I see cb_delay initialized below, but not otherwise used.  Am I missing
> >>> anything?
> >>
> >> Whoops!  I was using that earlier to try to fake up a callback, but I eventually decided it's easier to just do the copy asynchronously.  I must have forgotten to take it out :(
> >>
> >>>
> >>> What about OFFLOAD_STATUS and OFFLOAD_ABORT?
> >>
> >> I haven't thought out those too much... I haven't thought about a use for them on the client yet.
> > 
> > If it might be a long-running copy, I assume the client needs the
> > ability to abort if the caller is killed.
> > 
> > (Dumb question: what happens on the network partition?  Does the server
> > abort the copy when it expires the client state?)
> > 
> > In any case,
> > http://tools.ietf.org/html/draft-ietf-nfsv4-minorversion2-19#section-15.1.3
> > says "If a server's COPY operation returns a stateid, then the server
> > MUST also support these operations: CB_OFFLOAD, OFFLOAD_ABORT, and
> > OFFLOAD_STATUS."
> > 
> > So even if we've no use for them on the client then we still need to
> > implement them (and probably just write a basic pynfs test).  Either
> > that or update the spec.
> 
> Fair enough.  I'll think it out and do something!  Easy solution: save this patch for later and only support the sync version of copy for the final version of this patch series.

I can't remember--does the spec give the server a clear way to bail out
and tell the client to fall back on a normal copy in cases where the
server knows the copy could take an unreasonable amount of time?

--b.

> 
> - Bryan
> 
> > 
> >>> In some common cases the reply will be very quick, and we might be
> >>> better off handling it synchronously.  Could we implement a heuristic
> >>> like "copy synchronously if the filesystem has special support or the
> >>> range is less than the maximum iosize, otherwise copy asynchronously"?
> >>
> >> I'm sure that can be done, I'm just not sure how to do it yet...
> > 
> > OK, thanks.
> > 
> > --b.
> > 
> 

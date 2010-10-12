Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:38616 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932219Ab0JLNuX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 12 Oct 2010 09:50:23 -0400
Date: Tue, 12 Oct 2010 09:50:20 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Pavel Emelyanov <xemul@parallels.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Trond Myklebust <trond@netapp.com>
Subject: Re: [PATCH 0/13] sunrpc: Compact the xprtsock code a bit
Message-ID: <20101012135020.GB12752@fieldses.org>
References: <4CA9CDA8.4010407@parallels.com>
 <20101011234711.GC16442@fieldses.org>
 <4CB4137D.2000709@parallels.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4CB4137D.2000709@parallels.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, Oct 12, 2010 at 11:51:25AM +0400, Pavel Emelyanov wrote:
> On 10/12/2010 03:47 AM, J. Bruce Fields wrote:
> > On Mon, Oct 04, 2010 at 04:50:48PM +0400, Pavel Emelyanov wrote:
> >> Hi!
> >>
> >> This set removes some unused parts of code and merges together
> >> routines that are related to the sockets creation.
> >>
> >> After all the changes the result is
> >>
> >>  net/sunrpc/xprtsock.c: 77 insertions(+), 206 deletions(-)
> >>
> >> from the code-lines point of view and
> >>
> >>   add/remove: 2/11 grow/shrink: 4/1 up/down: 879/-1626 (-747)
> >>
> >> from the bloat-o-meter's point of view.
> > 
> > I'm assuming Trond is taking these.  Let me know if that doesn't
> > work....
> 
> When will these appear in your three then? The thing is my next patches
> depend on this set.

If Trond ACK's them I'd happily merge them into my tree.

(Or Trond could merge them, then one of us could merge the other's tree,
and you could work on top of that.)

--b.

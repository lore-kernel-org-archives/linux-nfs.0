Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:41305 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756185Ab0JOPDN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 15 Oct 2010 11:03:13 -0400
Date: Fri, 15 Oct 2010 11:03:10 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Pavel Emelyanov <xemul@parallels.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Trond Myklebust <trond@netapp.com>
Subject: Re: [PATCH 0/13] sunrpc: Compact the xprtsock code a bit
Message-ID: <20101015150309.GA12268@fieldses.org>
References: <4CA9CDA8.4010407@parallels.com>
 <20101011234711.GC16442@fieldses.org>
 <4CB4137D.2000709@parallels.com>
 <20101012135020.GB12752@fieldses.org>
 <4CB47CFB.7040503@parallels.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4CB47CFB.7040503@parallels.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, Oct 12, 2010 at 07:21:31PM +0400, Pavel Emelyanov wrote:
> >>> I'm assuming Trond is taking these.  Let me know if that doesn't
> >>> work....
> >>
> >> When will these appear in your three then? The thing is my next patches
> >> depend on this set.
> > 
> > If Trond ACK's them I'd happily merge them into my tree.
> > 
> > (Or Trond could merge them, then one of us could merge the other's tree,
> > and you could work on top of that.)
> 
> OK. Then I'll wait for Trond's decision.

OK, talking to Trond, he's fine with the patches, so I'll just go ahead
and merge them, including the 3-4 additional patches you posted
afterwards.  That also means all your patches so far are in my tree so
you can continue working off that one tree if that's simplest.

I want to run some quick tests and then I'll push them out, and you can
let me know if I've forgotten any.

(Oh, and Trond also reminds me that there's still the worry about we'll
handle the keyring upcalls.  Any ideas there?)

--b.

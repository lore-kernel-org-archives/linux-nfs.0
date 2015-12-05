Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qg0-f48.google.com ([209.85.192.48]:35796 "EHLO
	mail-qg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751103AbbLEMYN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 5 Dec 2015 07:24:13 -0500
Received: by qgec40 with SMTP id c40so110564100qge.2
        for <linux-nfs@vger.kernel.org>; Sat, 05 Dec 2015 04:24:13 -0800 (PST)
Date: Sat, 5 Dec 2015 07:24:09 -0500
From: Jeff Layton <jlayton@poochiereds.net>
To: Christoph Hellwig <hch@lst.de>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Kinglong Mee <kinglongmee@gmail.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH RFC] nfsd: serialize layout stateid morphing operations
Message-ID: <20151205072409.46d66109@tlielax.poochiereds.net>
In-Reply-To: <20151205120222.GA27009@lst.de>
References: <20151129084614.42fb1272@tlielax.poochiereds.net>
	<565BBB03.7020206@gmail.com>
	<20151130213420.GA31564@fieldses.org>
	<20151130193313.5bb10791@synchrony.poochiereds.net>
	<20151201115600.GA1557@lst.de>
	<20151201174800.407e2c40@synchrony.poochiereds.net>
	<20151202072504.GA15839@lst.de>
	<20151203220850.GC19518@fieldses.org>
	<20151204083803.GA2440@lst.de>
	<20151204155110.64a352dd@tlielax.poochiereds.net>
	<20151205120222.GA27009@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, 5 Dec 2015 13:02:22 +0100
Christoph Hellwig <hch@lst.de> wrote:

> On Fri, Dec 04, 2015 at 03:51:10PM -0500, Jeff Layton wrote:
> > > There is no reason not to do it, except for the significant effort
> > > to implement it a well as a synthetic test case to actually reproduce
> > > the behavior we want to handle.
> > 
> > Could you end up livelocking here? Suppose you issue the callback and
> > the client returns success. He then returns the layout and gets a new
> > one just before the delay timer pops. We then end up recalling _that_
> > layout...rinse, repeat...
> 
> If we start allowing layoutgets before the whole range has been
> returned there is a great chance for livelocks, yes.  But I don't think
> we should allow layoutgets to proceed before that.

Maybe I didn't describe it well enough. I think you can still end up
looping even if you don't allow LAYOUTGETs before the entire range is
returned.

If we treat NFS4_OK and NFS4ERR_DELAY equivalently, then we're
expecting the client to eventually return NFS4ERR_NOMATCHING_LAYOUT (or
a different error) to break the cycle of retransmissions. But, HZ/100
is enough time for the client to return a layout and request a new one.
We may never see that error -- only a continual cycle of
CB_LAYOUTRECALL/LAYOUTRETURN/LAYOUTGET.

I think we need a more reliable way to break that cycle so we don't end
up looping like that. We should either cancel any active callbacks
before reallowing LAYOUTGETs, or move the timeout handling outside of
the RPC state machine (like Bruce was suggesting).

-- 
Jeff Layton <jlayton@poochiereds.net>

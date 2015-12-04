Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f181.google.com ([209.85.220.181]:34348 "EHLO
	mail-qk0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753148AbbLDUx4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 4 Dec 2015 15:53:56 -0500
Received: by qkeg192 with SMTP id g192so2833119qke.1
        for <linux-nfs@vger.kernel.org>; Fri, 04 Dec 2015 12:53:55 -0800 (PST)
Date: Fri, 4 Dec 2015 15:51:10 -0500
From: Jeff Layton <jlayton@poochiereds.net>
To: Christoph Hellwig <hch@lst.de>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Kinglong Mee <kinglongmee@gmail.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH RFC] nfsd: serialize layout stateid morphing operations
Message-ID: <20151204155110.64a352dd@tlielax.poochiereds.net>
In-Reply-To: <20151204083803.GA2440@lst.de>
References: <1442491104-30080-1-git-send-email-jeff.layton@primarydata.com>
	<565A7A14.4010902@gmail.com>
	<20151129084614.42fb1272@tlielax.poochiereds.net>
	<565BBB03.7020206@gmail.com>
	<20151130213420.GA31564@fieldses.org>
	<20151130193313.5bb10791@synchrony.poochiereds.net>
	<20151201115600.GA1557@lst.de>
	<20151201174800.407e2c40@synchrony.poochiereds.net>
	<20151202072504.GA15839@lst.de>
	<20151203220850.GC19518@fieldses.org>
	<20151204083803.GA2440@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 4 Dec 2015 09:38:03 +0100
Christoph Hellwig <hch@lst.de> wrote:

> On Thu, Dec 03, 2015 at 05:08:50PM -0500, J. Bruce Fields wrote:
> > OK, so if I understand right, the current code is letting the rpc state
> > machine drive the whole thing, and your proposal is that the rpc task
> > lasts until the client either responds NFS4ERR_NOMATCHING_LAYOUT or we
> > just run out of time.  (NOMATCHING_LAYOUT being the one response that
> > isn't either "try again" or "OK I'll get to it soon").
> 
> Yes (except fatal errors would end the rpc state machine).
> 
> > I understand why that would work, and that handling anything other than
> > the NOMATCHING_LAYOUT case is a lower priority for now, but this
> > approach worries me.
> > 
> > Is there a reason we can't do as in the delegation case, and track the
> > revocation timeout separately from the callback rpc?
> 
> There is no reason not to do it, except for the significant effort
> to implement it a well as a synthetic test case to actually reproduce
> the behavior we want to handle.

Could you end up livelocking here? Suppose you issue the callback and
the client returns success. He then returns the layout and gets a new
one just before the delay timer pops. We then end up recalling _that_
layout...rinse, repeat...

I'm not opposed to using the state machine to drive this, but I think
I'd like to see some mechanism to cancel any callbacks that are still
in limbo, before the server starts handing out layouts again for the
file.

-- 
Jeff Layton <jlayton@poochiereds.net>

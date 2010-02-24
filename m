Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bld-mail15.adl6.internode.on.net ([150.101.137.100]:53932 "EHLO
	mail.internode.on.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755573Ab0BXHjp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 24 Feb 2010 02:39:45 -0500
Date: Wed, 24 Feb 2010 18:39:40 +1100
From: Dave Chinner <david@fromorbit.com>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
        Linux Memory Management List <linux-mm@kvack.org>,
        LKML <linux-kernel@vger.kernel.org>
Subject: Re: [RFC] nfs: use 2*rsize readahead size
Message-ID: <20100224073940.GJ16175@discord.disaster>
References: <20100224024100.GA17048@localhost> <20100224032934.GF16175@discord.disaster> <20100224041822.GB27459@localhost> <20100224052215.GH16175@discord.disaster> <20100224061247.GA8421@localhost>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20100224061247.GA8421@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Feb 24, 2010 at 02:12:47PM +0800, Wu Fengguang wrote:
> On Wed, Feb 24, 2010 at 01:22:15PM +0800, Dave Chinner wrote:
> > What I'm trying to say is that while I agree with your premise that
> > a 7.8MB readahead window is probably far larger than was ever
> > intended, I disagree with your methodology and environment for
> > selecting a better default value.  The default readahead value needs
> > to work well in as many situations as possible, not just in perfect
> > 1:1 client/server environment.
> 
> Good points. It's imprudent to change a default value based on one
> single benchmark. Need to collect more data, which may take time..

Agreed - better to spend time now to get it right...

> > > It sounds silly to have
> > > 
> > >         client_readahead_size > server_readahead_size
> > 
> > I don't think it is  - the client readahead has to take into account
> > the network latency as well as the server latency. e.g. a network
> > with a high bandwidth but high latency is going to need much more
> > client side readahead than a high bandwidth, low latency network to
> > get the same throughput. Hence it is not uncommon to see larger
> > readahead windows on network clients than for local disk access.
> 
> Hmm I wonder if I can simulate a high-bandwidth high-latency network
> with e1000's RxIntDelay/TxIntDelay parameters..

I think netem is the blessed method of emulating different network
behaviours. There's a howto+faq for setting it up here:

http://www.linuxfoundation.org/collaborate/workgroups/networking/netem

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:4768 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754391Ab1EDPbX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 4 May 2011 11:31:23 -0400
Date: Wed, 4 May 2011 11:31:19 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Andy Adamson <andros@netapp.com>
Cc: trond.myklebust@netapp.com, linux-nfs@vger.kernel.org
Subject: Re: [[RFC] 1/1] SUNRPC: dynamic rpc_slot allocator for TCP
Message-ID: <20110504113119.20388ad5@tlielax.poochiereds.net>
In-Reply-To: <6FD7BAA7-0E0D-42AD-98CC-DC528A091178@netapp.com>
References: <1304386808-2733-1-git-send-email-andros@netapp.com>
	<1304386808-2733-2-git-send-email-andros@netapp.com>
	<20110504110841.6e3e85e4@tlielax.poochiereds.net>
	<6FD7BAA7-0E0D-42AD-98CC-DC528A091178@netapp.com>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 4 May 2011 11:20:59 -0400
Andy Adamson <andros@netapp.com> wrote:

> 
> On May 4, 2011, at 11:08 AM, Jeff Layton wrote:
> 
> > On Mon,  2 May 2011 21:40:08 -0400
> > andros@netapp.com wrote:
> > 
> >> +	if (!test_and_clear_bit(XPRT_WRITE_SPACE, &xprt->state))
> >> +		return;
> > 
> > Also, I'm not sure that a single bit really conveys enough information
> > for this.
> > 
> > IIUC, sk_write_space gets called when a packet is TCP ACK'ed. It seems
> > possible that we would sometimes have buffer space available to queue
> > the packet without sk_write_space being called. With this, we'll
> > basically be serializing all dynamic slot allocations behind the
> > sk_write_space callbacks.
> 
> Which I thought was OK given that the TCP window takes a while to stabilize.
> 

Hmm, ok. I hadn't considered that, but you may be correct.

> > 
> > Consider the case of many small TCP frames being sent after a large one
> > just got ACK'ed. Only one would be allowed to be sent, even though
> > there might be enough send buffer space to allow for more.
> > 
> > Would it instead make more sense to base this on the amount of space
> > available in the actual socket rather than this bit?
> 
> So at each write_space, potentially allocate more than one rpc_slot as opposed
> to allocating one rpc_slot and waiting for the next write_space? I could look at this
> with the 10G testiing.
> 

xs_tcp_write_space has this:

        /* from net/core/stream.c:sk_stream_write_space */
        if (sk_stream_wspace(sk) >= sk_stream_min_wspace(sk))
                xs_write_space(sk);

...my (hand-wavy) thinking was that it might make sense to check
against this value again in the slot allocation routine.

IOW, allow allocation of a slot if there's reasonably enough buffer
space to do a send instead of allowing just one per xs_write_space
callback.

Of course, that gets complicated if there are a bunch of slot
allocations in parallel. You'd probably need to offset the amount of
available space by a certain amount for each slot that has been
allocated but not yet sent.

Perhaps though that's too complicated to be really useful...

-- 
Jeff Layton <jlayton@redhat.com>

Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44567 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751802Ab1EELro (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 5 May 2011 07:47:44 -0400
Date: Thu, 5 May 2011 07:47:41 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Andy Adamson <andros@netapp.com>, linux-nfs@vger.kernel.org
Subject: Re: [[RFC] 1/1] SUNRPC: dynamic rpc_slot allocator for TCP
Message-ID: <20110505074741.17f1698d@tlielax.poochiereds.net>
In-Reply-To: <1304523334.4476.12.camel@lade.trondhjem.org>
References: <1304386808-2733-1-git-send-email-andros@netapp.com>
	<1304386808-2733-2-git-send-email-andros@netapp.com>
	<20110504110841.6e3e85e4@tlielax.poochiereds.net>
	<6FD7BAA7-0E0D-42AD-98CC-DC528A091178@netapp.com>
	<1304523334.4476.12.camel@lade.trondhjem.org>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 04 May 2011 11:35:34 -0400
Trond Myklebust <Trond.Myklebust@netapp.com> wrote:

> On Wed, 2011-05-04 at 11:20 -0400, Andy Adamson wrote:
> > On May 4, 2011, at 11:08 AM, Jeff Layton wrote:
> > 
> > > On Mon,  2 May 2011 21:40:08 -0400
> > > andros@netapp.com wrote:
> > > 
> > >> +	if (!test_and_clear_bit(XPRT_WRITE_SPACE, &xprt->state))
> > >> +		return;
> > > 
> > > Also, I'm not sure that a single bit really conveys enough information
> > > for this.
> > > 
> > > IIUC, sk_write_space gets called when a packet is TCP ACK'ed. It seems
> > > possible that we would sometimes have buffer space available to queue
> > > the packet without sk_write_space being called. With this, we'll
> > > basically be serializing all dynamic slot allocations behind the
> > > sk_write_space callbacks.
> > 
> > Which I thought was OK given that the TCP window takes a while to stabilize.
> > 
> > > 
> > > Consider the case of many small TCP frames being sent after a large one
> > > just got ACK'ed. Only one would be allowed to be sent, even though
> > > there might be enough send buffer space to allow for more.
> > > 
> > > Would it instead make more sense to base this on the amount of space
> > > available in the actual socket rather than this bit?
> > 
> > So at each write_space, potentially allocate more than one rpc_slot as opposed
> > to allocating one rpc_slot and waiting for the next write_space? I could look at this
> > with the 10G testiing.
> 
> Why? You can't send that data. Once you hit the write space limit, then
> the socket remains blocked until you get the callback. It doesn't matter
> how small the frame, you will not be allowed to send more data.
> 
> On the other hand, we do set the SOCK_NOSPACE bit, which means that the
> socket layer will attempt to grow the TCP window even though we're not
> actually putting more data into the socket.
> 

I'm not sure I understand what you're suggesting here.

I guess my main point is that a single bit that we flip on in
write_space and flip off when a slot is allocated doesn't carry enough
info. That scheme will also be subject to subtle differences in timing.
For instance...

Suppose a large number of TCP ACKs come in all at around the same time.
write_space gets called a bunch of times in succession, so the bit gets
"set" several times. Several queued tasks get woken up but only one can
clear the bit so only one gets a slot.

However, if those acks come in with enough of a delay between them, then
you can potentially get one slot allocated per write_space callback.

I think we ought to consider a heuristic that doesn't rely on the
frequency and timing of write_space callbacks.

-- 
Jeff Layton <jlayton@redhat.com>

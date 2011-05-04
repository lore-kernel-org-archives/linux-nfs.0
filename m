Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:8057 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751608Ab1EDPfg convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 4 May 2011 11:35:36 -0400
Subject: Re: [[RFC] 1/1] SUNRPC: dynamic rpc_slot allocator for TCP
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Andy Adamson <andros@netapp.com>
Cc: Jeff Layton <jlayton@redhat.com>, linux-nfs@vger.kernel.org
In-Reply-To: <6FD7BAA7-0E0D-42AD-98CC-DC528A091178@netapp.com>
References: <1304386808-2733-1-git-send-email-andros@netapp.com>
	 <1304386808-2733-2-git-send-email-andros@netapp.com>
	 <20110504110841.6e3e85e4@tlielax.poochiereds.net>
	 <6FD7BAA7-0E0D-42AD-98CC-DC528A091178@netapp.com>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 04 May 2011 11:35:34 -0400
Message-ID: <1304523334.4476.12.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 2011-05-04 at 11:20 -0400, Andy Adamson wrote:
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

Why? You can't send that data. Once you hit the write space limit, then
the socket remains blocked until you get the callback. It doesn't matter
how small the frame, you will not be allowed to send more data.

On the other hand, we do set the SOCK_NOSPACE bit, which means that the
socket layer will attempt to grow the TCP window even though we're not
actually putting more data into the socket.

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com


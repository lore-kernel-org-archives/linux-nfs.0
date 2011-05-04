Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:19046 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754275Ab1EDPVC convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 4 May 2011 11:21:02 -0400
Subject: Re: [[RFC] 1/1] SUNRPC: dynamic rpc_slot allocator for TCP
Content-Type: text/plain; charset=us-ascii
From: Andy Adamson <andros@netapp.com>
In-Reply-To: <20110504110841.6e3e85e4@tlielax.poochiereds.net>
Date: Wed, 4 May 2011 11:20:59 -0400
Cc: trond.myklebust@netapp.com, linux-nfs@vger.kernel.org
Message-Id: <6FD7BAA7-0E0D-42AD-98CC-DC528A091178@netapp.com>
References: <1304386808-2733-1-git-send-email-andros@netapp.com> <1304386808-2733-2-git-send-email-andros@netapp.com> <20110504110841.6e3e85e4@tlielax.poochiereds.net>
To: Jeff Layton <jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On May 4, 2011, at 11:08 AM, Jeff Layton wrote:

> On Mon,  2 May 2011 21:40:08 -0400
> andros@netapp.com wrote:
> 
>> +	if (!test_and_clear_bit(XPRT_WRITE_SPACE, &xprt->state))
>> +		return;
> 
> Also, I'm not sure that a single bit really conveys enough information
> for this.
> 
> IIUC, sk_write_space gets called when a packet is TCP ACK'ed. It seems
> possible that we would sometimes have buffer space available to queue
> the packet without sk_write_space being called. With this, we'll
> basically be serializing all dynamic slot allocations behind the
> sk_write_space callbacks.

Which I thought was OK given that the TCP window takes a while to stabilize.

> 
> Consider the case of many small TCP frames being sent after a large one
> just got ACK'ed. Only one would be allowed to be sent, even though
> there might be enough send buffer space to allow for more.
> 
> Would it instead make more sense to base this on the amount of space
> available in the actual socket rather than this bit?

So at each write_space, potentially allocate more than one rpc_slot as opposed
to allocating one rpc_slot and waiting for the next write_space? I could look at this
with the 10G testiing.

-->Andy

> 
> -- 
> Jeff Layton <jlayton@redhat.com>


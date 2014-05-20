Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx5.framestore.com ([193.203.83.15]:35767 "EHLO
	mx5.framestore.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753127AbaETQzm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 20 May 2014 12:55:42 -0400
Subject: Re: NFS (or RPC) batching of calls over TCP results in 'unmatched'
 replies?
From: Jim Vanns <james.vanns@framestore.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
In-Reply-To: <1400603652.13140.32.camel@sys304.ldn.framestore.com>
References: <1400588966.13140.22.camel@sys304.ldn.framestore.com>
	 <20140520152654.GB4513@fieldses.org>
	 <1400603652.13140.32.camel@sys304.ldn.framestore.com>
Content-Type: text/plain; charset="ISO-8859-1"
Date: Tue, 20 May 2014 17:55:29 +0100
Message-ID: <1400604929.13140.35.camel@sys304.ldn.framestore.com>
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

<snip>

> > My suspicion is that tshark is missing some replies.  Either the packet
> > loss counters are wrong, or tshark is failing to identify RPC replies
> > that start in the middle of a tcp segment?  I seem to recall seeing that
> > before.
> 
> Yes - I had wondered about that and I will modify my own code to verify
> if this is the case.
> 
> I *assumed* that tcpdump or wireshark already did this! I guess it just
> expects application protocols to be aligned to the TCP boundary.

I have (rather rushed to be honest) written some code that scans the
entire TCP segment captured for a record fragment marker and I still see
the same results - very few replies for a great many calls.

Still at a loss (pun intended ;)

Jim

> Thanks for your help so far.
> 
> Jim
> 
> > --b.
> > 
> > > The IBM and Oracle websites also have some
> > > info but not much. I have found nothing that enables
> > > me to identify batched requests (or rather the replies for a batch) in
> > > the protocol itself. Wireshark seems unable to do this also.
> > > 
> > > I realise this is a bit off-topic but I was hoping someone might be able
> > > to point me in the right direction? Am I barking up the wrong tree? Is
> > > this behaviour expected - am I unable to match calls to replies when
> > > batching is used? The IBM website suggests;
> > > 
> > > 'Batching assumes the following:
> > > 
> > > Each remote procedure call in the pipeline requires no response from the
> > > server, and the server does not send a response message.'
> > > 
> > > This sounds a bit awkward! It then goes on to suggest that;
> > > 
> > > 'The remote procedure call's time out must be 0'
> > > 
> > > For batched calls. But there is no call timeout in the RPC protocol
> > > right? Again, this must be up to the client implementation I suspect?
> > > 
> > > Any help appreciated.
> > > 
> > > Regards,
> > > 
> > > Jim
> > > 
> > > PS. I may well join the Linux RPC mailing list and direct this question
> > > at them instead.
> > > 
> > > -- 
> > > Senior Software Engineer
> > > Systems Development
> > > Framestore
> > > 
> > > 
> > > --
> > > To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> > > the body of a message to majordomo@vger.kernel.org
> > > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

-- 
Software Engineer
Systems Development
Framestore



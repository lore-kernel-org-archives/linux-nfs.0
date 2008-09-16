From: Tom Tucker <tom@opengridcomputing.com>
Subject: Re: NFS regression? Odd delays and lockups accessing an NFS export.
Date: Tue, 16 Sep 2008 06:38:43 -0500
Message-ID: <48CF9AC3.6060801@opengridcomputing.com>
References: <48B2D7F8.5020206@opengridcomputing.com>	 <20080826192711.GJ4380@fieldses.org>	 <48B567F5.2090605@opengridcomputing.com>	 <1220111261.31172.14.camel@localhost.localdomain>	 <20080831193037.GB14876@fieldses.org>	 <1220211842.31172.18.camel@localhost.localdomain>	 <48BAF643.4070808@opengridcomputing.com>	 <1220217505.31172.26.camel@localhost.localdomain>	 <48BC2466.2070806@opengridcomputing.com>	 <1221036015.24993.27.camel@zakaz.uk.xensource.com>	 <20080912224323.GN22126@fieldses.org>	 <48CAF80A.4010109@opengridcomputing.com>	 <1221296243.2534.7.camel@localhost.localdomain> <1221544139.2534.18.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	Grant Coady <gcoady.lk@gmail.com>,
	linux-kernel@vger.kernel.org, neilb@suse.de,
	linux-nfs@vger.kernel.org
To: Ian Campbell <ijc-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.es335.com ([67.65.19.105]:20114 "EHLO mail.es335.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752476AbYIPLio (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 16 Sep 2008 07:38:44 -0400
In-Reply-To: <1221544139.2534.18.camel-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Ian Campbell wrote:
> (dropping the e1000 guys, it seems unnecessary to keep spamming them
> with this issue when it's unlikely to be anything to do with them. I've
> left their list on for now so they know. I'd suggest dropping it from
> any replies.)
>
> On Sat, 2008-09-13 at 09:57 +0100, Ian Campbell wrote:
>   
>> On Fri, 2008-09-12 at 18:15 -0500, Tom Tucker wrote:
>>     
>>> Iain sadly yes. There's a thread stuck holding the BUSY bit or a thread 
>>> failed to clear the bit properly
>>> (maybe an error path). Data continues to arrives, but the transport 
>>> never gets put back on the queue
>>> because it's BUSY bit is set.  In other words, this is a different error 
>>> than the one we've been chasing.
>>>
>>> If I sent you a patch, could you rebuild the kernel and give it a whirl? 
>>> Also, can you give me a
>>> kernel.org relative commit-id or tag for the kernel that you're using?
>>>       
>> I sure could. I'm using the Debian kernel which is currently at 2.6.26.3
>> (pkg version 2.6.26-4) although I have an update to 2.6.26.4 (via pkg
>> 2.6.26-5) pending.
>>
>> If I'm going to build my own I'll start with current git
>> (a551b98d5f6fce5897d497abd8bfb262efb33d2a) and repro there before trying
>> your patch.
>>     
>
> FYI I've repro'd with 
>         commit a551b98d5f6fce5897d497abd8bfb262efb33d2a
>         Merge: d1c6d2e... 50bed2e...
>         Author: Linus Torvalds <torvalds@linux-foundation.org>
>         Date:   Thu Sep 11 11:50:15 2008 -0700
>         
>             Merge branch 'for-linus' of git://git.kernel.dk/linux-2.6-block
>             
>             * 'for-linus' of git://git.kernel.dk/linux-2.6-block:
>               sg: disable interrupts inside sg_copy_buffer
> which was the latest git a few days back.
>
> I'm going to start bisecting between v2.6.25 and v2.6.26. There's 173
> commits in fs/nfs* net/sunrpc in that interval so with a day per test I
> should have something next week...
>
>   
Iain:

I'm assuming you'll do this in advance of any patch from me? I was 
simply going to add printk to the various shutdown paths and see if we 
could get some finer grained debug output since the generic transport 
debug output was too verbose.

Let me know and I'll help if I can,
Tom

> Ian.
>   


Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:36475 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751146AbbGILBx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Jul 2015 07:01:53 -0400
Received: by widjy10 with SMTP id jy10so241549399wid.1
        for <linux-nfs@vger.kernel.org>; Thu, 09 Jul 2015 04:01:52 -0700 (PDT)
Subject: Re: [PATCH V3 1/5] RDMA/core: Transport-independent access flags
To: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>,
        Tom Talpey <tom@talpey.com>
References: <559AAA22.1000608@dev.mellanox.co.il>
 <20150707090001.GB11736@infradead.org> <559B9891.8060907@dev.mellanox.co.il>
 <000b01d0b8bd$f2bfcc10$d83f6430$@opengridcomputing.com>
 <20150707161751.GA623@obsidianresearch.com>
 <559BFE03.4020709@dev.mellanox.co.il>
 <20150707213628.GA5661@obsidianresearch.com>
 <559CD174.4040901@dev.mellanox.co.il>
 <20150708190842.GB11740@obsidianresearch.com> <559D983D.6000804@talpey.com>
 <20150708233604.GA20765@obsidianresearch.com>
Cc: Steve Wise <swise@opengridcomputing.com>,
        "'Christoph Hellwig'" <hch@infradead.org>, dledford@redhat.com,
        sagig@mellanox.com, ogerlitz@mellanox.com, roid@mellanox.com,
        linux-rdma@vger.kernel.org, eli@mellanox.com,
        target-devel@vger.kernel.org, linux-nfs@vger.kernel.org,
        trond.myklebust@primarydata.com, bfields@fieldses.org,
        Oren Duer <oren@mellanox.com>
From: Sagi Grimberg <sagig@dev.mellanox.co.il>
Message-ID: <559E54AB.2010905@dev.mellanox.co.il>
Date: Thu, 9 Jul 2015 14:02:03 +0300
MIME-Version: 1.0
In-Reply-To: <20150708233604.GA20765@obsidianresearch.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 7/9/2015 2:36 AM, Jason Gunthorpe wrote:

>
> I'm arguing upper layer protocols should never even see local memory
> registration, that it is totally irrelevant to them. So yes, you can
> call that a common approach to memory registration if you like..
>
> Basically it appears there is nothing that NFS can do to optimize that
> process that cannot be done in the driver/core equally effectively and
> shared between all ULPs. If you see something otherwise, I'm really
> interested to hear about it.
>
> Even your case of the MR trade off for S/G list limitations - that is
> a performance point NFS has no buisness choosing. The driver is best
> placed to know when to switch between S/G lists, multiple RDMA READs
> and MR. The trade off will shift depending on HW limits:
>   - Old mthca hardware is probably better to use multiple RDMA READ
>   - mlx4 is probably better to use FRMR
>   - mlx5 is likely best with indirect MR
>   - All of the above are likely best to exhaust the S/G list first
>
> The same basic argument is true of WRITE, SEND and RECV. If the S/G
> list is exhausted then the API should transparently build a local MR
> to linearize the buffer, and the API should be designed so the core
> code can do that without the ULP having to be involved in those
> details.
>
> Is it possible?
>
> Jason
>

Jason,

We have protocol that involves remote memory keys transfer in their
standards so I don't see how we can remove it altogether from ULPs.

Putting that aside,

My main problem with this approach is that once you do non-trivial
things such as memory registration completely under the hood, it is
a slippery slope for device drivers.

If say a driver decides to register memory without the caller knowing,
it would need to post an extra work request on the send queue. So once
it sees the completion, it needs to silently consume it and have some
non trivial logic to invalidate it (another work request!) either from
poll_cq context or another thread.

Moreover, this also means that the driver needs to allocate bigger send
queues for possible future memory registration (depending on the IO
pattern maybe). And I really don't like an API that instructs the user
"please allocate some extra room in your send queue as I might need it".

This would also require the drivers to take a huristic approach on how
much memory registration resources are needed for all possible
consumers (ipoib, sdp, srp, iser, nfs, more...) which might have
different requirements.

I know that these are implementation details, but the point is that
vendor drivers can easily become a complete mess. I think we should
try to find a balanced approach where both consumers and providers are
not completely messed up.

Sagi.

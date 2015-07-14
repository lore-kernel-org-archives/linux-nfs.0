Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from p3plsmtpa09-04.prod.phx3.secureserver.net ([173.201.193.233]:38816
	"EHLO p3plsmtpa09-04.prod.phx3.secureserver.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752503AbbGNUu7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 14 Jul 2015 16:50:59 -0400
Message-ID: <55A5762D.8010009@talpey.com>
Date: Tue, 14 Jul 2015 16:50:53 -0400
From: Tom Talpey <tom@talpey.com>
MIME-Version: 1.0
To: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>,
        "'Christoph Hellwig'" <hch@infradead.org>
CC: Steve Wise <swise@opengridcomputing.com>,
        "'Sagi Grimberg'" <sagig@dev.mellanox.co.il>,
        "'Steve Wise'" <swise@ogc.us>, "'Doug Ledford'" <dledford@redhat.com>,
        sagig@mellanox.com, ogerlitz@mellanox.com, roid@mellanox.com,
        linux-rdma@vger.kernel.org, eli@mellanox.com,
        target-devel@vger.kernel.org, linux-nfs@vger.kernel.org,
        trond.myklebust@primarydata.com, bfields@fieldses.org,
        "'Oren Duer'" <oren@mellanox.com>
Subject: Re: [PATCH V3 1/5] RDMA/core: Transport-independent access flags
References: <559EF332.7060103@redhat.com> <20150709225306.GA30741@obsidianresearch.com> <559FC710.1050307@talpey.com> <20150710161108.GA19042@obsidianresearch.com> <CCB6E837-88FF-4DBB-976D-4CF56396A1A1@ogc.us> <55A24571.60902@dev.mellanox.co.il> <00e201d0be6a$e49bc910$add35b30$@opengridcomputing.com> <20150714192941.GA26292@obsidianresearch.com> <00e401d0be6b$d3952750$7abf75f0$@opengridcomputing.com> <20150714195511.GB7716@infradead.org> <20150714202943.GB26927@obsidianresearch.com>
In-Reply-To: <20150714202943.GB26927@obsidianresearch.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 7/14/2015 4:29 PM, Jason Gunthorpe wrote:
> On Tue, Jul 14, 2015 at 12:55:11PM -0700, 'Christoph Hellwig' wrote:
>> On Tue, Jul 14, 2015 at 02:32:31PM -0500, Steve Wise wrote:
>>> You mean "should not", yea?
>>>
>>> Ok.  I'll check for iWARP.  But don't tell me to remove the transport-specific hacks in this series when I post it! ;)
>>
>> Just curious if there are any holes in this little scheme to deal with
>> the lkey mess:
>>
>>   (1) make sure all drivers that currently do not set
>>       IB_DEVICE_LOCAL_DMA_LKEY but which can safely use ib_get_dma_mr
>>       call it underneath at device setup time, and tear it down before
>>       removal.
>
> Yes, I'd like this.
>
> local_dma_lkey appears to be global, it works with any PD.

Only if it's supported, right? There's an attribute that a provider uses
to expose it. For example, I would not expect a virtualized provider to
be able to support this.

>
> ib_get_dma_mr is tied to a PD, so it cannot replace local_dma_lkey at
> the struct device level.

Correct, and by design, in fact. In most implementations, a different
token is returned for each call, in fact.


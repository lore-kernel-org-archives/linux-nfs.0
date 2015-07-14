Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from p3plsmtpa11-06.prod.phx3.secureserver.net ([68.178.252.107]:34871
	"EHLO p3plsmtpa11-06.prod.phx3.secureserver.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753238AbbGNUqb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 14 Jul 2015 16:46:31 -0400
Message-ID: <55A57521.8030804@talpey.com>
Date: Tue, 14 Jul 2015 16:46:25 -0400
From: Tom Talpey <tom@talpey.com>
MIME-Version: 1.0
To: Steve Wise <swise@opengridcomputing.com>,
        "'Jason Gunthorpe'" <jgunthorpe@obsidianresearch.com>
CC: "'Sagi Grimberg'" <sagig@dev.mellanox.co.il>,
        "'Steve Wise'" <swise@ogc.us>, "'Doug Ledford'" <dledford@redhat.com>,
        "'Christoph Hellwig'" <hch@infradead.org>, sagig@mellanox.com,
        ogerlitz@mellanox.com, roid@mellanox.com, linux-rdma@vger.kernel.org,
        eli@mellanox.com, target-devel@vger.kernel.org,
        linux-nfs@vger.kernel.org, trond.myklebust@primarydata.com,
        bfields@fieldses.org, "'Oren Duer'" <oren@mellanox.com>
Subject: Re: [PATCH V3 1/5] RDMA/core: Transport-independent access flags
References: <20150708190842.GB11740@obsidianresearch.com> <20150708203205.GA21847@infradead.org> <20150709000337.GE16812@obsidianresearch.com> <559EF332.7060103@redhat.com> <20150709225306.GA30741@obsidianresearch.com> <559FC710.1050307@talpey.com> <20150710161108.GA19042@obsidianresearch.com> <CCB6E837-88FF-4DBB-976D-4CF56396A1A1@ogc.us> <55A24571.60902@dev.mellanox.co.il> <00e201d0be6a$e49bc910$add35b30$@opengridcomputing.com> <20150714192941.GA26292@obsidianresearch.com> <00e401d0be6b$d3952750$7abf75f0$@opengridcomputing.com>
In-Reply-To: <00e401d0be6b$d3952750$7abf75f0$@opengridcomputing.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 7/14/2015 3:32 PM, Steve Wise wrote:
>>
>> On Tue, Jul 14, 2015 at 02:25:50PM -0500, Steve Wise wrote:
>>
>>> The benefit is that we don't have to check for iWARP protocol in the
>>> ULP.
>>
>> IB should have to pay the cost of FRMR for lkey on RDMA READ, I'm
>> pretty sure you have to check for iWarp at somepoint..
>>
>
> You mean "should not", yea?
>
> Ok.  I'll check for iWARP.  But don't tell me to remove the transport-specific hacks in this series when I post it! ;)
>

FYI, in the Windows NDKPI (verbs-like kernel provider interface), there
is a device attribute defined as follows:

<https://msdn.microsoft.com/en-us/library/windows/hardware/hh439851(v=vs.85).aspx>

NDK_ADAPTER_FLAG_RDMA_READ_SINK_NOT_REQUIRED 0x00000002

Set if the provider does not require special access rights on the sink
buffer for an RDMA read request. When this flag is set, the consumer is
not required to use the NDK_MR_FLAG_RDMA_READ_SINK or
NDK_OP_FLAG_RDMA_READ_SINK flags when it registers sink buffers for
RDMA read requests. The consumer can also use logical address mappings
directly (with a token obtained with the
NDK_FN_GET_PRIVILEGED_MEMORY_REGION_TOKEN function) as RDMA read sink
buffers. This is similar to access to local buffers for RDMA write,
send, and receive operations.




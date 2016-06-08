Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from p3plsmtpa11-04.prod.phx3.secureserver.net ([68.178.252.105]:42411
	"EHLO p3plsmtpa11-04.prod.phx3.secureserver.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1423712AbcFHSwY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 8 Jun 2016 14:52:24 -0400
Subject: Re: [PATCH v1 09/20] xprtrdma: Limit the number of rpcrdma_mws
To: Chuck Lever <chuck.lever@oracle.com>,
        Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
References: <20160607194001.18401.88592.stgit@manet.1015granger.net>
 <20160607194732.18401.71941.stgit@manet.1015granger.net>
 <20160607204941.GA7991@obsidianresearch.com>
 <F1820E16-A2BF-4529-A5C9-59C9AD57369A@oracle.com>
 <20160607212831.GA9192@obsidianresearch.com>
 <D90190F5-ACCB-45D8-B08D-B75023ED6240@oracle.com>
 <20160607220107.GA9982@obsidianresearch.com>
 <c43e37cd-71ea-8629-20f2-bcd674d50b83@talpey.com>
 <8FF9BF11-C5BF-4418-9A84-AAD7A6D6321D@primarydata.com>
 <20160608174014.GB30822@obsidianresearch.com>
 <240BF8C6-AB80-4A27-8C38-1FE9BB02AD66@oracle.com>
Cc: Trond Myklebust <trondmy@primarydata.com>,
        linux-rdma <linux-rdma@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
From: Tom Talpey <tom@talpey.com>
Message-ID: <779423d0-3ba2-b534-66cd-54d585baae94@talpey.com>
Date: Wed, 8 Jun 2016 14:45:03 -0400
MIME-Version: 1.0
In-Reply-To: <240BF8C6-AB80-4A27-8C38-1FE9BB02AD66@oracle.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 6/8/2016 1:53 PM, Chuck Lever wrote:
>
>> On Jun 8, 2016, at 1:40 PM, Jason Gunthorpe <jgunthorpe@obsidianresearch.com> wrote:
>>
>> On Wed, Jun 08, 2016 at 03:06:56PM +0000, Trond Myklebust wrote:
>>
>>>   That would be a mount parameter which would only apply to RDMA since
>>>   everything else uses dynamic slot allocation these days. Iād prefer to
>>>   avoid that.
>>
>> The only reason RDMA cannot allocate MRs on the fly is
>> performance.. Maybe a dynamic scheme is the right answer..
>
> Dynamically managing the MR free list should be straightforward:
>
> 1. Allocate a minimum number of MRs at transport creation time
>
> 2. If workload causes the transport to exhaust its supply of
>     MRs, kick a worker thread to create some more
>
> 3. Maybe add a shrinker that can trim the MR list when the
>     system is under memory pressure

SMB Direct in Windows Server 2012R2 does this, and it works
extremely well. We reduced MR demand by approximately a factor
of 50, since it's rare that many connections are active at
high queue depths.

Tom.


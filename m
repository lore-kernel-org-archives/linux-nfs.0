Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:32070 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753011AbcFHRyI convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 8 Jun 2016 13:54:08 -0400
Content-Type: text/plain; charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [PATCH v1 09/20] xprtrdma: Limit the number of rpcrdma_mws
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20160608174014.GB30822@obsidianresearch.com>
Date: Wed, 8 Jun 2016 13:53:53 -0400
Cc: Trond Myklebust <trondmy@primarydata.com>, Tom Talpey <tom@talpey.com>,
        linux-rdma <linux-rdma@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <240BF8C6-AB80-4A27-8C38-1FE9BB02AD66@oracle.com>
References: <20160607194001.18401.88592.stgit@manet.1015granger.net> <20160607194732.18401.71941.stgit@manet.1015granger.net> <20160607204941.GA7991@obsidianresearch.com> <F1820E16-A2BF-4529-A5C9-59C9AD57369A@oracle.com> <20160607212831.GA9192@obsidianresearch.com> <D90190F5-ACCB-45D8-B08D-B75023ED6240@oracle.com> <20160607220107.GA9982@obsidianresearch.com> <c43e37cd-71ea-8629-20f2-bcd674d50b83@talpey.com> <8FF9BF11-C5BF-4418-9A84-AAD7A6D6321D@primarydata.com> <20160608174014.GB30822@obsidianresearch.com>
To: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Jun 8, 2016, at 1:40 PM, Jason Gunthorpe <jgunthorpe@obsidianresearch.com> wrote:
> 
> On Wed, Jun 08, 2016 at 03:06:56PM +0000, Trond Myklebust wrote:
> 
>>   That would be a mount parameter which would only apply to RDMA since
>>   everything else uses dynamic slot allocation these days. Iād prefer to
>>   avoid that.
> 
> The only reason RDMA cannot allocate MRs on the fly is
> performance.. Maybe a dynamic scheme is the right answer..

Dynamically managing the MR free list should be straightforward:

1. Allocate a minimum number of MRs at transport creation time

2. If workload causes the transport to exhaust its supply of
    MRs, kick a worker thread to create some more

3. Maybe add a shrinker that can trim the MR list when the
    system is under memory pressure


--
Chuck Lever




Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wm0-f47.google.com ([74.125.82.47]:33884 "EHLO
	mail-wm0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751127AbbKZKB3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Nov 2015 05:01:29 -0500
Received: by wmvv187 with SMTP id v187so23389188wmv.1
        for <linux-nfs@vger.kernel.org>; Thu, 26 Nov 2015 02:01:28 -0800 (PST)
Subject: Re: Future of FMR support, was: Re: [PATCH v1 5/9] xprtrdma: Add
 ro_unmap_sync method for FMR
To: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>,
        santosh shilimkar <santosh.shilimkar@oracle.com>
References: <20151123220627.32702.62667.stgit@manet.1015granger.net>
 <20151123221430.32702.86114.stgit@manet.1015granger.net>
 <5653B606.3070700@talpey.com> <20151124065225.GB29141@infradead.org>
 <5654DC7A.7080807@oracle.com> <20151125090009.GA11255@infradead.org>
 <5655EB40.8070508@oracle.com> <20151125192824.GD3223@obsidianresearch.com>
Cc: Christoph Hellwig <hch@infradead.org>, Tom Talpey <tom@talpey.com>,
        Chuck Lever <chuck.lever@oracle.com>, linux-rdma@vger.kernel.org,
        linux-nfs@vger.kernel.org, Sagi Grimberg <sagig@mellanox.com>
From: Sagi Grimberg <sagig@dev.mellanox.co.il>
Message-ID: <5656D874.8060500@dev.mellanox.co.il>
Date: Thu, 26 Nov 2015 12:01:24 +0200
MIME-Version: 1.0
In-Reply-To: <20151125192824.GD3223@obsidianresearch.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 25/11/2015 21:28, Jason Gunthorpe wrote:
> On Wed, Nov 25, 2015 at 09:09:20AM -0800, santosh shilimkar wrote:
>>> I'd say drop the current iWarp transport if it's not testable.  The
>>> only real difference between IB and iWarp is the needed to create
>>> a MR for the RDMA READ sink, and we're much better of adding that into
>>> the current IB transport if new iWarp users show up.
>>
>> Agree. I will probably do it along with RDS IB FR support in 4.6
>
> Great news!

Great news indeed!

Looking forward to seeing this.

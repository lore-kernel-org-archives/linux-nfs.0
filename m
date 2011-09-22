Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from natasha.panasas.com ([67.152.220.90]:55201 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751001Ab1IVHRd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 22 Sep 2011 03:17:33 -0400
Message-ID: <4E7AE0FD.2070702@panasas.com>
Date: Thu, 22 Sep 2011 10:17:17 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
CC: Peng Tao <bergwolf@gmail.com>, Benny Halevy <bhalevy@tonian.com>,
        <tao.peng@emc.com>, <linux-nfs@vger.kernel.org>,
        <honey@citi.umich.edu>, <rees@umich.edu>
Subject: Re: [PATCH 2/3] pnfs: introduce pnfs private workqueue
References: <1316488728-24912-1-git-send-email-rees@umich.edu>  <1316488728-24912-3-git-send-email-rees@umich.edu>  <1316558461.15093.4.camel@lade.trondhjem.org>  <20110921002917.GA30770@merit.edu>  <F19688880B763E40B28B2B462677FBF805C4952916@MX09A.corp.emc.com>  <2E1EB2CF9ED1CB4AA966F0EB76EAB4430B480226@SACMVEXC2-PRD.hq.netapp.com>  <F19688880B763E40B28B2B462677FBF805C495295A@MX09A.corp.emc.com>  <4E798C93.40409@tonian.com>  <F19688880B763E40B28B2B462677FBF805C4952A24@MX09A.corp.emc.com>  <4E79C2F0.30303@tonian.com>  <F19688880B763E40B28B2B462677FBF805C4952A34@MX09A.corp.emc.com>  <4E79CA34.3060602@tonian.com> <4E79CD8F.6050901@panasas.com>  <4E79CFA3.4090403@tonian.com> <4E79ED02.5010104@panasas.com>  <CA+a=Yy7PNsrQQdc9nwn1+2bZu86s8xUa9NBXVeo7NecGkc9-VQ@mail.gmail.com> <1316621016.21183.11.camel@lade.trondhjem.org>
In-Reply-To: <1316621016.21183.11.camel@lade.trondhjem.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 09/21/2011 07:03 PM, Trond Myklebust wrote:
>>>
>>> These are the options so far:
>>>
>>> [Toe's option which he rather not]
>>> 1. preallocate memory for extent state conversion
>>> 2. use nfsiod/rpciod to handle bl_write_cleanup
>>> 3. for pnfs error case, create a kthread to recollapse and resend to MDS
>>>
>>> [My option which I think Toe agrees with]
>>> 1. preallocate memory for extent state conversion
>>> 2. use pnfs-wq to handle bl_write_cleanup
>>> 3. pnfs error case, just like Toe's patches as part of io_done
>>>   on pnfs-wq
>> Yeah, I would vote for this one because of its simplicity. ;-)
> 
> Sigh... The problem is that it completely fails to address the problem.
> 
> What's the difference between having pNFS completions run on nfsiod or
> their own work queue? You'd be running i/o and allocations on the same
> queue in both cases.
> 

I don't understand, did you mean "io_done" and "coalescing" (which
does allocations), so IO cannot complete to clean up memory so
allocations can proceed?

But I thought we don't do that with Toe's latest patches. because
we no longer do coalescing on the io_done path. We only re-dirty the
memory and let the normal nfsiod/rpciod do the coalescing.

So it is what you want pnfs-wq is only for io_done the regular
coalescing/allocation is done in fsiod/rpciod. I though that
was the all Idea no? (It was your idea actually)

Or I might completely missed the point. Please explain

> Cheers
> Trond
> 

Thanks
Boaz

Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:26400 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932197AbbKXVyk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 24 Nov 2015 16:54:40 -0500
Subject: Re: Future of FMR support, was: Re: [PATCH v1 5/9] xprtrdma: Add
 ro_unmap_sync method for FMR
To: Christoph Hellwig <hch@infradead.org>, Tom Talpey <tom@talpey.com>
References: <20151123220627.32702.62667.stgit@manet.1015granger.net>
 <20151123221430.32702.86114.stgit@manet.1015granger.net>
 <5653B606.3070700@talpey.com> <20151124065225.GB29141@infradead.org>
Cc: Chuck Lever <chuck.lever@oracle.com>, linux-rdma@vger.kernel.org,
        linux-nfs@vger.kernel.org, Sagi Grimberg <sagig@mellanox.com>
From: santosh shilimkar <santosh.shilimkar@oracle.com>
Message-ID: <5654DC7A.7080807@oracle.com>
Date: Tue, 24 Nov 2015 13:54:02 -0800
MIME-Version: 1.0
In-Reply-To: <20151124065225.GB29141@infradead.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Christoph,

On 11/23/2015 10:52 PM, Christoph Hellwig wrote:
> On Mon, Nov 23, 2015 at 07:57:42PM -0500, Tom Talpey wrote:
>> On 11/23/2015 5:14 PM, Chuck Lever wrote:
>>> FMR's ro_unmap method is already synchronous because ib_unmap_fmr()
>>> is a synchronous verb. However, some improvements can be made here.
>>
>> I thought FMR support was about to be removed in the core.
>
> Seems like everyone would love to kill it, but no one dares to do
> it just yet.  Reasons to keep FMRs:
>
>   - mthca doesn't support FRs but haven't been staged out
>   - RDS only supports FRMs for the IB transports (it does support FRs for
>     an entirely separate iWarp transports.  I'd love to know why we can't
>     just use that iWarp transport for IB as well).
>   - mlx4 hardware might be slower with FRs than FRMs (Or mentioned this
>     in reply to the iSER remote invalidation series).
>
> So at lest for 4.5 we're unlikely to be able to get rid of it alone
> due to the RDS issue.  We'll then need performance numbers for mlx4,
> and figure out how much we care about mthca.
>
As already indicated to Sagi [1], RDS IB FR support is work in
progress and I was hoping to get it ready for 4.5. There are few
issues we found with one of the HCA and hence the progress
slowed down. Looking at where we are, 4.6 merge window seems
to be realistic for me to get RDS FR support.

Now on the iWARP transport itself, it has been bit tough because
of lack of hardware to tests. I have been requesting test(s) in
previous RDS patches and haven't seen any interest so far. If
this continues to be the trend, I might as well get rid of
RDS iWARP support after couple of merge windows.

Regards,
Santosh
[1] http://www.spinics.net/lists/linux-nfs/msg53909.html

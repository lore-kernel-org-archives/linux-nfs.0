Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:43861 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750726AbbKYRJ7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 25 Nov 2015 12:09:59 -0500
Subject: Re: Future of FMR support, was: Re: [PATCH v1 5/9] xprtrdma: Add
 ro_unmap_sync method for FMR
To: Christoph Hellwig <hch@infradead.org>
References: <20151123220627.32702.62667.stgit@manet.1015granger.net>
 <20151123221430.32702.86114.stgit@manet.1015granger.net>
 <5653B606.3070700@talpey.com> <20151124065225.GB29141@infradead.org>
 <5654DC7A.7080807@oracle.com> <20151125090009.GA11255@infradead.org>
Cc: Tom Talpey <tom@talpey.com>, Chuck Lever <chuck.lever@oracle.com>,
        linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org,
        Sagi Grimberg <sagig@mellanox.com>
From: santosh shilimkar <santosh.shilimkar@oracle.com>
Message-ID: <5655EB40.8070508@oracle.com>
Date: Wed, 25 Nov 2015 09:09:20 -0800
MIME-Version: 1.0
In-Reply-To: <20151125090009.GA11255@infradead.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 11/25/2015 1:00 AM, Christoph Hellwig wrote:
> On Tue, Nov 24, 2015 at 01:54:02PM -0800, santosh shilimkar wrote:
>> As already indicated to Sagi [1], RDS IB FR support is work in
>> progress and I was hoping to get it ready for 4.5. There are few
>> issues we found with one of the HCA and hence the progress
>> slowed down. Looking at where we are, 4.6 merge window seems
>> to be realistic for me to get RDS FR support.
>
> Ok.
>
>> Now on the iWARP transport itself, it has been bit tough because
>> of lack of hardware to tests. I have been requesting test(s) in
>> previous RDS patches and haven't seen any interest so far. If
>> this continues to be the trend, I might as well get rid of
>> RDS iWARP support after couple of merge windows.
>
> I'd say drop the current iWarp transport if it's not testable.  The
> only real difference between IB and iWarp is the needed to create
> a MR for the RDMA READ sink, and we're much better of adding that into
> the current IB transport if new iWarp users show up.

Agree. I will probably do it along with RDS IB FR support in 4.6

Regards,
Santosh

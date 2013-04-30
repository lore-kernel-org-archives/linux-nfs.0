Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp.opengridcomputing.com ([72.48.136.20]:42249 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933457Ab3D3S6h (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 30 Apr 2013 14:58:37 -0400
Message-ID: <5180145A.5030305@opengridcomputing.com>
Date: Tue, 30 Apr 2013 13:58:34 -0500
From: Tom Tucker <tom@opengridcomputing.com>
MIME-Version: 1.0
To: Yan Burman <yanb@mellanox.com>
CC: Tom Talpey <tom@talpey.com>, "J. Bruce Fields" <bfields@fieldses.org>,
        Wendy Cheng <s.wendy.cheng@gmail.com>,
        "Atchley, Scott" <atchleyes@ornl.gov>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: NFS over RDMA benchmark
References: <0EE9A1CDC8D6434DB00095CD7DB873462CF96C65@MTLDAG01.mtl.com> <CABgxfbF7c9ktSoMSPV21JU76V5J4iwbJQ257S91Y3z36WJbJVA@mail.gmail.com> <62745258-4F3B-4C05-BFFD-03EA604576E4@ornl.gov> <CABgxfbGxhnKj2n0Z-w87rZ6fwCssO31G009gwej957gv1p8PQQ@mail.gmail.com> <0EE9A1CDC8D6434DB00095CD7DB873462CF9715B@MTLDAG01.mtl.com> <20130423210607.GJ3676@fieldses.org> <0EE9A1CDC8D6434DB00095CD7DB873462CF988C9@MTLDAG01.mtl.com> <20130424150540.GB20275@fieldses.org> <20130424152631.GC20275@fieldses.org> <0EE9A1CDC8D6434DB00095CD7DB873462CF9A820@MTLDAG01.mtl.com> <20130428144248.GA2037@fieldses.org> <0EE9A1CDC8D6434DB00095CD7DB873462CF9C90C@MTLDAG01.mtl.com> <517FD327.3060901@talpey.com> <0EE9A1CDC8D6434DB00095CD7DB873462CF9CBD0@MTLDAG01.mtl.com>
In-Reply-To: <0EE9A1CDC8D6434DB00095CD7DB873462CF9CBD0@MTLDAG01.mtl.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 4/30/13 9:38 AM, Yan Burman wrote:
>
>> -----Original Message-----
>> From: Tom Talpey [mailto:tom@talpey.com]
>> Sent: Tuesday, April 30, 2013 17:20
>> To: Yan Burman
>> Cc: J. Bruce Fields; Wendy Cheng; Atchley, Scott; Tom Tucker; linux-
>> rdma@vger.kernel.org; linux-nfs@vger.kernel.org; Or Gerlitz
>> Subject: Re: NFS over RDMA benchmark
>>
>> On 4/30/2013 1:09 AM, Yan Burman wrote:
>>> I now get up to ~95K IOPS and 4.1GB/sec bandwidth.
>>> ...
>>>   ib_send_bw with intel iommu enabled did get up to 4.5GB/sec
>> BTW, you may want to verify that these are the same GB. Many benchmarks
>> say KB/MB/GB when they really mean KiB/MiB/GiB.
>>
>> At GB/GiB, the difference is about 7.5%, very close to the difference between
>> 4.1 and 4.5.
>>
>> Just a thought.
> The question is not why there is 400MBps difference between ib_send_bw and NFSoRDMA.
> The question is why with IOMMU ib_send_bw got to the same bandwidth as without it while NFSoRDMA got half.
NFSRDMA is constantly registering and unregistering memory when you use 
FRMR mode. By contrast IPoIB has a descriptor ring that is set up once 
and re-used. I suspect this is the difference maker. Have you tried 
running the server in ALL_PHYSICAL mode, i.e. where it uses a DMA_MR for 
all of memory?

Tom
> >From some googling, it seems that when IOMMU is enabled, dma mapping functions get a lot more expensive.
> Perhaps that is the reason for the performance drop.
>
> Yan


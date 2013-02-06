Return-Path: linux-nfs-owner@vger.kernel.org
Received: from ndmsnpf02.ndc.nasa.gov ([198.117.0.122]:44741 "EHLO
	ndmsnpf02.ndc.nasa.gov" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757454Ab3BFR10 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 6 Feb 2013 12:27:26 -0500
Message-ID: <51128DAC.9000206@nasa.gov>
Date: Wed, 6 Feb 2013 09:06:52 -0800
From: Jeff Becker <jeffrey.c.becker@nasa.gov>
MIME-Version: 1.0
To: Steve Wise <swise@opengridcomputing.com>
CC: Yan Burman <yanb@mellanox.com>,
        "bfields@fieldses.org" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Tom Tucker <tom@opengridcomputing.com>
Subject: Re: NFS over RDMA crashing
References: <51127B3F.2090200@mellanox.com> <51127DB1.6070804@opengridcomputing.com>
In-Reply-To: <51127DB1.6070804@opengridcomputing.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi. In case you're interested, I did the NFS/RDMA backports for OFED. I 
tested that NFS/RDMA in OFED 3.5 works on kernel 3.5, and also the RHEL 
6.3 kernel. However, I did not test it with SRIOV. If you test it 
(OFED-3.5-rc6 was released last week), I'd like to know how it goes. Thanks.

Jeff Becker

On 02/06/2013 07:58 AM, Steve Wise wrote:
> On 2/6/2013 9:48 AM, Yan Burman wrote:
>> When I moved to commit 79f77bf9a4e3dd5ead006b8f17e7c4ff07d8374e I was
>> no longer getting the server crashes,
>> so the reset of my tests were done using that point (it is somewhere
>> in the middle of 3.7.0-rc2)
>>
> +tom tucker
>
> I'd try going back a few kernels, like to 3.5.x and see if things are
> more stable.  If you find a point that works, then git bisect might help
> identify the regression.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


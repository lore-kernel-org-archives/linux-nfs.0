Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-we0-f171.google.com ([74.125.82.171]:65098 "EHLO
	mail-we0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S967447Ab3DSC2M convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 18 Apr 2013 22:28:12 -0400
MIME-Version: 1.0
In-Reply-To: <0EE9A1CDC8D6434DB00095CD7DB873462CF96C65@MTLDAG01.mtl.com>
References: <0EE9A1CDC8D6434DB00095CD7DB873462CF96C65@MTLDAG01.mtl.com>
From: Peng Tao <bergwolf@gmail.com>
Date: Fri, 19 Apr 2013 10:27:50 +0800
Message-ID: <CA+a=Yy7zruyGbjLyYXtPsYs12xs1uCwXo9BJtU1Fg6OMoC2z6g@mail.gmail.com>
Subject: Re: NFS over RDMA benchmark
To: Yan Burman <yanb@mellanox.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Tom Tucker <tom@opengridcomputing.com>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Apr 17, 2013 at 10:36 PM, Yan Burman <yanb@mellanox.com> wrote:
> Hi.
>
> I've been trying to do some benchmarks for NFS over RDMA and I seem to only get about half of the bandwidth that the HW can give me.
> My setup consists of 2 servers each with 16 cores, 32Gb of memory, and Mellanox ConnectX3 QDR card over PCI-e gen3.
> These servers are connected to a QDR IB switch. The backing storage on the server is tmpfs mounted with noatime.
> I am running kernel 3.5.7.
>
> When running ib_send_bw, I get 4.3-4.5 GB/sec for block sizes 4-512K.
> When I run fio over rdma mounted nfs, I get 260-2200MB/sec for the same block sizes (4-512K). running over IPoIB-CM, I get 200-980MB/sec.
> I got to these results after the following optimizations:
> 1. Setting IRQ affinity to the CPUs that are part of the NUMA node the card is on
> 2. Increasing /proc/sys/sunrpc/svc_rdma/max_outbound_read_requests and /proc/sys/sunrpc/svc_rdma/max_requests to 256 on server
> 3. Increasing RPCNFSDCOUNT to 32 on server
Did you try to affine nfsd to corresponding CPUs where your IB card
locates? Given that you see a bottleneck on CPU (as in your later
email), it might be worth trying.

> 4. FIO arguments: --rw=randread --bs=4k --numjobs=2 --iodepth=128 --ioengine=libaio --size=100000k --prioclass=1 --prio=0 --cpumask=255 --loops=25 --direct=1 --invalidate=1 --fsync_on_close=1 --randrepeat=1 --norandommap --group_reporting --exitall --buffered=0
>
On client side, it may be good to affine FIO processes and nfsiod to
CPUs where IB card locates as well, in case client is the bottleneck.

--
Thanks,
Tao

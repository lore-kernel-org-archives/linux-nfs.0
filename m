Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mta01.ornl.gov ([128.219.177.14]:31185 "EHLO mta01.ornl.gov"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965732Ab3DQRmj convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 17 Apr 2013 13:42:39 -0400
From: "Atchley, Scott" <atchleyes@ornl.gov>
To: Wendy Cheng <s.wendy.cheng@gmail.com>
CC: Yan Burman <yanb@mellanox.com>, "J. Bruce Fields" <bfields@fieldses.org>,
        Tom Tucker <tom@opengridcomputing.com>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Date: Wed, 17 Apr 2013 13:32:48 -0400
Subject: Re: NFS over RDMA benchmark
Message-ID: <62745258-4F3B-4C05-BFFD-03EA604576E4@ornl.gov>
References: <0EE9A1CDC8D6434DB00095CD7DB873462CF96C65@MTLDAG01.mtl.com>
 <CABgxfbF7c9ktSoMSPV21JU76V5J4iwbJQ257S91Y3z36WJbJVA@mail.gmail.com>
In-Reply-To: <CABgxfbF7c9ktSoMSPV21JU76V5J4iwbJQ257S91Y3z36WJbJVA@mail.gmail.com>
Content-Type: text/plain; charset=US-ASCII
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Apr 17, 2013, at 1:15 PM, Wendy Cheng <s.wendy.cheng@gmail.com> wrote:

> On Wed, Apr 17, 2013 at 7:36 AM, Yan Burman <yanb@mellanox.com> wrote:
>> Hi.
>> 
>> I've been trying to do some benchmarks for NFS over RDMA and I seem to only get about half of the bandwidth that the HW can give me.
>> My setup consists of 2 servers each with 16 cores, 32Gb of memory, and Mellanox ConnectX3 QDR card over PCI-e gen3.
>> These servers are connected to a QDR IB switch. The backing storage on the server is tmpfs mounted with noatime.
>> I am running kernel 3.5.7.
>> 
>> When running ib_send_bw, I get 4.3-4.5 GB/sec for block sizes 4-512K.
>> When I run fio over rdma mounted nfs, I get 260-2200MB/sec for the same block sizes (4-512K). running over IPoIB-CM, I get 200-980MB/sec.

Yan,

Are you trying to optimize single client performance or server performance with multiple clients?


> Remember there are always gaps between wire speed (that ib_send_bw
> measures) and real world applications.
> 
> That being said, does your server use default export (sync) option ?
> Export the share with "async" option can bring you closer to wire
> speed. However, the practice (async) is generally not recommended in a
> real production system - as it can cause data integrity issues, e.g.
> you have more chances to lose data when the boxes crash.
> 
> -- Wendy


Wendy,

It has a been a few years since I looked at RPCRDMA, but I seem to remember that RPCs were limited to 32KB which means that you have to pipeline them to get linerate. In addition to requiring pipelining, the argument from the authors was that the goal was to maximize server performance and not single client performance.

Scott


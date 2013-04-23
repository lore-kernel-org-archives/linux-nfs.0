Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:48455 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755875Ab3DWVGN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 23 Apr 2013 17:06:13 -0400
Date: Tue, 23 Apr 2013 17:06:07 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Yan Burman <yanb@mellanox.com>
Cc: Wendy Cheng <s.wendy.cheng@gmail.com>,
        "Atchley, Scott" <atchleyes@ornl.gov>,
        Tom Tucker <tom@opengridcomputing.com>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: NFS over RDMA benchmark
Message-ID: <20130423210607.GJ3676@fieldses.org>
References: <0EE9A1CDC8D6434DB00095CD7DB873462CF96C65@MTLDAG01.mtl.com>
 <CABgxfbF7c9ktSoMSPV21JU76V5J4iwbJQ257S91Y3z36WJbJVA@mail.gmail.com>
 <62745258-4F3B-4C05-BFFD-03EA604576E4@ornl.gov>
 <CABgxfbGxhnKj2n0Z-w87rZ6fwCssO31G009gwej957gv1p8PQQ@mail.gmail.com>
 <0EE9A1CDC8D6434DB00095CD7DB873462CF9715B@MTLDAG01.mtl.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <0EE9A1CDC8D6434DB00095CD7DB873462CF9715B@MTLDAG01.mtl.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Apr 18, 2013 at 12:47:09PM +0000, Yan Burman wrote:
> 
> 
> > -----Original Message-----
> > From: Wendy Cheng [mailto:s.wendy.cheng@gmail.com]
> > Sent: Wednesday, April 17, 2013 21:06
> > To: Atchley, Scott
> > Cc: Yan Burman; J. Bruce Fields; Tom Tucker; linux-rdma@vger.kernel.org;
> > linux-nfs@vger.kernel.org
> > Subject: Re: NFS over RDMA benchmark
> > 
> > On Wed, Apr 17, 2013 at 10:32 AM, Atchley, Scott <atchleyes@ornl.gov>
> > wrote:
> > > On Apr 17, 2013, at 1:15 PM, Wendy Cheng <s.wendy.cheng@gmail.com>
> > wrote:
> > >
> > >> On Wed, Apr 17, 2013 at 7:36 AM, Yan Burman <yanb@mellanox.com>
> > wrote:
> > >>> Hi.
> > >>>
> > >>> I've been trying to do some benchmarks for NFS over RDMA and I seem to
> > only get about half of the bandwidth that the HW can give me.
> > >>> My setup consists of 2 servers each with 16 cores, 32Gb of memory, and
> > Mellanox ConnectX3 QDR card over PCI-e gen3.
> > >>> These servers are connected to a QDR IB switch. The backing storage on
> > the server is tmpfs mounted with noatime.
> > >>> I am running kernel 3.5.7.
> > >>>
> > >>> When running ib_send_bw, I get 4.3-4.5 GB/sec for block sizes 4-512K.
> > >>> When I run fio over rdma mounted nfs, I get 260-2200MB/sec for the
> > same block sizes (4-512K). running over IPoIB-CM, I get 200-980MB/sec.
> > >
> > > Yan,
> > >
> > > Are you trying to optimize single client performance or server performance
> > with multiple clients?
> > >
> 
> I am trying to get maximum performance from a single server - I used 2 processes in fio test - more than 2 did not show any performance boost.
> I tried running fio from 2 different PCs on 2 different files, but the sum of the two is more or less the same as running from single client PC.
> 
> What I did see is that server is sweating a lot more than the clients and more than that, it has 1 core (CPU5) in 100% softirq tasklet:
> cat /proc/softirqs

Would any profiling help figure out which code it's spending time in?
(E.g. something simple as "perf top" might have useful output.)

--b.

>                     CPU0       CPU1       CPU2       CPU3       CPU4       CPU5       CPU6       CPU7       CPU8       CPU9       CPU10      CPU11      CPU12      CPU13      CPU14      CPU15
>           HI:          0          0          0          0          0          0          0          0          0          0          0          0          0          0          0          0
>        TIMER:     418767      46596      43515      44547      50099      34815      40634      40337      39551      93442      73733      42631      42509      41592      40351      61793
>       NET_TX:      28719        309       1421       1294       1730       1243        832        937         11         44         41         20         26         19         15         29
>       NET_RX:     612070         19         22         21          6        235          3          2          9          6         17         16         20         13         16         10
>        BLOCK:       5941          0          0          0          0          0          0          0        519        259       1238        272        253        174        215       2618
> BLOCK_IOPOLL:          0          0          0          0          0          0          0          0          0          0          0          0          0          0          0          0
>      TASKLET:         28          1          1          1          1    1540653          1          1         29          1          1          1          1          1          1          2
>        SCHED:     364965      26547      16807      18403      22919       8678      14358      14091      16981      64903      47141      18517      19179      18036      17037      38261
>      HRTIMER:         13          0          1          1          0          0          0          0          0          0          0          0          1          1          0          1
>          RCU:     945823     841546     715281     892762     823564      42663     863063     841622     333577     389013     393501     239103     221524     258159     313426     234030
> > >
> > >> Remember there are always gaps between wire speed (that ib_send_bw
> > >> measures) and real world applications.
> 
> I realize that, but I don't expect the difference to be more than twice.
> 
> > >>
> > >> That being said, does your server use default export (sync) option ?
> > >> Export the share with "async" option can bring you closer to wire
> > >> speed. However, the practice (async) is generally not recommended in
> > >> a real production system - as it can cause data integrity issues, e.g.
> > >> you have more chances to lose data when the boxes crash.
> 
> I am running with async export option, but that should not matter too much, since my backing storage is tmpfs mounted with noatime.
> 
> > >>
> > >> -- Wendy
> > >
> > >
> > > Wendy,
> > >
> > > It has a been a few years since I looked at RPCRDMA, but I seem to
> > remember that RPCs were limited to 32KB which means that you have to
> > pipeline them to get linerate. In addition to requiring pipelining, the
> > argument from the authors was that the goal was to maximize server
> > performance and not single client performance.
> > >
> 
> What I see is that performance increases almost linearly up to block size 256K and falls a little at block size 512K
> 
> > > Scott
> > >
> > 
> > That (client count) brings up a good point ...
> > 
> > FIO is really not a good benchmark for NFS. Does anyone have SPECsfs
> > numbers on NFS over RDMA to share ?
> > 
> > -- Wendy
> 
> What do you suggest for benchmarking NFS?
> 
> Yan
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

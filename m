Return-Path: linux-nfs-owner@vger.kernel.org
Received: from userp1040.oracle.com ([156.151.31.81]:45210 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755125AbaKTSYf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 20 Nov 2014 13:24:35 -0500
Message-ID: <546E31C0.1070400@oracle.com>
Date: Thu, 20 Nov 2014 10:24:00 -0800
From: Shirley Ma <shirley.ma@oracle.com>
MIME-Version: 1.0
To: "Charles EDWARD Lever" <chuck.lever@oracle.com>,
        "Anna.Schumaker@netapp.com" <Anna.Schumaker@netapp.com>,
        "Devesh.Sharma@emulex.com" <Devesh.Sharma@emulex.com>,
        "dledford@redhat.com" <dledford@redhat.com>,
        "dominique.martinet@cea.fr" <dominique.martinet@cea.fr>,
        "jeffrey.c.becker@nasa.gov" <jeffrey.c.becker@nasa.gov>,
        "rsdance@soft-forge.com" <rsdance@soft-forge.com>,
        "skc@lanl.gov" <skc@lanl.gov>,
        "sprabhu@redhat.com" <sprabhu@redhat.com>,
        "SteveD@redhat.com" <SteveD@redhat.com>,
        "swise@opengridcomputing.com" <swise@opengridcomputing.com>,
        "wendy.cheng@intel.com" <wendy.cheng@intel.com>,
        "yanb@mellanox.com" <yanb@mellanox.com>,
        linux-rdma <linux-rdma@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: NFSoRDMA developers bi-weekly meeting minutes (11/20)
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Attendees:

Jeff Becker (NASA)
Yan Burman (Mellanox)
Wendy Cheng (Intel)
Rupert Dance (Soft Forge)
Steve Dickson (Red Hat)
Chuck Lever (Oracle)
Doug Ledford (RedHat)
Shirley Ma (Oracle)
Sachin Prabhu (RedHat)
Devesh Sharma (Emulex)
Anna Schumaker (Net App)
Steve Wise (OpenGridComputing, Chelsio)

Moderator:
Shirley Ma (Oracle)

NFSoRDMA developers bi-weekly meeting is to help organizing NFSoRDMA development and test effort from different resources to speed up NFSoRDMA upstream kernel work and NFSoRDMA diagnosing/debugging tools development. Hopefully the quality of NFSoRDMA upstream patches can be improved by being tested with a quorum of HW vendors.

Today's meeting notes:

NFSoRDMA performance:
---------------------
Even though NFSoRDMA performance seems better than IPoIB-cm, the gap between what the IB protocol can provide and what NFS(RDMA,IPoIB-cm) can achieve is still big on small I/O block size (focused on 8K IO size for database workload). Even large I/O block size(128K above), NFS performance is not comparable to RDMA microbenchmark. We are focusing the effort to figure out the root cause. Several experimental methods have been used on how to improve NFSoRDMA performance.

Yan saw NFS server does RDMA send for small packet size, less than 100bytes, which should have used post_send instead.

1. performance experimental investigation: (Shirley, Chuck, Yan)
-- multiple QPs support:
Created multiple subnets with different partition keys, different NFS client mount points to stretch single link performance, iozone multiple threading DIO 8K showed around 17% improvement, still a big gap to link speed

-- completion vector loading balance
Split send queue and completion queue interrupts to different CPUs did not help on performance, then created a patch on distributing interrupts among available CPUs for different QPs, send and recv completion share the same completion vector, iozone multiple threading 8K DIO showed that 10% performance improvement

Yan shared iser performance enhancement ideas:
-- batch recv packet processing
-- batch completion processing, not signaling every completion
-- per CPU connection, cq
iser 8K could reach 4.5GB/s in 56Gb/s link speed, 1.5 million IOPS. 32K could reach 1.8 million IOPS
 
-- increasing RPC credit limit from 32 to 64
iozone 8K DIO results doesn't show any gain, which might indicate that we need to look at general NFS IO stack.

-- increasing work queue priority to reduce latency
NFS used work_queue not tasklet since it's in cansleep context, changed the flags to WQ_HIGHPRI | WQ_CPU_INTENSIVE did help reducing the latency when system under heavy workloads. 

-- lock contention
perf top does show lock contention on top five list for both NFS client and NFS server. More granularity lock contention investigation is needed.

-- scheduling latency
IO scheduling was developed for high latency devices, there might be some room in IO scheduling improvement.

-- wsize, rsize
Chuck is looking at wsize, rsize to 1MB

2. performance analysis tools to use: 
-- perf, lockstat, ftrace, mountstats, nfsiostats... 

3. performance test tools:
-- iozone, fio
-- direct IO, cached IO

Next step for performance analysis:
1. Shirley will collect performance data on NFS IO layer to see any bottlenecks there.
2. Someone needs to look at NFS server for RDMA small message size Yan has seen

Feel free to reply here for anything missing. See you 12/4.

12/04/2014
@7:30am PDT
@8:30am MDT
@9:30am CDT
@10:30am EDT
@Bangalore @8:00pm
@Israel @5:30pm

Duration: 1 hour

Call-in number:
Israel: +972 37219638
Bangalore: +91 8039890080 (180030109800)
France  Colombes +33 1 5760 2222    +33 176728936
US: 8666824770,  408-7744073

Conference Code: 2308833
Passcode: 63767362 (it's NFSoRDMA, in case you couldn't remember)

Thanks everyone for joining the call and providing valuable inputs/work to the community to make NFSoRDMA better.

Cheers,
Shirley

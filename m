Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aserp1040.oracle.com ([141.146.126.69]:26810 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751062AbaKFRzy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 6 Nov 2014 12:55:54 -0500
Message-ID: <545BB608.2040401@oracle.com>
Date: Thu, 06 Nov 2014 09:55:20 -0800
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
Subject: NFSoRDMA bi-weekly meeting minutes (11/6)
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Attendees:

Jeff Becker (NASA)
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

Yan Burman(Mellanox) missed the call because of the daylight time change. :(

Moderator:
Shirley Ma (Oracle)

NFSoRDMA developers bi-weekly meeting is to help organizing NFSoRDMA development and test effort from different resources to speed up NFSoRDMA upstream kernel work and NFSoRDMA diagnosing/debugging tools development. Hopefully the quality of NFSoRDMA upstream patches can be improved by being tested with a quorum of HW vendors.

Today's meeting notes:
1. OFA OFA Interop event (Rupert)
The Interop event went pretty well. The test covered IB, RoCE and iWARP with different vendors HW and upsteam/OFED stack. NFSoRDMA IB was included in this test event, however NFSoRDMA RoCE wasn't able to test since the modules were not in the stack yet. The detail report will come in a few weeks.

2. Upstream bugs: (Chuck, Anna, Shirley)
3.17 kernel has a bug in tearing down connection, this bug was hit consistently when enabling multiple EQs in xprtrdma when Shirley run fio multithread random read/write workload. Chuck has a nice patch to this bug, Shirley has validated this fix by stressing the fio overnight. Anna will check to see the possibility to push to the stable tree since it blocks multi-threads NFSoRDMA workload. Here is the link to the bug report:
https://bugzilla.linux-nfs.org/show_bug.cgi?id=276

3. Performance test and analyze tools: (Sachin, Chuck, Wendy, Shirley, SteveW)
Discussed about several tools on analyzing NFSoRDMA performance for both latency and bandwidth:
-- systemTap: Sachine starts to look at how to use systemTap, it requires sometimes to study the tool and create the probe scripts to NFS, RPC, xprtrdma layer.
-- Ftrace: enabling trace modules and functions to report the execution flow latency.
-- perf: report execution flows APIs latency and cpu usage
-- /proc/self/mountstats: report total execution time, RTT and wait time for each RPC. The execution time latency contributes from wake up and wait, which depends on how busy the system is. RPC RTT itself latency is reasonable.

The NFSoRDMA performance relies on both implementation and protocol. We don't know the weight of performance gap from either implementation or protocol yet. RPC seems slow, pNFS might have better performance for supporting multiple queue pairs. Chuck will increase RPC credit limit to see how much performance gain from there. Our performance goal is to look at the implementation issues, then protocols.

Feel free to reply here for anything missing or incorrect. See you on Nov.20th.

10/23/2014
@7:30am PT
@8:30am MT
@9:30am CT
@10:30am ET
@Bangalore @9:00pm
@Israel @6:30pm

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

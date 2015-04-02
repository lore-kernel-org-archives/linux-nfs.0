Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:35717 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753306AbbDBRyE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Apr 2015 13:54:04 -0400
Message-ID: <551D821F.5080006@oracle.com>
Date: Thu, 02 Apr 2015 10:53:35 -0700
From: Shirley Ma <shirley.ma@oracle.com>
MIME-Version: 1.0
To: Charles EDWARD Lever <chuck.lever@oracle.com>,
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
Subject: NFSoRDMA bi-weekly developers meeting minutes (4/2)
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Attendees:

Yan Burman (Mellanox)
Steve Dickson (Red Hat)
Chuck Lever (Oracle)
Shirley Ma (Oracle)
Sachin Prabhu (RedHat)
Devesh Sharma (Emulex)
Anna Schumaker (Net App)
Steve Wise (OpenGridComputing, Chelsio)

Moderator:
Shirley Ma (Oracle)

Today's meeting notes:
Sorry for the late start, it has changed from 7:30am PST time to 8:30am PST time but I didn't notice the change wasn't sent out. :( Thanks for your patient to join the call one hour later.

1. NFSoRDMA deployment:
NFSoRDMA has much better performance than NFSoIPoIB-CM in general. People are looking for both Linux NFSoRDMA client and Server support for deployment, however distros only support NFSoRDMA client at this moment. Developers have been fixing bugs on server side, more dedicated resources on NFSoRDMA server development are needed for stability and performance work. We will continue to improve NFSoRDMA performance and try to find more resources on server side.

2. NFSoRDMA performance
After experimenting performance with different approaches (multiple QPs, different completion vector per QP), we think we should focus on single QP scalability first. Right now small I/O single QP IOPS is around 100K, large I/O single QP NFS READ can reach 3.6GB/s (which almost reaches link speed in the fabric). To identify single QP scalability, here are list of things we can try:
-- Generic RPC dispatching: identify serialized operations to make them paralleled
-- scheduling mechanism: wait_on_bit latency, queue work latency
-- RDMA transport layer: hack poll_cq on both client and server to make pulling longer, like wait for RPC RTT time, wait for more WCs to process more completions to reduce interrupts/wait overheads to see any better results

3. We will cover iSCSI/iSER/SRP in the future discussions.

10/23/2014
@8:30am PT DST
@9:30am MT DST
@10:30am CT DST
@11:30am ET DST
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

Shirley

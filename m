Return-Path: linux-nfs-owner@vger.kernel.org
Received: from userp1040.oracle.com ([156.151.31.81]:30709 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754490AbaJWUql (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 23 Oct 2014 16:46:41 -0400
Message-ID: <54496910.1020100@oracle.com>
Date: Thu, 23 Oct 2014 13:46:08 -0700
From: Shirley Ma <shirley.ma@oracle.com>
MIME-Version: 1.0
To: "Charles EDWARD Lever" <chuck.lever@oracle.com>, Anna.Schumaker@netapp.com,
        Devesh.Sharma@emulex.com, dledford@redhat.com,
        dominique.martinet@cea.fr, jeffrey.c.becker@nasa.gov,
        rsdance@soft-forge.com, skc@lanl.gov, sprabhu@redhat.com,
        SteveD@redhat.com, swise@opengridcomputing.com, wendy.cheng@intel.com,
        yanb@mellanox.com
CC: linux-rdma <linux-rdma@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: NFSoRDMA developers bi-weekly meeting minutes (10/23)
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Attendees:

Steve Dickson (Red Hat)
Chuck Lever (Oracle)
Doug Ledford (RedHat)
Shirley Ma (Oracle)
Sachin Prabhu (RedHat)
Anna Schumaker (Net App)
Steve Wise (OpenGridComputing, Chelsio)

Moderator:
Shirley Ma (Oracle)

NFSoRDMA developers bi-weekly meeting is to help organizing NFSoRDMA development and test effort from different resources to speed up NFSoRDMA upstream kernel work and NFSoRDMA diagnosing/debugging tools development. Hopefully the quality of NFSoRDMA upstream patches can be improved by being tested with a quorum of HW vendors.

Today's meeting notes:
1. OFED update and bug status (Rupert):
-- Intel has discovered some issues with infinipath-psm and is working on an update so there will have to be an OFED 3.12-1 rc4
-- Vlad (Mellanox) has agreed to put together the next version of OFED which will be based on kernel 3.18 rc1. This will be ready will be ready to use in the OFA Interop Debug event next week. This will allow us to test some of these NFSoRDMA bugs that are outstanding.

2. NFS 4.1 RDMA client support (Chuck)
Chuck has submitted the patchset to upstream review. The patch includes bi-directional RPC xprt support and sidecar client support, default is TCP to handle backchannel if not specified in mounting option. Patchset is under review, here is the link:
http://www.spinics.net/lists/linux-nfs/msg47278.html
-- NFS 4.1 enables pNFS
-- bi-redictional RDMA

3. Performance tools and test I/O block size:
-- RPC GETATTR, LOOKUP, ACCESS, READ, WRITE latency are more important than other RPCs: mountstats ouput
-- I/O latency changes with heavy CPU workload (like kernel build)
-- direction I/O performance, tmpfs, ramdisk, big file size equal to 80% of physical memory
-- 8K block size performance in particular for database workload
-- mixed block size performance
-- benchmark tools: fio, iozone, dbench, connecthon, xfstest...
-- scalability: number of mountpoints, number of clients

4. RDMA emulate driver for testing if no HW is available: (Steve Wise)
-- soft iwarp: repo is 
https://www.gitorious.org/softiwarp/ (maintainer Bernard Metzler)

5. Whether we can use RDMA write for both NFS write/read to improve the performance?

Feel free to reply here for anything missing. See you on Nov.6th.

10/23/2014
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

Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:25559 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754104AbbE1SL7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 28 May 2015 14:11:59 -0400
Message-ID: <55675A52.1010700@oracle.com>
Date: Thu, 28 May 2015 11:11:30 -0700
From: Shirley Ma <shirley.ma@oracle.com>
MIME-Version: 1.0
To: Charles EDWARD Lever <chuck.lever@oracle.com>,
        "Anna.Schumaker@netapp.com" <Anna.Schumaker@netapp.com>,
        "devesh.sharma@avagotech.com" <devesh.sharma@avagotech.com>,
        "dledford@redhat.com" <dledford@redhat.com>,
        "dominique.martinet@cea.fr" <dominique.martinet@cea.fr>,
        "jeffrey.c.becker@nasa.gov" <jeffrey.c.becker@nasa.gov>,
        "rsdance@soft-forge.com" <rsdance@soft-forge.com>,
        "skc@lanl.gov" <skc@lanl.gov>,
        "sprabhu@redhat.com" <sprabhu@redhat.com>,
        "SteveD@redhat.com" <SteveD@redhat.com>,
        "swise@opengridcomputing.com" <swise@opengridcomputing.com>,
        "wendy.cheng@intel.com" <wendy.cheng@intel.com>
CC: linux-rdma <linux-rdma@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: NFSoRDMA bi-weekly developers meeting minutes (5/28/15)
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Attendees:

Jeff Becker (NASA)
Yan Burman (Mellanox)
Chuck Lever (Oracle)
Rupert Dance (Soft Forge)
Steve Dickson (Red Hat)
Shirley Ma (Oracle)
Anna Schumaker (Net App)
Devesh Sharma (Avago Tech)

Today's meeting notes:

NFSoRDMA deployment (Jeff)
-------------------
NASA is interested in deployment NFS/RDMA, it's on the table.

NFSoRDMA RFC update (Chuck)
--------------------
Updating IETF specifications for RPC/RDMA (RGFC5666) and NFS/RDMA (RFC5667) to close the holes that might cause confusion. We’d like to replace RFC 5666 with a new document that fixes problems with the RPC/RDMA version 1 protocol; and replace RFC 5667 with a new document that fills in missing or
incorrect items with regard to NFSv4.0 and NFSv4.1 (and pNFS). There will be no protocol changes that would break backwards compatibility.

Chuck has published an experimental draft describing the conventions needed for bi-directional RPC/RDMA:
https://datatracker.ietf.org/doc/draft-cel-nfsv4-rpcrdma-bidirection/

NFSoRDMA bi-directional implementation (Chuck)
---------------------------------------
Chuck has done an experimental implementation, which has been tested among Linux client, Linux server, Solaris client and Solaris server. NFS/RDMA bi-directional support is targeted in Linux 4.3 or 4.4, which might be available 6 months later.

Wireshark dissectors support RPC/RDMA, NFS/RDMA (Yan)
-----------------------------------------------
Yan and his team have been working on wireshark dissectors to support RPC/RDMA, NFS/RDMA. The patches will be submitted next week for review. This is a good news for debugging NFS/RDMA problems.

NFS/RDMA client and server shutdown issue (Nevesh, Shirley)
-----------------------------------------
Any outstanding mounts will prevent both client and server from shut down properly. The right fix is to handle CM_DEVICE_REMOVAL properly so the resources being allocated can be gracefully clean up. We can suggest umount before shutdown the client to avoid this issue, but on server side, we need to add a handler to handle outstanding cm_ids, which is not presented in current implementation.

NFSD workqueue mode vs. threading mode performance impacts: (Shirley)
---------------------------------------------------------------------
Shirley has spent sometime test/fix/evaluating NFSD workqueue mode originally implemented by Jeff Layton. NFSD workqueue patchset NFSD workqueue modes benefit some workloads while global threading mode benefits some other workloads. workqueue mode is better than per-cpu threading mode in general. workqueue is per-cpu workqueue while global threading mode is not per-cpu based. There might be some room to make NFSD workqueue not worse than global threading mode, but this requires to do more in depth performance investigation work.

Feel free to reply here for anything missing or incorrect. Thanks everyone for joining the call and providing valuable inputs/work to the community to make NFSoRDMA better.

Cheers,
Shirley

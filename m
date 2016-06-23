Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([72.48.136.20]:56693 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750919AbcFWPma (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 23 Jun 2016 11:42:30 -0400
From: "Steve Wise" <swise@opengridcomputing.com>
To: "Chuck Lever" <chuck.lever@oracle.com>
Cc: "Raju  Rangoju" <rajur@chelsio.com>, <linux-nfs@vger.kernel.org>,
        <linux-rdma@vger.kernel.org>
Subject: Interrupted IO causing async errors
Date: Thu, 23 Jun 2016 10:42:43 -0500
Message-ID: <00e101d1cd65$e19bf360$a4d3da20$@opengridcomputing.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hey chuck, we observe with 4.7-rc4 (and older kernels too) that interrupting a
dbench test on a nfsrdma/cxgb4 mount while it is doing heavy I/O can result in
cxgb4 logging an "invalid stag" error on an ingress RDMA WRITE message.   Is
this expected?  I'm wondering if this is a normal side effect of interrupting
the IO on the mount.  Maybe due to the mount options or NFS version?    This
error could happen if the NFSRDMA client invalidated MRs that were advertised to
the server for IO, while IO was still in flight.  Is this expected or should we
dive in further?  Thoughts?  thanks...
 
Here are the details of the test.

Steps:

-> Load iw_cxgb4,rdma_ucm on both nodes.
-> Assign ip to chelsio interfaces on both nodes.

Server Side [gayabari]:

-> mknod /dev/ram0 b 1 0
-> modprobe brd rd_nr=1 rd_size=1048576
-> mkdir /nfsrdma 
-> mkfs.ext3 /dev/ram0
-> mount /dev/ram0 /nfsrdma
-> vim /etc/exports
   /nfsrdma  *(sync,insecure,rw,no_root_squash,no_subtree_check)

-> modprobe xprtrdma 
-> modprobe svcrdma
-> service nfsserver restart 
-> echo rdma 20049 > /proc/fs/nfsd/portlist
-> exportfs -rav

Client Side [sonada]:

-> modprobe xprtrdma 
-> modprobe svcrdma

-> mount 102.1.1.186:/nfsrdma/ -o
rdma,port=20049,vers=3,wsize=65536,rsize=65536
/mnt/ 

-> Then run below command on client [sonada] : 
sonada:~ # dbench -t100 -D /root/share1/  10


-> Issue is seen only on killing dbench test in between otherwise it ran fine.

Error seen on the nfsdma client:

[ 1593.398351] cxgb4 0000:01:00.4: AE qpid 1028 opcode 0 status 0x1 type 0 len
0x18e6009c wrid.hi 0x2cce2dc wrid.lo 0x2
[ 1593.398374] RPC:       rpcrdma_qp_async_error_upcall: QP request error on
device cxgb4_0 ep ffff88022f3567e8


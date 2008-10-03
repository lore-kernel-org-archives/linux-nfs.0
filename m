From: Tom Tucker <tom@opengridcomputing.com>
Subject: [PATCH 12/12] svcrdma: Documentation update for the FastReg memory model
Date: Fri,  3 Oct 2008 16:33:49 -0500
Message-ID: <1223069629-5267-13-git-send-email-tom@opengridcomputing.com>
References: <1223069629-5267-1-git-send-email-tom@opengridcomputing.com>
 <1223069629-5267-2-git-send-email-tom@opengridcomputing.com>
 <1223069629-5267-3-git-send-email-tom@opengridcomputing.com>
 <1223069629-5267-4-git-send-email-tom@opengridcomputing.com>
 <1223069629-5267-5-git-send-email-tom@opengridcomputing.com>
 <1223069629-5267-6-git-send-email-tom@opengridcomputing.com>
 <1223069629-5267-7-git-send-email-tom@opengridcomputing.com>
 <1223069629-5267-8-git-send-email-tom@opengridcomputing.com>
 <1223069629-5267-9-git-send-email-tom@opengridcomputing.com>
 <1223069629-5267-10-git-send-email-tom@opengridcomputing.com>
 <1223069629-5267-11-git-send-email-tom@opengridcomputing.com>
 <1223069629-5267-12-git-send-email-tom@opengridcomputing.com>
Cc: thomas.talpey@netapp.com, linux-nfs@vger.kernel.org,
	Tom Tucker <tom@opengridcomputing.com>
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([209.198.142.2]:40995 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753432AbYJCVdv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 3 Oct 2008 17:33:51 -0400
In-Reply-To: <1223069629-5267-12-git-send-email-tom@opengridcomputing.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch adds security related documentation to the nfs-rdma.txt file
that describes the memory registration model, the potential security
exploits, and compares these exploits to a similar threat when using TCP
as the transport.

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>

---
 Documentation/filesystems/nfs-rdma.txt |  126 ++++++++++++++++++++++++++++++++
 1 files changed, 126 insertions(+), 0 deletions(-)

diff --git a/Documentation/filesystems/nfs-rdma.txt b/Documentation/filesystems/nfs-rdma.txt
index 44bd766..6abdc6d 100644
--- a/Documentation/filesystems/nfs-rdma.txt
+++ b/Documentation/filesystems/nfs-rdma.txt
@@ -269,3 +269,129 @@ NFS/RDMA Setup
     the "proto" field for the given mount.
 
   Congratulations! You're using NFS/RDMA!
+
+Security
+--------
+
+  NFSRDMA exploits the RDMA capabilities of the IB and iWARP
+  transports to more efficiently exchange RPC data between the client
+  and the server. This section discusses the security implications of
+  the exchange of memory information on the wire when the wire may be
+  monitorable by an untrusted application. The identifier that
+  encapsulates this memory information is called an RKEY.
+
+  A principal exploit is that a node on the local network could snoop
+  RDMA packets containing RKEY and then forge a packet with this RKEY
+  to write and/or read the memory of the peer to which the RKEY
+  referred.
+
+  If the underlying RDMA device is capable of Fast Memory Registration
+  or the transport is IB, then NFSRDMA is no less secure than TCP.
+  However, if the transport is iWARP and the device does not support
+  Fast Memory Registration, then the node above could write anywhere
+  in the server's memory using the method described.
+
+  When the client connects, NFSRDMA sends a string to the message log
+  providing information about the new connection. Examples of this
+  string are shown below:
+
+      svcrdma: New connection accepted with the following attributes:
+           transport       : iWARP
+           local_ip        : 192.168.70.121
+           local_port      : 20049
+           remote_ip       : 192.168.70.122
+           remote_port     : 44286
+           max_sge         : 4
+           sq_depth        : 128
+           max_requests    : 16
+           ord             : 8
+           using fastreg?  : Y
+           memory exposure : Safe. Only RPC memory exposed.
+
+  This connection is safe. iWARP is the transport, however, the device
+  supports Fast Memory Registration.
+
+      svcrdma: New connection accepted with the following attributes:
+           transport       : iWARP
+           local_ip        : 192.168.70.121
+           local_port      : 20049
+           remote_ip       : 192.168.70.122
+           remote_port     : 44286
+           max_sge         : 4
+           sq_depth        : 128
+           max_requests    : 16
+           ord             : 8
+           using fastreg?  : N
+           memory exposure : Unsafe. Server memory exposed.
+
+  This conneciton is unsafe, the transport is iWARP and Fast Memory
+  Registration is not supported.
+
+       svcrdma: New connection accepted with the following attributes:
+           transport       : IB
+           local_ip        : 192.168.79.121
+           local_port      : 20049
+           remote_ip       : 192.168.79.122
+           remote_port     : 44287
+           max_sge         : 27
+           sq_depth        : 128
+           max_requests    : 16
+           ord             : 4
+           using fastreg?  : N
+           memory exposure : Safe. Only RPC memory exposed.
+
+  This connection is safe because although the adapter does not
+  support Fast Memory Registration, the transport is IB.
+
+  These messages can be disabled as follows:
+
+      # echo 0 > /proc/sys/sunrpc/svc_rdma/show_conn_info
+
+  The text below provides additional information on this issue.
+
+  The NFSRDMA protocol is defined such that a) only the server
+  initiates RDMA, and b) only the client's memory is exposed via
+  RKEY. This is why the server reads to fetch RPC data from the client
+  even though it would be more efficient for the client to write the
+  data to the server's memory. This design goal is not entirely
+  realized with iWARP, however, because the RKEY (called an STag on
+  iWARP) for the data sink of an RDMA_READ is actually placed on the
+  wire, and this RKEY has Remote Write permission. This means that the
+  server's memory is exposed by virtue of having placed the RKEY for
+  its local memory on the wire in order to receive the result of the
+  RDMA_READ.
+
+  By contrast, IB uses an opaque transaction ID# to associate the
+  READ_RPL with the READ_REQ and the data sink of an READ_REQ does not
+  require remote access. That said, the byzantine node in question
+  could still forge a packet with this transaction ID and corrupt the
+  target memory, however, the scope of the exploit is bounded to the
+  lifetime of this single RDMA_READ request and to the memory mapped
+  by the data sink of the READ_REQ.
+
+  The newer RDMA adapters (both iWARP and IB) support "Fast Memory
+  Registration". This capability allows memory to be quickly
+  registered (i.e. made available for remote access) and de-registered
+  by submitting WR on the SQ. These capabilities provide a mechanism
+  to reduce the exposure discused above by limiting the scope of the
+  exploit. The idea is to create an RKEY that only maps the single RPC
+  and whose effective lifetime is only the exchange of this single
+  RPC. This is the default memory model that is employed by the server
+  when supported by the adapter and by the client when the
+  rdma_memreg_strategy is set to 6. Note that the client and server
+  may use different memory registration strategies, however,
+  performance is better when both the client and server use the
+  FastReg memory registration strategy.
+
+  This approach has two benefits, a) it restricts the domain of the
+  exploit to the memory of a single RPC, and b) it limits the duration
+  of the exploit to the time it takes to satisfy the RDMA_READ.
+
+  It is arguable that a one-shot STag/RKEY is no less secure than RPC
+  on the TCP transport. Consider that the exact same byzantine
+  application could more easily corrupt TCP RPC payload by simply
+  forging a packet with the correct TCP sequence number -- in fact
+  it's easier than the RDMA exploit because the RDMA exploit requires
+  that you correctly forge both the TCP packet and the RDMA
+  payload. In addition the duration of the TCP exploit is the lifetime
+  of the connection, not the lifetime of a single WR/RPC data transfer.

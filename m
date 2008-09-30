From: Tom Tucker <tom@opengridcomputing.com>
Subject: Re: [PATCH 10/10] svcrdma: Documentation update for the FastReg	memory
 model
Date: Tue, 30 Sep 2008 15:17:21 -0500
Message-ID: <48E28951.6010700@opengridcomputing.com>
References: <1221564879-85046-8-git-send-email-tom@opengridcomputing.com> <1221564879-85046-9-git-send-email-tom@opengridcomputing.com> <1221564879-85046-10-git-send-email-tom@opengridcomputing.com> <1221564879-85046-11-git-send-email-tom@opengridcomputing.com> <20080924212102.GD10841@fieldses.org> <48DB939E.4090503@opengridcomputing.com> <20080926234006.GA9889@fieldses.org> <48E197ED.6080409@opengridcomputing.com> <20080930184433.GC12268@fieldses.org> <48E27631.4090202@opengridcomputing.com> <20080930185729.GE12268@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>,
	Tom Talpey <Thomas.Talpey@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([209.198.142.2]:59414 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751793AbYI3URW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 30 Sep 2008 16:17:22 -0400
In-Reply-To: <20080930185729.GE12268@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Bruce/Tom:

Below is an updated Documentation patch. Please take a look and tell me 
what you think.

I've made all the changes to the code per Bruce's suggestions plus added 
a patch to display the mem. reg. strategy used at mount time.

Please tweak the doc patch as needed and then I'll repost the whole lot.

Thanks,
Tom

From: Tom Tucker <tom@opengridcomputing.com>
Date: Tue, 30 Sep 2008 14:41:30 -0500
Subject: [PATCH 10/11] svcrdma: Documentation update for the FastReg 
memory model

This patch adds security related documentation to the nfs-rdma.txt file
that describes the memory registration model, the potential security
exploits, and compares these exploits to a similar threat when using TCP
as the transport.

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>

---
  Documentation/filesystems/nfs-rdma.txt |   84 
++++++++++++++++++++++++++++++++
  1 files changed, 84 insertions(+), 0 deletions(-)

diff --git a/Documentation/filesystems/nfs-rdma.txt 
b/Documentation/filesystems/nfs-rdma.txt
index 44bd766..266a57b 100644
--- a/Documentation/filesystems/nfs-rdma.txt
+++ b/Documentation/filesystems/nfs-rdma.txt
@@ -269,3 +269,87 @@ NFS/RDMA Setup
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
+  If the underlying RDMA device is capable of Fast Memory
+  Registration, then NFSRDMA is no less secure than TCP with
+  auth_unix. However, if the device does not support Fast Memory
+  Registration, then such a node could write anywhere in the server's
+  memory using the method above. At mount time, the server sends a
+  string to the message log to indicate whether or not Fast Memory
+  Registration is being used. If Fast Memory Registration is being
+  used, the string
+
+	"svcrdma: Using Fast Memory Registration"
+
+  is logged, otherwise,
+
+	"svcrdma: Using a Global DMA MR"
+
+  will be logged.
+
+  The sections below provide additional information on this issue.
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
+  could forge a packet with this transaction ID and corrupt the target
+  memory, however, the scope of the exploit is bounded to the lifetime
+  of this single RDMA_READ request and to the memory mapped by the
+  data sink of the READ_REQ.
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
+
+  RDMA on IB or iWARP using Fast Reg is no less secure than TCP.
+


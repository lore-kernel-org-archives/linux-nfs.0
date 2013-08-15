Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ve0-f171.google.com ([209.85.128.171]:53133 "EHLO
	mail-ve0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754319Ab3HOAOc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 14 Aug 2013 20:14:32 -0400
MIME-Version: 1.0
Date: Wed, 14 Aug 2013 17:14:31 -0700
Message-ID: <CABgxfbGFHv2n5=78_irkxXnX9BFDFPzZvqgs_iDn64AR_3cf5w@mail.gmail.com>
Subject: Helps to Decode rpc_debug Output
From: Wendy Cheng <s.wendy.cheng@gmail.com>
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The IO on top of a NFS mounted directory was hanging so I forced a
(client side) "rpc_debug" output from the proc entry.

<6>[ 4311.590317]  1676 0001    -11 ffff8801e0bde400 ffff8801d18b1248
      0 ffffffff81420d40 nfsv3 WRITE a:call_status q:xprt_resend
... (similar lines) ...
<6>[ 4311.590435]  1682 0001    -11 ffff8801e0bde400 ffff8801d18b0e10
      0 ffffffff81420d40 nfsv3 WRITE a:call_connect_status
q:xprt_sending
... (similar lines) ...

Could someone give me an educational statement on what the above two
lines mean ?  . More specifically, what "call_connect_status" does and
what "xprt_sending" means ? Is there any way to force (i.e. hacking
the code to get) a re-connect (i.e. invoke "connect" from
rpc_xprt_ops) ?

Longer version of the question:
I'm trying to enable NFS-RDMA on an embedded system (based on 2.6.38
kernel) as a client. The IB stacks are taken from OFED 1.5.4. NFS
server is a RHEL 6.3 Xeon box. The connection uses mellox-4 driver.
Memory registration is "RPCRDMA_ALLPHYSICAL". There are many issues so
far but I do manage to get nfs mount working. Simple file operations
(such as "ls", file read/write, "scp", etc) seem to work as well.
While trying to run iozone to see whether the performance gain can be
justified for the development efforts, the program runs until it
reaches 2MB file size - at that point, RDMA CM sends out
"TIMEWAIT_EXIT" event, the xprt is disconnected, and all IOs on that
share hang. IPOIB still works though. Not sure what would be the best
way to debug this.

Thanks,
Wendy

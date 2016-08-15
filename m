Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:33860 "EHLO
	mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932256AbcHOUuQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 15 Aug 2016 16:50:16 -0400
Subject: [PATCH v1 00/22] client-side NFS/RDMA patches proposed for v4.9
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 15 Aug 2016 16:50:10 -0400
Message-ID: <20160815195649.11652.32252.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Posted for review, the following patch series makes these changes:

- Correct use of DMA API
- Delay DMA mapping to permit device driver unload
- Introduce simple RDMA-CM private message exchange
- Support Remote Invalidation
- Support s/g list when sending RPC calls


Available in the "nfs-rdma-for-4.9" topic branch of this git repo:

git://git.linux-nfs.org/projects/cel/cel-2.6.git


Or for browsing:

http://git.linux-nfs.org/?p=cel/cel-2.6.git;a=log;h=refs/heads/nfs-rdma-for-4.9


== Performance results ==

This is NFSv3 / RDMA, CX-3 Pro (FRWR) on a 12-core dual-socket
client and an 8-core single-socket server. The exported fs is a
tmpfs. Note that iozone reports latency for a system call, not
RPC round-trip.

Test #1: The inline threshold is set to 1KB, and Remote Invalidation
is disabled (RPC-over-RDMA Version One baseline).

    O_DIRECT feature enabled
    Microseconds/op Mode. Output is in microseconds per operation.
    Command line used: /home/cel/bin/iozone -i0 -i1 -s128m -y1k -az -I -N

              KB  reclen   write rewrite    read    reread
          131072       1      61      62       51       51
          131072       2      63      62       51       51
          131072       4      64      63       52       51
          131072       8      67      66       54       52
          131072      16      71      70       56       56
          131072      32      83      80       63       63
          131072      64     104     100       83       82

    O_DIRECT feature enabled
    OPS Mode. Output is in operations per second.
    Command line used: /home/cel/bin/iozone -i0 -i1 -s16m -r4k -t12 -I -O
    Throughput test with 12 processes
    Each process writes a 16384 Kbyte file in 4 Kbyte records

    Children see throughput for 12 readers =   84198.24 ops/sec
    Parent sees throughput for 12 readers  =   84065.36 ops/sec
    Min throughput per process             =    5925.38 ops/sec
    Max throughput per process             =    7346.19 ops/sec
    Avg throughput per process             =    7016.52 ops/sec
    Min xfer                               =    3300.00 ops

Test #2: The inline threshold is set to 4KB, and Remote Invalidation
is enabled. This means I/O payloads smaller than about 3.9KB do not
use explicit RDMA at all, and no LOCAL_INV WR is needed for operations
that do use RDMA.

    O_DIRECT feature enabled
    Microseconds/op Mode. Output is in microseconds per operation.
    Command line used: /home/cel/bin/iozone -i0 -i1 -s128m -y1k -az -I -N

              KB  reclen   write rewrite    read    reread
          131072       1      41      43       37       37
          131072       2      44      44       37       37
          131072       4      61      59       41       41
          131072       8      63      62       43       43
          131072      16      68      66       47       47
          131072      32      76      72       53       53
          131072      64     100      95       70       70

    O_DIRECT feature enabled
    OPS Mode. Output is in operations per second.
    Command line used: /home/cel/bin/iozone -i0 -i1 -s16m -r4k -t12 -I -O
    Throughput test with 12 processes
    Each process writes a 16384 Kbyte file in 4 Kbyte records

    Children see throughput for 12 readers =  111520.52 ops/sec
    Parent sees throughput for 12 readers  =  111250.80 ops/sec
    Min throughput per process             =    8463.72 ops/sec
    Max throughput per process             =    9658.81 ops/sec
    Avg throughput per process             =    9293.38 ops/sec
    Min xfer                               =    3596.00 ops

== Analysis ==

To understand these results, note that:

Typical round-trip latency in this configuration for LOOKUP, ACCESS
and GETATTR (which bear no data payload) is 30-35us.

- An NFS READ call is a pure inline RDMA Send
- A small NFS READ reply is a pure inline RDMA Send
- A large NFS READ reply is an RDMA Write followed by an RDMA Send

- A small NFS WRITE call is a pure inline RDMA Send
- A large NFS WRITE call is an RDMA Send followed by the
server doing an RDMA Read
- An NFS WRITE reply is a pure inline RDMA Send

In Test #2, the 1KB and 2KB I/Os are all pure inline. No explicit
RDMA operation is involved. At 4KB and above, explicit RDMA is used
with a single STag. The server invalidates each RPC's STag, so no
LOCAL_INV WR is needed on the client for Test #2.

The key take-aways are that:

- For small payloads, NFS READ using RDMA Write with Remote
Invalidation is nearly as fast as pure inline; both modes take
about 40usec per RPC

- The NFS READ improvement with Remote Invalidation enabled is
effective even at 8KB payloads and above, but 10us is relatively
small compared to other transmission costs

- For small payloads, the RDMA Read round-trip still adds
significant per-WRITE latency

---

Chuck Lever (22):
      xprtrdma: Eliminate INLINE_THRESHOLD macros
      SUNRPC: Refactor rpc_xdr_buf_init()
      SUNRPC: Generalize the RPC buffer allocation API
      SUNRPC: Generalize the RPC buffer release API
      SUNRPC: Separate buffer pointers for RPC Call and Reply messages
      SUNRPC: Add a transport-specific private field in rpc_rqst
      xprtrdma: Initialize separate RPC call and reply buffers
      xprtrdma: Use smaller buffers for RPC-over-RDMA headers
      xprtrdma: Replace DMA_BIDIRECTIONAL
      xprtrdma: Delay DMA mapping Send and Receive buffers
      xprtrdma: Eliminate "ia" argument in rpcrdma_{alloc,free}_regbuf
      xprtrdma: Simplify rpcrdma_ep_post_recv()
      xprtrdma: Move send_wr to struct rpcrdma_req
      xprtrdma: Move recv_wr to struct rpcrdma_rep
      xprtrmda: Report address of frmr, not mw
      rpcrdma: RDMA/CM private message data structure
      xprtrdma: Client-side support for rpcrdma_connect_private
      xprtrdma: Basic support for Remote Invalidation
      xprtrdma: Use gathered Send for large inline messages
      xprtrdma: Support larger inline thresholds
      xprtrdma: Rename rpcrdma_receive_wc()
      xprtrdma: Eliminate rpcrdma_receive_worker()


 include/linux/sunrpc/rpc_rdma.h            |   39 ++++
 include/linux/sunrpc/sched.h               |    4 
 include/linux/sunrpc/xdr.h                 |   10 +
 include/linux/sunrpc/xprt.h                |   12 +
 include/linux/sunrpc/xprtrdma.h            |    4 
 net/sunrpc/backchannel_rqst.c              |    8 -
 net/sunrpc/clnt.c                          |   36 +--
 net/sunrpc/sched.c                         |   36 ++-
 net/sunrpc/sunrpc.h                        |    2 
 net/sunrpc/xprt.c                          |    2 
 net/sunrpc/xprtrdma/backchannel.c          |   48 ++--
 net/sunrpc/xprtrdma/fmr_ops.c              |    7 -
 net/sunrpc/xprtrdma/frwr_ops.c             |   27 ++-
 net/sunrpc/xprtrdma/rpc_rdma.c             |  299 ++++++++++++++++++++--------
 net/sunrpc/xprtrdma/svc_rdma_backchannel.c |   19 +-
 net/sunrpc/xprtrdma/transport.c            |  201 +++++++++++--------
 net/sunrpc/xprtrdma/verbs.c                |  238 +++++++++++++---------
 net/sunrpc/xprtrdma/xprt_rdma.h            |  102 ++++++----
 net/sunrpc/xprtsock.c                      |   23 +-
 19 files changed, 700 insertions(+), 417 deletions(-)

--
Chuck Lever

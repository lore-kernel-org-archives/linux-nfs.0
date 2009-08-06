Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from adsl-76-241-169-38.dsl.sfldmi.sbcglobal.net ([76.241.169.38]:45889
	"EHLO matisse.1015granger.net" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751355AbZHFSyf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 6 Aug 2009 14:54:35 -0400
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 00/10] Update rpcbind client's XDR functions [take 2]
To: trond.myklebust@fys.uio.no
Cc: linux-nfs@vger.kernel.org
Date: Thu, 06 Aug 2009 14:54:24 -0400
Message-ID: <20090806184944.3458.44739.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi Trond-

Here is a second stab at replacing the XDR functions in the kernel's
rpcbind client.  I update the kernel rpcbind client's XDR functions to
use the NFSv4-style encoding and decoding, and use the new universal
address API added in a previously posted series.

This series of patches is for 2.6.32, and depends on the last series I
just sent.  I've addressed review comments, removing support for
setting the remote's address at rpcbind time.  A handful of other
simplifications were added to this set.

---

Chuck Lever (10):
      SUNRPC: Add documenting comments in net/sunrpc/timer.c
      SUNRPC: Update xprt address strings after an rpcbind completes
      SUNRPC: Kill RPC_DISPLAY_ALL
      SUNRPC: Rename sock_xprt.addr as sock_xprt.srcaddr
      SUNRPC: Eliminate PROC macro from rpcb_clnt
      SUNRPC: Clean up: Remove unused XDR decoder functions from rpcb_clnt.c
      SUNRPC: Introduce new xdr_stream-based decoders to rpcb_clnt.c
      SUNRPC: Introduce xdr_stream-based decoders for RPCB_UNSET
      SUNRPC: Clean up: Remove unused XDR encoder functions from rpcb_clnt.c
      SUNRPC: Introduce new xdr_stream-based encoders to rpcb_clnt.c


 include/linux/sunrpc/xprt.h     |    1 
 net/sunrpc/rpcb_clnt.c          |  318 +++++++++++++++++++++++++++------------
 net/sunrpc/timer.c              |   45 ++++--
 net/sunrpc/xprtrdma/transport.c |    5 -
 net/sunrpc/xprtsock.c           |  156 +++++++++++--------
 5 files changed, 337 insertions(+), 188 deletions(-)

-- 
Chuck Lever <chuck.lever@oracle.com>

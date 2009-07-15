Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from adsl-76-241-169-38.dsl.sfldmi.sbcglobal.net ([76.241.169.38]:60972
	"EHLO matisse.1015granger.net" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752159AbZGOVlu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 15 Jul 2009 17:41:50 -0400
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 00/10] Update rpcbind client's XDR functions
To: trond.myklebust@fys.uio.no
Cc: linux-nfs@vger.kernel.org
Date: Wed, 15 Jul 2009 17:41:47 -0400
Message-ID: <20090715213842.7883.48947.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi Trond-

Here, I update the kernel rpcbind client's XDR functions to use the
NFSv4-style encoding and decoding, use the new universal address API
added in the previous series, and introduce support for using the
whole address returned by RPCB_GETADDR instead of just the port
number.

This series of patches is for 2.6.32, and depends on the last series I
just sent.  These patches have seen light testing here, and are also
available in the cel-2.6.git linux.nfs.org repository under
the cel-ipv6-07152009 tag.

The last patch in this series is a one-off, not dependent on any of
the others.

---

Chuck Lever (10):
      SUNRPC: Add documenting comments in net/sunrpc/timer.c
      SUNRPC: Use address returned by rpcbind when connecting
      SUNRPC: Rename sock_xprt.addr as sock_xprt.srcaddr
      SUNRPC: Pass full bind address to transports after GETPORT/GETADDR
      SUNRPC: Eliminate PROC macro from rpcb_clnt
      SUNRPC: Clean up: Remove unused XDR decoder functions from rpcb_clnt.c
      SUNRPC: Introduce new xdr_stream-based decoders to rpcb_clnt.c
      SUNRPC: Introduce xdr_stream-based decoders for RPCB_UNSET
      SUNRPC: Clean up: Remove unused XDR encoder functions from rpcb_clnt.c
      SUNRPC: Introduce new xdr_stream-based encoders to rpcb_clnt.c


 include/linux/sunrpc/xprt.h     |    4 
 net/sunrpc/rpcb_clnt.c          |  384 ++++++++++++++++++++++++++++-----------
 net/sunrpc/timer.c              |   45 +++--
 net/sunrpc/xprtrdma/transport.c |   23 ++
 net/sunrpc/xprtsock.c           |  173 ++++++++++++------
 5 files changed, 451 insertions(+), 178 deletions(-)

-- 
Chuck Lever <chuck.lever@oracle.com>

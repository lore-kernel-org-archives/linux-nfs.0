Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f175.google.com ([209.85.213.175]:56682 "EHLO
	mail-ig0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933495AbbBIWsP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 9 Feb 2015 17:48:15 -0500
Received: by mail-ig0-f175.google.com with SMTP id hn18so19905959igb.2
        for <linux-nfs@vger.kernel.org>; Mon, 09 Feb 2015 14:48:14 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v3 00/15] Fix TCP connection port number reuse in NFSv3
Date: Mon,  9 Feb 2015 17:47:56 -0500
Message-Id: <1423522091-35365-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Over the years, the code that manages the TCP connections has accumulated
a lot of cargo cult code, largely in due to the fact that the RPC duplicate
replay caches do a lot of stuff that is not really sanctioned by the IETF
spec; the main unsanctioned thing being port reuse.
This patchset is an attempt to clean up the mess, and replace our current
hacky code to disconnect sockets using the TCP RST mechanism with a more
robust version that uses the SO_REUSEPORT socket option to ensure that
we can reuse the socket ports even if they are stuck in TIME_WAIT.

V2: Move close code to use shutdown() instead of sock_release() so that
we always can monitor the close process through xs_tcp_state_change().

V3: Final version: fix a typo in xs_sock_set_reuseport that broke
the call to kernel_setsockopt().

Trond Myklebust (15):
  SUNRPC: Set SO_REUSEPORT socket option for TCP connections
  SUNRPC: Handle EADDRINUSE on connect
  SUNRPC: Do not clear the source port in xs_reset_transport
  SUNRPC: Ensure xs_reset_transport() resets the close connection flags
  SUNRPC: Add helpers to prevent socket create from racing
  SUNRPC: TCP/UDP always close the old socket before reconnecting
  SUNRPC: Remove TCP client connection reset hack
  SUNRPC: Remove TCP socket linger code
  SUNRPC: Cleanup to remove remaining uses of XPRT_CONNECTION_ABORT
  SUNRPC: Ensure xs_tcp_shutdown() requests a full close of the
    connection
  SUNRPC: Make xs_tcp_close() do a socket shutdown rather than a
    sock_release
  SUNRPC: Remove the redundant XPRT_CONNECTION_CLOSE flag
  SUNRPC: Handle connection reset more efficiently.
  SUNRPC: Define xs_tcp_fin_timeout only if CONFIG_SUNRPC_DEBUG
  SUNRPC: Fix stupid typo in xs_sock_set_reuseport

 include/linux/sunrpc/xprt.h |   6 +-
 net/sunrpc/clnt.c           |   3 +
 net/sunrpc/xprt.c           |  38 +++++++-
 net/sunrpc/xprtsock.c       | 233 +++++++++++++++++---------------------------
 4 files changed, 126 insertions(+), 154 deletions(-)

-- 
2.1.0


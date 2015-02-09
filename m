Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f173.google.com ([209.85.213.173]:52010 "EHLO
	mail-ig0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759149AbbBIDHq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 8 Feb 2015 22:07:46 -0500
Received: by mail-ig0-f173.google.com with SMTP id a13so13809192igq.0
        for <linux-nfs@vger.kernel.org>; Sun, 08 Feb 2015 19:07:45 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 00/11] Fix TCP connection port number reuse in NFSv3
Date: Sun,  8 Feb 2015 22:07:31 -0500
Message-Id: <1423451262-84493-1-git-send-email-trond.myklebust@primarydata.com>
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


Trond Myklebust (11):
  SUNRPC: Set SO_REUSEPORT socket option for TCP connections
  SUNRPC: Handle EADDRINUSE on connect
  SUNRPC: Do not clear the source port in xs_reset_transport
  SUNRPC: Ensure xs_reset_transport() resets the close connection flags
  SUNRPC: Add helpers to prevent socket create from racing
  SUNRPC: TCP/UDP always close the old socket before reconnecting
  SUNRPC: Remove TCP client connection reset hack
  SUNRPC: Kill the special TCP close mechanisms
  SUNRPC: Remove TCP socket linger code
  SUNRPC: Cleanup to remove remaining uses of XPRT_CONNECTION_ABORT
  SUNRPC: Remove the redundant XPRT_CONNECTION_CLOSE flag

 include/linux/sunrpc/xprt.h |   6 +-
 net/sunrpc/clnt.c           |   3 +
 net/sunrpc/xprt.c           |  38 +++++++-
 net/sunrpc/xprtsock.c       | 230 ++++++++++++++------------------------------
 4 files changed, 111 insertions(+), 166 deletions(-)

-- 
2.1.0


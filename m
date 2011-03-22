Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:56842 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755416Ab1CVWJB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 22 Mar 2011 18:09:01 -0400
Received: by iwn34 with SMTP id 34so7906460iwn.19
        for <linux-nfs@vger.kernel.org>; Tue, 22 Mar 2011 15:09:01 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 0/4] RFC: RPC over AF_LOCAL, kernel client-side
To: linux-nfs@vger.kernel.org
Date: Tue, 22 Mar 2011 18:08:57 -0400
Message-ID: <20110322220518.4360.51304.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Just for sh*ts and giggles, I threw together a partial implementation
of RPC over AF_LOCAL sockets, and taught the kernel rpcbind client to
use it for registering in-kernel RPC services.

It's still a little rough around the edges.  Any thoughts?

---

Chuck Lever (4):
      SUNRPC: Use AF_LOCAL for rpcbind upcalls
      SUNRPC: Support for RPC over AF_LOCAL transports
      SUNRPC: Rename xs_encode_tcp_fragment_header()
      SUNRPC: Clean up use of curly braces in switch cases


 include/linux/sunrpc/msg_prot.h |    1 
 include/linux/sunrpc/xprt.h     |    3 
 net/sunrpc/clnt.c               |   25 +-
 net/sunrpc/rpcb_clnt.c          |   97 ++++++++-
 net/sunrpc/svc.c                |    2 
 net/sunrpc/xprtsock.c           |  417 ++++++++++++++++++++++++++++++++++++++-
 6 files changed, 506 insertions(+), 39 deletions(-)

-- 
Chuck Lever

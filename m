Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gw0-f46.google.com ([74.125.83.46]:47666 "EHLO
	mail-gw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753369Ab1EITWI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 9 May 2011 15:22:08 -0400
Received: by gwaa18 with SMTP id a18so1904909gwa.19
        for <linux-nfs@vger.kernel.org>; Mon, 09 May 2011 12:22:07 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 0/6] For 2.6.40: NFSROOT fix, AF_LOCAL support
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Mon, 09 May 2011 15:22:04 -0400
Message-ID: <20110509191859.16449.73749.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi-

The following are miscellaneous patches for 2.6.40.

---

Chuck Lever (6):
      SUNRPC: Remove obsolete comment
      SUNRPC: Use AF_LOCAL for rpcbind upcalls
      SUNRPC: Support for RPC over AF_LOCAL transports
      SUNRPC: Rename xs_encode_tcp_fragment_header()
      SUNRPC: Clean up use of curly braces in switch cases
      NFS: Revert NFSROOT default mount options


 fs/nfs/nfsroot.c                |    2 
 include/linux/sunrpc/msg_prot.h |    1 
 include/linux/sunrpc/xprt.h     |    3 
 net/sunrpc/clnt.c               |   29 +--
 net/sunrpc/rpcb_clnt.c          |   97 ++++++++-
 net/sunrpc/svc.c                |    2 
 net/sunrpc/xprtsock.c           |  419 ++++++++++++++++++++++++++++++++++++++-
 7 files changed, 509 insertions(+), 44 deletions(-)

-- 
Chuck Lever

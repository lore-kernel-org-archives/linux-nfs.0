Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:38684 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753758AbZERVv2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 18 May 2009 17:51:28 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 0/3] Fix the Linux rpc-over-tcp server performance
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org,
        Jeff Moyer <jmoyer@redhat.com>
Date: Mon, 18 May 2009 17:47:56 -0400
Message-ID: <20090518214756.786.28129.stgit@heimdal.trondhjem.org>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

I squashed the previous set of 4 incremental patches into 3. Otherwise
there should be no differences w.r.t. the set that Jeff tested.

Cheers
  Trond

---

Trond Myklebust (3):
      SUNRPC: Fix svc_tcp_recvfrom()
      SUNRPC: Fix the TCP write space reservations for deferred requests
      SUNRPC: Fix the TCP server's send buffer accounting


 include/linux/sunrpc/svc.h     |    1 
 include/linux/sunrpc/svcsock.h |    1 
 net/sunrpc/svc_xprt.c          |   10 +-
 net/sunrpc/svcsock.c           |  203 ++++++++++++++++++++++++++++------------
 4 files changed, 149 insertions(+), 66 deletions(-)

-- 
Signature

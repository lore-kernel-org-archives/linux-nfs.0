Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([209.198.142.2]:54195 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752470Ab1BITpY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 9 Feb 2011 14:45:24 -0500
From: Tom Tucker <tom@ogc.us>
Subject: [PATCH 0/2] RPCRDMA Fixes
To: Trond.Myklebust@netapp.com
Cc: spelic@shiftmail.org, linux-rdma@vger.kernel.org,
        linux-nfs@vger.kernel.org
Date: Wed, 09 Feb 2011 13:45:23 -0600
Message-ID: <20110209194430.22358.46254.stgit@build.ogc.int>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

This pair of patches fixes a problem with the marshalling of XDR into
RPCRDMA messages and an issue with FRMR mapping in the presence of transport
errors. The problems were discovered together as part of looking into the
ENOSPC problems seen by spelic@shiftmail.com.

The fixes, however, are independent and do not rely on each other. I have tested
them indepently and together on 64b with both Infiniband and iWARP. They have been
compile tested on 32b.

---

Tom Tucker (2):
      RPCRDMA: Fix FRMR registration/invalidate handling.
      RPCRDMA: Fix to XDR page base interpretation in marshalling logic.


 net/sunrpc/xprtrdma/rpc_rdma.c  |   86 +++++++++++++++++++--------------------
 net/sunrpc/xprtrdma/verbs.c     |   52 ++++++++++++++++++++----
 net/sunrpc/xprtrdma/xprt_rdma.h |    1 
 3 files changed, 87 insertions(+), 52 deletions(-)

-- 
Signed-off-by: Tom Tucker <tom@ogc.us>

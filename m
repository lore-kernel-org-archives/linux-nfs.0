Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qg0-f42.google.com ([209.85.192.42]:35052 "EHLO
	mail-qg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750968AbbEDQSf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 4 May 2015 12:18:35 -0400
Received: by qgej70 with SMTP id j70so67913507qge.2
        for <linux-nfs@vger.kernel.org>; Mon, 04 May 2015 09:18:34 -0700 (PDT)
Received: from klimt.1015granger.net ([2604:8800:100:81fc:be5f:f4ff:fed6:c3ba])
        by mx.google.com with ESMTPSA id b203sm25206027qhc.40.2015.05.04.09.18.32
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 May 2015 09:18:33 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH v1 0/8] server NFS/RDMA patches for 4.2
To: linux-nfs@vger.kernel.org
Date: Mon, 04 May 2015 12:18:31 -0400
Message-ID: <20150504160738.16870.19295.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I'd like to see these merged into 4.2. Thanks in advance for any
review! This patch series includes:

 - Don't use a non-byte-swapped value as an array index
 - Perform a memory access check before doing a copy_to_user
 - A server-side pre-requisite for increasing r/wsize on the client
 - A server-side pre-requisite for client RPC/RDMA bi-direction
 - Miscellaneous clean-ups

These are largely RPC infrastructure patches not related to RDMA
specifics, so I'm posting this series just to linux-nfs.

---

Chuck Lever (8):
      svcrdma: Add backward direction service for RPC/RDMA transport
      svcrdma: Add a separate "max data segs macro for svcrdma
      svcrdma: Replace GFP_KERNEL in a loop with GFP_NOFAIL
      svcrdma: Keep rpcrdma_msg fields in network byte-order
      svcrdma: Remove svc_rdma_xdr_decode_deferred_req()
      SUNRPC: Move EXPORT_SYMBOL for svc_process
      svcrdma: Add missing access_ok() call in svc_rdma.c
      svcrdma: Fix byte-swapping in svc_rdma_sendto.c


 include/linux/sunrpc/svc_rdma.h          |   17 +++-
 include/linux/sunrpc/xprt.h              |    1 
 net/sunrpc/svc.c                         |    2 
 net/sunrpc/xprtrdma/svc_rdma.c           |   14 +++
 net/sunrpc/xprtrdma/svc_rdma_marshal.c   |  140 ++++++++----------------------
 net/sunrpc/xprtrdma/svc_rdma_recvfrom.c  |    2 
 net/sunrpc/xprtrdma/svc_rdma_sendto.c    |   16 ++-
 net/sunrpc/xprtrdma/svc_rdma_transport.c |   95 ++++++++++++++------
 net/sunrpc/xprtrdma/xprt_rdma.h          |    6 -
 9 files changed, 143 insertions(+), 150 deletions(-)

-- 
Chuck Lever

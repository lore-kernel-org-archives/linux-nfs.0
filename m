Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([209.198.142.2]:55049 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754247Ab0JLUdr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 12 Oct 2010 16:33:47 -0400
From: Tom Tucker <tom@ogc.us>
Subject: [PATCH 0/2] svcrdma: NFSRDMA Server fixes for 2.6.37
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, linux-rdma@vger.kernel.org
Date: Tue, 12 Oct 2010 15:33:46 -0500
Message-ID: <20101012203332.22154.37230.stgit@build.ogc.int>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi Bruce,

These fixes are ready for 2.6.37. They fix two bugs in the server-side
NFSRDMA transport.

Thanks,
Tom
---

Tom Tucker (2):
      svcrdma: Cleanup DMA unmapping in error paths.
      svcrdma: Change DMA mapping logic to avoid the page_address kernel API


 net/sunrpc/xprtrdma/svc_rdma_recvfrom.c  |   19 ++++---
 net/sunrpc/xprtrdma/svc_rdma_sendto.c    |   82 ++++++++++++++++++++++--------
 net/sunrpc/xprtrdma/svc_rdma_transport.c |   41 +++++++--------
 3 files changed, 92 insertions(+), 50 deletions(-)

-- 
Signed-off-by: Tom Tucker <tom@ogc.us>

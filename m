From: Tom Tucker <tom@opengridcomputing.com>
Subject: [PATCH 0/7] rdma: SVCRDMA Transport Provider
Date: Wed, 12 Dec 2007 16:13:14 -0600
Message-ID: <20071212221314.12650.69032.stgit@dell3.ogc.int>
Content-Type: text/plain; charset=utf-8; format=fixed
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from 209-198-142-2-host.prismnet.net ([209.198.142.2]:50841 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752221AbXLLWNP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 12 Dec 2007 17:13:15 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


This patchset implements the SVC Transport Provider driver for
RDMA. Clean up in this version includes:

- Simplified the build by having it share the client side config
  variable CONFIG_SUNRPC_XPRT_RDMA

- All files have been moved to net/sunrpc/xprtrdma

- Changed the type of the sc_flag bit field to unsigned long

- Fixed incorrect clearing of the xpt_pool variable in transport
  connect handler.

This patchset is based on 2.6.24-rc5 and has been tested with
Connectathon, iozone, and a kernel build on V3 with the new text based
mount command.

-- 
Signed-off-by: Tom Tucker <tom@opengridcomputing.com>

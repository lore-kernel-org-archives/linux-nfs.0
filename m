From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 3/8] NFS: Make nfs_commitdata_release static
Date: Mon, 25 Jan 2010 16:57:35 -0500
Message-ID: <20100125215735.14716.76603.stgit@localhost.localdomain>
References: <20100125215734.14716.19614.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:8838 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752241Ab0AYWEJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 25 Jan 2010 17:04:09 -0500
Received: from sacrsexc2-prd.hq.netapp.com (sacrsexc2-prd.hq.netapp.com [10.99.115.28])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o0PM48LA014248
	for <linux-nfs@vger.kernel.org>; Mon, 25 Jan 2010 14:04:08 -0800 (PST)
In-Reply-To: <20100125215734.14716.19614.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: H Hartley Sweeten <hartleys-3FF4nKcrg1dE2c76skzGb0EOCMrvLtNR@public.gmane.org>

The symbol nfs_commitdata_release is only used locally
in this file. Make it static to prevent the following sparse warning:

warning: symbol 'nfs_commitdata_release' was not declared. Should it be static?

Signed-off-by: H Hartley Sweeten <hsweeten-3FF4nKcrg1dE2c76skzGb0EOCMrvLtNR@public.gmane.org>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/write.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index dac8d76..7b54b8b 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1233,7 +1233,7 @@ int nfs_writeback_done(struct rpc_task *task, struct nfs_write_data *data)
 
 
 #if defined(CONFIG_NFS_V3) || defined(CONFIG_NFS_V4)
-void nfs_commitdata_release(void *data)
+static void nfs_commitdata_release(void *data)
 {
 	struct nfs_write_data *wdata = data;
 


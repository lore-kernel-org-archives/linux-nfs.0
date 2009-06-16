From: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
Subject: [PATCH 2/3] SQUASHME: nfs41: Backchannel: Remove FIXME comment
Date: Tue, 16 Jun 2009 11:26:39 -0700
Message-ID: <1245176800-10595-2-git-send-email-Ricardo.Labiaga@netapp.com>
References: <>
 <1245176800-10595-1-git-send-email-Ricardo.Labiaga@netapp.com>
Cc: bhalevy@panasas.com, pnfs@linux-nfs.org, linux-nfs@vger.kernel.org,
	Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:61377 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757995AbZFPSbM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 16 Jun 2009 14:31:12 -0400
In-Reply-To: <1245176800-10595-1-git-send-email-Ricardo.Labiaga@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We already correctly monitor and manage the callback service for NFSv4
and NFSv4.1.  Remove the comment calling attention to this.

[squash with: nfs41: minorversion support for nfs4_{init,destroy}_callback]

Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
---
 fs/nfs/callback.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/callback.c b/fs/nfs/callback.c
index f874640..e69b8f6 100644
--- a/fs/nfs/callback.c
+++ b/fs/nfs/callback.c
@@ -265,8 +265,6 @@ int nfs_callback_up(u32 minorversion, struct rpc_xprt *xprt)
 		goto out_err;
 	}
 
-	/* FIXME: either 4.0 or 4.1 callback service can be up at a time
-	 * need to monitor and control them both */
 	minorversion_setup =  nfs_minorversion_callback_svc_setup(minorversion,
 					serv, xprt, &rqstp, &callback_svc);
 	if (!minorversion_setup) {
-- 
1.5.4.3


From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 17/17] NSM: Check result of SM_UNMON upcall
Date: Thu, 04 Dec 2008 14:21:46 -0500
Message-ID: <20081204192146.8039.92151.stgit@ingres.1015granger.net>
References: <20081204191113.8039.76714.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:17893 "EHLO
	rgminet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754877AbYLDTWO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 4 Dec 2008 14:22:14 -0500
In-Reply-To: <20081204191113.8039.76714.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Make sure any error returned by rpc.statd during an SM_UNMON call is
reported rather than ignored completely.  There isn't much to do with
such an error, but we should log it in any case.

Similar to a recent change to nsm_monitor().

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/lockd/mon.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/fs/lockd/mon.c b/fs/lockd/mon.c
index d61cdc6..3bb71e1 100644
--- a/fs/lockd/mon.c
+++ b/fs/lockd/mon.c
@@ -126,6 +126,8 @@ void nsm_unmonitor(const struct nlm_host *host)
 		dprintk("lockd: nsm_unmonitor(%s)\n", nsm->sm_name);
 
 		status = nsm_mon_unmon(nsm, SM_UNMON, &res);
+		if (res.status != 0)
+			status = -EIO;
 		if (status < 0)
 			printk(KERN_NOTICE "lockd: cannot unmonitor %s\n",
 					nsm->sm_name);


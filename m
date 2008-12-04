From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 12/17] NSM: Remove BUG_ON() in nsm_monitor()
Date: Thu, 04 Dec 2008 14:21:08 -0500
Message-ID: <20081204192108.8039.12479.stgit@ingres.1015granger.net>
References: <20081204191113.8039.76714.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:50160 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754480AbYLDTV1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 4 Dec 2008 14:21:27 -0500
In-Reply-To: <20081204191113.8039.76714.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: Remove the BUG_ON() invocation in nsm_monitor().  It's not
likely that nsm_monitor() is ever called with a NULL host pointer, and
the code will die anyway if host is NULL.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/lockd/mon.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/fs/lockd/mon.c b/fs/lockd/mon.c
index 697bdcd..bb5fc1b 100644
--- a/fs/lockd/mon.c
+++ b/fs/lockd/mon.c
@@ -80,7 +80,6 @@ nsm_monitor(struct nlm_host *host)
 	int		status;
 
 	dprintk("lockd: nsm_monitor(%s)\n", nsm->sm_name);
-	BUG_ON(nsm == NULL);
 
 	if (nsm->sm_monitored)
 		return 0;


From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: [PATCH] nfs: fix compile error in rpc_pipefs.h
Date: Thu, 20 Aug 2009 17:08:39 -0400
Message-ID: <20090820210839.GC2451@fieldses.org>
References: <1250725135-14632-23-git-send-email-Trond.Myklebust@netapp.com> <1250725135-14632-24-git-send-email-Trond.Myklebust@netapp.com> <1250725135-14632-25-git-send-email-Trond.Myklebust@netapp.com> <1250725135-14632-26-git-send-email-Trond.Myklebust@netapp.com> <1250725135-14632-27-git-send-email-Trond.Myklebust@netapp.com> <1250725135-14632-28-git-send-email-Trond.Myklebust@netapp.com> <1250725135-14632-29-git-send-email-Trond.Myklebust@netapp.com> <1250725135-14632-30-git-send-email-Trond.Myklebust@netapp.com> <1250725135-14632-31-git-send-email-Trond.Myklebust@netapp.com> <20090820210352.GB2451@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:54519 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751442AbZHTVIh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 20 Aug 2009 17:08:37 -0400
In-Reply-To: <20090820210352.GB2451@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: J. Bruce Fields <bfields@citi.umich.edu>

This include is needed for the definition of delayed_work.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 include/linux/sunrpc/rpc_pipe_fs.h |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

One possible fix.  Works for me, anyway.

diff --git a/include/linux/sunrpc/rpc_pipe_fs.h b/include/linux/sunrpc/rpc_pipe_fs.h
index a92571a..cf14db9 100644
--- a/include/linux/sunrpc/rpc_pipe_fs.h
+++ b/include/linux/sunrpc/rpc_pipe_fs.h
@@ -3,6 +3,8 @@
 
 #ifdef __KERNEL__
 
+#include <linux/workqueue.h>
+
 struct rpc_pipe_msg {
 	struct list_head list;
 	void *data;
-- 
1.6.0.4


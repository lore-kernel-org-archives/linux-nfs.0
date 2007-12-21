From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 2/6] SUNRPC: export svc_sock_update_bufs
Date: Fri, 21 Dec 2007 10:28:06 -0500
Message-ID: <1198250890-25571-3-git-send-email-jlayton@redhat.com>
References: <1198250890-25571-1-git-send-email-jlayton@redhat.com>
 <1198250890-25571-2-git-send-email-jlayton@redhat.com>
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:38581 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753006AbXLUP2U (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 21 Dec 2007 10:28:20 -0500
In-Reply-To: <1198250890-25571-2-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Needed since the plan is to not have a svc_create_thread helper and to
have current users of that function just call kthread_run directly.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 net/sunrpc/svcsock.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index c75bffe..f34af48 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -1405,6 +1405,7 @@ svc_sock_update_bufs(struct svc_serv *serv)
 	}
 	spin_unlock_bh(&serv->sv_lock);
 }
+EXPORT_SYMBOL(svc_sock_update_bufs);
 
 /*
  * Receive the next request on any socket.  This code is carefully
-- 
1.5.3.6


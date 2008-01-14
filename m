From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 2/4] SUNRPC: export svc_sock_update_bufs
Date: Mon, 14 Jan 2008 09:05:16 -0500
Message-ID: <1200319518-22422-3-git-send-email-jlayton@redhat.com>
References: <1200319518-22422-1-git-send-email-jlayton@redhat.com>
 <1200319518-22422-2-git-send-email-jlayton@redhat.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
To: neilb@suse.de
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:57408 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751199AbYANOFV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 14 Jan 2008 09:05:21 -0500
In-Reply-To: <1200319518-22422-2-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Needed since the plan is to not have a svc_create_thread helper and to
have current users of that function just call kthread_run directly.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 net/sunrpc/svcsock.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 057c870..f2bef16 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -1407,6 +1407,7 @@ svc_sock_update_bufs(struct svc_serv *serv)
 	}
 	spin_unlock_bh(&serv->sv_lock);
 }
+EXPORT_SYMBOL(svc_sock_update_bufs);
 
 /*
  * Receive the next request on any socket.  This code is carefully
-- 
1.5.3.7


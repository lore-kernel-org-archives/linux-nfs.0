From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 1/2] SUNRPC: export svc_sock_update_bufs
Date: Tue,  5 Feb 2008 14:37:56 -0500
Message-ID: <1202240277-24437-2-git-send-email-jlayton@redhat.com>
References: <1202240277-24437-1-git-send-email-jlayton@redhat.com>
Cc: neilb@suse.de, linux-nfs@vger.kernel.org
To: bfields@citi.umich.edu
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:35158 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755487AbYBETiD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 5 Feb 2008 14:38:03 -0500
In-Reply-To: <1202240277-24437-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Needed since the plan is to not have a svc_create_thread helper and to
have current users of that function just call kthread_run directly.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
Reviewed-by: NeilBrown <neilb@suse.de>
Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 net/sunrpc/svcsock.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 1d3e5fc..b73a92a 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -1101,6 +1101,7 @@ void svc_sock_update_bufs(struct svc_serv *serv)
 	}
 	spin_unlock_bh(&serv->sv_lock);
 }
+EXPORT_SYMBOL(svc_sock_update_bufs);
 
 /*
  * Initialize socket for RPC use and create svc_sock struct
-- 
1.5.3.8


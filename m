Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38044 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726151AbeIGWoE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 7 Sep 2018 18:44:04 -0400
From: Steve Dickson <steved@redhat.com>
To: Libtirpc-devel Mailing List <libtirpc-devel@lists.sourceforge.net>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 10/13] rpcb_clnt.c: resource_leak
Date: Fri,  7 Sep 2018 14:01:48 -0400
Message-Id: <20180907180151.178872-11-steved@redhat.com>
In-Reply-To: <20180907180151.178872-1-steved@redhat.com>
References: <20180907180151.178872-1-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Variable "nc_handle" going out of scope leaks the storage it points to.

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 src/rpcb_clnt.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/src/rpcb_clnt.c b/src/rpcb_clnt.c
index e45736a..0c34cb7 100644
--- a/src/rpcb_clnt.c
+++ b/src/rpcb_clnt.c
@@ -547,6 +547,7 @@ try_nconf:
 		if (tmpnconf == NULL) {
  			rpc_createerr.cf_stat = RPC_UNKNOWNPROTO;
 			mutex_unlock(&loopnconf_lock);
+			endnetconfig(nc_handle);
 			return (NULL);
 		}
 		loopnconf = getnetconfigent(tmpnconf->nc_netid);
-- 
2.17.1

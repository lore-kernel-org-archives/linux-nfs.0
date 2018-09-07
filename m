Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49432 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726151AbeIGWn7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 7 Sep 2018 18:43:59 -0400
From: Steve Dickson <steved@redhat.com>
To: Libtirpc-devel Mailing List <libtirpc-devel@lists.sourceforge.net>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 03/13] clnt_bcast.c: resource_leak
Date: Fri,  7 Sep 2018 14:01:41 -0400
Message-Id: <20180907180151.178872-4-steved@redhat.com>
In-Reply-To: <20180907180151.178872-1-steved@redhat.com>
References: <20180907180151.178872-1-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Variable "sys_auth" going out of scope leaks the storage it points to.

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 src/clnt_bcast.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/src/clnt_bcast.c b/src/clnt_bcast.c
index 98cf061..2ad6c89 100644
--- a/src/clnt_bcast.c
+++ b/src/clnt_bcast.c
@@ -330,6 +330,7 @@ rpc_broadcast_exp(prog, vers, proc, xargs, argsp, xresults, resultsp,
 	if (nettype == NULL)
 		nettype = "datagram_n";
 	if ((handle = __rpc_setconf(nettype)) == NULL) {
+		AUTH_DESTROY(sys_auth);
 		return (RPC_UNKNOWNPROTO);
 	}
 	while ((nconf = __rpc_getconf(handle)) != NULL) {
-- 
2.17.1

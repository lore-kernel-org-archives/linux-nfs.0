From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 2/3] NFSD: Support AF_INET6 in svc_addsock() function
Date: Wed, 13 Jan 2010 16:10:40 -0500
Message-ID: <20100113211039.19409.3284.stgit@localhost.localdomain>
References: <20100113210650.19409.38009.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:29969 "EHLO
	rcsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756402Ab0AMVLJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 13 Jan 2010 16:11:09 -0500
In-Reply-To: <20100113210650.19409.38009.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Aime Le Rouzic <aime.le-rouzic@bull.net>

Relax the address family check at the top of svc_addsock() to allow AF_INET6
listener sockets to be specified via /proc/fs/nfsd/portlist.

Signed-off-by: Aime Le Rouzic <aime.le-rouzic@bull.net>
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/svcsock.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 870929e..9e09391 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -1357,7 +1357,7 @@ int svc_addsock(struct svc_serv *serv, const int fd, char *name_return,
 
 	if (!so)
 		return err;
-	if (so->sk->sk_family != AF_INET)
+	if ((so->sk->sk_family != PF_INET) && (so->sk->sk_family != PF_INET6))
 		err =  -EAFNOSUPPORT;
 	else if (so->sk->sk_protocol != IPPROTO_TCP &&
 	    so->sk->sk_protocol != IPPROTO_UDP)


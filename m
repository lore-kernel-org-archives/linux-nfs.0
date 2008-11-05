From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 10/13] NFSD: Support AF_INET6 in svc_addsock() function
Date: Wed, 05 Nov 2008 12:29:36 -0500
Message-ID: <20081105172936.7330.72312.stgit@ingres.1015granger.net>
References: <20081105172351.7330.50739.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:36919 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752478AbYKERaI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Nov 2008 12:30:08 -0500
In-Reply-To: <20081105172351.7330.50739.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
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
index 62d65bb..a307834 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -1221,7 +1221,7 @@ int svc_addsock(struct svc_serv *serv, int fd, char *name_return, size_t len)
 
 	if (!so)
 		return err;
-	if (so->sk->sk_family != AF_INET)
+	if ((so->sk->sk_family != AF_INET) && (so->sk->sk_family != AF_INET6))
 		err =  -EAFNOSUPPORT;
 	else if (so->sk->sk_protocol != IPPROTO_TCP &&
 	    so->sk->sk_protocol != IPPROTO_UDP)


From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 05/40] SUNRPC: svc_setup_socket() gets protocol family from
	socket
Date: Thu, 12 Mar 2009 12:07:36 -0400
Message-ID: <20090312160736.16019.65556.stgit@ingres.1015granger.net>
References: <20090312155609.16019.86499.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org, trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:24071 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754694AbZCLQIc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 12 Mar 2009 12:08:32 -0400
In-Reply-To: <20090312155609.16019.86499.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Since the sv_family field is going away, modify svc_setup_socket() to
extract the protocol family from the passed-in socket instead of from
the passed-in svc_serv struct.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/svcsock.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index d00583c..d00bc33 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -1122,7 +1122,7 @@ static struct svc_sock *svc_setup_socket(struct svc_serv *serv,
 
 	/* Register socket with portmapper */
 	if (*errp >= 0 && pmap_register)
-		*errp = svc_register(serv, serv->sv_family, inet->sk_protocol,
+		*errp = svc_register(serv, inet->sk_family, inet->sk_protocol,
 				     ntohs(inet_sk(inet)->sport));
 
 	if (*errp < 0) {
@@ -1145,13 +1145,13 @@ static struct svc_sock *svc_setup_socket(struct svc_serv *serv,
 
 	/*
 	 * We start one listener per sv_serv.  We want AF_INET
-	 * requests to be automatically shunted to our AF_INET6
+	 * requests to be automatically shunted to our PF_INET6
 	 * listener using a mapped IPv4 address.  Make sure
 	 * no-one starts an equivalent IPv4 listener, which
 	 * would steal our incoming connections.
 	 */
 	val = 0;
-	if (serv->sv_family == AF_INET6)
+	if (inet->sk_family == PF_INET6)
 		kernel_setsockopt(sock, SOL_IPV6, IPV6_V6ONLY,
 					(char *)&val, sizeof(val));
 


Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:39153 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754116Ab1EITW2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 9 May 2011 15:22:28 -0400
Received: by yxs7 with SMTP id 7so1909710yxs.19
        for <linux-nfs@vger.kernel.org>; Mon, 09 May 2011 12:22:27 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 2/6] SUNRPC: Clean up use of curly braces in switch cases
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Mon, 09 May 2011 15:22:25 -0400
Message-ID: <20110509192225.16449.92373.stgit@matisse.1015granger.net>
In-Reply-To: <20110509191859.16449.73749.stgit@matisse.1015granger.net>
References: <20110509191859.16449.73749.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Clean up.  Preferred style is not to use curly braces around
switch cases.  I'm about to add another case that needs a third
type cast.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/clnt.c |   17 ++++++++---------
 1 files changed, 8 insertions(+), 9 deletions(-)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 8d83f9d..b91f8f9 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -298,22 +298,21 @@ struct rpc_clnt *rpc_create(struct rpc_create_args *args)
 	 * up a string representation of the passed-in address.
 	 */
 	if (args->servername == NULL) {
+		struct sockaddr_in *sin =
+				(struct sockaddr_in *)args->address;
+		struct sockaddr_in6 *sin6 =
+				(struct sockaddr_in6 *)args->address;
+
 		servername[0] = '\0';
 		switch (args->address->sa_family) {
-		case AF_INET: {
-			struct sockaddr_in *sin =
-					(struct sockaddr_in *)args->address;
+		case AF_INET:
 			snprintf(servername, sizeof(servername), "%pI4",
 				 &sin->sin_addr.s_addr);
 			break;
-		}
-		case AF_INET6: {
-			struct sockaddr_in6 *sin =
-					(struct sockaddr_in6 *)args->address;
+		case AF_INET6:
 			snprintf(servername, sizeof(servername), "%pI6",
-				 &sin->sin6_addr);
+				 &sin6->sin6_addr);
 			break;
-		}
 		default:
 			/* caller wants default server name, but
 			 * address family isn't recognized. */


Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:49542 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755416Ab1CVWJL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 22 Mar 2011 18:09:11 -0400
Received: by iyb26 with SMTP id 26so7900353iyb.19
        for <linux-nfs@vger.kernel.org>; Tue, 22 Mar 2011 15:09:11 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 1/4] SUNRPC: Clean up use of curly braces in switch cases
To: linux-nfs@vger.kernel.org
Date: Tue, 22 Mar 2011 18:09:08 -0400
Message-ID: <20110322220907.4360.79821.stgit@matisse.1015granger.net>
In-Reply-To: <20110322220518.4360.51304.stgit@matisse.1015granger.net>
References: <20110322220518.4360.51304.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Clean up.  Preferred style is not to use curly braces around
switch cases.  I'm about to add another case that needs yet
another different type cast.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/clnt.c |   17 ++++++++---------
 1 files changed, 8 insertions(+), 9 deletions(-)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 6111ea2..3725c6d 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -305,22 +305,21 @@ struct rpc_clnt *rpc_create(struct rpc_create_args *args)
 	 * up a string representation of the passed-in address.
 	 */
 	if (xprtargs.servername == NULL) {
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


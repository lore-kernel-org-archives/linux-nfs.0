Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:7447 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751880Ab0JFJqI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 6 Oct 2010 05:46:08 -0400
Message-ID: <4CAC4554.7020001@parallels.com>
Date: Wed, 06 Oct 2010 13:45:56 +0400
From: Pavel Emelyanov <xemul@parallels.com>
To: Chuck Lever <chuck.lever@oracle.com>,
        "J. Bruce Fields" <bfields@fieldses.org>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: [PATCH v2] sunrpc: Don't return NULL from rpcb_create
References: <4CAB56F0.9000504@parallels.com> <85B789F1-7E43-4C31-8C63-F1EF8C920051@oracle.com>
In-Reply-To: <85B789F1-7E43-4C31-8C63-F1EF8C920051@oracle.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

> The reason for this is in the future, we may want to support additional 
> address family types.  We should, therefore, ensure that every piece of 
> code that is sensitive to address families fail in some orderly manner
> to let developers know where a change is needed.

Makes sense. I was under impression, that AF-s other than INET are not
cared about at all :(

Here's a fixed version of the patch.

Log:

Its callers check for ERR_PTR.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
---

 net/sunrpc/rpcb_clnt.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
index 83af38d..1ef2d41 100644
--- a/net/sunrpc/rpcb_clnt.c
+++ b/net/sunrpc/rpcb_clnt.c
@@ -249,7 +249,7 @@ static struct rpc_clnt *rpcb_create(char *hostname, struct sockaddr *srvaddr,
 		((struct sockaddr_in6 *)srvaddr)->sin6_port = htons(RPCBIND_PORT);
 		break;
 	default:
-		return NULL;
+		return ERR_PTR(-EAFNOSUPPORT);
 	}
 
 	return rpc_create(&args);
-- 
1.5.5.6


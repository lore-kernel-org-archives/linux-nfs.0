From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 2/2] SUNRPC: Don't display zero scope IDs
Date: Tue, 12 Jan 2010 17:41:20 -0500
Message-ID: <20100112224120.3167.22567.stgit@localhost.localdomain>
References: <20100112223826.3167.13900.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:47206 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751808Ab0ALWmg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 12 Jan 2010 17:42:36 -0500
In-Reply-To: <20100112223826.3167.13900.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

A zero scope ID means that it wasn't set, so we don't need to append
it to presentation format addresses.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Acked-by: Jeff Layton <jlayton@redhat.com>
---

 net/sunrpc/addr.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/net/sunrpc/addr.c b/net/sunrpc/addr.c
index 0756c5d..f845d9d 100644
--- a/net/sunrpc/addr.c
+++ b/net/sunrpc/addr.c
@@ -73,6 +73,8 @@ static size_t rpc_ntop6(const struct sockaddr *sap,
 
 	if (!(ipv6_addr_type(&sin6->sin6_addr) & IPV6_ADDR_LINKLOCAL))
 		return len;
+	if (sin6->sin6_scope_id == 0)
+		return len;
 
 	rc = snprintf(scopebuf, sizeof(scopebuf), "%c%u",
 			IPV6_SCOPE_DELIMITER, sin6->sin6_scope_id);


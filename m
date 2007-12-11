From: Tom Tucker <tom@opengridcomputing.com>
Subject: [PATCH 03/38] svc: Change the svc_sock in the rqstp structure to a transport
Date: Tue, 11 Dec 2007 17:31:59 -0600
Message-ID: <20071211233158.15718.42885.stgit@dell3.ogc.int>
References: <20071211233150.15718.40579.stgit@dell3.ogc.int>
Content-Type: text/plain; charset=utf-8; format=fixed
Cc: neilb@suse.de, linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from 209-198-142-2-host.prismnet.net ([209.198.142.2]:35351 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753300AbXLKXcA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 11 Dec 2007 18:32:00 -0500
In-Reply-To: <20071211233150.15718.40579.stgit-gUwIgmpLGaKNDNWfRnPdfg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


The rqstp structure contains a pointer to the transport for the 
RPC request. This functionaly trivial patch adds an unamed union 
with pointers to both svc_sock and svc_xprt. Ultimately the 
union will be removed and only the rq_xprt field will remain. This 
allows incrementally extracting transport independent interfaces without 
one gigundo patch.

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
---

 include/linux/sunrpc/svc.h |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index 8531a70..37f7448 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -204,7 +204,10 @@ union svc_addr_u {
 struct svc_rqst {
 	struct list_head	rq_list;	/* idle list */
 	struct list_head	rq_all;		/* all threads list */
-	struct svc_sock *	rq_sock;	/* socket */
+	union {
+		struct svc_xprt *	rq_xprt;	/* transport ptr */
+		struct svc_sock *	rq_sock; 	/* socket ptr */
+	};
 	struct sockaddr_storage	rq_addr;	/* peer address */
 	size_t			rq_addrlen;
 

From: Tom Tucker <tom@opengridcomputing.com>
Subject: [RFC,
	PATCH 03/33] svc: Change the svc_sock in the rqstp structure to a
	transport
Date: Thu, 27 Sep 2007 00:01:40 -0500
Message-ID: <20070927050140.12677.25741.stgit@dell3.ogc.int>
References: <20070927045751.12677.98896.stgit@dell3.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: neilb@suse.de, gnb@sgi.com
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IalVO-0005b7-I9
	for nfs@lists.sourceforge.net; Wed, 26 Sep 2007 22:01:42 -0700
Received: from 209-198-142-2-host.prismnet.net ([209.198.142.2]
	helo=smtp.opengridcomputing.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IalVS-0005A5-8w
	for nfs@lists.sourceforge.net; Wed, 26 Sep 2007 22:01:47 -0700
In-Reply-To: <20070927045751.12677.98896.stgit@dell3.ogc.int>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net


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
 

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

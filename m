From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 8 of 8 - Get buf size and page count right for RPC services.
Date: Tue, 24 Jun 2003 16:54:53 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E19Uhhd-0001qy-00@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28] ident=root)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19Uhhx-0007Rc-00
	for <nfs@lists.sourceforge.net>; Mon, 23 Jun 2003 23:55:13 -0700
Received: From notabene ([129.94.172.124] == notabene.cse.unsw.EDU.AU)
	(for <torvalds@transmeta.com>) (for <nfs@lists.sourceforge.net>) By
	tone With Smtp ; Tue, 24 Jun 2003 16:55:00 +1000
To: Linus Torvalds <torvalds@transmeta.com>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

### Comments for ChangeSet

The old calculations BUGed on 64k PAGESIZE machines.

 ----------- Diffstat output ------------
 ./include/linux/sunrpc/svc.h |   15 +++++++++------
 ./net/sunrpc/svc.c           |    5 ++++-
 2 files changed, 13 insertions(+), 7 deletions(-)

diff ./include/linux/sunrpc/svc.h~current~ ./include/linux/sunrpc/svc.h
--- ./include/linux/sunrpc/svc.h~current~	2003-06-24 16:28:55.000000000 +1000
+++ ./include/linux/sunrpc/svc.h	2003-06-24 16:30:35.000000000 +1000
@@ -57,11 +57,11 @@ struct svc_serv {
  * Requests are copied into these pages as they arrive.  Remaining
  * pages are available to write the reply into.
  *
- * Currently pages are all re-used by the same server.  Later we 
- * will use ->sendpage to transmit pages with reduced copying.  In
- * that case we will need to give away the page and allocate new ones.
- * In preparation for this, we explicitly move pages off the recv
- * list onto the transmit list, and back.
+ * Pages are sent using ->sendpage so each server thread needs to
+ * allocate more to replace those used in sending.  To help keep track
+ * of these pages we have a receive list where all pages initialy live,
+ * and a send list where pages are moved to when there are to be part
+ * of a reply.
  *
  * We use xdr_buf for holding responses as it fits well with NFS
  * read responses (that have a header, and some data pages, and possibly
@@ -72,8 +72,11 @@ struct svc_serv {
  * list.  xdr_buf.tail points to the end of the first page.
  * This assumes that the non-page part of an rpc reply will fit
  * in a page - NFSd ensures this.  lockd also has no trouble.
+ *
+ * Each request/reply pair can have at most one "payload", plus two pages,
+ * one for the request, and one for the reply.
  */
-#define RPCSVC_MAXPAGES		((RPCSVC_MAXPAYLOAD+PAGE_SIZE-1)/PAGE_SIZE + 1)
+#define RPCSVC_MAXPAGES		((RPCSVC_MAXPAYLOAD+PAGE_SIZE-1)/PAGE_SIZE + 2)
 
 static inline u32 svc_getu32(struct iovec *iov)
 {

diff ./net/sunrpc/svc.c~current~ ./net/sunrpc/svc.c
--- ./net/sunrpc/svc.c~current~	2003-06-24 16:28:55.000000000 +1000
+++ ./net/sunrpc/svc.c	2003-06-24 16:29:14.000000000 +1000
@@ -113,9 +113,12 @@ svc_destroy(struct svc_serv *serv)
 static int
 svc_init_buffer(struct svc_rqst *rqstp, unsigned int size)
 {
-	int pages = 2 + (size+ PAGE_SIZE -1) / PAGE_SIZE;
+	int pages;
 	int arghi;
 	
+	if (size > RPCSVC_MAXPAYLOAD)
+		size = RPCSVC_MAXPAYLOAD;
+	pages = 2 + (size+ PAGE_SIZE -1) / PAGE_SIZE;
 	rqstp->rq_argused = 0;
 	rqstp->rq_resused = 0;
 	arghi = 0;


-------------------------------------------------------
This SF.Net email is sponsored by: INetU
Attention Web Developers & Consultants: Become An INetU Hosting Partner.
Refer Dedicated Servers. We Manage Them. You Get 10% Monthly Commission!
INetU Dedicated Managed Hosting http://www.inetu.net/partner/index.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

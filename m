From: NeilBrown <neilb@suse.de>
Subject: [PATCH 003 of 5] knfsd: Fix an NFSD bug with full sized,
	non-page-aligned reads.
Date: Tue, 23 Jan 2007 11:22:18 +1100
Message-ID: <1070123002218.27842@suse.de>
References: <20070123111558.27683.patches@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1H99Qz-0007RL-JG
	for nfs@lists.sourceforge.net; Mon, 22 Jan 2007 16:22:45 -0800
Received: from ns.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1H99R0-0002E5-Mc
	for nfs@lists.sourceforge.net; Mon, 22 Jan 2007 16:22:47 -0800
To: Andrew Morton <akpm@osdl.org>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net


NFSd assumes that largest number of pages that will be needed
for a request+response is 2+N where N pages is the size of the largest
permitted read/write request.  The '2' are 1 for the non-data part of
the request, and 1 for the non-data part of the reply.

However, when a read request is not page-aligned, and we choose to use
->sendfile to send it directly from the page cache, we may need N+1
pages to hold the whole reply.  This can overflow and array and cause
an Oops.

This patch increases size of the array for holding pages by one and
makes sure that entry is NULL when it is not in use.

Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./fs/nfsd/vfs.c              |    3 ++-
 ./include/linux/sunrpc/svc.h |    5 ++++-
 ./net/sunrpc/svcsock.c       |    2 ++
 3 files changed, 8 insertions(+), 2 deletions(-)

diff .prev/fs/nfsd/vfs.c ./fs/nfsd/vfs.c
--- .prev/fs/nfsd/vfs.c	2007-01-23 11:13:45.000000000 +1100
+++ ./fs/nfsd/vfs.c	2007-01-23 11:14:54.000000000 +1100
@@ -822,7 +822,8 @@ nfsd_read_actor(read_descriptor_t *desc,
 		rqstp->rq_res.page_len = size;
 	} else if (page != pp[-1]) {
 		get_page(page);
-		put_page(*pp);
+		if (*pp)
+			put_page(*pp);
 		*pp = page;
 		rqstp->rq_resused++;
 		rqstp->rq_res.page_len += size;

diff .prev/include/linux/sunrpc/svc.h ./include/linux/sunrpc/svc.h
--- .prev/include/linux/sunrpc/svc.h	2007-01-23 11:13:45.000000000 +1100
+++ ./include/linux/sunrpc/svc.h	2007-01-23 11:14:54.000000000 +1100
@@ -144,8 +144,11 @@ extern u32 svc_max_payload(const struct 
  *
  * Each request/reply pair can have at most one "payload", plus two pages,
  * one for the request, and one for the reply.
+ * We using ->sendfile to return read data, we might need one extra page
+ * if the request is not page-aligned.  So add another '1'.
  */
-#define RPCSVC_MAXPAGES		((RPCSVC_MAXPAYLOAD+PAGE_SIZE-1)/PAGE_SIZE + 2)
+#define RPCSVC_MAXPAGES		((RPCSVC_MAXPAYLOAD+PAGE_SIZE-1)/PAGE_SIZE \
+				+ 2 + 1)
 
 static inline u32 svc_getnl(struct kvec *iov)
 {

diff .prev/net/sunrpc/svcsock.c ./net/sunrpc/svcsock.c
--- .prev/net/sunrpc/svcsock.c	2007-01-23 11:13:45.000000000 +1100
+++ ./net/sunrpc/svcsock.c	2007-01-23 11:14:54.000000000 +1100
@@ -1306,6 +1306,8 @@ svc_recv(struct svc_rqst *rqstp, long ti
 				schedule_timeout_uninterruptible(msecs_to_jiffies(500));
 			rqstp->rq_pages[i] = p;
 		}
+	rqstp->rq_pages[i++] = NULL; /* this might be seen in nfs_read_actor */
+	BUG_ON(pages >= RPCSVC_MAXPAGES);
 
 	/* Make arg->head point to first page and arg->pages point to rest */
 	arg = &rqstp->rq_arg;

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

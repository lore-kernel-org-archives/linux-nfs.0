From: NeilBrown <neilb@suse.de>
Subject: [PATCH 013 of 14] knfsd: nfsd: mark rqstp to prevent use of
	sendfile in privacy case
Date: Tue, 27 Jun 2006 17:20:43 +1000
Message-ID: <1060627072043.26745@suse.de>
References: <20060627171533.26405.patches@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Fv7sR-0006QR-UH
	for nfs@lists.sourceforge.net; Tue, 27 Jun 2006 00:20:52 -0700
Received: from ns1.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Fv7sP-00072x-SU
	for nfs@lists.sourceforge.net; Tue, 27 Jun 2006 00:20:52 -0700
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

From: J. Bruce Fields <bfields@citi.umich.edu>


Add a rq_sendfile_ok flag to svc_rqst which will be cleared in the privacy
case so that the wrapping code will get copies of the read data instead of
real page cache pages.  This makes life simpler when we encrypt the
response.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>

### Diffstat output
 ./fs/nfsd/vfs.c              |    2 +-
 ./include/linux/sunrpc/svc.h |    4 +++-
 ./net/sunrpc/svc.c           |    2 ++
 3 files changed, 6 insertions(+), 2 deletions(-)

diff .prev/fs/nfsd/vfs.c ./fs/nfsd/vfs.c
--- .prev/fs/nfsd/vfs.c	2006-06-27 15:04:03.000000000 +1000
+++ ./fs/nfsd/vfs.c	2006-06-27 15:07:01.000000000 +1000
@@ -840,7 +840,7 @@ nfsd_vfs_read(struct svc_rqst *rqstp, st
 	if (ra && ra->p_set)
 		file->f_ra = ra->p_ra;
 
-	if (file->f_op->sendfile) {
+	if (file->f_op->sendfile && rqstp->rq_sendfile_ok) {
 		svc_pushback_unused_pages(rqstp);
 		err = file->f_op->sendfile(file, &offset, *count,
 						 nfsd_read_actor, rqstp);

diff .prev/include/linux/sunrpc/svc.h ./include/linux/sunrpc/svc.h
--- .prev/include/linux/sunrpc/svc.h	2006-06-27 15:07:01.000000000 +1000
+++ ./include/linux/sunrpc/svc.h	2006-06-27 15:07:01.000000000 +1000
@@ -159,7 +159,9 @@ struct svc_rqst {
 						 * determine what device number
 						 * to report (real or virtual)
 						 */
-
+	int			rq_sendfile_ok; /* turned off in gss privacy
+						 * to prevent encrypting page
+						 * cache pages */
 	wait_queue_head_t	rq_wait;	/* synchronization */
 };
 

diff .prev/net/sunrpc/svc.c ./net/sunrpc/svc.c
--- .prev/net/sunrpc/svc.c	2006-06-27 15:07:01.000000000 +1000
+++ ./net/sunrpc/svc.c	2006-06-27 15:07:01.000000000 +1000
@@ -281,6 +281,8 @@ svc_process(struct svc_serv *serv, struc
 	rqstp->rq_res.page_len = 0;
 	rqstp->rq_res.buflen = PAGE_SIZE;
 	rqstp->rq_res.tail[0].iov_len = 0;
+	/* Will be turned off only in gss privacy case: */
+	rqstp->rq_sendfile_ok = 1;
 	/* tcp needs a space for the record length... */
 	if (rqstp->rq_prot == IPPROTO_TCP)
 		svc_putu32(resv, 0);

Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

From: NeilBrown <neilb@suse.de>
Subject: [PATCH 010 of 16] knfsd: svcrpc: gss: don't call svc_take_page unnecessarily
Date: Mon, 3 Apr 2006 15:18:56 +1000
Message-ID: <1060403051856.1845@suse.de>
References: <20060403151452.1567.patches@notabene>
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FQHUa-0005UP-UB
	for nfs@lists.sourceforge.net; Sun, 02 Apr 2006 22:20:44 -0700
Received: from mx2.suse.de ([195.135.220.15])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1FQHUa-0004Tk-By
	for nfs@lists.sourceforge.net; Sun, 02 Apr 2006 22:20:44 -0700
To: Andrew Morton <akpm@osdl.org>
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>


We're using svc_take_page here to get another page for the tail in case one
wasn't already allocated.  But there isn't always guaranteed to be another
page available.

Also fix a typo that made us check the tail buffer for space when we meant
to be checking the head buffer.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./net/sunrpc/auth_gss/svcauth_gss.c |   14 ++++++++------
 1 file changed, 8 insertions(+), 6 deletions(-)

diff ./net/sunrpc/auth_gss/svcauth_gss.c~current~ ./net/sunrpc/auth_gss/svcauth_gss.c
--- ./net/sunrpc/auth_gss/svcauth_gss.c~current~	2006-04-03 15:12:14.000000000 +1000
+++ ./net/sunrpc/auth_gss/svcauth_gss.c	2006-04-03 15:12:14.000000000 +1000
@@ -1122,18 +1122,20 @@ svcauth_gss_release(struct svc_rqst *rqs
 					integ_len))
 			BUG();
 		if (resbuf->page_len == 0
-			&& resbuf->tail[0].iov_len + RPC_MAX_AUTH_SIZE
+			&& resbuf->head[0].iov_len + RPC_MAX_AUTH_SIZE
 				< PAGE_SIZE) {
 			BUG_ON(resbuf->tail[0].iov_len);
 			/* Use head for everything */
 			resv = &resbuf->head[0];
 		} else if (resbuf->tail[0].iov_base == NULL) {
-			/* copied from nfsd4_encode_read */
-			svc_take_page(rqstp);
-			resbuf->tail[0].iov_base = page_address(rqstp
-					->rq_respages[rqstp->rq_resused-1]);
-			rqstp->rq_restailpage = rqstp->rq_resused-1;
+			if (resbuf->head[0].iov_len + RPC_MAX_AUTH_SIZE
+					> PAGE_SIZE)
+				goto out_err;
+			resbuf->tail[0].iov_base =
+				resbuf->head[0].iov_base
+				+ resbuf->head[0].iov_len;
 			resbuf->tail[0].iov_len = 0;
+			rqstp->rq_restailpage = 0;
 			resv = &resbuf->tail[0];
 		} else {
 			resv = &resbuf->tail[0];


-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

From: NeilBrown <neilb@suse.de>
Subject: [PATCH 011 of 16] knfsd: svcrpc: WARN() instead of returning an error from svc_take_page
Date: Mon, 3 Apr 2006 15:19:01 +1000
Message-ID: <1060403051901.1857@suse.de>
References: <20060403151452.1567.patches@notabene>
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FQHUh-0005Up-3J
	for nfs@lists.sourceforge.net; Sun, 02 Apr 2006 22:20:51 -0700
Received: from mx2.suse.de ([195.135.220.15])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1FQHUf-0004UW-Er
	for nfs@lists.sourceforge.net; Sun, 02 Apr 2006 22:20:51 -0700
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


Every caller of svc_take_page ignores its return value and assumes it
succeeded.  So just WARN() instead of returning an ignored error.  This
would have saved some time debugging a recent nfsd4 problem.

If there are still failure cases here, then the result is probably that we
overwrite an earlier part of the reply while xdr-encoding.

While the corrupted reply is a nasty bug, it would be worse to panic here
and create the possibility of a remote DOS; hence WARN() instead of BUG().

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./include/linux/sunrpc/svc.h |    6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff ./include/linux/sunrpc/svc.h~current~ ./include/linux/sunrpc/svc.h
--- ./include/linux/sunrpc/svc.h~current~	2006-04-03 15:12:15.000000000 +1000
+++ ./include/linux/sunrpc/svc.h	2006-04-03 15:12:15.000000000 +1000
@@ -197,15 +197,13 @@ svc_take_res_page(struct svc_rqst *rqstp
 	return rqstp->rq_respages[rqstp->rq_resused++];
 }
 
-static inline int svc_take_page(struct svc_rqst *rqstp)
+static inline void svc_take_page(struct svc_rqst *rqstp)
 {
-	if (rqstp->rq_arghi <= rqstp->rq_argused)
-		return -ENOMEM;
+	WARN_ON(rqstp->rq_arghi <= rqstp->rq_argused);
 	rqstp->rq_arghi--;
 	rqstp->rq_respages[rqstp->rq_resused] =
 		rqstp->rq_argpages[rqstp->rq_arghi];
 	rqstp->rq_resused++;
-	return 0;
 }
 
 static inline void svc_pushback_allpages(struct svc_rqst *rqstp)


-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

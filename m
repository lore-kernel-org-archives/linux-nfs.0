From: NeilBrown <neilb@suse.de>
Subject: [PATCH 003 of 9] knfsd: svcrpc: use consistent variable name
	for the reply state
Date: Tue, 5 Sep 2006 09:15:38 +1000
Message-ID: <1060904231538.23086@suse.de>
References: <20060905090617.21303.patches@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GKNfM-0000KX-My
	for nfs@lists.sourceforge.net; Mon, 04 Sep 2006 16:15:44 -0700
Received: from ns1.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GKNfQ-00043F-CD
	for nfs@lists.sourceforge.net; Mon, 04 Sep 2006 16:15:49 -0700
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


From: J.Bruce Fields <bfields@fieldses.org>

The rpc reply has multiple levels of error returns.  The code here
contributes to the confusion by using "accept_statp" for a pointer to what
the rfc (and wireshark, etc.) refer to as the "reply_stat".  (The confusion
is compounded by the fact that the rfc also has an "accept_stat" which
follows the reply_stat in the succesful case.)

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./net/sunrpc/svc.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff .prev/net/sunrpc/svc.c ./net/sunrpc/svc.c
--- .prev/net/sunrpc/svc.c	2006-09-04 17:09:50.000000000 +1000
+++ ./net/sunrpc/svc.c	2006-09-04 17:15:35.000000000 +1000
@@ -699,7 +699,7 @@ svc_process(struct svc_rqst *rqstp)
 	u32			dir, prog, vers, proc,
 				auth_stat, rpc_stat;
 	int			auth_res;
-	u32			*accept_statp;
+	u32			*reply_statp;
 
 	rpc_stat = rpc_success;
 
@@ -740,7 +740,7 @@ svc_process(struct svc_rqst *rqstp)
 		goto err_bad_rpc;
 
 	/* Save position in case we later decide to reject: */
-	accept_statp = resv->iov_base + resv->iov_len;
+	reply_statp = resv->iov_base + resv->iov_len;
 
 	svc_putu32(resv, xdr_zero);		/* ACCEPT */
 
@@ -888,7 +888,7 @@ err_bad_auth:
 	dprintk("svc: authentication failed (%d)\n", ntohl(auth_stat));
 	serv->sv_stats->rpcbadauth++;
 	/* Restore write pointer to location of accept status: */
-	xdr_ressize_check(rqstp, accept_statp);
+	xdr_ressize_check(rqstp, reply_statp);
 	svc_putu32(resv, xdr_one);	/* REJECT */
 	svc_putu32(resv, xdr_one);	/* AUTH_ERROR */
 	svc_putu32(resv, auth_stat);	/* status */

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

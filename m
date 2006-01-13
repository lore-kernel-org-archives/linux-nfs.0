From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 010 of 26] svcrpc: gss: handle the GSS_S_CONTINUE
Date: Fri, 13 Jan 2006 12:00:57 +1100
Message-ID: <1060113010057.23048@cse.unsw.edu.au>
References: <20060113115744.22704.patches@notabene>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1ExDJO-0002YJ-Ac
	for nfs@lists.sourceforge.net; Thu, 12 Jan 2006 17:01:02 -0800
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.59] ident=root)
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1ExDJN-0006ir-QP
	for nfs@lists.sourceforge.net; Thu, 12 Jan 2006 17:01:02 -0800
Received: From
	smtp-dist.unsw.edu.au ([149.171.97.16] == smtp-dist-01.services.comms.unsw.EDU.AU)
	(for <nfs@lists.sourceforge.net>) By tone With Smtp ;
	Fri, 13 Jan 2006 12:00:59 +1100
Received: From
	neil.brown.name ([220.233.11.133] == 133.11.233.220.exetel.com.au) (auth-user neilb)
	(for <nfs@lists.sourceforge.net>) By tone With Smtp ;
	Fri, 13 Jan 2006 12:00:57 +1100
To: nfs@lists.sourceforge.net
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


Kerberos context initiation is handled in a single round trip, but other
mechanisms (including spkm3) may require more, so we need to handle the
GSS_S_CONTINUE case in svcauth_gss_accept. Send a null verifier.

Signed-off-by: Andy Adamson <andros@citi.umich.edu>
Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./net/sunrpc/auth_gss/svcauth_gss.c |   30 +++++++++++++++++++++++++-----
 1 file changed, 25 insertions(+), 5 deletions(-)

diff ./net/sunrpc/auth_gss/svcauth_gss.c~current~ ./net/sunrpc/auth_gss/svcauth_gss.c
--- ./net/sunrpc/auth_gss/svcauth_gss.c~current~	2006-01-13 11:50:54.000000000 +1100
+++ ./net/sunrpc/auth_gss/svcauth_gss.c	2006-01-13 11:51:06.000000000 +1100
@@ -586,6 +586,20 @@ gss_verify_header(struct svc_rqst *rqstp
 }
 
 static int
+gss_write_null_verf(struct svc_rqst *rqstp)
+{
+	u32     *p;
+
+	svc_putu32(rqstp->rq_res.head, htonl(RPC_AUTH_NULL));
+	p = rqstp->rq_res.head->iov_base + rqstp->rq_res.head->iov_len;
+	/* don't really need to check if head->iov_len > PAGE_SIZE ... */
+	*p++ = 0;
+	if (!xdr_ressize_check(rqstp, p))
+		return -1;
+	return 0;
+}
+
+static int
 gss_write_verf(struct svc_rqst *rqstp, struct gss_ctx *ctx_id, u32 seq)
 {
 	u32			xdr_seq;
@@ -876,12 +890,18 @@ svcauth_gss_accept(struct svc_rqst *rqst
 		case -ENOENT:
 			goto drop;
 		case 0:
-			rsci = gss_svc_searchbyctx(&rsip->out_handle);
-			if (!rsci) {
-				goto drop;
+			if (rsip->major_status == GSS_S_COMPLETE) {
+				rsci = gss_svc_searchbyctx(&rsip->out_handle);
+				if (!rsci) {
+					goto drop;
+				}
+				if (gss_write_verf(rqstp, rsci->mechctx,
+							GSS_SEQ_WIN))
+					goto drop;
+			} else {
+				if (gss_write_null_verf(rqstp))
+					goto drop;
 			}
-			if (gss_write_verf(rqstp, rsci->mechctx, GSS_SEQ_WIN))
-				goto drop;
 			if (resv->iov_len + 4 > PAGE_SIZE)
 				goto drop;
 			svc_putu32(resv, rpc_success);


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

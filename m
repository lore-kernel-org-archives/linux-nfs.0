From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 011 of 26] svcrpc: gss: server context init failure handling
Date: Fri, 13 Jan 2006 12:00:57 +1100
Message-ID: <1060113010057.23060@cse.unsw.edu.au>
References: <20060113115744.22704.patches@notabene>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1ExDJS-0002ZZ-Kp
	for nfs@lists.sourceforge.net; Thu, 12 Jan 2006 17:01:06 -0800
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.59] ident=root)
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1ExDJR-0004v9-MZ
	for nfs@lists.sourceforge.net; Thu, 12 Jan 2006 17:01:06 -0800
Received: From
	smtp-dist.unsw.edu.au ([149.171.97.16] == smtp-dist-01.services.comms.unsw.EDU.AU)
	(for <nfs@lists.sourceforge.net>) By tone With Smtp ;
	Fri, 13 Jan 2006 12:01:01 +1100
Received: From
	neil.brown.name ([220.233.11.133] == 133.11.233.220.exetel.com.au) (auth-user neilb)
	(for <nfs@lists.sourceforge.net>) By note With Smtp ;
	Fri, 13 Jan 2006 12:00:58 +1100
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


We require the server's gssd to create a completed context before asking the
kernel to send a final context init reply.  However, gssd could be buggy, or
under some bizarre circumstances we might purge the context from our cache
before we get the chance to use it here.

Handle this case by returning GSS_S_NO_CONTEXT to the client.

Also move the relevant code here to a separate function rather than nesting
excessively.

>From Kevin Coffman <kwc@citi.umich.edu>

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./net/sunrpc/auth_gss/svcauth_gss.c |   29 +++++++++++++++++------------
 1 file changed, 17 insertions(+), 12 deletions(-)

diff ./net/sunrpc/auth_gss/svcauth_gss.c~current~ ./net/sunrpc/auth_gss/svcauth_gss.c
--- ./net/sunrpc/auth_gss/svcauth_gss.c~current~	2006-01-13 11:51:06.000000000 +1100
+++ ./net/sunrpc/auth_gss/svcauth_gss.c	2006-01-13 11:51:06.000000000 +1100
@@ -755,6 +755,21 @@ svcauth_gss_set_client(struct svc_rqst *
 	return SVC_OK;
 }
 
+static inline int
+gss_write_init_verf(struct svc_rqst *rqstp, struct rsi *rsip)
+{
+	struct rsc *rsci;
+
+	if (rsip->major_status != GSS_S_COMPLETE)
+		return gss_write_null_verf(rqstp);
+	rsci = gss_svc_searchbyctx(&rsip->out_handle);
+	if (rsci == NULL) {
+		rsip->major_status = GSS_S_NO_CONTEXT;
+		return gss_write_null_verf(rqstp);
+	}
+	return gss_write_verf(rqstp, rsci->mechctx, GSS_SEQ_WIN);
+}
+
 /*
  * Accept an rpcsec packet.
  * If context establishment, punt to user space
@@ -890,18 +905,8 @@ svcauth_gss_accept(struct svc_rqst *rqst
 		case -ENOENT:
 			goto drop;
 		case 0:
-			if (rsip->major_status == GSS_S_COMPLETE) {
-				rsci = gss_svc_searchbyctx(&rsip->out_handle);
-				if (!rsci) {
-					goto drop;
-				}
-				if (gss_write_verf(rqstp, rsci->mechctx,
-							GSS_SEQ_WIN))
-					goto drop;
-			} else {
-				if (gss_write_null_verf(rqstp))
-					goto drop;
-			}
+			if (gss_write_init_verf(rqstp, rsip))
+				goto drop;
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

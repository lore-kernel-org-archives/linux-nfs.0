From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 6 of 18] rpcsec_gss: comparing pointer to 0 instead of NULL
Date: Tue, 16 Nov 2004 15:50:49 +1100
Message-ID: <E1CTvIn-0004pe-UV@notabene.cse.unsw.edu.au>
References: <20041116154601.18412.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CTvF6-0005s3-4I
	for nfs@lists.sourceforge.net; Mon, 15 Nov 2004 20:47:00 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1CTvF1-0007Hq-5y
	for nfs@lists.sourceforge.net; Mon, 15 Nov 2004 20:46:59 -0800
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



Just noticed while fixing some other sparse-related stuff.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./net/sunrpc/auth_gss/svcauth_gss.c |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

diff ./net/sunrpc/auth_gss/svcauth_gss.c~current~ ./net/sunrpc/auth_gss/svcauth_gss.c
--- ./net/sunrpc/auth_gss/svcauth_gss.c~current~	2004-11-16 14:41:21.000000000 +1100
+++ ./net/sunrpc/auth_gss/svcauth_gss.c	2004-11-16 14:41:21.000000000 +1100
@@ -958,7 +958,7 @@ svcauth_gss_release(struct svc_rqst *rqs
 	if (gc->gc_proc != RPC_GSS_PROC_DATA)
 		goto out;
 	/* Release can be called twice, but we only wrap once. */
-	if (gsd->body_start == 0)
+	if (gsd->body_start == NULL)
 		goto out;
 	/* normally not set till svc_send, but we need it here: */
 	resbuf->len = resbuf->head[0].iov_len


-------------------------------------------------------
This SF.Net email is sponsored by: InterSystems CACHE
FREE OODBMS DOWNLOAD - A multidimensional database that combines
robust object and relational technologies, making it a perfect match
for Java, C++,COM, XML, ODBC and JDBC. www.intersystems.com/match8
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

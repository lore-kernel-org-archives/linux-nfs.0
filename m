From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd ] Make sure svc_process call the correct pg_authenticate for multi-service port
Date: Mon, 31 Oct 2005 17:01:09 +1100
Message-ID: <1051031060109.8246@cse.unsw.edu.au>
References: <20051031165939.8227.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EWSjO-0002aN-1P
	for nfs@lists.sourceforge.net; Sun, 30 Oct 2005 22:01:18 -0800
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.59] ident=root)
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1EWSjM-0001d4-DN
	for nfs@lists.sourceforge.net; Sun, 30 Oct 2005 22:01:18 -0800
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

Patch against 2.6.14-rc5-mm1.  Should apply against most recent 2.6 
kernels.  Fixes potential bug, not an actual bug (at least, not in mainline..)

--

If an RPC socket is serving multiple programs, then the
pg_authenticate of the first program in the list is called,
instead of pg_authenticate for the program to be run.

This does not cause a problem with any programs in the current kernel,
but could confuse future code.

Also set pg_authenticate for nfsd_acl_program incase it ever gets used.


Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./fs/nfsd/nfssvc.c |    1 +
 ./net/sunrpc/svc.c |   12 +++++++-----
 2 files changed, 8 insertions(+), 5 deletions(-)

diff ./fs/nfsd/nfssvc.c~current~ ./fs/nfsd/nfssvc.c
--- ./fs/nfsd/nfssvc.c~current~	2005-10-31 15:55:20.000000000 +1100
+++ ./fs/nfsd/nfssvc.c	2005-10-31 15:55:20.000000000 +1100
@@ -427,6 +427,7 @@ static struct svc_program	nfsd_acl_progr
 	.pg_name		= "nfsd",
 	.pg_class		= "nfsd",
 	.pg_stats		= &nfsd_acl_svcstats,
+	.pg_authenticate	= &svc_set_client,
 };
 
 static struct svc_stat	nfsd_acl_svcstats = {

diff ./net/sunrpc/svc.c~current~ ./net/sunrpc/svc.c
--- ./net/sunrpc/svc.c~current~	2005-10-31 15:55:20.000000000 +1100
+++ ./net/sunrpc/svc.c	2005-10-31 15:55:20.000000000 +1100
@@ -310,6 +310,11 @@ svc_process(struct svc_serv *serv, struc
 	rqstp->rq_proc = proc = ntohl(svc_getu32(argv));	/* procedure number */
 
 	progp = serv->sv_program;
+
+	for (progp = serv->sv_program; progp; progp = progp->pg_next)
+		if (prog == progp->pg_prog)
+			break;
+
 	/*
 	 * Decode auth data, and add verifier to reply buffer.
 	 * We do this before anything else in order to get a decent
@@ -317,7 +322,7 @@ svc_process(struct svc_serv *serv, struc
 	 */
 	auth_res = svc_authenticate(rqstp, &auth_stat);
 	/* Also give the program a chance to reject this call: */
-	if (auth_res == SVC_OK) {
+	if (auth_res == SVC_OK && progp) {
 		auth_stat = rpc_autherr_badcred;
 		auth_res = progp->pg_authenticate(rqstp);
 	}
@@ -337,10 +342,7 @@ svc_process(struct svc_serv *serv, struc
 	case SVC_COMPLETE:
 		goto sendit;
 	}
-		
-	for (progp = serv->sv_program; progp; progp = progp->pg_next)
-		if (prog == progp->pg_prog)
-			break;
+
 	if (progp == NULL)
 		goto err_bad_prog;
 


-------------------------------------------------------
This SF.Net email is sponsored by the JBoss Inc.
Get Certified Today * Register for a JBoss Training Course
Free Certification Exam for All Training Attendees Through End of 2005
Visit http://www.jboss.com/services/certification for more information
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

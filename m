From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSdv4 - 5 of 10 - Fix bad error returm from svcauth_gss_accept
Date: Thu, 08 Apr 2004 11:18:46 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E1BBOBq-0001Qq-K5@notabene.cse.unsw.edu.au>
References: <20040408111135.5397.patches@notabene>
Cc: nfs@lists.sourceforge.net,  "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BBOCG-0007i8-T1
	for nfs@lists.sourceforge.net; Wed, 07 Apr 2004 18:19:12 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1BBOCF-00021y-9c
	for nfs@lists.sourceforge.net; Wed, 07 Apr 2004 18:19:11 -0700
Received: From
	notabene.cse.unsw.edu.au ([129.94.241.7] == ppp2-007.ppp2.cse.unsw.EDU.AU) (auth-user neilb)
	(for <akpm@osdl.org>) (for <nfs@lists.sourceforge.net>)
	(for <bfields@fieldses.org>) By note With Smtp ;
	Thu, 8 Apr 2004 11:19:07 +1000
To: Andrew Morton <akpm@osdl.org>
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


From: "J. Bruce Fields" <bfields@fieldses.org>

Error return when the client supplies a bad service should be badcred.

 ----------- Diffstat output ------------
 ./net/sunrpc/auth_gss/svcauth_gss.c |    1 +
 1 files changed, 1 insertion(+)

diff ./net/sunrpc/auth_gss/svcauth_gss.c~current~ ./net/sunrpc/auth_gss/svcauth_gss.c
--- ./net/sunrpc/auth_gss/svcauth_gss.c~current~	2004-04-08 10:56:10.000000000 +1000
+++ ./net/sunrpc/auth_gss/svcauth_gss.c	2004-04-08 10:56:10.000000000 +1000
@@ -895,6 +895,7 @@ svcauth_gss_accept(struct svc_rqst *rqst
 		svc_putu32(resv, rpc_success);
 		goto complete;
 	case RPC_GSS_PROC_DATA:
+		*authp = rpc_autherr_badcred;
 		rqstp->rq_client =
 			find_gss_auth_domain(rsci->mechctx, gc->gc_svc);
 		if (rqstp->rq_client == NULL)


-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

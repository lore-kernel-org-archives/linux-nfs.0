From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH]  Remove un-necessary locking in lockd
Date: Mon, 20 Oct 2003 11:32:19 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E1ABOuB-0002a9-00@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1ABQv3-0007lA-00
	for <nfs@lists.sourceforge.net>; Sun, 19 Oct 2003 20:41:21 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with smtp (Exim 4.22)
	id 1ABQtj-0000fX-Q2
	for nfs@lists.sourceforge.net; Sun, 19 Oct 2003 20:39:59 -0700
Received: From notabene ([129.94.211.194] == dulcimer.orchestra.cse.unsw.EDU.AU)
	(for <marcelo.tosatti@cyclades.com.br>)
	(for <nfs@lists.sourceforge.net>) By note With Smtp ;
	Mon, 20 Oct 2003 11:32:19 +1000
To: Marcelo Tosatti <marcelo.tosatti@cyclades.com.br>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>


Two places in lockd readlock the nfsd export table before calling
exp_getclient.
This is not needed because the export table is already locked by
code in svc.c.
It is a problem because if a write_lock is attempted while the svc.c
readlock is active, and before the secondary readlock is attempted,
you get a deadlock.

 ----------- Diffstat output ------------
 ./fs/lockd/svc4proc.c |    2 --
 ./fs/lockd/svcproc.c  |    2 --
 2 files changed, 4 deletions(-)

diff ./fs/lockd/svc4proc.c~current~ ./fs/lockd/svc4proc.c
--- ./fs/lockd/svc4proc.c~current~	2003-10-20 11:31:33.000000000 +1000
+++ ./fs/lockd/svc4proc.c	2003-10-20 11:31:33.000000000 +1000
@@ -449,13 +449,11 @@ nlm4svc_proc_sm_notify(struct svc_rqst *
 	if (nlmsvc_ops != NULL) {
 		struct svc_client	*clnt;
 		saddr.sin_addr.s_addr = argp->addr;
-		nlmsvc_ops->exp_readlock();
 		if ((clnt = nlmsvc_ops->exp_getclient(&saddr)) != NULL 
 		 && (host = nlm_lookup_host(clnt, &saddr, 0, 0)) != NULL) {
 			nlmsvc_free_host_resources(host);
 		}
 		nlm_release_host(host);
-		nlmsvc_ops->exp_unlock();
 	}
 
 	return rpc_success;

diff ./fs/lockd/svcproc.c~current~ ./fs/lockd/svcproc.c
--- ./fs/lockd/svcproc.c~current~	2003-10-20 11:31:33.000000000 +1000
+++ ./fs/lockd/svcproc.c	2003-10-20 11:31:33.000000000 +1000
@@ -477,13 +477,11 @@ nlmsvc_proc_sm_notify(struct svc_rqst *r
 	if (nlmsvc_ops != NULL) {
 		struct svc_client	*clnt;
 		saddr.sin_addr.s_addr = argp->addr;
-		nlmsvc_ops->exp_readlock();
 		if ((clnt = nlmsvc_ops->exp_getclient(&saddr)) != NULL 
 		 && (host = nlm_lookup_host(clnt, &saddr, 0, 0)) != NULL) {
 			nlmsvc_free_host_resources(host);
 		}
 		nlm_release_host(host);
-		nlmsvc_ops->exp_unlock();
 	}
 
 	return rpc_success;


-------------------------------------------------------
This SF.net email sponsored by: Enterprise Linux Forum Conference & Expo
The Event For Linux Datacenter Solutions & Strategies in The Enterprise 
Linux in the Boardroom; in the Front Office; & in the Server Room 
http://www.enterpriselinuxforum.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

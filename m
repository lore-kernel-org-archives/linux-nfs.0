From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 8 of 8 - Set nfsd user every time a filehandle is verified.
Date: Wed, 18 Jun 2003 09:51:37 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E19SQEj-00084B-00@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28] ident=root)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19SQBP-0002U1-00
	for <nfs@lists.sourceforge.net>; Tue, 17 Jun 2003 16:48:11 -0700
Received: From notabene ([129.94.172.124] == notabene.cse.unsw.EDU.AU)
	(for <torvalds@transmeta.com>) (for <nfs@lists.sourceforge.net>) By
	tone With Smtp ; Wed, 18 Jun 2003 09:47:07 +1000
To: Linus Torvalds <torvalds@transmeta.com>
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

### Comments for ChangeSet
request might traverse several export points which may
have different uid squashing.

 ----------- Diffstat output ------------
 ./fs/nfsd/auth.c             |    4 ----
 ./fs/nfsd/nfsfh.c            |    7 ++++---
 ./include/linux/sunrpc/svc.h |    1 -
 ./net/sunrpc/svcsock.c       |    1 -
 4 files changed, 4 insertions(+), 9 deletions(-)

diff ./fs/nfsd/auth.c~current~ ./fs/nfsd/auth.c
--- ./fs/nfsd/auth.c~current~	2003-06-18 09:31:29.000000000 +1000
+++ ./fs/nfsd/auth.c	2003-06-18 09:31:29.000000000 +1000
@@ -17,9 +17,6 @@ nfsd_setuser(struct svc_rqst *rqstp, str
 	struct svc_cred	*cred = &rqstp->rq_cred;
 	int		i;
 
-	if (rqstp->rq_userset)
-		return;
-
 	if (exp->ex_flags & NFSEXP_ALLSQUASH) {
 		cred->cr_uid = exp->ex_anon_uid;
 		cred->cr_gid = exp->ex_anon_gid;
@@ -57,5 +54,4 @@ nfsd_setuser(struct svc_rqst *rqstp, str
 						  current->cap_permitted);
 	}
 
-	rqstp->rq_userset = 1;
 }

diff ./fs/nfsd/nfsfh.c~current~ ./fs/nfsd/nfsfh.c
--- ./fs/nfsd/nfsfh.c~current~	2003-06-18 09:31:29.000000000 +1000
+++ ./fs/nfsd/nfsfh.c	2003-06-18 09:31:29.000000000 +1000
@@ -161,9 +161,6 @@ fh_verify(struct svc_rqst *rqstp, struct
 			goto out;
 		}
 
-		/* Set user creds if we haven't done so already. */
-		nfsd_setuser(rqstp, exp);
-
 		/*
 		 * Look up the dentry using the NFS file handle.
 		 */
@@ -223,6 +220,10 @@ fh_verify(struct svc_rqst *rqstp, struct
 
 	inode = dentry->d_inode;
 
+
+	/* Set user creds for this exportpoint */
+	nfsd_setuser(rqstp, exp);
+
 	/* Type check. The correct error return for type mismatches
 	 * does not seem to be generally agreed upon. SunOS seems to
 	 * use EISDIR if file isn't S_IFREG; a comment in the NFSv3

diff ./include/linux/sunrpc/svc.h~current~ ./include/linux/sunrpc/svc.h
--- ./include/linux/sunrpc/svc.h~current~	2003-06-18 09:30:59.000000000 +1000
+++ ./include/linux/sunrpc/svc.h	2003-06-18 09:31:29.000000000 +1000
@@ -125,7 +125,6 @@ struct svc_rqst {
 	u32			rq_proc;	/* procedure number */
 	u32			rq_prot;	/* IP protocol */
 	unsigned short
-				rq_userset : 1,	/* auth->setuser OK */
 				rq_secure  : 1;	/* secure port */
 
 

diff ./net/sunrpc/svcsock.c~current~ ./net/sunrpc/svcsock.c
--- ./net/sunrpc/svcsock.c~current~	2003-06-18 09:30:59.000000000 +1000
+++ ./net/sunrpc/svcsock.c	2003-06-18 09:31:29.000000000 +1000
@@ -1222,7 +1222,6 @@ svc_recv(struct svc_serv *serv, struct s
 	}
 
 	rqstp->rq_secure  = ntohs(rqstp->rq_addr.sin_port) < 1024;
-	rqstp->rq_userset = 0;
 	rqstp->rq_chandle.defer = svc_defer;
 
 	if (serv->sv_stats)


-------------------------------------------------------
This SF.Net email is sponsored by: INetU
Attention Web Developers & Consultants: Become An INetU Hosting Partner.
Refer Dedicated Servers. We Manage Them. You Get 10% Monthly Commission!
INetU Dedicated Managed Hosting http://www.inetu.net/partner/index.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 7 of 16 - Discard cl_idlen
Date: Thu, 12 Sep 2002 12:35:06 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1020912023506.19603@cse.unsw.edu.au>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17pJpR-0002I2-00
	for <nfs@lists.sourceforge.net>; Wed, 11 Sep 2002 19:35:37 -0700
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>


### Comments for ChangeSet

It is never used




 ----------- Diffstat output ------------
 ./fs/nfsd/export.c            |    1 -
 ./include/linux/nfsd/export.h |    1 -
 2 files changed, 2 deletions(-)

--- ./include/linux/nfsd/export.h	2002/09/11 01:33:52	1.4
+++ ./include/linux/nfsd/export.h	2002/09/11 01:35:01	1.5
@@ -51,7 +51,6 @@
 struct svc_client {
 	struct svc_client *	cl_next;
 	char			cl_ident[NFSCLNT_IDMAX];
-	int			cl_idlen;
 	int			cl_naddr;
 	struct in_addr		cl_addr[NFSCLNT_ADDRMAX];
 	struct list_head	cl_export[NFSCLNT_EXPMAX];
--- ./fs/nfsd/export.c	2002/09/11 01:34:31	1.6
+++ ./fs/nfsd/export.c	2002/09/11 01:35:01	1.7
@@ -734,7 +734,6 @@ exp_addclient(struct nfsctl_client *ncp)
 		dprintk("created client %s (%p)\n", ncp->cl_ident, clp);
 
 		strcpy(clp->cl_ident, ncp->cl_ident);
-		clp->cl_idlen = ilen;
 	}
 
 	/* Allocate hash buckets */


-------------------------------------------------------
In remembrance
www.osdn.com/911/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 4 of 16 - Discard svc_uidmap structure
Date: Thu, 12 Sep 2002 12:34:38 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1020912023438.19557@cse.unsw.edu.au>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17pJon-0002CG-00
	for <nfs@lists.sourceforge.net>; Wed, 11 Sep 2002 19:34:57 -0700
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

It is un-used and never will be.  uid mapping will be done a 
different way (if at all).




 ----------- Diffstat output ------------
 ./fs/nfsd/export.c            |    1 -
 ./include/linux/nfsd/auth.h   |   18 ------------------
 ./include/linux/nfsd/export.h |    1 -
 3 files changed, 20 deletions(-)

--- ./include/linux/nfsd/export.h	2002/09/11 01:10:25	1.2
+++ ./include/linux/nfsd/export.h	2002/09/11 01:32:34	1.3
@@ -54,7 +54,6 @@ struct svc_client {
 	int			cl_idlen;
 	int			cl_naddr;
 	struct in_addr		cl_addr[NFSCLNT_ADDRMAX];
-	struct svc_uidmap *	cl_umap;
 	struct list_head	cl_export[NFSCLNT_EXPMAX];
 	struct list_head	cl_expfsid[NFSCLNT_EXPMAX];
 	struct list_head	cl_list;
--- ./include/linux/nfsd/auth.h	2002/09/11 01:32:05	1.1
+++ ./include/linux/nfsd/auth.h	2002/09/11 01:32:34	1.2
@@ -23,23 +23,5 @@
  */
 void		nfsd_setuser(struct svc_rqst *, struct svc_export *);
 
-#if 0
-/*
- * These must match the actual size of uid_t and gid_t
- */
-#define UGID_BITS		(8 * sizeof(uid_t))
-#define UGID_SHIFT		8
-#define UGID_MASK		((1 << UGID_SHIFT) - 1)
-#define UGID_NRENTRIES		((1 << (UGID_BITS - UGID_SHIFT)) + 1)
-#define UGID_NONE		((unsigned short)-1)
-
-typedef struct svc_uidmap {
-	uid_t *			um_ruid[UGID_NRENTRIES];
-	uid_t *			um_luid[UGID_NRENTRIES];
-	gid_t *			um_rgid[UGID_NRENTRIES];
-	gid_t *			um_lgid[UGID_NRENTRIES];
-} svc_uidmap;
-#endif
-
 #endif /* __KERNEL__ */
 #endif /* LINUX_NFSD_AUTH_H */
--- ./fs/nfsd/export.c	2002/09/11 01:28:27	1.3
+++ ./fs/nfsd/export.c	2002/09/11 01:32:34	1.4
@@ -838,7 +838,6 @@ exp_freeclient(svc_client *clp)
 {
 	exp_unhashclient(clp);
 
-	/* umap_free(&(clp->cl_umap)); */
 	exp_unexport_all(clp);
 	kfree (clp);
 }


-------------------------------------------------------
In remembrance
www.osdn.com/911/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

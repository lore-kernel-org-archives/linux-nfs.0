From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSdv4 - 2 of 10 - better handling of failed idmap lookups
Date: Thu, 08 Apr 2004 11:18:46 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E1BBOBq-0001Qh-FD@notabene.cse.unsw.edu.au>
References: <20040408111135.5397.patches@notabene>
Cc: nfs@lists.sourceforge.net,  "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BBOCE-0007h8-3A
	for nfs@lists.sourceforge.net; Wed, 07 Apr 2004 18:19:10 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1BBOCD-0008Vq-Fv
	for nfs@lists.sourceforge.net; Wed, 07 Apr 2004 18:19:09 -0700
Received: From
	notabene.cse.unsw.edu.au ([129.94.241.7] == ppp2-007.ppp2.cse.unsw.EDU.AU) (auth-user neilb)
	(for <akpm@osdl.org>) (for <nfs@lists.sourceforge.net>)
	(for <bfields@fieldses.org>) By note With Smtp ;
	Thu, 8 Apr 2004 11:19:04 +1000
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

Slightly better behavior on failed mapping (which may happen either because
idmapd is not running, or because there it has told us it doesn't know the
mapping.):
	on name->id (setattr), return BADNAME.  (I used ESRCH to
		communicate BADNAME, just because it was the first error in
		include/asm-generic/errno-base.h that had something to
		do with nonexistance of something, and that we weren't
		already using.)
	id->name (getattr), return a string representation of the numerical
		id.  This is probably useless to the client, especially
		since we're unlikely to accept such a string on a setattr,
		but perhaps some client will find it mildly helpful.


 ----------- Diffstat output ------------
 ./fs/nfsd/nfs4idmap.c       |    4 ++++
 ./fs/nfsd/nfsproc.c         |    1 +
 ./include/linux/nfsd/nfsd.h |    1 +
 3 files changed, 6 insertions(+)

diff ./fs/nfsd/nfs4idmap.c~current~ ./fs/nfsd/nfs4idmap.c
--- ./fs/nfsd/nfs4idmap.c~current~	2004-04-08 10:50:09.000000000 +1000
+++ ./fs/nfsd/nfs4idmap.c	2004-04-08 10:50:13.000000000 +1000
@@ -545,6 +545,8 @@ idmap_name_to_id(struct svc_rqst *rqstp,
 	key.name[namelen] = '\0';
 	strlcpy(key.authname, rqstp->rq_client->name, sizeof(key.authname));
 	ret = idmap_lookup(rqstp, nametoid_lookup, &key, &nametoid_cache, &item);
+	if (ret == -ENOENT)
+		ret = -ESRCH; /* nfserr_badname */
 	if (ret)
 		return ret;
 	*id = item->id;
@@ -563,6 +565,8 @@ idmap_id_to_name(struct svc_rqst *rqstp,
 
 	strlcpy(key.authname, rqstp->rq_client->name, sizeof(key.authname));
 	ret = idmap_lookup(rqstp, idtoname_lookup, &key, &idtoname_cache, &item);
+	if (ret == -ENOENT)
+		return sprintf(name, "%u", id);
 	if (ret)
 		return ret;
 	ret = strlen(item->name);

diff ./fs/nfsd/nfsproc.c~current~ ./fs/nfsd/nfsproc.c
--- ./fs/nfsd/nfsproc.c~current~	2004-04-06 10:57:05.000000000 +1000
+++ ./fs/nfsd/nfsproc.c	2004-04-08 10:50:13.000000000 +1000
@@ -588,6 +588,7 @@ nfserrno (int errno)
 		{ nfserr_jukebox, -ETIMEDOUT },
 		{ nfserr_dropit, -EAGAIN },
 		{ nfserr_dropit, -ENOMEM },
+		{ nfserr_badname, -ESRCH },
 		{ -1, -EIO }
 	};
 	int	i;

diff ./include/linux/nfsd/nfsd.h~current~ ./include/linux/nfsd/nfsd.h
--- ./include/linux/nfsd/nfsd.h~current~	2004-04-06 10:57:05.000000000 +1000
+++ ./include/linux/nfsd/nfsd.h	2004-04-08 10:50:13.000000000 +1000
@@ -196,6 +196,7 @@ void		nfsd_lockd_shutdown(void);
 #define	nfserr_openmode		__constant_htonl(NFSERR_OPENMODE)
 #define	nfserr_locks_held	__constant_htonl(NFSERR_LOCKS_HELD)
 #define	nfserr_op_illegal	__constant_htonl(NFSERR_OP_ILLEGAL)
+#define nfserr_badname		__constant_htonl(NFSERR_BADNAME)
 
 /* error codes for internal use */
 /* if a request fails due to kmalloc failure, it gets dropped.


-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

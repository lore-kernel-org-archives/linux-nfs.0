From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 7 of 10 - Improve idmapper behaviour on failure.
Date: Tue, 18 May 2004 11:31:38 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E1BPtSE-0004BS-R7@notabene.cse.unsw.edu.au>
References: <20040518112921.15964.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BPtSO-00072c-KL
	for nfs@lists.sourceforge.net; Mon, 17 May 2004 18:31:48 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1BPtSN-0002Vy-Uy
	for nfs@lists.sourceforge.net; Mon, 17 May 2004 18:31:48 -0700
Received: From notabene.cse.unsw.edu.au ([129.94.172.124]) (auth-user neilb)
	(for <akpm@osdl.org>) (for <nfs@lists.sourceforge.net>) By note With
	Smtp ; Tue, 18 May 2004 11:31:40 +1000
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


From: "J. Bruce Fields" <bfields@fieldses.org>

 ----------- Diffstat output ------------
 ./fs/nfsd/nfs4idmap.c       |    4 ++++
 ./fs/nfsd/nfsproc.c         |    1 +
 ./include/linux/nfsd/nfsd.h |    1 +
 3 files changed, 6 insertions(+)

diff ./fs/nfsd/nfs4idmap.c~current~ ./fs/nfsd/nfs4idmap.c
--- ./fs/nfsd/nfs4idmap.c~current~	2004-05-18 11:17:53.000000000 +1000
+++ ./fs/nfsd/nfs4idmap.c	2004-05-18 11:18:14.000000000 +1000
@@ -543,6 +543,8 @@ idmap_name_to_id(struct svc_rqst *rqstp,
 	key.name[namelen] = '\0';
 	strlcpy(key.authname, rqstp->rq_client->name, sizeof(key.authname));
 	ret = idmap_lookup(rqstp, nametoid_lookup, &key, &nametoid_cache, &item);
+	if (ret == -ENOENT)
+		ret = -ESRCH; /* nfserr_badname */
 	if (ret)
 		return ret;
 	*id = item->id;
@@ -561,6 +563,8 @@ idmap_id_to_name(struct svc_rqst *rqstp,
 
 	strlcpy(key.authname, rqstp->rq_client->name, sizeof(key.authname));
 	ret = idmap_lookup(rqstp, idtoname_lookup, &key, &idtoname_cache, &item);
+	if (ret == -ENOENT)
+		return sprintf(name, "%u", id);
 	if (ret)
 		return ret;
 	ret = strlen(item->name);

diff ./fs/nfsd/nfsproc.c~current~ ./fs/nfsd/nfsproc.c
--- ./fs/nfsd/nfsproc.c~current~	2004-05-18 11:16:20.000000000 +1000
+++ ./fs/nfsd/nfsproc.c	2004-05-18 11:18:14.000000000 +1000
@@ -589,6 +589,7 @@ nfserrno (int errno)
 		{ nfserr_jukebox, -ETIMEDOUT },
 		{ nfserr_dropit, -EAGAIN },
 		{ nfserr_dropit, -ENOMEM },
+		{ nfserr_badname, -ESRCH },
 		{ -1, -EIO }
 	};
 	int	i;

diff ./include/linux/nfsd/nfsd.h~current~ ./include/linux/nfsd/nfsd.h
--- ./include/linux/nfsd/nfsd.h~current~	2004-05-18 11:09:16.000000000 +1000
+++ ./include/linux/nfsd/nfsd.h	2004-05-18 11:18:14.000000000 +1000
@@ -199,6 +199,7 @@ void		nfsd_lockd_shutdown(void);
 #define	nfserr_grace		__constant_htonl(NFSERR_GRACE)
 #define	nfserr_no_grace		__constant_htonl(NFSERR_NO_GRACE)
 #define	nfserr_reclaim_bad	__constant_htonl(NFSERR_RECLAIM_BAD)
+#define	nfserr_badname		__constant_htonl(NFSERR_BADNAME)
 
 /* error codes for internal use */
 /* if a request fails due to kmalloc failure, it gets dropped.


-------------------------------------------------------
This SF.Net email is sponsored by: SourceForge.net Broadband
Sign-up now for SourceForge Broadband and get the fastest
6.0/768 connection for only $19.95/mo for the first 3 months!
http://ads.osdn.com/?ad_id=2562&alloc_id=6184&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 2 of 12 - NFSv4: error codes in include/linux/nfsd/nfsd.h
Date: Thu, 22 Aug 2002 10:34:44 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E17hfvw-000512-00@notabene.cse.unsw.edu.au>
Cc: nfs@lists.sourceforge.net,  "Kendrick M. Smith" <kmsmith@umich.edu>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17hfwE-0008Ht-00
	for <nfs@lists.sourceforge.net>; Wed, 21 Aug 2002 17:35:02 -0700
Received: From
	notabene.cse.unsw.edu.au ([129.94.242.45] == bartok.orchestra.cse.unsw.EDU.AU)
	(for <torvalds@transmeta.com>) (for <nfs@lists.sourceforge.net>)
	(for <kmsmith@umich.edu>) By tone With Smtp ;
	Thu, 22 Aug 2002 10:34:51 +1000
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

From:	"Kendrick M. Smith" <kmsmith@umich.edu>
Add some new NFSv4-only error codes to include/linux/nfsd/nfsd.h



 ----------- Diffstat output ------------
 ./include/linux/nfsd/nfsd.h |   10 ++++++++++
 1 files changed, 10 insertions(+)

--- ./include/linux/nfsd/nfsd.h	2002/08/21 23:21:55	1.1
+++ ./include/linux/nfsd/nfsd.h	2002/08/21 23:21:57	1.2
@@ -170,6 +170,16 @@ void		nfsd_lockd_unexport(struct svc_cli
 #define	nfserr_serverfault	__constant_htonl(NFSERR_SERVERFAULT)
 #define	nfserr_badtype		__constant_htonl(NFSERR_BADTYPE)
 #define	nfserr_jukebox		__constant_htonl(NFSERR_JUKEBOX)
+#define	nfserr_bad_cookie	__constant_htonl(NFSERR_BAD_COOKIE)
+#define	nfserr_same		__constant_htonl(NFSERR_SAME)
+#define	nfserr_clid_inuse	__constant_htonl(NFSERR_CLID_INUSE)
+#define	nfserr_resource		__constant_htonl(NFSERR_RESOURCE)
+#define	nfserr_nofilehandle	__constant_htonl(NFSERR_NOFILEHANDLE)
+#define	nfserr_minor_vers_mismatch	__constant_htonl(NFSERR_MINOR_VERS_MISMATCH)
+#define	nfserr_symlink		__constant_htonl(NFSERR_SYMLINK)
+#define	nfserr_not_same		__constant_htonl(NFSERR_NOT_SAME)
+#define	nfserr_readdir_nospc	__constant_htonl(NFSERR_READDIR_NOSPC)
+#define	nfserr_bad_xdr		__constant_htonl(NFSERR_BAD_XDR)
 
 /* error code for internal use - if a request fails due to
  * kmalloc failure, it gets dropped.  Client should resend eventually


-------------------------------------------------------
This sf.net email is sponsored by: OSDN - Tired of that same old
cell phone?  Get a new here for FREE!
https://www.inphonic.com/r.asp?r=sourceforge1&refcode1=vs3390
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 2 of 4 - Use correct value for max size for readlink response.
Date: Fri, 11 Oct 2002 10:00:19 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E17znE3-0007ca-00@notabene.cse.unsw.edu.au>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17znEH-0000R9-00
	for <nfs@lists.sourceforge.net>; Thu, 10 Oct 2002 17:00:33 -0700
Received: From
	notabene.cse.unsw.edu.au ([129.94.242.45] == bartok.orchestra.cse.unsw.EDU.AU)
	(for <torvalds@transmeta.com>) (for <nfs@lists.sourceforge.net>) By
	tone With Smtp ; Fri, 11 Oct 2002 10:00:23 +1000
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
List-Archive: <http://sourceforge.net/mailarchives/forum.php?forum=nfs>


### Comments for ChangeSet

Symlinks in NFSv3 can be upto 1024 bytes, not 256 like nfsv2.

 ----------- Diffstat output ------------
 ./fs/nfsd/nfs3proc.c |    2 +-
 ./fs/nfsd/nfsproc.c  |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

--- ./fs/nfsd/nfsproc.c	2002/10/10 23:06:25	1.1
+++ ./fs/nfsd/nfsproc.c	2002/10/10 23:06:36	1.2
@@ -545,7 +545,7 @@ struct svc_procedure		nfsd_procedures2[1
   PROC(setattr,  sattrargs,	attrstat,	fhandle,	RC_REPLBUFF, ST+AT),
   PROC(none,	 void,		void,		none,		RC_NOCACHE, ST),
   PROC(lookup,	 diropargs,	diropres,	fhandle,	RC_NOCACHE, ST+FH+AT),
-  PROC(readlink, fhandle,	readlinkres,	none,		RC_NOCACHE, ST+1+256),
+  PROC(readlink, fhandle,	readlinkres,	none,		RC_NOCACHE, ST+1+NFS_MAXPATHLEN/4),
   PROC(read,	 readargs,	readres,	fhandle,	RC_NOCACHE, ST+AT+1+NFSSVC_MAXBLKSIZE),
   PROC(none,	 void,		void,		none,		RC_NOCACHE, ST),
   PROC(write,	 writeargs,	attrstat,	fhandle,	RC_REPLBUFF, ST+AT),
--- ./fs/nfsd/nfs3proc.c	2002/10/10 23:06:25	1.1
+++ ./fs/nfsd/nfs3proc.c	2002/10/10 23:06:36	1.2
@@ -670,7 +670,7 @@ struct svc_procedure		nfsd_procedures3[2
   PROC(setattr,  sattr,		wccstat,	fhandle,  RC_REPLBUFF, ST+WC),
   PROC(lookup,	 dirop,		dirop,		fhandle2, RC_NOCACHE, ST+FH+pAT+pAT),
   PROC(access,	 access,	access,		fhandle,  RC_NOCACHE, ST+pAT+1),
-  PROC(readlink, fhandle,	readlink,	fhandle,  RC_NOCACHE, ST+pAT+1+256),
+  PROC(readlink, fhandle,	readlink,	fhandle,  RC_NOCACHE, ST+pAT+1+NFS3_MAXPATHLEN/4),
   PROC(read,	 read,		read,		fhandle,  RC_NOCACHE, ST+pAT+4+NFSSVC_MAXBLKSIZE),
   PROC(write,	 write,		write,		fhandle,  RC_REPLBUFF, ST+WC+4),
   PROC(create,	 create,	create,		fhandle2, RC_REPLBUFF, ST+(1+FH+pAT)+WC),


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

From: NeilBrown <neilb@suse.de>
Subject: [PATCH] knfsd: Correct reserved reply space for read requests.
Date: Thu, 30 Mar 2006 16:53:50 +1100
Message-ID: <1060330055350.25337@suse.de>
References: <20060330165307.25307.patches@notabene>
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FOq85-0004Vf-6t
	for nfs@lists.sourceforge.net; Wed, 29 Mar 2006 21:55:33 -0800
Received: from ns2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1FOq84-0001el-OM
	for nfs@lists.sourceforge.net; Wed, 29 Mar 2006 21:55:33 -0800
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

Single patch for nfsd in 2.6.16.  As the comment say, it is sensible
for this to sit in -mm for a while just in case.

### Comments for Changeset

NFSd makes sure there is enough space to hold the maximum possible
reply before accepting a request.  The units for this maximum is
(4byte) words.  However in three places, particularly for read
request, the number given is a number of bytes.

This means too much space is reserved which is slightly wasteful.

This is the sort of patch that could uncover a deeper bug, and it is
not critical, so it would be best for it to spend a while in -mm before going in to mainline.

Discovered-by: "Eivind  Sarto" <ivan@kasenna.com>

Cc: "Eivind  Sarto" <ivan@kasenna.com>

Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./fs/nfsd/nfs3proc.c |    2 +-
 ./fs/nfsd/nfs4proc.c |    2 +-
 ./fs/nfsd/nfsproc.c  |    2 +-
 3 files changed, 3 insertions(+), 3 deletions(-)

diff ./fs/nfsd/nfs3proc.c~current~ ./fs/nfsd/nfs3proc.c
--- ./fs/nfsd/nfs3proc.c~current~	2006-03-30 16:48:30.000000000 +1100
+++ ./fs/nfsd/nfs3proc.c	2006-03-30 16:48:58.000000000 +1100
@@ -682,7 +682,7 @@ static struct svc_procedure		nfsd_proced
   PROC(lookup,	 dirop,		dirop,		fhandle2, RC_NOCACHE, ST+FH+pAT+pAT),
   PROC(access,	 access,	access,		fhandle,  RC_NOCACHE, ST+pAT+1),
   PROC(readlink, readlink,	readlink,	fhandle,  RC_NOCACHE, ST+pAT+1+NFS3_MAXPATHLEN/4),
-  PROC(read,	 read,		read,		fhandle,  RC_NOCACHE, ST+pAT+4+NFSSVC_MAXBLKSIZE),
+  PROC(read,	 read,		read,		fhandle,  RC_NOCACHE, ST+pAT+4+NFSSVC_MAXBLKSIZE/4),
   PROC(write,	 write,		write,		fhandle,  RC_REPLBUFF, ST+WC+4),
   PROC(create,	 create,	create,		fhandle2, RC_REPLBUFF, ST+(1+FH+pAT)+WC),
   PROC(mkdir,	 mkdir,		create,		fhandle2, RC_REPLBUFF, ST+(1+FH+pAT)+WC),

diff ./fs/nfsd/nfs4proc.c~current~ ./fs/nfsd/nfs4proc.c
--- ./fs/nfsd/nfs4proc.c~current~	2006-03-30 16:48:30.000000000 +1100
+++ ./fs/nfsd/nfs4proc.c	2006-03-30 16:48:58.000000000 +1100
@@ -973,7 +973,7 @@ struct nfsd4_voidargs { int dummy; };
  */
 static struct svc_procedure		nfsd_procedures4[2] = {
   PROC(null,	 void,		void,		void,	  RC_NOCACHE, 1),
-  PROC(compound, compound,	compound,	compound, RC_NOCACHE, NFSD_BUFSIZE)
+  PROC(compound, compound,	compound,	compound, RC_NOCACHE, NFSD_BUFSIZE/4)
 };
 
 struct svc_version	nfsd_version4 = {

diff ./fs/nfsd/nfsproc.c~current~ ./fs/nfsd/nfsproc.c
--- ./fs/nfsd/nfsproc.c~current~	2006-03-30 16:48:30.000000000 +1100
+++ ./fs/nfsd/nfsproc.c	2006-03-30 16:48:58.000000000 +1100
@@ -553,7 +553,7 @@ static struct svc_procedure		nfsd_proced
   PROC(none,	 void,		void,		none,		RC_NOCACHE, ST),
   PROC(lookup,	 diropargs,	diropres,	fhandle,	RC_NOCACHE, ST+FH+AT),
   PROC(readlink, readlinkargs,	readlinkres,	none,		RC_NOCACHE, ST+1+NFS_MAXPATHLEN/4),
-  PROC(read,	 readargs,	readres,	fhandle,	RC_NOCACHE, ST+AT+1+NFSSVC_MAXBLKSIZE),
+  PROC(read,	 readargs,	readres,	fhandle,	RC_NOCACHE, ST+AT+1+NFSSVC_MAXBLKSIZE/4),
   PROC(none,	 void,		void,		none,		RC_NOCACHE, ST),
   PROC(write,	 writeargs,	attrstat,	fhandle,	RC_REPLBUFF, ST+AT),
   PROC(create,	 createargs,	diropres,	fhandle,	RC_REPLBUFF, ST+FH+AT),


-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

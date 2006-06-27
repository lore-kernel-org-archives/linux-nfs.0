From: NeilBrown <neilb@suse.de>
Subject: [PATCH 011 of 14] knfsd: nfsd4: fix open flag passing
Date: Tue, 27 Jun 2006 17:20:32 +1000
Message-ID: <1060627072032.26721@suse.de>
References: <20060627171533.26405.patches@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Fv7sF-0006Oy-C4
	for nfs@lists.sourceforge.net; Tue, 27 Jun 2006 00:20:39 -0700
Received: from ns1.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Fv7sF-0007OS-2A
	for nfs@lists.sourceforge.net; Tue, 27 Jun 2006 00:20:39 -0700
To: Andrew Morton <akpm@osdl.org>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

From: J. Bruce Fields <bfields@citi.umich.edu>


Since nfsv4 actually keeps around the file descriptors it gets from open
(instead of just using them for a single read or write operation), we need
to make sure that we can do RDWR opens and not just RDONLY/WRONLY.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>

### Diffstat output
 ./fs/nfsd/nfs4state.c |    6 +++---
 ./fs/nfsd/vfs.c       |    5 ++++-
 2 files changed, 7 insertions(+), 4 deletions(-)

diff .prev/fs/nfsd/nfs4state.c ./fs/nfsd/nfs4state.c
--- .prev/fs/nfsd/nfs4state.c	2006-06-27 15:00:26.000000000 +1000
+++ ./fs/nfsd/nfs4state.c	2006-06-27 15:04:03.000000000 +1000
@@ -1790,10 +1790,10 @@ nfsd4_process_open2(struct svc_rqst *rqs
 	} else {
 		/* Stateid was not found, this is a new OPEN */
 		int flags = 0;
+		if (open->op_share_access & NFS4_SHARE_ACCESS_READ)
+			flags |= MAY_READ;
 		if (open->op_share_access & NFS4_SHARE_ACCESS_WRITE)
-			flags = MAY_WRITE;
-		else
-			flags = MAY_READ;
+			flags |= MAY_WRITE;
 		status = nfs4_new_open(rqstp, &stp, dp, current_fh, flags);
 		if (status)
 			goto out;

diff .prev/fs/nfsd/vfs.c ./fs/nfsd/vfs.c
--- .prev/fs/nfsd/vfs.c	2006-06-27 14:59:40.000000000 +1000
+++ ./fs/nfsd/vfs.c	2006-06-27 15:04:03.000000000 +1000
@@ -673,7 +673,10 @@ nfsd_open(struct svc_rqst *rqstp, struct
 		goto out_nfserr;
 
 	if (access & MAY_WRITE) {
-		flags = O_WRONLY|O_LARGEFILE;
+		if (access & MAY_READ)
+			flags = O_RDWR|O_LARGEFILE;
+		else
+			flags = O_WRONLY|O_LARGEFILE;
 
 		DQUOT_INIT(inode);
 	}

Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

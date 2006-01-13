From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 023 of 26] nfsd/vfs.c: endianness fixes
Date: Fri, 13 Jan 2006 12:01:06 +1100
Message-ID: <1060113010106.23204@cse.unsw.edu.au>
References: <20060113115744.22704.patches@notabene>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1ExDJd-0002bB-OJ
	for nfs@lists.sourceforge.net; Thu, 12 Jan 2006 17:01:17 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1ExDJa-00055N-Sg
	for nfs@lists.sourceforge.net; Thu, 12 Jan 2006 17:01:17 -0800
Received: From
	smtp-dist.unsw.edu.au ([149.171.97.18] == smtp-dist-03.services.comms.unsw.EDU.AU)
	(for <nfs@lists.sourceforge.net>) By note With Smtp ;
	Fri, 13 Jan 2006 12:01:10 +1100
Received: From
	neil.brown.name ([220.233.11.133] == 133.11.233.220.exetel.com.au) (auth-user neilb)
	(for <nfs@lists.sourceforge.net>) By note With Smtp ;
	Fri, 13 Jan 2006 12:01:07 +1100
To: nfs@lists.sourceforge.net
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


From: Al Viro <viro@zeniv.linux.org.uk>
Date: 1135476096 -0500

several failure exits return -E<something> instead of nfserr_<something>
and vice versa.

Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./fs/nfsd/vfs.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff ./fs/nfsd/vfs.c~current~ ./fs/nfsd/vfs.c
--- ./fs/nfsd/vfs.c~current~	2006-01-13 11:50:54.000000000 +1100
+++ ./fs/nfsd/vfs.c	2006-01-13 11:51:10.000000000 +1100
@@ -1134,7 +1134,7 @@ nfsd_create(struct svc_rqst *rqstp, stru
 				"nfsd_create: parent %s/%s not locked!\n",
 				dentry->d_parent->d_name.name,
 				dentry->d_name.name);
-			err = -EIO;
+			err = nfserr_io;
 			goto out;
 		}
 	}
@@ -1600,7 +1600,7 @@ nfsd_rename(struct svc_rqst *rqstp, stru
 	if ((ffhp->fh_export->ex_flags & NFSEXP_MSNFS) &&
 		((atomic_read(&odentry->d_count) > 1)
 		 || (atomic_read(&ndentry->d_count) > 1))) {
-			err = nfserr_perm;
+			err = -EPERM;
 	} else
 #endif
 	err = vfs_rename(fdir, odentry, tdir, ndentry);
@@ -1672,7 +1672,7 @@ nfsd_unlink(struct svc_rqst *rqstp, stru
 #ifdef MSNFS
 		if ((fhp->fh_export->ex_flags & NFSEXP_MSNFS) &&
 			(atomic_read(&rdentry->d_count) > 1)) {
-			err = nfserr_perm;
+			err = -EPERM;
 		} else
 #endif
 		err = vfs_unlink(dirp, rdentry);


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 9 of 12 - NFSv4: allow type==0 in nfsd_unlink()
Date: Thu, 22 Aug 2002 10:35:12 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E17hfwO-00051h-00@notabene.cse.unsw.edu.au>
Cc: nfs@lists.sourceforge.net,  "Kendrick M. Smith" <kmsmith@umich.edu>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17hfwb-0000PM-00
	for <nfs@lists.sourceforge.net>; Wed, 21 Aug 2002 17:35:25 -0700
Received: From
	notabene.cse.unsw.edu.au ([129.94.242.45] == bartok.orchestra.cse.unsw.EDU.AU)
	(for <torvalds@transmeta.com>) (for <nfs@lists.sourceforge.net>)
	(for <kmsmith@umich.edu>) By tone With Smtp ;
	Thu, 22 Aug 2002 10:35:17 +1000
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

If nfsd_unlink() is called with @type equal to 0, then let it do the
right thing regardless of the type of the file being unlinked.  This
is needed for the NFSv4 REMOVE operation, which works for any type of
file, even directories.



 ----------- Diffstat output ------------
 ./fs/nfsd/vfs.c |    3 +++
 1 files changed, 3 insertions(+)

--- ./fs/nfsd/vfs.c	2002/08/21 23:24:08	1.3
+++ ./fs/nfsd/vfs.c	2002/08/21 23:25:39	1.4
@@ -1329,6 +1329,9 @@ nfsd_unlink(struct svc_rqst *rqstp, stru
 		goto out;
 	}
 
+	if (!type)
+		type = rdentry->d_inode->i_mode & S_IFMT;
+
 	if (type != S_IFDIR) { /* It's UNLINK */
 #ifdef MSNFS
 		if ((fhp->fh_export->ex_flags & NFSEXP_MSNFS) &&


-------------------------------------------------------
This sf.net email is sponsored by: OSDN - Tired of that same old
cell phone?  Get a new here for FREE!
https://www.inphonic.com/r.asp?r=sourceforge1&refcode1=vs3390
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

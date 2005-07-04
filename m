From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 003 of 19] nfsd4: lookup_one_len takes i_sem
Date: Mon, 04 Jul 2005 11:01:42 +1000
Message-ID: <E1DpFLC-0007GC-H5@notabene.cse.unsw.edu.au>
References: <20050704110022.27753.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from [10.3.1.91] (helo=sc8-sf-mx1-new.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DpFM8-0001l0-0q
	for nfs@lists.sourceforge.net; Sun, 03 Jul 2005 18:02:40 -0700
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.59] ident=root)
	by sc8-sf-mx1-new.sourceforge.net with esmtp (Exim 4.44)
	id 1DpFM6-00070m-IV
	for nfs@lists.sourceforge.net; Sun, 03 Jul 2005 18:02:40 -0700
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


Oops, this lookup_one_len needs the i_sem.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfs4recover.c |    2 ++
 1 files changed, 2 insertions(+)

diff ./fs/nfsd/nfs4recover.c~current~ ./fs/nfsd/nfs4recover.c
--- ./fs/nfsd/nfs4recover.c~current~	2005-07-04 10:57:51.000000000 +1000
+++ ./fs/nfsd/nfs4recover.c	2005-07-04 10:57:52.000000000 +1000
@@ -289,7 +289,9 @@ nfsd4_unlink_clid_dir(char *name, int na
 
 	dprintk("NFSD: nfsd4_unlink_clid_dir. name %.*s\n", namlen, name);
 
+	down(&rec_dir.dentry->d_inode->i_sem);
 	dentry = lookup_one_len(name, rec_dir.dentry, namlen);
+	up(&rec_dir.dentry->d_inode->i_sem);
 	if (IS_ERR(dentry)) {
 		status = PTR_ERR(dentry);
 		return status;


-------------------------------------------------------
SF.Net email is sponsored by: Discover Easy Linux Migration Strategies
from IBM. Find simple to follow Roadmaps, straightforward articles,
informative Webcasts and more! Get everything you need to get up to
speed, fast. http://ads.osdn.com/?ad_id=7477&alloc_id=16492&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

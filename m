From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 2 of 12] exportfs: reduce stack usage
Date: Tue, 08 Feb 2005 14:06:54 +1100
Message-ID: <E1CyLiI-0006VG-0B@notabene.cse.unsw.edu.au>
References: <20050208140033.24886.patches@notabene>
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CyLiU-0006uN-22
	for nfs@lists.sourceforge.net; Mon, 07 Feb 2005 19:07:06 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1CyLiS-0004Cm-H5
	for nfs@lists.sourceforge.net; Mon, 07 Feb 2005 19:07:05 -0800
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



find_exported_dentry() declares
	char nbuf[NAME_MAX+1];
in 2 separate places, and gcc allocates space on the stack for both
of them.  Having just one of them will suffice, if we can put put
with its scope.

Reduces function stack usage on x86-32 from 0x230 to 0x130.

Signed-off-by: Randy Dunlap <rddunlap@osdl.org>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/exportfs/expfs.c |    4 +---
 1 files changed, 1 insertion(+), 3 deletions(-)

diff ./fs/exportfs/expfs.c~current~ ./fs/exportfs/expfs.c
--- ./fs/exportfs/expfs.c~current~	2005-02-07 15:04:00.000000000 +1100
+++ ./fs/exportfs/expfs.c	2005-02-07 15:04:00.000000000 +1100
@@ -55,7 +55,7 @@ find_exported_dentry(struct super_block 
 	struct list_head *le, *head;
 	struct dentry *toput = NULL;
 	int noprogress;
-
+	char nbuf[NAME_MAX+1];
 
 	/*
 	 * Attempt to find the inode.
@@ -176,7 +176,6 @@ find_exported_dentry(struct super_block 
 			 */
 			struct dentry *ppd;
 			struct dentry *npd;
-			char nbuf[NAME_MAX+1];
 
 			down(&pd->d_inode->i_sem);
 			ppd = CALL(nops,get_parent)(pd);
@@ -241,7 +240,6 @@ find_exported_dentry(struct super_block 
 	/* if we weren't after a directory, have one more step to go */
 	if (result != target_dir) {
 		struct dentry *nresult;
-		char nbuf[NAME_MAX+1];
 		err = CALL(nops,get_name)(target_dir, nbuf, result);
 		if (!err) {
 			down(&target_dir->d_inode->i_sem);


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

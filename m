From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 2 of 5 - Make sure export_open cleans up on failure.
Date: Thu, 31 Oct 2002 11:07:59 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1021031000759.29560@cse.unsw.edu.au>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 1872ss-0005nZ-00
	for <nfs@lists.sourceforge.net>; Wed, 30 Oct 2002 16:08:27 -0800
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
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>


### Comments for ChangeSet

Currently if the kmalloc in exports_open fails,
the seq_file isn't seq_released.

We now do the kmalloc first, and make sure to kfree
if seq_open fails.



 ----------- Diffstat output ------------
 ./fs/nfsd/nfsctl.c |   16 +++++++++-------
 1 files changed, 9 insertions(+), 7 deletions(-)

--- ./fs/nfsd/nfsctl.c	2002/10/30 22:40:15	1.1
+++ ./fs/nfsd/nfsctl.c	2002/10/30 22:40:23	1.2
@@ -127,14 +127,16 @@ extern struct seq_operations nfs_exports
 static int exports_open(struct inode *inode, struct file *file)
 {
 	int res;
+	char *namebuf = kmalloc(PAGE_SIZE, GFP_KERNEL);
+	if (namebuf == NULL)
+		return -ENOMEM;
+
 	res = seq_open(file, &nfs_exports_op);
-	if (!res) {
-		char *namebuf = kmalloc(PAGE_SIZE, GFP_KERNEL);
-		if (namebuf == NULL)
-			res = -ENOMEM;
-		else
-			((struct seq_file *)file->private_data)->private = namebuf;
-	}
+	if (res)
+		kfree(namebuf);
+	else
+		((struct seq_file *)file->private_data)->private = namebuf;
+
 	return res;
 }
 static int exports_release(struct inode *inode, struct file *file)


-------------------------------------------------------
This sf.net email is sponsored by: Influence the future 
of Java(TM) technology. Join the Java Community 
Process(SM) (JCP(SM)) program now. 
http://ads.sourceforge.net/cgi-bin/redirect.pl?sunm0004en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

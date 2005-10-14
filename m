From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 002 of 4] Restore functionality to read from file in /proc/fs/nfsd/
Date: Fri, 14 Oct 2005 12:23:08 +1000
Message-ID: <1051014022308.11554@cse.unsw.edu.au>
References: <20051014122041.11376.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EQFE8-0006Rs-HD
	for nfs@lists.sourceforge.net; Thu, 13 Oct 2005 19:23:20 -0700
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.59] ident=root)
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1EQFE5-0006JR-0r
	for nfs@lists.sourceforge.net; Thu, 13 Oct 2005 19:23:17 -0700
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


Most files in the nfsd filesystems are transaction files.
You write a request, and read a response.
For some (e.g. 'threads') it makes sense to just be able to read
and get the current value.
This functionality did exist but was broken recently when someone
modified nfsctl.c without going through the maintainer.
This patch fixes the regression.

Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./fs/nfsd/nfsctl.c |   16 +++++++++++++++-
 1 file changed, 15 insertions(+), 1 deletion(-)

diff ./fs/nfsd/nfsctl.c~current~ ./fs/nfsd/nfsctl.c
--- ./fs/nfsd/nfsctl.c~current~	2005-10-14 12:01:38.000000000 +1000
+++ ./fs/nfsd/nfsctl.c	2005-10-14 12:02:35.000000000 +1000
@@ -104,9 +104,23 @@ static ssize_t nfsctl_transaction_write(
 	return rv;
 }
 
+static ssize_t nfsctl_transaction_read(struct file *file, char __user *buf, size_t size, loff_t *pos)
+{
+	if (! file->private_data) {
+		/* An attempt to read a transaction file without writing
+		 * causes a 0-byte write so that the file can return
+		 * state information
+		 */
+		ssize_t rv = nfsctl_transaction_write(file, buf, 0, pos);
+		if (rv < 0)
+			return rv;
+	}
+	return simple_transaction_read(file, buf, size, pos);
+}
+
 static struct file_operations transaction_ops = {
 	.write		= nfsctl_transaction_write,
-	.read		= simple_transaction_read,
+	.read		= nfsctl_transaction_read,
 	.release	= simple_transaction_release,
 };
 


-------------------------------------------------------
This SF.Net email is sponsored by:
Power Architecture Resource Center: Free content, downloads, discussions,
and more. http://solutions.newsforge.com/ibmarch.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

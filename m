From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: [PATCH] Fix NFS typos in 2.5.43...
Date: Wed, 16 Oct 2002 15:18:32 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15789.26408.851059.191809@charged.uio.no>
Reply-To: trond.myklebust@fys.uio.no
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Kernel <linux-kernel@vger.kernel.org>,
    NFS maillist <nfs@lists.sourceforge.net>,
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pat.uio.no ([129.240.130.16])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 181o4S-0005zm-00
	for <nfs@lists.sourceforge.net>; Wed, 16 Oct 2002 06:18:44 -0700
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


The following patch fixes 2 obvious typos. Thanks to davem and George
Anzinger for pointing them out.

Cheers,
  Trond

diff -u --recursive --new-file linux-2.5.43/fs/nfs/inode.c linux-2.5.43-fixes/fs/nfs/inode.c
--- linux-2.5.43/fs/nfs/inode.c	2002-10-14 12:43:11.000000000 -0400
+++ linux-2.5.43-fixes/fs/nfs/inode.c	2002-10-16 08:44:04.000000000 -0400
@@ -1355,7 +1355,7 @@
 	if (data->auth_flavourlen != 0) {
 		if (data->auth_flavourlen > 1)
 			printk(KERN_INFO "NFS: cannot yet deal with multiple auth flavours.\n");
-		if (copy_from_user(authflavour, data->auth_flavours, sizeof(authflavour))) {
+		if (copy_from_user(&authflavour, data->auth_flavours, sizeof(authflavour))) {
 			err = -EFAULT;
 			goto out_fail;
 		}
diff -u --recursive --new-file linux-2.5.43/fs/nfs/proc.c linux-2.5.43-fixes/fs/nfs/proc.c
--- linux-2.5.43/fs/nfs/proc.c	2002-10-12 19:33:34.000000000 -0400
+++ linux-2.5.43-fixes/fs/nfs/proc.c	2002-10-16 08:44:29.000000000 -0400
@@ -490,7 +490,7 @@
 
 	dprintk("NFS call  fsinfo\n");
 	info->fattr->valid = 0;
-	status = rpc_call(server->client, NFSPROC_STATFS, fhandle, &info, 0);
+	status = rpc_call(server->client, NFSPROC_STATFS, fhandle, &fsinfo, 0);
 	dprintk("NFS reply fsinfo: %d\n", status);
 	if (status)
 		goto out;


-------------------------------------------------------
This sf.net email is sponsored by: viaVerio will pay you up to
$1,000 for every account that you consolidate with us.
http://ad.doubleclick.net/clk;4749864;7604308;v?
http://www.viaverio.com/consolidator/osdn.cfm
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

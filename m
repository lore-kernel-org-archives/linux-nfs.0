From: Olaf Kirch <okir@suse.de>
Subject: Re: [PATCH] NFS nolock broken in 2.6.9-rc4
Date: Fri, 15 Oct 2004 17:21:56 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20041015152156.GH27307@suse.de>
References: <20041015095840.GA22992@suse.de> <1097851471.5558.12.camel@lade.trondhjem.org> <20041015151257.GF27307@suse.de>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="O5XBE6gyVG5Rl6Rj"
Cc: nfs@lists.sourceforge.net, Andrew Morton <akpm@osdl.org>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CIU2h-0007GE-49
	for nfs@lists.sourceforge.net; Fri, 15 Oct 2004 08:30:55 -0700
Received: from cantor.suse.de ([195.135.220.2])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.41)
	id 1CIU2f-0003bw-NN
	for nfs@lists.sourceforge.net; Fri, 15 Oct 2004 08:30:55 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <20041015151257.GF27307@suse.de>
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


--O5XBE6gyVG5Rl6Rj
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

> Urrrgh.. this looks complicated and duplicates code. Then I'd rather
> have two struct file_operations, one for normal operations with a .lock
> function, and a second one for nolock without.

Please find attached proposed fix3 that does just this.

Olaf
-- 
Olaf Kirch     | Things that make Monday morning interesting, #1:
okir@suse.de   |        "I want to use NFS over AX25, can you help me?"
---------------+ 

--O5XBE6gyVG5Rl6Rj
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=nfs-nolock-fix3

Index: linux-2.6.9-rc4/fs/nfs/inode.c
===================================================================
--- linux-2.6.9-rc4.orig/fs/nfs/inode.c
+++ linux-2.6.9-rc4/fs/nfs/inode.c
@@ -666,7 +666,10 @@ nfs_fhget(struct super_block *sb, struct
 		 */
 		inode->i_op = &nfs_file_inode_operations;
 		if (S_ISREG(inode->i_mode)) {
-			inode->i_fop = &nfs_file_operations;
+			if (NFS_SERVER(inode)->flags & NFS_MOUNT_NONLM)
+				inode->i_fop = &nfs_file_operations_nolock;
+			else
+				inode->i_fop = &nfs_file_operations;
 			inode->i_data.a_ops = &nfs_file_aops;
 			inode->i_data.backing_dev_info = &NFS_SB(sb)->backing_dev_info;
 		} else if (S_ISDIR(inode->i_mode)) {
Index: linux-2.6.9-rc4/fs/nfs/file.c
===================================================================
--- linux-2.6.9-rc4.orig/fs/nfs/file.c
+++ linux-2.6.9-rc4/fs/nfs/file.c
@@ -60,6 +60,20 @@ struct file_operations nfs_file_operatio
 	.sendfile	= nfs_file_sendfile,
 	.check_flags	= nfs_check_flags,
 };
+struct file_operations nfs_file_operations_nolock = {
+	.llseek		= remote_llseek,
+	.read		= do_sync_read,
+	.write		= do_sync_write,
+	.aio_read		= nfs_file_read,
+	.aio_write		= nfs_file_write,
+	.mmap		= nfs_file_mmap,
+	.open		= nfs_file_open,
+	.flush		= nfs_file_flush,
+	.release	= nfs_file_release,
+	.fsync		= nfs_fsync,
+	.sendfile	= nfs_file_sendfile,
+	.check_flags	= nfs_check_flags,
+};
 
 struct inode_operations nfs_file_inode_operations = {
 	.permission	= nfs_permission,
Index: linux-2.6.9-rc4/include/linux/nfs_fs.h
===================================================================
--- linux-2.6.9-rc4.orig/include/linux/nfs_fs.h
+++ linux-2.6.9-rc4/include/linux/nfs_fs.h
@@ -319,6 +319,7 @@ extern u32 root_nfs_parse_addr(char *nam
  */
 extern struct inode_operations nfs_file_inode_operations;
 extern struct file_operations nfs_file_operations;
+extern struct file_operations nfs_file_operations_nolock;
 extern struct address_space_operations nfs_file_aops;
 
 static inline struct rpc_cred *nfs_file_cred(struct file *file)

--O5XBE6gyVG5Rl6Rj--


-------------------------------------------------------
This SF.net email is sponsored by: IT Product Guide on ITManagersJournal
Use IT products in your business? Tell us what you think of them. Give us
Your Opinions, Get Free ThinkGeek Gift Certificates! Click to find out more
http://productguide.itmanagersjournal.com/guidepromo.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

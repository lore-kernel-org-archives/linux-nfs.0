From: Hirokazu Takahashi <taka@valinux.co.jp>
Subject: [PATCH][BUG] nfsd may deadlock (linux-2.5.8)
Date: Mon, 22 Apr 2002 16:02:42 +0900 (JST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20020422.160242.21920993.taka@valinux.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sv1.valinux.co.jp ([202.221.173.100])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 16zXrm-0006n4-00
	for <nfs@lists.sourceforge.net>; Mon, 22 Apr 2002 00:04:02 -0700
To: linux-kernel@vger.kernel.org, nfs@lists.sourceforge.net
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

Hi,

I fixed a nfsd bug.
KNFSDs will deadlock in nfsd_symlink() as they try to grab i_sem doubly,
though the i_sem is already grabbed by fh_lock().


Thank you,
Hirokazu Takahashi.

--- linux/fs/nfsd/vfs.c.ORG	Sat Apr 20 09:09:30 2002
+++ linux/fs/nfsd/vfs.c	Mon Apr 22 06:08:51 2002
@@ -1127,9 +1135,7 @@
 				iap->ia_valid |= ATTR_CTIME;
 				iap->ia_mode = (iap->ia_mode&S_IALLUGO)
 					| S_IFLNK;
-				down(&dentry->d_inode->i_sem);
 				err = notify_change(dnew, iap);
-				up(&dentry->d_inode->i_sem);
 				if (!err && EX_ISSYNC(fhp->fh_export))
 					write_inode_now(dentry->d_inode, 1);
 		       }

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

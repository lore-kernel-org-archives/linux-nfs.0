From: Frank Cusack <fcusack@fcusack.com>
Subject: Re: Re: [autofs] VFS: Busy inodes after unmount on 2 way SMP
Date: Sun, 28 Sep 2003 20:27:58 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030928202757.A21288@google.com>
References: <shsd6dyabju.fsf@charged.uio.no> <Pine.LNX.4.44.0309251614290.22478-100000@fubar.phlinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>, Olaf Hering <olh@suse.de>,
   "H. Peter Anvin" <hpa@zytor.com>, Arun Sharma <arun.sharma@intel.com>,
   autofs@linux.kernel.org, nfs@lists.sourceforge.net,
   Ian Kent <raven@themaw.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1A3qrk-0005AT-00
	for <nfs@lists.sourceforge.net>; Sun, 28 Sep 2003 22:46:37 -0700
Received: from panoramix.vasoftware.com
	([198.186.202.147] helo=externalmx.vasoftware.com ident=mail)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.22)
	id 1A3qri-0005uS-Au
	for nfs@lists.sourceforge.net; Sun, 28 Sep 2003 22:46:34 -0700
Received: from 216-239-45-4.google.com ([216.239.45.4]:51587)
	by externalmx.vasoftware.com with esmtp (Exim 4.22 #1 (Debian))
	id 1A3oj6-0005aC-8e
	for <nfs@lists.sourceforge.net>; Sun, 28 Sep 2003 20:29:32 -0700
To: Matt C <wago@phlinux.com>
In-Reply-To: <Pine.LNX.4.44.0309251614290.22478-100000@fubar.phlinux.com>; from wago@phlinux.com on Thu, Sep 25, 2003 at 04:17:54PM -0700
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

Does this patch help?

--- linux-2.4.22/fs/namei.c	2003-08-25 04:44:43.000000000 -0700
+++ linux-2.4.22-gg4/fs/namei.c	2003-09-26 00:03:16.000000000 -0700
@@ -893,6 +893,8 @@ static inline int check_sticky(struct in
  *  7. If we were asked to remove a directory and victim isn't one - ENOTDIR.
  *  8. If we were asked to remove a non-directory and victim isn't one - EISDIR.
  *  9. We can't remove a root or mountpoint.
+ * 10. We don't allow removal of NFS sillyrenamed files; it's handled by
+ *     nfs_async_unlink().
  */
 static inline int may_delete(struct inode *dir,struct dentry *victim, int isdir)
 {
@@ -916,6 +918,8 @@ static inline int may_delete(struct inod
 		return -EISDIR;
 	if (IS_DEADDIR(dir))
 		return -ENOENT;
+	if (victim->d_flags & DCACHE_NFSFS_RENAMED)
+		return -EBUSY;
 	return 0;
 }
 
@@ -1484,13 +1488,14 @@ int vfs_unlink(struct inode *dir, struct
 				lock_kernel();
 				error = dir->i_op->unlink(dir, dentry);
 				unlock_kernel();
-				if (!error)
+				if (!error &&
+				    !(dentry->d_flags & DCACHE_NFSFS_RENAMED))
 					d_delete(dentry);
 			}
 		}
 	}
 	up(&dir->i_zombie);
-	if (!error)
+	if (!error && !(dentry->d_flags & DCACHE_NFSFS_RENAMED))
 		inode_dir_notify(dir, DN_DELETE);
 	return error;
 }


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

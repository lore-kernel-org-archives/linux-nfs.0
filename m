From: Jesper Juhl <jesper.juhl@gmail.com>
Subject: Kill NFS_PARANOIA (was: Re: [PATCH] NFS: possible NULL
	pointer deref in nfs_sillyrename() )
Date: Tue, 19 Sep 2006 02:25:59 +0200
Message-ID: <200609190225.59501.jesper.juhl@gmail.com>
References: <200608170022.29168.jesper.juhl@gmail.com>
	<1155773801.6739.5.camel@localhost>
	<9a8748490608170305v53a2fd20q29d12e2a7b7229d4@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Jesper Juhl <jesper.juhl@gmail.com>, nfs@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, Rick Sladkey <jrs@world.std.com>,
	Neil Brown <neilb@cse.unsw.edu.au>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GPTQc-0000Hi-Td
	for nfs@lists.sourceforge.net; Mon, 18 Sep 2006 17:25:34 -0700
Received: from nf-out-0910.google.com ([64.233.182.191])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GPTQc-0004Uu-FX
	for nfs@lists.sourceforge.net; Mon, 18 Sep 2006 17:25:35 -0700
Received: by nf-out-0910.google.com with SMTP id p46so25047nfa
	for <nfs@lists.sourceforge.net>; Mon, 18 Sep 2006 17:25:30 -0700 (PDT)
To: "Trond Myklebust" <trond.myklebust@fys.uio.no>
In-Reply-To: <9a8748490608170305v53a2fd20q29d12e2a7b7229d4@mail.gmail.com>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Thursday 17 August 2006 12:05, Jesper Juhl wrote:
> On 17/08/06, Trond Myklebust <trond.myklebust@fys.uio.no> wrote:
[...]
> 
> > IOW: Feel free to kill the NFS_PARANOIA crap. It looks like legacy code
> > from a debugging session about a decade or so ago.
> >
> Sure thing, I'll cook up a patch to do that.
> 
How about something like this: 


Remove obsolete NFS_PARANOIA

Signed-off-by: Jesper Juhl <jesper.juhl@gmail.com>
---

 fs/nfs/dir.c      |   22 ++--------------------
 fs/nfs/inode.c    |   11 +----------
 fs/nfs/nfs2xdr.c  |    1 -
 fs/nfs/pagelist.c |    7 ++-----
 4 files changed, 5 insertions(+), 36 deletions(-)

diff -upr linux-2.6.18-rc7-git2-orig/fs/nfs/dir.c linux-2.6.18-rc7-git2/fs/nfs/dir.c
--- linux-2.6.18-rc7-git2-orig/fs/nfs/dir.c	2006-09-14 13:08:55.000000000 +0200
+++ linux-2.6.18-rc7-git2/fs/nfs/dir.c	2006-09-19 01:35:02.000000000 +0200
@@ -36,7 +36,6 @@
 #include "delegation.h"
 #include "iostat.h"
 
-#define NFS_PARANOIA 1
 /* #define NFS_DEBUG_VERBOSE 1 */
 
 static int nfs_opendir(struct inode *, struct file *);
@@ -1299,11 +1298,7 @@ static int nfs_sillyrename(struct inode 
 		atomic_read(&dentry->d_count));
 	nfs_inc_stats(dir, NFSIOS_SILLYRENAME);
 
-#ifdef NFS_PARANOIA
-if (!dentry->d_inode)
-printk("NFS: silly-renaming %s/%s, negative dentry??\n",
-dentry->d_parent->d_name.name, dentry->d_name.name);
-#endif
+	BUG_ON(!dentry->d_inode);
 	/*
 	 * We don't allow a dentry to be silly-renamed twice.
 	 */
@@ -1452,11 +1447,6 @@ nfs_symlink(struct inode *dir, struct de
 	dfprintk(VFS, "NFS: symlink(%s/%ld, %s, %s)\n", dir->i_sb->s_id,
 		dir->i_ino, dentry->d_name.name, symname);
 
-#ifdef NFS_PARANOIA
-if (dentry->d_inode)
-printk("nfs_proc_symlink: %s/%s not negative!\n",
-dentry->d_parent->d_name.name, dentry->d_name.name);
-#endif
 	/*
 	 * Fill in the sattr for the call.
  	 * Note: SunOS 4.1.2 crashes if the mode isn't initialized!
@@ -1584,16 +1574,8 @@ static int nfs_rename(struct inode *old_
 			new_inode = NULL;
 			/* instantiate the replacement target */
 			d_instantiate(new_dentry, NULL);
-		} else if (atomic_read(&new_dentry->d_count) > 1) {
-		/* dentry still busy? */
-#ifdef NFS_PARANOIA
-			printk("nfs_rename: target %s/%s busy, d_count=%d\n",
-			       new_dentry->d_parent->d_name.name,
-			       new_dentry->d_name.name,
-			       atomic_read(&new_dentry->d_count));
-#endif
+		} else if (atomic_read(&new_dentry->d_count) > 1)
 			goto out;
-		}
 	} else
 		new_inode->i_nlink--;
 
diff -upr linux-2.6.18-rc7-git2-orig/fs/nfs/inode.c linux-2.6.18-rc7-git2/fs/nfs/inode.c
--- linux-2.6.18-rc7-git2-orig/fs/nfs/inode.c	2006-09-14 13:08:55.000000000 +0200
+++ linux-2.6.18-rc7-git2/fs/nfs/inode.c	2006-09-19 01:37:10.000000000 +0200
@@ -48,7 +48,6 @@
 #include "internal.h"
 
 #define NFSDBG_FACILITY		NFSDBG_VFS
-#define NFS_PARANOIA 1
 
 static void nfs_invalidate_inode(struct inode *);
 static int nfs_update_inode(struct inode *, struct nfs_fattr *);
@@ -895,7 +894,7 @@ static int nfs_update_inode(struct inode
 	 * Make sure the inode's type hasn't changed.
 	 */
 	if ((inode->i_mode & S_IFMT) != (fattr->mode & S_IFMT))
-		goto out_changed;
+		goto out_err;
 
 	server = NFS_SERVER(inode);
 	/* Update the fsid if and only if this is the root directory */
@@ -1005,14 +1004,6 @@ static int nfs_update_inode(struct inode
 		nfsi->cache_validity |= invalid;
 
 	return 0;
- out_changed:
-	/*
-	 * Big trouble! The inode has become a different object.
-	 */
-#ifdef NFS_PARANOIA
-	printk(KERN_DEBUG "%s: inode %ld mode changed, %07o to %07o\n",
-			__FUNCTION__, inode->i_ino, inode->i_mode, fattr->mode);
-#endif
  out_err:
 	/*
 	 * No need to worry about unhashing the dentry, as the
diff -upr linux-2.6.18-rc7-git2-orig/fs/nfs/nfs2xdr.c linux-2.6.18-rc7-git2/fs/nfs/nfs2xdr.c
--- linux-2.6.18-rc7-git2-orig/fs/nfs/nfs2xdr.c	2006-09-14 13:08:55.000000000 +0200
+++ linux-2.6.18-rc7-git2/fs/nfs/nfs2xdr.c	2006-09-19 01:37:31.000000000 +0200
@@ -26,7 +26,6 @@
 #include "internal.h"
 
 #define NFSDBG_FACILITY		NFSDBG_XDR
-/* #define NFS_PARANOIA 1 */
 
 /* Mapping from NFS error code to "errno" error code. */
 #define errno_NFSERR_IO		EIO
diff -upr linux-2.6.18-rc7-git2-orig/fs/nfs/pagelist.c linux-2.6.18-rc7-git2/fs/nfs/pagelist.c
--- linux-2.6.18-rc7-git2-orig/fs/nfs/pagelist.c	2006-09-14 13:08:55.000000000 +0200
+++ linux-2.6.18-rc7-git2/fs/nfs/pagelist.c	2006-09-19 01:38:28.000000000 +0200
@@ -18,7 +18,6 @@
 #include <linux/nfs_fs.h>
 #include <linux/nfs_mount.h>
 
-#define NFS_PARANOIA 1
 
 static kmem_cache_t *nfs_page_cachep;
 
@@ -171,10 +170,8 @@ nfs_release_request(struct nfs_page *req
 	if (!atomic_dec_and_test(&req->wb_count))
 		return;
 
-#ifdef NFS_PARANOIA
-	BUG_ON (!list_empty(&req->wb_list));
-	BUG_ON (NFS_WBACK_BUSY(req));
-#endif
+	BUG_ON(!list_empty(&req->wb_list));
+	BUG_ON(NFS_WBACK_BUSY(req));
 
 	/* Release struct file or cached credential */
 	nfs_clear_request(req);



-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

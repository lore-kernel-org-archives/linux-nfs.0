From: Jesper Juhl <jesper.juhl@gmail.com>
Subject: [PATCH] NFS: possible NULL pointer deref in nfs_sillyrename()
Date: Thu, 17 Aug 2006 00:22:28 +0200
Message-ID: <200608170022.29168.jesper.juhl@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	nfs@lists.sourceforge.net, Olaf Kirch <okir@monad.swb.de>,
	Rick Sladkey <jrs@world.std.com>, Neil Brown <neilb@cse.unsw.edu.au>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GDTlN-0005DP-HL
	for nfs@lists.sourceforge.net; Wed, 16 Aug 2006 15:21:25 -0700
Received: from nf-out-0910.google.com ([64.233.182.189])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GDTlK-0006sB-M6
	for nfs@lists.sourceforge.net; Wed, 16 Aug 2006 15:21:26 -0700
Received: by nf-out-0910.google.com with SMTP id m19so860349nfc
	for <nfs@lists.sourceforge.net>; Wed, 16 Aug 2006 15:21:20 -0700 (PDT)
To: linux-kernel@vger.kernel.org
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

The coverity checker spotted this as bug #1013.

If we get a NULL dentry->d_inode, then regardless of 
NFS_PARANOIA or no NFS_PARANOIA, then if 
   if (dentry->d_flags & DCACHE_NFSFS_RENAMED)
turns out to be false we'll end up dereferencing 
that NULL d_inode in two places below.

And since the check for "(!dentry->d_inode)" even exists
(although inside #ifdef NFS_PARANOIA) I take that to mean
that this is a possibility. 
And the fact that we check 
    if (dentry->d_flags & DCACHE_NFSFS_RENAMED)
must also mean that there are cases where the check could 
fail.

So, we can get in trouble here : 

1) as an arg to sprintf() :
 		sprintf(silly, ".nfs%*.*lx",
 			i_inosize, i_inosize, dentry->d_inode->i_ino);

2) or we pass it to nfs_inode_return_delegation() which then dereferences it.
 		nfs_inode_return_delegation(dentry->d_inode);

I propose the following patch to handle this.

Compile tested only.

If this patch is somehow incorrect I'd appreciate an explanation of why :)


Signed-off-by: Jesper Juhl <jesper.juhl@gmail.com>
---

 fs/nfs/dir.c |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

--- linux-2.6.18-rc4-orig/fs/nfs/dir.c	2006-08-11 00:11:12.000000000 +0200
+++ linux-2.6.18-rc4/fs/nfs/dir.c	2006-08-17 00:06:23.000000000 +0200
@@ -1299,15 +1299,15 @@ static int nfs_sillyrename(struct inode 
 		atomic_read(&dentry->d_count));
 	nfs_inc_stats(dir, NFSIOS_SILLYRENAME);
 
-#ifdef NFS_PARANOIA
-if (!dentry->d_inode)
-printk("NFS: silly-renaming %s/%s, negative dentry??\n",
-dentry->d_parent->d_name.name, dentry->d_name.name);
-#endif
+	error = -EBUSY;
+	if (!dentry->d_inode) {
+		printk("NFS: silly-renaming %s/%s, negative dentry??\n",
+			dentry->d_parent->d_name.name, dentry->d_name.name);
+		goto out;
+	}
 	/*
 	 * We don't allow a dentry to be silly-renamed twice.
 	 */
-	error = -EBUSY;
 	if (dentry->d_flags & DCACHE_NFSFS_RENAMED)
 		goto out;
 



-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

From: =?UTF-8?Q?Peter_=C3=85strand?= <astrand@cendio.se>
Subject: Re: [PATCH] 64 bit ino support for NFS client
Date: Mon, 13 Aug 2007 15:14:29 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0708131511470.15451@maggie.lkpg.cendio.se>
References: <46B37CDE.1070904@redhat.com>
Mime-Version: 1.0
Content-Type: MULTIPART/Mixed; BOUNDARY=------------080203070307020606040400
Cc: Andrew Morton <akpm@linux-foundation.org>,
	NFS List <nfs@lists.sourceforge.net>,
	Trond Myklebust <trond.myklebust@fys.uio.no>
To: Peter Staubach <staubach@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IKZki-00011v-CC
	for nfs@lists.sourceforge.net; Mon, 13 Aug 2007 06:14:36 -0700
Received: from mail.cendio.se ([193.12.253.69])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IKZkl-00011r-19
	for nfs@lists.sourceforge.net; Mon, 13 Aug 2007 06:14:40 -0700
In-Reply-To: <46B37CDE.1070904@redhat.com>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--------------080203070307020606040400
Content-Type: TEXT/PLAIN; CHARSET=ISO-8859-1; FORMAT=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Content-ID: <Pine.LNX.4.64.0708131511472.15451@maggie.lkpg.cendio.se>

On Fri, 3 Aug 2007, Peter Staubach wrote:

> Attached is a patch to modify the NFS client code to support
> 64 bit ino's, as appropriate for the system and the NFS
> protocol version.
>=20
> The code basically just expand the NFS interfaces for routines
> which handle ino's from using ino_t to u64 and then uses the
> fileid in the nfs_inode instead of i_ino in the inode.  The

This patch seems to overlap with linux-2.6-nfs-64-bit-inode-support.patch,=
=20
which is included in RHEL5 kernels. Are these patches related, somehow?=20
The RHEL5 patch causes problems, as described at=20
https://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=3D241348.

Regards,=20
---
Peter =C3=85strand=09=09ThinLinc Chief Developer
Cendio AB=09=09http://www.cendio.se
Wallenbergs gata 4
583 30 Link=C3=B6ping=09Phone: +46-13-21 46 00
--------------080203070307020606040400
Content-Type: TEXT/PLAIN; NAME=fc-6.ino64.client
Content-ID: <Pine.LNX.4.64.0708131511473.15451@maggie.lkpg.cendio.se>
Content-Description: 
Content-Disposition: INLINE; FILENAME=fc-6.ino64.client

--- linux-2.6.22.i686/fs/nfs/dir.c.org
+++ linux-2.6.22.i686/fs/nfs/dir.c
@@ -407,7 +407,7 @@ int nfs_do_filldir(nfs_readdir_descripto
 	struct file	*file = desc->file;
 	struct nfs_entry *entry = desc->entry;
 	struct dentry	*dentry = NULL;
-	unsigned long	fileid;
+	u64		fileid;
 	int		loop_count = 0,
 			res;
 
@@ -418,7 +418,7 @@ int nfs_do_filldir(nfs_readdir_descripto
 		unsigned d_type = DT_UNKNOWN;
 		/* Note: entry->prev_cookie contains the cookie for
 		 *	 retrieving the current dirent on the server */
-		fileid = nfs_fileid_to_ino_t(entry->ino);
+		fileid = entry->ino;
 
 		/* Get a dentry if we have one */
 		if (dentry != NULL)
@@ -428,7 +428,7 @@ int nfs_do_filldir(nfs_readdir_descripto
 		/* Use readdirplus info */
 		if (dentry != NULL && dentry->d_inode != NULL) {
 			d_type = dt_type(dentry->d_inode);
-			fileid = dentry->d_inode->i_ino;
+			fileid = NFS_FILEID(dentry->d_inode);
 		}
 
 		res = filldir(dirent, entry->name, entry->len, 
@@ -1349,9 +1349,9 @@ static int nfs_rmdir(struct inode *dir, 
 static int nfs_sillyrename(struct inode *dir, struct dentry *dentry)
 {
 	static unsigned int sillycounter;
-	const int      i_inosize  = sizeof(dir->i_ino)*2;
+	const int      fileidsize  = sizeof(NFS_FILEID(dentry->d_inode))*2;
 	const int      countersize = sizeof(sillycounter)*2;
-	const int      slen       = sizeof(".nfs") + i_inosize + countersize - 1;
+	const int      slen        = sizeof(".nfs")+fileidsize+countersize-1;
 	char           silly[slen+1];
 	struct qstr    qsilly;
 	struct dentry *sdentry;
@@ -1369,8 +1369,9 @@ static int nfs_sillyrename(struct inode 
 	if (dentry->d_flags & DCACHE_NFSFS_RENAMED)
 		goto out;
 
-	sprintf(silly, ".nfs%*.*lx",
-		i_inosize, i_inosize, dentry->d_inode->i_ino);
+	sprintf(silly, ".nfs%*.*Lx",
+		fileidsize, fileidsize,
+		(unsigned long long)NFS_FILEID(dentry->d_inode));
 
 	/* Return delegation in anticipation of the rename */
 	nfs_inode_return_delegation(dentry->d_inode);
--- linux-2.6.22.i686/fs/nfs/inode.c.org
+++ linux-2.6.22.i686/fs/nfs/inode.c
@@ -450,8 +450,10 @@ int nfs_getattr(struct vfsmount *mnt, st
 		err = __nfs_revalidate_inode(NFS_SERVER(inode), inode);
 	else
 		err = nfs_revalidate_inode(NFS_SERVER(inode), inode);
-	if (!err)
+	if (!err) {
 		generic_fillattr(inode, stat);
+		stat->ino = NFS_FILEID(inode);
+	}
 	return err;
 }
 
--- linux-2.6.22.i686/fs/nfs/nfs4proc.c.org
+++ linux-2.6.22.i686/fs/nfs/nfs4proc.c
@@ -174,7 +174,7 @@ static void nfs4_setup_readdir(u64 cooki
 		*p++ = xdr_one;                         /* bitmap length */
 		*p++ = htonl(FATTR4_WORD0_FILEID);             /* bitmap */
 		*p++ = htonl(8);              /* attribute buffer length */
-		p = xdr_encode_hyper(p, dentry->d_inode->i_ino);
+		p = xdr_encode_hyper(p, NFS_FILEID(dentry->d_inode));
 	}
 	
 	*p++ = xdr_one;                                  /* next */
@@ -186,7 +186,7 @@ static void nfs4_setup_readdir(u64 cooki
 	*p++ = xdr_one;                         /* bitmap length */
 	*p++ = htonl(FATTR4_WORD0_FILEID);             /* bitmap */
 	*p++ = htonl(8);              /* attribute buffer length */
-	p = xdr_encode_hyper(p, dentry->d_parent->d_inode->i_ino);
+	p = xdr_encode_hyper(p, NFS_FILEID(dentry->d_parent->d_inode));
 
 	readdir->pgbase = (char *)p - (char *)start;
 	readdir->count -= readdir->pgbase;

--------------080203070307020606040400
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
--------------080203070307020606040400
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------080203070307020606040400--

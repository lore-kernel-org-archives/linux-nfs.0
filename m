From: Neil Brown <neilb@suse.de>
Subject: kernel BUG at fs/nfs/namespace.c:108! - can be triggered by
 bad server
Date: Thu, 1 Nov 2007 16:50:20 +1100
Message-ID: <18217.26908.696010.781137@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1InSwh-0006PH-Oj
	for nfs@lists.sourceforge.net; Wed, 31 Oct 2007 22:50:24 -0700
Received: from ns.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1InSwm-0001Q4-UO
	for nfs@lists.sourceforge.net; Wed, 31 Oct 2007 22:50:29 -0700
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


Hi Trond,

I have discovered that the BUG_ON in nfs_follow_mountpoint:

	BUG_ON(IS_ROOT(dentry));

can be triggered by a misbehaving server.

What happens is the client does a lookup and discoveres that the named
directory has a different fsid, so it initiates a mount.
It then performs a GETATTR on the mounted directory and gets a
different fsid again (due to a bug in the NFS server).
This causes nfs_follow_mountpoint to be called on the newly mounted
root, which triggers the BUG_ON.

To duplicate this, have a directory which contains some mountpoints,
and export that directory with the "crossmnt" flag using nfs-utils
1.1.1 (or 1.1.0 I think)

The GETATTR on the root of the mounted filesystem will return the
information for the top exportpoint, while a lookup will return the
correct information.  This difference causes the NFS client to BUG.

I think the best way to fix this is to trap this possibility early, so
just before completing the mount in the NFS client, check that it isn't
going to use nfs_mountpoint_inode_operations.
As long as i_op will never change once set (is that true?), this
should be adequately safe.

The following patch shows a possible approach, and it works for me.
i.e. when the NFS server is misbehaving, I get ESTALE on those
mountpoints, while when the NFS server is working correctly, I get
correct behaviour on the client.

NeilBrown

diff .prev/fs/nfs/super.c ./fs/nfs/super.c
--- .prev/fs/nfs/super.c	2007-11-01 16:30:49.000000000 +1100
+++ ./fs/nfs/super.c	2007-11-01 16:32:24.000000000 +1100
@@ -1474,6 +1474,11 @@ static int nfs_xdev_get_sb(struct file_s
 		error = PTR_ERR(mntroot);
 		goto error_splat_super;
 	}
+	if (mntroot->d_inode->i_op != nfs_dir_operations) {
+		dput(mntroot);
+		error = -ESTALE;
+		goto error_splat_super;
+	}
 
 	s->s_flags |= MS_ACTIVE;
 	mnt->mnt_sb = s;


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

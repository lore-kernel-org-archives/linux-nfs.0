From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: [PATCH] NFS client doesn't flush dirty mmap'd pages during fsync/msync
Date: Tue, 20 Jan 2004 05:55:53 -0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <482A3FA0050D21419C269D13989C611302B07B38@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1AiwMU-0000XO-Qk
	for nfs@lists.sourceforge.net; Tue, 20 Jan 2004 05:56:10 -0800
Received: from mx01.netapp.com ([198.95.226.53])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1AiwMU-0008Jb-70
	for nfs@lists.sourceforge.net; Tue, 20 Jan 2004 05:56:10 -0800
To: <trond.myklebust@fys.uio.no>, <okir@suse.de>
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

> > Given that we have the inode for these dirty pages,=20
> > couldn't we at least
> > compare the req->wb_inode to filp->f_dentry->d_inode?
>=20
> I believe that is indeed what Chuck's patch does.

no, my patch simply removes the filp check.  the inode
is not available in nfs_scan_list, and there was never
a check there to see if the inode pointers match.

> > With your patch, an fsync degenerates to a global sync
> > on the mounted file system, if I'm not mistaken.

the patch does not change which list is passed to nfs_scan_list.
nfs_scan_list is used by nfs_scan_dirty and nfs_scan_commit --
so it always works on a single file at a time.


-------------------------------------------------------
The SF.Net email is sponsored by EclipseCon 2004
Premiere Conference on Open Tools Development and Integration
See the breadth of Eclipse activity. February 3-5 in Anaheim, CA.
http://www.eclipsecon.org/osdn
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

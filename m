From: <trond.myklebust@fys.uio.no>
Subject: RE: [PATCH] NFS client doesn't flush dirty mmap'd pages during fsync/msync
Date: Tue, 20 Jan 2004 15:37:43 +0100 (CET)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <35259.68.42.103.198.1074609463.squirrel@webmail.uio.no>
References: <482A3FA0050D21419C269D13989C611302B07B38@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: <okir@suse.de>, <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Aix0u-0007mP-2F
	for nfs@lists.sourceforge.net; Tue, 20 Jan 2004 06:37:56 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1Aix0t-0004Cj-Oc
	for nfs@lists.sourceforge.net; Tue, 20 Jan 2004 06:37:55 -0800
To: <Charles.Lever@netapp.com>
In-Reply-To: <482A3FA0050D21419C269D13989C611302B07B38@lavender-fe.eng.netapp.com>
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

> no, my patch simply removes the filp check.  the inode
> is not available in nfs_scan_list, and there was never
> a check there to see if the inode pointers match.

An explicit check would be superfluous. The point is that there's an
implicit check given that nfs_flush_file() and nfs_commit_file() both take
an inode argument in order to be able to pass the per-inode dirtyand
commit request lists respectively as arguments to nfs_scan_list().

Note: this would be more transparent if you would also convert all
remaining nfs_wb_file() calls to nfs_wb_all(), and then kill the former.

Cheers,
  Trond




-------------------------------------------------------
The SF.Net email is sponsored by EclipseCon 2004
Premiere Conference on Open Tools Development and Integration
See the breadth of Eclipse activity. February 3-5 in Anaheim, CA.
http://www.eclipsecon.org/osdn
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

From: Olaf Kirch <okir@suse.de>
Subject: Re: [PATCH] NFS client doesn't flush dirty mmap'd pages during fsync/msync
Date: Tue, 20 Jan 2004 15:58:33 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040120145833.GT17993@suse.de>
References: <482A3FA0050D21419C269D13989C611302B07B38@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Cc: trond.myklebust@fys.uio.no, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1AixKv-0002mH-Ur
	for nfs@lists.sourceforge.net; Tue, 20 Jan 2004 06:58:37 -0800
Received: from ns.suse.de ([195.135.220.2] helo=Cantor.suse.de)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.30)
	id 1AixKv-0006aN-Jh
	for nfs@lists.sourceforge.net; Tue, 20 Jan 2004 06:58:37 -0800
To: "Lever, Charles" <Charles.Lever@netapp.com>
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

On Tue, Jan 20, 2004 at 05:55:53AM -0800, Lever, Charles wrote:
> > > With your patch, an fsync degenerates to a global sync
> > > on the mounted file system, if I'm not mistaken.
> 
> the patch does not change which list is passed to nfs_scan_list.
> nfs_scan_list is used by nfs_scan_dirty and nfs_scan_commit --
> so it always works on a single file at a time.

Ah, that was the point I missed.

Thanks,
Olaf
-- 
Olaf Kirch     |  Stop wasting entropy - start using predictable
okir@suse.de   |  tempfile names today!
---------------+ 


-------------------------------------------------------
The SF.Net email is sponsored by EclipseCon 2004
Premiere Conference on Open Tools Development and Integration
See the breadth of Eclipse activity. February 3-5 in Anaheim, CA.
http://www.eclipsecon.org/osdn
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

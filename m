From: Olaf Kirch <okir@suse.de>
Subject: Re: [PATCH] NFS client doesn't flush dirty mmap'd pages during fsync/msync
Date: Tue, 20 Jan 2004 13:01:17 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040120120116.GP17993@suse.de>
References: <Pine.BSO.4.33.0401141300540.10050-100000@citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	Linux NFS List <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1AiubQ-00086k-W1
	for nfs@lists.sourceforge.net; Tue, 20 Jan 2004 04:03:28 -0800
Received: from ns.suse.de ([195.135.220.2] helo=Cantor.suse.de)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.30)
	id 1AiubO-00078z-3W
	for nfs@lists.sourceforge.net; Tue, 20 Jan 2004 04:03:26 -0800
To: Chuck Lever <cel@citi.umich.edu>
In-Reply-To: <Pine.BSO.4.33.0401141300540.10050-100000@citi.umich.edu>
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

Hi,

On Wed, Jan 14, 2004 at 01:46:27PM -0500, Chuck Lever wrote:
> the nfs_writepage interface causes dirty mmap'd pages to be queued on an
> NFS inode's dirty page queue.  these pages are queued with a NULL filp
> because a filp is not available via the nfs_writepage interface.  when
> nfs_fsync is invoked (either via fsync() or via msync()), it is looking
> specifically for dirty pages associated with a given filp, so it skips the
> dirty pages with a NULL filp.

Given that we have the inode for these dirty pages, couldn't we at least
compare the req->wb_inode to filp->f_dentry->d_inode? With your patch,
an fsync degenerates to a global sync on the mounted file system, if
I'm not mistaken.

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

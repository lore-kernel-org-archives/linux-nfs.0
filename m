From: Jeremy Sanders <jss@ast.cam.ac.uk>
Subject: Re: Permission denied
Date: Wed, 7 May 2003 17:32:09 +0100 (BST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.55.0305071723530.2587@xpc5.ast.cam.ac.uk>
References: <Pine.LNX.4.55.0305071639490.2587@xpc5.ast.cam.ac.uk>
 <3EB93285.F40CC32A@moving-picture.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from gold.csi.cam.ac.uk ([131.111.8.12])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19DRqT-00080h-00
	for <nfs@lists.sourceforge.net>; Wed, 07 May 2003 09:32:41 -0700
To: James Pearson <james-p@moving-picture.com>
In-Reply-To: <3EB93285.F40CC32A@moving-picture.com>
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

On Wed, 7 May 2003, James Pearson wrote:

> What version of nfs-utils are you running on the server?

nfs-utils-0.3.3 on both. From the thread this looks like it has the bug
(unless RedHat patched it in their rpm).  I'll have a go updating it and
see whether we still get the bug.

> Also, if you manually attempt to umount an NFS file system (automounted
> or not), but the umount fails because the file system is busy - this
> will cause a problem as rpc.mountd on the server has already removed the
> client from /var/lib/nfs/rmtab - which means if the server reboots, the
> server has no record of the client mount, so you get permission denied
> on client when it accesses the mount point ... see:

That's interesting. Thanks!

Jeremy

-- 
Jeremy Sanders <jss@ast.cam.ac.uk>   http://www-xray.ast.cam.ac.uk/~jss/
X-Ray Group, Institute of Astronomy, University of Cambridge, UK.
Public Key Server PGP Key ID: E1AAE053


-------------------------------------------------------
Enterprise Linux Forum Conference & Expo, June 4-6, 2003, Santa Clara
The only event dedicated to issues related to Linux enterprise solutions
www.enterpriselinuxforum.com

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

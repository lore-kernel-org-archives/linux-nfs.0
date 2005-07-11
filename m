From: Olaf Kirch <okir@suse.de>
Subject: Re: [PATCH NFSv2] Drop inode after rename
Date: Mon, 11 Jul 2005 13:07:33 +0200
Message-ID: <20050711110733.GN27163@suse.de>
References: <20050711104611.GK27163@suse.de> <1121079942.8204.15.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net, Michael Schroeder <mls@suse.de>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Drw96-0004Ig-Po
	for nfs@lists.sourceforge.net; Mon, 11 Jul 2005 04:08:20 -0700
Received: from cantor2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.44)
	id 1Drw96-0008Tg-F4
	for nfs@lists.sourceforge.net; Mon, 11 Jul 2005 04:08:20 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1121079942.8204.15.camel@lade.trondhjem.org>
Sender: nfs-admin@lists.sourceforge.net
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

On Mon, Jul 11, 2005 at 07:05:42AM -0400, Trond Myklebust wrote:
> > When doing a rename on a NFSv2 mount on top of an existing file, the
> > inode of the overwritten file would remain, with all caches intact. If
> > a new file created subsequently ended up with the same inode number, it
> > would pick up the stale cache.
> 
> This should never happen. The inodes are not indexed on the inode
> number, they are indexed on the _filehandle_.

But it does happen. The new file on the NFS server has the exact
same file handle.

Olaf
-- 
Olaf Kirch   |  --- o --- Nous sommes du soleil we love when we play
okir@suse.de |    / | \   sol.dhoop.naytheet.ah kin.ir.samse.qurax


-------------------------------------------------------
This SF.Net email is sponsored by the 'Do More With Dual!' webinar happening
July 14 at 8am PDT/11am EDT. We invite you to explore the latest in dual
core and dual graphics technology at this free one hour event hosted by HP, 
AMD, and NVIDIA.  To register visit http://www.hp.com/go/dualwebinar
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

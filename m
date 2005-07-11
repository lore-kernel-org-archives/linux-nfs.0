From: Olaf Kirch <okir@suse.de>
Subject: Re: [PATCH NFSv2] Drop inode after rename
Date: Mon, 11 Jul 2005 13:24:31 +0200
Message-ID: <20050711112431.GP27163@suse.de>
References: <20050711104611.GK27163@suse.de> <1121079942.8204.15.camel@lade.trondhjem.org> <20050711110733.GN27163@suse.de> <1121080460.8204.18.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net, Michael Schroeder <mls@suse.de>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DrwOp-0004zq-Is
	for nfs@lists.sourceforge.net; Mon, 11 Jul 2005 04:24:35 -0700
Received: from ns2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.44)
	id 1DrwOo-0003P2-1t
	for nfs@lists.sourceforge.net; Mon, 11 Jul 2005 04:24:35 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1121080460.8204.18.camel@lade.trondhjem.org>
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

On Mon, Jul 11, 2005 at 07:14:20AM -0400, Trond Myklebust wrote:
> If people care enough about their data to worry about this sort of
> problem, then they should care enough to use a server that doesn't
> violate the NFS protocol.

unfsd definitely does it this way, unfortunately. I agree that
it's not a very good idea to continue to use unfsd, but...

I would still vote for merging this patch, as it just does
the same nlink accounting that other functions already do,
eg nfs_rmdir, nfs_safe_remove, etc. The latter even has a comment
preceding it that says

* We invalidate the attribute cache and free the inode prior to the operation
* to avoid possible races if the server reuses the inode.

So I think my patch isn't that absurd, is it? :)

Cheers,
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

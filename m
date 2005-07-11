From: Michael Schroeder <mls@suse.de>
Subject: Re: [PATCH NFSv2] Drop inode after rename
Date: Mon, 11 Jul 2005 14:28:18 +0200
Message-ID: <20050711122818.GA19562@suse.de>
References: <20050711104611.GK27163@suse.de> <1121079942.8204.15.camel@lade.trondhjem.org> <20050711110733.GN27163@suse.de> <1121080460.8204.18.camel@lade.trondhjem.org> <20050711112431.GP27163@suse.de> <1121082965.8204.42.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Olaf Kirch <okir@suse.de>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DrxOd-0007m8-6V
	for nfs@lists.sourceforge.net; Mon, 11 Jul 2005 05:28:27 -0700
Received: from mx1.suse.de ([195.135.220.2])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.44)
	id 1DrxOb-0002Xo-BJ
	for nfs@lists.sourceforge.net; Mon, 11 Jul 2005 05:28:27 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1121082965.8204.42.camel@lade.trondhjem.org>
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

On Mon, Jul 11, 2005 at 07:56:05AM -0400, Trond Myklebust wrote:
> ...but it should be unnecessary.
> 
> d_delete() is supposed to cause the inode to be dropped: if it cannot
> immediately iput the inode, it will drop the dentry. So unless there
> exists a hard link or an aliased dentry, the inode should get dropped
> and freed pretty rapidly.

AFAIR the problem is that i_nlink doesn't get decremented and
therefore the inode doesn't get deleted.

Cheers,
  Michael.

-- 
Michael Schroeder                                   mls@suse.de
main(_){while(_=~getchar())putchar(~_-1/(~(_|32)/13*2-11)*13);}


-------------------------------------------------------
This SF.Net email is sponsored by the 'Do More With Dual!' webinar happening
July 14 at 8am PDT/11am EDT. We invite you to explore the latest in dual
core and dual graphics technology at this free one hour event hosted by HP, 
AMD, and NVIDIA.  To register visit http://www.hp.com/go/dualwebinar
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

From: Junfeng Yang <yjf@stanford.edu>
Subject: Re: [CHECKER] inconsistent NFS stat cache (NFS on ext3, 2.6.11)
Date: Sat, 12 Mar 2005 22:16:34 -0800 (PST)
Message-ID: <Pine.GSO.4.44.0503122216030.5685-100000@elaine24.Stanford.EDU>
References: <1110690267.24123.7.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: nfs@lists.sourceforge.net,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	<ext2-devel@lists.sourceforge.net>, <mc@cs.Stanford.EDU>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1110690267.24123.7.camel@lade.trondhjem.org>
Sender: ext2-devel-admin@lists.sourceforge.net
Errors-To: ext2-devel-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/ext2-devel>,
	<mailto:ext2-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Post: <mailto:ext2-devel@lists.sourceforge.net>
List-Help: <mailto:ext2-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/ext2-devel>,
	<mailto:ext2-devel-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=ext2-devel>
List-ID: <nfs.lists.sourceforge.net>

> This is a known problem. Turn off the (default - grrr) subtree checking
> export option on the server, and it will all work properly. The subtree
> checking option violates the NFS standards for filehandle generation in
> so many ways, that it isn't even funny.

Thanks Trond.  no_subtree_check fixes the problem.

-Junfeng



-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click

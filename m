From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [CHECKER] inconsistent NFS stat cache (NFS on ext3, 2.6.11)
Date: Sun, 13 Mar 2005 15:46:34 -0500
Message-ID: <1110746794.23876.11.camel@lade.trondhjem.org>
References: <Pine.GSO.4.44.0503120335160.12085-100000@elaine24.Stanford.EDU>
	 <1110690267.24123.7.camel@lade.trondhjem.org>
	 <20050313200412.GA21521@nevyn.them.org>
	 <1110746550.23876.8.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Junfeng Yang <yjf@stanford.edu>, nfs@lists.sourceforge.net,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	ext2-devel@lists.sourceforge.net, mc@cs.Stanford.EDU
To: Daniel Jacobowitz <dan@debian.org>
In-Reply-To: <1110746550.23876.8.camel@lade.trondhjem.org>
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

su den 13.03.2005 Klokka 15:42 (-0500) skreiv Trond Myklebust:

> No, that's a very different issue: you are violating the NFS cache
> consistency rules if you are changing a file that is being held open by
> other machines.
> The correct way to do the above is to use GNU install with the '-b'
> option: that will rename the version of glibc that is in use, and then
> install the new glibc in a different inode.

BTW: there is a more complete description of the NFS cache consistency
model in the NFS FAQ:

  http://nfs.sourceforge.net/index.cel.php#faq_a8

Cheers,
  Trond

-- 
Trond Myklebust <trond.myklebust@fys.uio.no>



-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click

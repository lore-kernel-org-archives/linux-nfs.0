From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [CHECKER] inconsistent NFS stat cache (NFS on ext3, 2.6.11)
Date: Sun, 13 Mar 2005 15:42:29 -0500
Message-ID: <1110746550.23876.8.camel@lade.trondhjem.org>
References: <Pine.GSO.4.44.0503120335160.12085-100000@elaine24.Stanford.EDU>
	 <1110690267.24123.7.camel@lade.trondhjem.org>
	 <20050313200412.GA21521@nevyn.them.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Junfeng Yang <yjf@stanford.edu>, nfs@lists.sourceforge.net,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	ext2-devel@lists.sourceforge.net, mc@cs.Stanford.EDU
To: Daniel Jacobowitz <dan@debian.org>
In-Reply-To: <20050313200412.GA21521@nevyn.them.org>
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

su den 13.03.2005 Klokka 15:04 (-0500) skreiv Daniel Jacobowitz:

> I can't find any documentation about this, but it seems like the same
> problem that has been causing me headaches lately; when I replace glibc
> from the server side of an nfsroot, the client has a couple of
> variously wrong reads before it sees the new files.  If it breaks NFS
> so badly, why is it the default for the Linux NFS server?

No, that's a very different issue: you are violating the NFS cache
consistency rules if you are changing a file that is being held open by
other machines.
The correct way to do the above is to use GNU install with the '-b'
option: that will rename the version of glibc that is in use, and then
install the new glibc in a different inode.

Cheers,
  Trond
-- 
Trond Myklebust <trond.myklebust@fys.uio.no>



-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [CHECKER] inconsistent NFS stat cache (NFS on ext3, 2.6.11)
Date: Sun, 13 Mar 2005 00:04:27 -0500
Message-ID: <1110690267.24123.7.camel@lade.trondhjem.org>
References: <Pine.GSO.4.44.0503120335160.12085-100000@elaine24.Stanford.EDU>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	ext2-devel@lists.sourceforge.net, mc@cs.Stanford.EDU
To: Junfeng Yang <yjf@stanford.edu>
In-Reply-To: <Pine.GSO.4.44.0503120335160.12085-100000@elaine24.Stanford.EDU>
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

lau den 12.03.2005 Klokka 03:56 (-0800) skreiv Junfeng Yang:
> Hi,
> 
> We checked NFS on top of ext3 using FiSC (our file system model checker)
> and found a case where NFS stat cache can contain inconsistent entries.
> 
> Basically, to trigger this inconsistency, just do the following steps:
> 1. create a file A1, write a few bytes to it, so A1 is 4 words
> 2. create a hard link A2, pointing to A1
> 3. stat on A2. A2's size is 4 words
> 4. truncate A1 to a larger size, write a few bytes at the end. now it's
> 1031 words.
> 5. stat on A2. it's size is still 4 words, which should be 1031 words
> 
> We have a test case to re-create this warning.  You can download it at
> http://fisc.stanford.edu/bug16/crash.c.  It includes some sudo commands
> to mount nfs partitions, which you might want to change according to your
> local settings.
> 
> cat /etc/exports shows:
> /mnt/sbd0-export          localhost(rw,sync)
> /mnt/sbd1-export          localhost(rw,sync)
> 
> Let me know if you have any problems reproducing the warning. We'd
> appreciate any confirmations/clarifications.
> 

This is a known problem. Turn off the (default - grrr) subtree checking
export option on the server, and it will all work properly. The subtree
checking option violates the NFS standards for filehandle generation in
so many ways, that it isn't even funny.

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

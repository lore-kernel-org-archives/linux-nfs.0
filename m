From: Chuck Lever <cel@monkey.org>
Subject: Re: [PATCH] 2.4.19-pre10 RPC changes...
Date: Sat, 29 Jun 2002 14:53:37 -0400 (EDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.BSO.4.44.0206291443140.8167-100000@naughty.monkey.org>
References: <200206212140.34595.trond.myklebust@fys.uio.no>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from vhost.monkey.org ([204.181.64.9] helo=naughty.monkey.org)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17ONMW-0003c1-00
	for <nfs@lists.sourceforge.net>; Sat, 29 Jun 2002 11:54:24 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <200206212140.34595.trond.myklebust@fys.uio.no>
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

hi trond-

i'm able to deadlock my dual 1.26GHz P-III with just these patches applied
to a naked 2.4.19-pre10 kernel:

linux-2.4.19-00-fix_refresh.dif
linux-2.4.19-01-fix_kmap1.dif
linux-2.4.19-02-fix_kmap2.dif
linux-2.4.19-03-fix_kmap3.dif

i'm running "make -j2 bzImage" with other minor activity in the same file
system (editing files, building small packages).  the file system is
stored on a NetApp filer.

i was using 19-pre8-NFSALL on other slower systems without trouble, but
i think 19-pre8-NFSALL may have had some trouble on this system too.
pre8, pre9, and pre10 work without problem on this system.  fix_refresh
alone appeared to work OK on this system.

On Fri, 21 Jun 2002, Trond Myklebust wrote:

>
> Hi,
>
> I've put up the full set of RPC changes that I'd like to push into 2.4.20 in
>
>   http://www.fys.uio.no/~trondmy/src/2.4.19-pre10/linux-2.4.19-RPC_ALL.dif
>
> The full set of partial patches can be found in the same directory.
>
> Patches contain
>
>   1) Full set of 2.5.x kmap() changes for avoiding highmem deadlocks.
>
>   2) RTT (round trip timing) estimation for improving the UDP timeout + resend
> mechanism. Algorithm is the standard one as described in the Van Jacobson
> paper (see http://www-nrg.ee.lbl.gov/papers/congavoid.pdf)
>
>   3) Slow start + congestion avoidance algorithms for UDP. Again see the Van
> Jacobson paper.
>
>   4) A couple of minor cleanups.
>
> In particular, it would be nice if people could test out the RTT + congestion
> avoidance. Although it is probably not a cure for all of our UDP problems, I
> would expect performance to improve on most platforms. In particular, I'd
> very much encourage those people who reported a performance slowdown with the
> previous NFS_ALL patch to test this out.
>
> Cheers,
>    Trond
>

	- Chuck Lever
--
corporate:	<cel@netapp.com>
personal:	<chucklever@bigfoot.com>



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
No, I will not fix your computer.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

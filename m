From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: [PATCH] 2.4.19-pre10 RPC changes...
Date: Fri, 21 Jun 2002 21:40:34 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200206212140.34595.trond.myklebust@fys.uio.no>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pat.uio.no ([129.240.130.16])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17LUGy-0007QD-00
	for <nfs@lists.sourceforge.net>; Fri, 21 Jun 2002 12:40:44 -0700
To: Chuck Lever <cel@monkey.org>
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


Hi,

I've put up the full set of RPC changes that I'd like to push into 2.4.20 in

  http://www.fys.uio.no/~trondmy/src/2.4.19-pre10/linux-2.4.19-RPC_ALL.dif

The full set of partial patches can be found in the same directory.

Patches contain

  1) Full set of 2.5.x kmap() changes for avoiding highmem deadlocks.

  2) RTT (round trip timing) estimation for improving the UDP timeout + resend 
mechanism. Algorithm is the standard one as described in the Van Jacobson 
paper (see http://www-nrg.ee.lbl.gov/papers/congavoid.pdf)

  3) Slow start + congestion avoidance algorithms for UDP. Again see the Van 
Jacobson paper.

  4) A couple of minor cleanups.

In particular, it would be nice if people could test out the RTT + congestion 
avoidance. Although it is probably not a cure for all of our UDP problems, I 
would expect performance to improve on most platforms. In particular, I'd 
very much encourage those people who reported a performance slowdown with the 
previous NFS_ALL patch to test this out.

Cheers,
   Trond


-------------------------------------------------------
Sponsored by:
ThinkGeek at http://www.ThinkGeek.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

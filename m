From: Greg Banks <gnb@melbourne.sgi.com>
Subject: [PATCH 0/8] knfsd: repcache renovation
Date: Wed, 11 Oct 2006 21:24:22 +1000
Message-ID: <1160565862.8530.5.camel@hole.melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GXcCM-000185-3E
	for nfs@lists.sourceforge.net; Wed, 11 Oct 2006 04:24:30 -0700
Received: from omx2-ext.sgi.com ([192.48.171.19] helo=omx2.sgi.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GXcCL-0006T0-Rz
	for nfs@lists.sourceforge.net; Wed, 11 Oct 2006 04:24:31 -0700
To: Neil Brown <neilb@suse.de>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

G'day,

This patch set renovates the knfsd duplicate request reply
cache aka the repcache, primarily aimed at scalability to
large workloads.  Substantially identical patches to these
have been shipping for some months as part of SGI's NAS
Server Bundle.

1 minor cleanups
    Minor whitespace, formatting and comment changes.
2 make REQHASH a function
    Make the REQHASH() macro an inline function and tweak
    it to handle observed client xid behaviour.
3 inline hash_refile
    Explicitly inline hash_refile(), it's only used in one place.
4 split hash index
    Split the repcache hash into multiple buckets on SMP platforms,
    to avoid lock contention and bouncing cachelines.
5 dynamically expand under load
    Allow the repcache to expand on demand, when too young an
    entry falls off the end of an LRU chain.
6 use client IP address in hash
    Use the client's IP address in the repcache hash function, to
    avoid contention on computer cluster workloads.
7 faster hash chain probe
    Squeeze some small performance improvements out of the repcache's
    lookup function by speeding comparisons during hash chain probing.
8 add statistics
    Add more statistics to the repcache, and reduce contention
    by keeping stats per-bucket and aggregating them on demand.

P.S. AFAIK this is the repcache work referred to in Olaf Kirch's
talk at OLS this year.

Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
I don't speak for SGI.



-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

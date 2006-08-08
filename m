From: Greg Banks <gnb@melbourne.sgi.com>
Subject: [PATCH 0 of 5] knfsd: miscellaneous performance-related fixes
Date: Tue, 08 Aug 2006 14:04:40 +1000
Message-ID: <1155009879.29877.229.camel@hole.melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GAIpj-0001ot-2i
	for nfs@lists.sourceforge.net; Mon, 07 Aug 2006 21:04:47 -0700
Received: from omx2-ext.sgi.com ([192.48.171.19] helo=omx2.sgi.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GAIpi-0006zT-CC
	for nfs@lists.sourceforge.net; Mon, 07 Aug 2006 21:04:47 -0700
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

Five more patches which fix various issues found in knfsd,
mostly directly performance-related.

1 of 5 knfsd: make readahead params cache SMP-friendly
	the racache is a global contention point and performance 	bottleneck in
some read-dominated workloads, alleviate that

2 of 5 knfsd: cache ipmap per TCP socket
	for TCP we can avoid doing a hash lookup on the ip_map
	cache for every RPC call

3 of 5 knfsd: avoid nfsd CPU scheduler overload
	avoid enormous load averages and CPU scheduler overload
	with workloads which generate extremely high call rates

4 of 5 knfsd: add RPC pool thread stats
	add some statistics to the svc_pool

5 of 5 knfsd: remove nfsd threadstats
	remove the 'th' stats line from /proc/net/rc/nfsd, it's
	a global contention point in high call rate workloads

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

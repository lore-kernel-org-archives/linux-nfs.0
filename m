From: Jason Holmes <jholmes@psu.edu>
Subject: 2.4 vs. 2.6 nfs client performance
Date: Wed, 12 Nov 2003 13:05:36 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3FB27670.4C878A84@psu.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1AJzNW-0001Ea-00
	for <nfs@lists.sourceforge.net>; Wed, 12 Nov 2003 10:06:06 -0800
Received: from vpn-19-18.aset.psu.edu ([146.186.19.18] helo=funkmachine.cac.psu.edu)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.24)
	id 1AJzNV-0007RQ-UM
	for nfs@lists.sourceforge.net; Wed, 12 Nov 2003 10:06:06 -0800
Received: from psu.edu (localhost.localdomain [127.0.0.1])
	by funkmachine.cac.psu.edu (Postfix) with ESMTP id 28FBFFA19
	for <nfs@lists.sourceforge.net>; Wed, 12 Nov 2003 13:05:37 -0500 (EST)
To: nfs@lists.sourceforge.net
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
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Hi,

I'm running some NFS performance tests to determine the best way to go
to configure a few fileservers for some linux clusters I run.  Right now
I'm getting together a suite of test programs representative of the
typical applications we see run on our clusters (scientific applications
such as Ansys or Abaqus, custom MPI code, etc.) for use as a benchmark
suite that I can disperse across 16 machines or so to create a decent
load on the fileservers.  I've just got started with a program called
Gaussian03 (molecular modelling code that does a lot of I/O) and I'm
already seeing some odd performance differences between the 2.4.22
client and the 2.6.0-test9-mm1 client (both against a 2.6.0-test9-mm2
server):

async mounts
------------
2.4.22:           110.87user 43.69system 4:04.58elapsed 63%CPU
2.6.0-test9-mm1:  111.88user 315.57system 9:51.87elapsed 72%CPU

sync mounts
-----------
2.4.22:           109.99user 45.49system 32:04.44elapsed 8%CPU
2.6.0-test9-mm1:  112.33user 197.76system 1:08:13elapsed 7%CPU

Note that the 1:08:13 in the sync 2.6.0-test9-mm1 is 1 *hour*, 8
minutes, not 1 *minute*.  In both cases the 2.6 client came in at about
twice the time.  A local run not using NFS finishes in 2:13.49.

The nfsstats output for two async runs looks like:

-- 2.4.22 --
Client nfs v3:
null       getattr    setattr    lookup     access     readlink
0       0% 880     0% 0       0% 160     0% 4745    0% 0       0%
read       write      create     mkdir      symlink    mknod
780     0% 178588 32% 24      0% 0       0% 0       0% 0       0%
remove     rmdir      rename     link       readdir    readdirplus
24      0% 0       0% 0       0% 0       0% 18      0% 0       0%
fsstat     fsinfo     pathconf   commit
3       0% 3       0% 0       0% 369185 66%

Client rpc stats:
calls      retrans    authrefrsh
554410     2099       0


-- 2.6.0-test9-mm1 --

Client nfs v3:
null       getattr    setattr    lookup     access     readlink
0       0% 740     0% 0       0% 126     0% 249     0% 0       0%
read       write      create     mkdir      symlink    mknod
855     0% 178574 14% 24      0% 0       0% 0       0% 0       0%
remove     rmdir      rename     link       readdir    readdirplus
24      0% 0       0% 0       0% 0       0% 18      0% 0       0%
fsstat     fsinfo     pathconf   commit
0       0% 3       0% 0       0% 1023777 85%

Client rpc stats:
calls      retrans    authrefrsh
1204390    5          0

The 2.6 client has over twice the number of RPC calls and almost 3 times
the number of commits whereas the 2.4 client has alot more accesses. 
Mounts were done with rsize=32768,wsize=32768.  The NFS filesystem is
ext3.  The two machines are connected via gigabit ethernet and the
traffic between them never goes above 20-30 MB/s.

Can someone clue me in as to why this may be happening and if it's a
"bug" or not?

Thanks,

--
Jason Holmes


-------------------------------------------------------
This SF.Net email sponsored by: ApacheCon 2003,
16-19 November in Las Vegas. Learn firsthand the latest
developments in Apache, PHP, Perl, XML, Java, MySQL,
WebDAV, and more! http://www.apachecon.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

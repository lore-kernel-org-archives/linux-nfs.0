From: "John Roberts" <john_roberts@credence.com>
Subject: Linux NFS client to Solaris server performance inversion
Date: Thu, 14 Oct 2004 16:10:21 -0700 (PDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200410142310.i9ENAL229446@algebra.hillsboro.credence.com>
Reply-To: John Roberts <john_roberts@credence.com>
Mime-Version: 1.0
Content-Type: MULTIPART/mixed; BOUNDARY=Swarm_of_Insects_651_000
Cc: john_roberts@credence.com
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CIEjv-0001ap-6W
	for nfs@lists.sourceforge.net; Thu, 14 Oct 2004 16:10:31 -0700
Received: from hifw1.credence.com ([63.127.103.172] helo=hinscp.hillsboro.credence.com)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1CIEjs-0003tr-Bj
	for nfs@lists.sourceforge.net; Thu, 14 Oct 2004 16:10:31 -0700
To: nfs@lists.sourceforge.net
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

--Swarm_of_Insects_651_000
Content-Type: TEXT/plain; charset=us-ascii
Content-MD5: Du5JFmYKP41yg38TiCxiJQ==


Hi,

We're noticing some strange behavior when using Linux NFS clients
talking to Solaris systems.  The faster the Solaris system,
the slower the write performance of the Linux client.

I'm running Redhat Enterprise Linux 3 (2.4.21-4.0.1).

My benchmark is performing a g++ link creating an executable image
with the output on a network drive.

strace is showing me times to a "fast" central Solaris server like:

    [pid 23002]      0.000057 _llseek(18, 7287808, [7287808], SEEK_SET) = 0
    [pid 23002]      0.000043 _llseek(11, -384, [12246656], SEEK_CUR) = 0
    [pid 23002]      0.000035 write(11, 
"U\211\345\203\354\30\211]\374\213]\10\213CP\307
    \3h\254"..., 84) = 84
    [pid 23002]      0.011686 _llseek(11, 12246528, [12246528], SEEK_SET) = 0

and to a "slow" Solaris workstation like:

    [pid 14673]      0.000057 _llseek(18, 7287808, [7287808], SEEK_SET) = 0
    [pid 14673]      0.000042 _llseek(11, -384, [12246656], SEEK_CUR) = 0
    [pid 14673]      0.000035 write(11, 
"U\211\345\203\354\30\211]\374\213]\10\213CP\307\3h
    \254"..., 84) = 84
    [pid 14673]      0.001477 _llseek(11, 12246528, [12246528], SEEK_SET) = 0

So the slower workstation is reporting back a much faster write time.

(Both are Solaris 2.8).


I thought it would be interesting to use nfsstat to try to "profile"
the differences:

nfsstat data to fast server
===========================
Client nfs v3:

write:      65459
commit:       982
getattr:     2489
lookup:       386
access:      1697


nfsstat data to slow workstation
================================
Client nfs v3:

write:      65333
commit:       850
getattr:     1133
lookup:       220
access:       630

So writing to the slower workstation causes about 15% fewer commits,
but also less than half the getattr and access numbers.

Why might this be?


thanks,

John Roberts
john_roberts@credence.com

ps
I've attached the nfsstat snapshots taken before and after
running my benchmark.

--Swarm_of_Insects_651_000
Content-Type: TEXT/plain; name="nfsstat_to_fast_server.txt"; charset=us-ascii; x-unix-mode=0664
Content-Description: nfsstat_to_fast_server.txt
Content-MD5: Oh7mvQ2PVXBX30xOyfgrpg==


Here is the result of running "nfsstat" on the Linux NFS client
workstation both before and after running the g++ link-step
benchmark.  The target volume is a "fast" SunFire server
(SunOS hifs2 5.8 Generic_108528-26 sun4u sparc SUNW,Sun-Fire-480R).


Before
======
Server rpc stats:
calls      badcalls   badauth    badclnt    xdrcall
2          0          0          0          0
Server nfs v2:
null       getattr    setattr    root       lookup     readlink
1      100% 0       0% 0       0% 0       0% 0       0% 0       0%
read       wrcache    write      create     remove     rename
0       0% 0       0% 0       0% 0       0% 0       0% 0       0%
link       symlink    mkdir      rmdir      readdir    fsstat
0       0% 0       0% 0       0% 0       0% 0       0% 0       0%

Server nfs v3:
null       getattr    setattr    lookup     access     readlink
1      100% 0       0% 0       0% 0       0% 0       0% 0       0%
read       write      create     mkdir      symlink    mknod
0       0% 0       0% 0       0% 0       0% 0       0% 0       0%
remove     rmdir      rename     link       readdir    readdirplus
0       0% 0       0% 0       0% 0       0% 0       0% 0       0%
fsstat     fsinfo     pathconf   commit
0       0% 0       0% 0       0% 0       0%

Client rpc stats:
calls      retrans    authrefrsh
932691     22         0
Client nfs v3:
null       getattr    setattr    lookup     access     readlink
0       0% 326807 35% 1780    0% 67776   7% 200779 21% 8568    0%
read       write      create     mkdir      symlink    mknod
45398   4% 238915 25% 1584    0% 107     0% 16      0% 0       0%
remove     rmdir      rename     link       readdir    readdirplus
1794    0% 86      0% 1134    0% 67      0% 32      0% 2744    0%
fsstat     fsinfo     pathconf   commit
739     0% 101     0% 0       0% 34264   3%


After
=====
Server rpc stats:
calls      badcalls   badauth    badclnt    xdrcall
2          0          0          0          0
Server nfs v2:
null       getattr    setattr    root       lookup     readlink
1      100% 0       0% 0       0% 0       0% 0       0% 0       0%
read       wrcache    write      create     remove     rename
0       0% 0       0% 0       0% 0       0% 0       0% 0       0%
link       symlink    mkdir      rmdir      readdir    fsstat
0       0% 0       0% 0       0% 0       0% 0       0% 0       0%

Server nfs v3:
null       getattr    setattr    lookup     access     readlink
1      100% 0       0% 0       0% 0       0% 0       0% 0       0%
read       write      create     mkdir      symlink    mknod
0       0% 0       0% 0       0% 0       0% 0       0% 0       0%
remove     rmdir      rename     link       readdir    readdirplus
0       0% 0       0% 0       0% 0       0% 0       0% 0       0%
fsstat     fsinfo     pathconf   commit
0       0% 0       0% 0       0% 0       0%

Client rpc stats:
calls      retrans    authrefrsh
1006095    22         0
Client nfs v3:
null       getattr    setattr    lookup     access     readlink
0       0% 329296 32% 1781    0% 68162   6% 202476 20% 8570    0%
read       write      create     mkdir      symlink    mknod
47735   4% 304374 30% 1587    0% 107     0% 16      0% 0       0%
remove     rmdir      rename     link       readdir    readdirplus
1796    0% 86      0% 1135    0% 68      0% 32      0% 2744    0%
fsstat     fsinfo     pathconf   commit
779     0% 105     0% 0       0% 35246   3%



Differences to fast server
==========================
Client nfs v3:

write:    238915 --> 304374  =  65459
commit:    34264 -->  35246  =    982
getattr:  326807 --> 329296  =   2489
lookup:    67776 -->  68162  =    386
access:   200779 --> 202476  =   1697



--Swarm_of_Insects_651_000
Content-Type: TEXT/plain; name="nfsstat_to_slow_workstation.txt"; charset=us-ascii; x-unix-mode=0664
Content-Description: nfsstat_to_slow_workstation.txt
Content-MD5: omRiQIfT4k2YjUqTwyTX5Q==


Here is the result of running "nfsstat" on the Linux NFS client
workstation both before and after running the g++ link-step
benchmark.  The target volume is a "fast" SunFire server
(SunOS hifs2 5.8 Generic_108528-26 sun4u sparc SUNW,Sun-Fire-480R).


nfsstat before link
===================
60 mexia(2.4.21-4.0.1.EL):jroberts:jroberts> nfsstat
Server rpc stats:
calls      badcalls   badauth    badclnt    xdrcall
2          0          0          0          0
Server nfs v2:
null       getattr    setattr    root       lookup     readlink
1      100% 0       0% 0       0% 0       0% 0       0% 0       0%
read       wrcache    write      create     remove     rename
0       0% 0       0% 0       0% 0       0% 0       0% 0       0%
link       symlink    mkdir      rmdir      readdir    fsstat
0       0% 0       0% 0       0% 0       0% 0       0% 0       0%

Server nfs v3:
null       getattr    setattr    lookup     access     readlink
1      100% 0       0% 0       0% 0       0% 0       0% 0       0%
read       write      create     mkdir      symlink    mknod
0       0% 0       0% 0       0% 0       0% 0       0% 0       0%
remove     rmdir      rename     link       readdir    readdirplus
0       0% 0       0% 0       0% 0       0% 0       0% 0       0%
fsstat     fsinfo     pathconf   commit
0       0% 0       0% 0       0% 0       0%

Client rpc stats:
calls      retrans    authrefrsh
861814     22         0
Client nfs v3:
null       getattr    setattr    lookup     access     readlink
0       0% 325044 37% 1748    0% 67432   7% 199595 23% 8567    0%
read       write      create     mkdir      symlink    mknod
44323   5% 173522 20% 1550    0% 107     0% 16      0% 0       0%
remove     rmdir      rename     link       readdir    readdirplus
1761    0% 86      0% 1123    0% 67      0% 32      0% 2650    0%
fsstat     fsinfo     pathconf   commit
733     0% 101     0% 0       0% 33357   3%


nfsstat after link
==================
61 mexia(2.4.21-4.0.1.EL):jroberts:jroberts> nfsstat
Server rpc stats:
calls      badcalls   badauth    badclnt    xdrcall
2          0          0          0          0
Server nfs v2:
null       getattr    setattr    root       lookup     readlink
1      100% 0       0% 0       0% 0       0% 0       0% 0       0%
read       wrcache    write      create     remove     rename
0       0% 0       0% 0       0% 0       0% 0       0% 0       0%
link       symlink    mkdir      rmdir      readdir    fsstat
0       0% 0       0% 0       0% 0       0% 0       0% 0       0%

Server nfs v3:
null       getattr    setattr    lookup     access     readlink
1      100% 0       0% 0       0% 0       0% 0       0% 0       0%
read       write      create     mkdir      symlink    mknod
0       0% 0       0% 0       0% 0       0% 0       0% 0       0%
remove     rmdir      rename     link       readdir    readdirplus
0       0% 0       0% 0       0% 0       0% 0       0% 0       0%
fsstat     fsinfo     pathconf   commit
0       0% 0       0% 0       0% 0       0%

Client rpc stats:
calls      retrans    authrefrsh
931083     22         0
Client nfs v3:
null       getattr    setattr    lookup     access     readlink
0       0% 326177 35% 1760    0% 67652   7% 200225 21% 8568    0%
read       write      create     mkdir      symlink    mknod
45393   4% 238855 25% 1558    0% 107     0% 16      0% 0       0%
remove     rmdir      rename     link       readdir    readdirplus
1769    0% 86      0% 1127    0% 67      0% 32      0% 2650    0%
fsstat     fsinfo     pathconf   commit
733     0% 101     0% 0       0% 34207   3%



Differences to slow workstation
===============================
Client nfs v3:

write:    173522 --> 238855  = 65333
commit:    33357 -->  34207  =   850
getattr:  325044 --> 326177  =  1133
lookup:    67432 -->  67652  =   220
access:   199595 --> 200225  =   630



--Swarm_of_Insects_651_000--


-------------------------------------------------------
This SF.net email is sponsored by: IT Product Guide on ITManagersJournal
Use IT products in your business? Tell us what you think of them. Give us
Your Opinions, Get Free ThinkGeek Gift Certificates! Click to find out more
http://productguide.itmanagersjournal.com/guidepromo.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

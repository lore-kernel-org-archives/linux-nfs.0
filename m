From: Harald Hannelius <harald+nfs@arcada.fi>
Subject: Re: Poor NFS performance, kernel 2.6.6.
Date: Fri, 28 May 2004 10:17:29 +0300 (EEST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.58.0405280953240.29286@penti.sit.fi>
References: <Pine.LNX.4.58.0405271331430.7539@penti.sit.fi>
 <1085695748.23934.94.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BTbcS-00073y-CV
	for nfs@lists.sourceforge.net; Fri, 28 May 2004 00:17:32 -0700
Received: from penti.sit.fi ([193.167.33.237])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1BTbcR-000501-L6
	for nfs@lists.sourceforge.net; Fri, 28 May 2004 00:17:31 -0700
Received: from penti.sit.fi (harald@localhost [127.0.0.1])
	by penti.sit.fi (8.12.10/8.12.10) with ESMTP id i4S7HTgT029888
	for <nfs@lists.sourceforge.net>; Fri, 28 May 2004 10:17:29 +0300
Received: from localhost (harald@localhost)
	by penti.sit.fi (8.12.10/8.12.9/Submit) with ESMTP id i4S7HTQb029885
	for <nfs@lists.sourceforge.net>; Fri, 28 May 2004 10:17:29 +0300
To: nfs@lists.sourceforge.net
In-Reply-To: <1085695748.23934.94.camel@lade.trondhjem.org>
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


On Thu, 27 May 2004, Trond Myklebust wrote:

> P=E5 to , 27/05/2004 klokka 06:31, skreiv Harald Hannelius:
>
> > But dd'ing the 2GB file over nfs as some NFS-HOWTO suggests takes over =
5
> > minutes. That should equal to something around 49 Mbps, correct?
>
> So what is the speed when dding the file locally on the server? (that is
> *not* the same as rsync)

:)

Kernel 2.4.26:

# time dd if=3D/dev/zero of=3Dlarge bs=3D1M count=3D2000
2000+0 records in
2000+0 records out

real    1m11.565s
user    0m0.010s
sys     0m10.520s

# time dd if=3Dlarge of=3D/dev/null
4096000+0 records in
4096000+0 records out

real    0m23.506s
user    0m1.360s
sys     0m6.820s


From=20now on all tests with kernel 2.6.6;

# time dd if=3Dlarge of=3D/dev/null
4096000+0 records in
4096000+0 records out

real    0m21.190s
user    0m1.622s
sys     0m5.192s

> What if you then do the same thing on the server via a loopback mount on
> the server (i.e. mount localhost:/home /mnt)?

While doing the dd;

 10:07:25  up 8 min,  2 users,  load average: 9.87, 6.16, 2.60

And timings for the dd-command;

 # time dd if=3Dlarge of=3D/dev/null
4096000+0 records in
4096000+0 records out

real    6m21.086s
user    0m1.712s
sys     0m5.454s

Just for the heck of it I rebooted into 2.4.26 and did  the same test over
nfs on localhost;

 # time dd if=3Dlarge of=3D/dev/null
4096000+0 records in
4096000+0 records out

real    1m11.875s
user    0m1.730s
sys     0m7.730s


> Finally, if you do "nfsstat", what sort of values are you getting for
> "retrans"?

(2.6.6)
# nfsstat
Server rpc stats:
calls      badcalls   badauth    badclnt    xdrcall
48018      0          0          0          0
Server nfs v2:
null       getattr    setattr    root       lookup     readlink
0       0% 0       0% 0       0% 0       0% 0       0% 0       0%
read       wrcache    write      create     remove     rename
0       0% 0       0% 0       0% 0       0% 0       0% 0       0%
link       symlink    mkdir      rmdir      readdir    fsstat
0       0% 0       0% 0       0% 0       0% 0       0% 0       0%

Server nfs v3:
null       getattr    setattr    lookup     access     readlink
0       0% 9       0% 0       0% 1       0% 10      0% 0       0%
read       write      create     mkdir      symlink    mknod
47995  99% 0       0% 0       0% 0       0% 0       0% 0       0%
remove     rmdir      rename     link       readdir    readdirplus
0       0% 0       0% 0       0% 0       0% 0       0% 2       0%
fsstat     fsinfo     pathconf   commit
0       0% 1       0% 0       0% 0       0%

Client rpc stats:
calls      retrans    authrefrsh
47656      609        0
Client nfs v2:
null       getattr    setattr    root       lookup     readlink
0       0% 0       0% 0       0% 0       0% 0       0% 0       0%
read       wrcache    write      create     remove     rename
0       0% 0       0% 0       0% 0       0% 0       0% 0       0%
link       symlink    mkdir      rmdir      readdir    fsstat
0       0% 0       0% 0       0% 0       0% 0       0% 0       0%

Client nfs v3:
null       getattr    setattr    lookup     access     readlink
0       0% 9       0% 0       0% 1       0% 10      0% 0       0%
read       write      create     mkdir      symlink    mknod
47633  99% 0       0% 0       0% 0       0% 0       0% 0       0%
remove     rmdir      rename     link       readdir    readdirplus
0       0% 0       0% 0       0% 0       0% 0       0% 2       0%
fsstat     fsinfo     pathconf   commit
0       0% 1       0% 0       0% 0       0%


And here's output from vmstat while doing the dd (2.6.6);

# vmstat 1
procs                      memory      swap          io     system
cpu
 r  b   swpd   free   buff  cache   si   so    bi    bo   in    cs us sy
wa id
 1 15      0   5452   1548 1009476    0    0  3350     4  910  1186  0  2
55 42
 0  8      0   6452   1556 1008312    0    0  6104     0 2583  4576  1  2
94  3
 0 12      0   4876   1552 1009948    0    0  5252     0 2395  3915  0  2
98  1
 0  8      0   5388   1536 1009488    0    0  5132     0 2404  4099  0  2
89 10
 0 12      0   6564   1536 1008264    0    0  4856     0 2310  3737  0  2
96  3
 0 17      0   4556   1544 1010364    0    0  4364    72 2157  3128  0  1
98  0
 0  7      0   5772   1552 1009132    0    0  4880     4 2325  3639  0  2
97  1
 0  5      0   6220   1536 1008808    0    0  5316     0 2377  4361  1  2
94  4
 0  2      0   5708   1528 1009156    0    0  6748     0 2756  4942  0  3
93  4
 0  6      0   6388   1536 1008468    0    0  4784     0 2269  3458  0  2
92  7
 0 16      0   5196   1504 1009724    0    0  5928     0 2563  4368  1  2
96  2
 0  3      0   6284   1508 1008632    0    0  5136     8 2384  4121  0  3
95  2
 0  2      0   6452   1488 1008380    0    0  5288     4 2400  4311  1  1
92  6
 0  6      0   4812   1492 1010144    0    0  5256     0 2428  3806  0  2
96  2
 0  7      0   5260   1472 1009756    0    0  5244     0 2379  4180  0  2
98  1
 0  8      0   5580   1456 1009500    0    0  5332     0 2418  3858  0  2
98  1
 0  6      0   5004   1464 1009968    0    0  4524     8 2238  3263  0  1
95  3


>
> Cheers,
>   Trond
>

--=20
A: Top Posters
Q: What is the most annoying thing on mailing lists?

Harald H Hannelius | harald/a\arcada.fi      | GSM +358 50 594 1020


-------------------------------------------------------
This SF.Net email is sponsored by: Oracle 10g
Get certified on the hottest thing ever to hit the market... Oracle 10g. 
Take an Oracle 10g class now, and we'll give you the exam FREE.
http://ads.osdn.com/?ad_id=3149&alloc_id=8166&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

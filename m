From: Stephan Koledin <skoledin@neolinear.com>
Subject: Re: NFS lockups with 2.4.18
Date: Thu, 25 Sep 2003 15:54:39 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3F7347FF.2000403@neolinear.com>
References: <3F71CB8A.3090208@neolinear.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1A2cCI-0005DV-00
	for <nfs@lists.sourceforge.net>; Thu, 25 Sep 2003 12:54:42 -0700
Received: from n5.neolinear.com ([208.20.218.5] helo=flood.neolinear.com)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.22)
	id 1A2cCH-0001gz-7C
	for nfs@lists.sourceforge.net; Thu, 25 Sep 2003 12:54:41 -0700
Received: from rain ([192.9.200.77])
	by flood.neolinear.com with esmtp (Exim 3.35 #1 (Debian))
	id 1A2cCF-0003XB-00
	for <nfs@lists.sourceforge.net>; Thu, 25 Sep 2003 15:54:39 -0400
To: nfs@lists.sourceforge.net
In-Reply-To: <3F71CB8A.3090208@neolinear.com>
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

We ran into an NFS lockup again this morning. It continued for 
approximately 1.5 hours, then cleared up (after a number of consecutive 
reboots) and nfs worked perfectly again.

I managed to collect some more data, in the hopes that someone might 
have some suggestions.

A process list shows that the lockd and all 32 nfsd processes are in the 
D state (uninterruptible sleep). lockd is stuck at a WCHAN of 'down'. 
Also, 31 of the nfsd processes have lost the 'super-user' process flag 
and are now marked 040 instead of the normal 140. The first nfsd and 
lockd are still 140.

Interestingly, a process snapshot from a period when nfs was still 
running, but shortly before it died, shows the nfsd processes in a 
normal 'S' state, but they have all lost their super-user process flag. 
The lockd is already in a 'D' state. Not sure if it really means much, 
but does seem strange.

nfsstat doesn't seem to show anything out of the ordinary, but maybe 
someone here will see something relevant.

Once again, thanks for any help you can provide.
-Stephan


a relevant excerpt from a `ps -elfjHm` during the lockup:

   F S UID        PID  PPID WCHAN  STIME     TIME CMD
140 D root       337     1 ?      07:36 00:00:00   [nfsd]
140 D root       338     1 down   07:36 00:00:00   [lockd]
040 S root       339   338 ?      07:36 00:00:00     [rpciod]
040 D root       340     1 ?      07:36 00:00:00   [nfsd]
040 D root       341     1 ?      07:36 00:00:00   [nfsd]
040 D root       342     1 ?      07:36 00:00:00   [nfsd]
040 D root       343     1 ?      07:36 00:00:00   [nfsd]
040 D root       344     1 ?      07:36 00:00:00   [nfsd]
040 D root       345     1 ?      07:36 00:00:00   [nfsd]
040 D root       346     1 ?      07:36 00:00:00   [nfsd]
040 D root       347     1 ?      07:36 00:00:00   [nfsd]
040 D root       348     1 ?      07:36 00:00:00   [nfsd]
040 D root       349     1 ?      07:36 00:00:00   [nfsd]
040 D root       350     1 ?      07:36 00:00:00   [nfsd]
040 D root       351     1 ?      07:36 00:00:00   [nfsd]
040 D root       352     1 ?      07:36 00:00:00   [nfsd]
040 D root       353     1 ?      07:36 00:00:00   [nfsd]
040 D root       354     1 ?      07:36 00:00:00   [nfsd]
040 D root       355     1 ?      07:36 00:00:00   [nfsd]
040 D root       356     1 ?      07:36 00:00:00   [nfsd]
040 D root       357     1 ?      07:36 00:00:00   [nfsd]
040 D root       358     1 ?      07:36 00:00:00   [nfsd]
040 D root       359     1 ?      07:36 00:00:00   [nfsd]
040 D root       360     1 ?      07:36 00:00:00   [nfsd]
040 D root       361     1 ?      07:36 00:00:00   [nfsd]
040 D root       362     1 ?      07:36 00:00:00   [nfsd]
040 D root       363     1 ?      07:36 00:00:00   [nfsd]
040 D root       364     1 ?      07:36 00:00:00   [nfsd]
040 D root       365     1 ?      07:36 00:00:00   [nfsd]
040 D root       366     1 ?      07:36 00:00:00   [nfsd]
040 D root       367     1 ?      07:36 00:00:00   [nfsd]
040 D root       368     1 ?      07:36 00:00:00   [nfsd]
040 D root       369     1 ?      07:36 00:00:00   [nfsd]
040 D root       370     1 ?      07:36 00:00:00   [nfsd]
140 S root       373     1 ?      07:36 00:00:00   /usr/sbin/rpc.mountd


an excerpt from a `ps -elfjHm` between lockups:

   F S UID        PID  PPID WCHAN  STIME TIME CMD
140 S root       327     1 ?      07:57 00:00:00   [nfsd]
140 D root       328     1 down   07:57 00:00:00   [lockd]
040 S root       329   328 ?      07:57 00:00:00     [rpciod]
040 S root       330     1 ?      07:57 00:00:00   [nfsd]
040 S root       331     1 ?      07:57 00:00:00   [nfsd]
040 S root       332     1 ?      07:57 00:00:00   [nfsd]
...
040 S root       359     1 ?      07:57 00:00:00   [nfsd]
040 S root       360     1 ?      07:57 00:00:00   [nfsd]
140 S root       363     1 poll   07:57 00:00:00   /usr/sbin/rpc.mountd


nfsstat -s during lockup:

Server rpc stats:
calls      badcalls   badauth    badclnt    xdrcall
67445      0          0          0          0
Server nfs v2:
null       getattr    setattr    root       lookup     readlink
8       0% 50557  77% 668     1% 0       0% 9828   15% 4       0%
read       wrcache    write      create     remove     rename
1762    2% 0       0% 1434    2% 184     0% 6       0% 168     0%
link       symlink    mkdir      rmdir      readdir    fsstat
0       0% 0       0% 19      0% 0       0% 675     1% 9       0%

Server nfs v3:
null       getattr    setattr    lookup     access     readlink
69      3% 342    16% 0       0% 108     5% 1601   75% 0       0%
read       write      create     mkdir      symlink    mknod
0       0% 0       0% 0       0% 0       0% 0       0% 0       0%
remove     rmdir      rename     link       readdir    readdirplus
0       0% 0       0% 0       0% 0       0% 3       0% 0       0%
fsstat     fsinfo     pathconf   commit
0       0% 0       0% 0       0% 0       0%


nfsstat -s during normal operation:

Server rpc stats:
calls      badcalls   badauth    badclnt    xdrcall
8781107    4384       4384       0          0
Server nfs v2:
null       getattr    setattr    root       lookup     readlink
3845    0% 6360155 82% 30228   0% 0       0% 643234  8% 30581   0%
read       wrcache    write      create     remove     rename
298134  3% 0       0% 212600  2% 5476    0% 5240    0% 801     0%
link       symlink    mkdir      rmdir      readdir    fsstat
11      0% 12      0% 336     0% 349     0% 75643   0% 5488    0%

Server nfs v3:
null       getattr    setattr    lookup     access     readlink
6481    0% 942506 84% 0       0% 81868   7% 64802   5% 1119    0%
read       write      create     mkdir      symlink    mknod
9091    0% 0       0% 0       0% 0       0% 0       0% 0       0%
remove     rmdir      rename     link       readdir    readdirplus
0       0% 0       0% 0       0% 0       0% 1673    0% 0       0%
fsstat     fsinfo     pathconf   commit
717     0% 717     0% 0       0% 0       0%


-- 
Stephan B Koledin
Network Systems Developer
http://neolinear.com/



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

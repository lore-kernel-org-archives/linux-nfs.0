From: Fabrizio Nesti <nesti@medialab.sissa.it>
Subject: Re: 2.4.20 TCP server + solaris client performance
Date: Wed, 19 Feb 2003 17:54:11 +0100 (MET)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.GSO.4.40.0302191725200.29315-100000@bodoni>
References: <Pine.LNX.4.44.0302191034310.29393-100000@guppy.limebrokerage.com>
Reply-To: Fabrizio Nesti <nesti@medialab.sissa.it>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from didot.sissa.it ([147.122.2.50])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18lXYD-0006KL-00
	for <nfs@lists.sourceforge.net>; Wed, 19 Feb 2003 08:58:29 -0800
To: Ion Badulescu <ionut@badula.org>
In-Reply-To: <Pine.LNX.4.44.0302191034310.29393-100000@guppy.limebrokerage.com>
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

Hello, some more precise data as requested...

> > I report below some of it during the write of one file from tar.
> If you could get timestamps for that snoop (or tcpdump) output, it would
> be great. We could at least see who is taking too much time.

This is the comparison of two UDP traffics for a "tar xf", up to the
first file written (README) from the same solaris client to two different
linux/solaris servers (apologies for the large column size..):

TO LINUX SERVER:                                                    TO SOLARIS SERVER:

0.00000   sunclient:   NFS C ACCESS3 FH=1600 (lookup)              0.00000 sunclient:   NFS C GETATTR3 FH=0102
0.00018  linuxserver:  NFS R ACCESS3 OK (lookup)                   0.00022  sunserver:  NFS R GETATTR3 OK
0.00051   sunclient:   NFS C GETATTR3 FH=1600
0.00063  linuxserver:  NFS R GETATTR3 OK

0.00083   sunclient:   NFS C MKDIR3 FH=1600 cvs-1.11.5             0.00049 sunclient:   NFS C MKDIR3 FH=0102 cvs-1.11.5
0.00112  linuxserver:  NFS R MKDIR3 OK FH=4E81                     0.00281  sunserver:  NFS R MKDIR3 OK FH=0588
0.02229   sunclient:   NFS C ACCESS3 FH=1600 (lookup)
0.02248  linuxserver:  NFS R ACCESS3 OK (lookup)

0.02273   sunclient:   NFS C LOOKUP3 FH=4E81 contrib               0.00322 sunclient:   NFS C LOOKUP3 FH=0588 contrib
0.02290  linuxserver:  NFS R LOOKUP3 No such file or directory     0.00345  sunserver:  NFS R LOOKUP3 No such file or directory
0.02311   sunclient:   NFS C MKDIR3 FH=4E81 contrib                0.00363 sunclient:   NFS C MKDIR3 FH=0588 contrib
0.02353  linuxserver:  NFS R MKDIR3 OK FH=4C81                     0.00565  sunserver:  NFS R MKDIR3 OK FH=6324
0.02402   sunclient:   NFS C ACCESS3 FH=4E81 (lookup)              0.00589 sunclient:   NFS C ACCESS3 FH=0588 (lookup)
0.02418  linuxserver:  NFS R ACCESS3 OK (lookup)                   0.00611  sunserver:  NFS R ACCESS3 OK (lookup)

0.02438   sunclient:   NFS C LOOKUP3 FH=4C81 README                0.00627 sunclient:   NFS C LOOKUP3 FH=6324 README
0.02453  linuxserver:  NFS R LOOKUP3 No such file or directory     0.00650  sunserver:  NFS R LOOKUP3 No such file or directory
0.02470   sunclient:   NFS C LOOKUP3 FH=4C81 README                0.00664 sunclient:   NFS C LOOKUP3 FH=6324 README
0.02483  linuxserver:  NFS R LOOKUP3 No such file or directory     0.00685  sunserver:  NFS R LOOKUP3 No such file or directory
0.02500   sunclient:   NFS C CREATE3 FH=4C81 (EXCLUSIVE) README    0.00699 sunclient:   NFS C CREATE3 FH=6324 (EXCLUSIVE) README
0.02537  linuxserver:  NFS R CREATE3 OK FH=DD86                    0.00851  sunserver:  NFS R CREATE3 OK FH=CA37
0.02588   sunclient:   NFS C SETATTR3 FH=DD86                      0.00894 sunclient:   NFS C SETATTR3 FH=CA37
0.02608  linuxserver:  NFS R SETATTR3 OK                           0.00983  sunserver:  NFS R SETATTR3 OK
0.04781   sunclient:   UDP IP fragment ID=59208 Offset=0    MF=1   0.01063 sunclient:   UDP IP fragment ID=46356 Offset=0    MF=1
0.04784   sunclient:   UDP IP fragment ID=59208 Offset=1480 MF=1   0.01066 sunclient:   UDP IP fragment ID=46356 Offset=1480 MF=1
0.04786   sunclient:   UDP IP fragment ID=59208 Offset=2960 MF=1   0.01068 sunclient:   UDP IP fragment ID=46356 Offset=2960 MF=1
0.04789   sunclient:   UDP IP fragment ID=59208 Offset=4440 MF=0   0.01070 sunclient:   UDP IP fragment ID=46356 Offset=4440 MF=0
0.04900  linuxserver:  RPC R XID=991204799 Success                 0.01176  sunserver:  RPC R XID=991211441 Success
0.04943   sunclient:   NFS C COMMIT3 FH=DD86 at 0 for 8192         0.01220 sunclient:   NFS C COMMIT3 FH=CA37 at 0 for 8192
0.04959  linuxserver:  NFS R COMMIT3 OK                            0.01419  sunserver:  NFS R COMMIT3 OK
0.04990   sunclient:   NFS C LOOKUP3 FH=4C81 README                0.01460 sunclient:   NFS C ACCESS3 FH=6324 (lookup)
0.05006  linuxserver:  NFS R LOOKUP3 OK FH=DD86                    0.01481  sunserver:  NFS R ACCESS3 OK (lookup)
0.05032   sunclient:   NFS C SETATTR3 FH=DD86                      0.01504 sunclient:   NFS C SETATTR3 FH=CA37
0.05048  linuxserver:  NFS R SETATTR3 OK                           0.01592  sunserver:  NFS R SETATTR3 OK
0.07132   sunclient:   NFS C LOOKUP3 FH=4C81 README                0.01750 sunclient:   NFS C SETATTR3 FH=CA37
0.07152  linuxserver:  NFS R LOOKUP3 OK FH=DD86                    0.01838  sunserver:  NFS R SETATTR3 OK
0.07184   sunclient:   NFS C SETATTR3 FH=DD86
0.07201  linuxserver:  NFS R SETATTR3 OK

At this point linux traffic is already late wrt sun traffic...

These were mounted with UDP and performance is still worse on the
linux side (say double times).

TCP improves dramatically on solaris, but not on linux.
Tomorrow I'll pack up TCP data for kernel 2.4.20.

Ciao...
Fabrizio

PS:

--- nfsstat -m on the client for the two servers:

sunserver:
 Flags:         vers=3,proto=udp,sec=sys,hard,intr,link,symlink,acl,rsize=8192,wsize=8192,retrans=5,timeo=11
 Attr cache:    acregmin=3,acregmax=60,acdirmin=30,acdirmax=60
 Lookups:     srtt=7 (17ms), dev=3 (15ms), cur=2 (40ms)
 Reads:     srtt=7 (17ms), dev=3 (15ms), cur=2 (40ms)
 Writes:     srtt=7 (17ms), dev=3 (15ms), cur=2 (40ms)
 All:     srtt=7 (17ms), dev=3 (15ms), cur=2 (40ms)


linuxserver:
 Flags:         vers=3,proto=udp,sec=none,hard,intr,link,symlink,acl,rsize=8192,wsize=8192,retrans=5,timeo=11
 Attr cache:    acregmin=3,acregmax=60,acdirmin=30,acdirmax=60
 Lookups:     srtt=1 (2ms), dev=1 (5ms), cur=0 (0ms)


--- And nfsstat -c for the client (retrans did not increase during this test)

Client rpc:
Connection oriented:
calls       badcalls    badxids     timeouts    newcreds    badverfs
2209288     117         5           1           0           0
timers      cantconn    nomem       interrupts
0           111         0           5
Connectionless:
calls       badcalls    retrans     badxids     timeouts    newcreds
14327877    17289       4498        105         21658       0
badverfs    timers      nomem       cantsend
0           2502        0           0

Client nfs:
calls       badcalls    clgets      cltoomany
16115088    132         16115088    0
Version 2: (1067 calls)
null        getattr     setattr     root        lookup      readlink
0 0%        1061 99%    0 0%        0 0%        5 0%        0 0%
read        wrcache     write       create      remove      rename
0 0%        0 0%        0 0%        0 0%        0 0%        0 0%
link        symlink     mkdir       rmdir       readdir     statfs
0 0%        0 0%        0 0%        0 0%        0 0%        1 0%
Version 3: (16109023 calls)
null        getattr     setattr     lookup      access      readlink
0 0%        5103618 31% 289621 1%   2757869 17% 772866 4%   8005 0%
read        write       create      mkdir       symlink     mknod
2955234 18% 3392759 21% 118810 0%   8634 0%     7433 0%     2 0%
remove      rmdir       rename      link        readdir     readdirplus
133306 0%   8222 0%     10810 0%    11005 0%    93489 0%    94502 0%
fsstat      fsinfo      pathconf    commit
38683 0%    475 0%      3118 0%     300562 1%

Client nfs_acl:
Version 2: (1 calls)
null        getacl      setacl      getattr     access
0 0%        0 0%        0 0%        1 100%      0 0%
Version 3: (4997 calls)
null        getacl      setacl
0 0%        4997 100%   0 0%







































Tomorrow We'll try to packup the
same analysis for TCP.



-------------------------------------------------------
This SF.net email is sponsored by: SlickEdit Inc. Develop an edge.
The most comprehensive and flexible code editor you can use.
Code faster. C/C++, C#, Java, HTML, XML, many more. FREE 30-Day Trial.
www.slickedit.com/sourceforge
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

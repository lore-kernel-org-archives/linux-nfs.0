From: Fabrizio Nesti <nesti@medialab.sissa.it>
Subject: Re: 2.4.20 TCP server + solaris client performance
Date: Thu, 20 Feb 2003 19:18:06 +0100 (MET)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.GSO.4.40.0302201543110.1800-100000@bodoni>
References: <3E53C55D.1FCF2982@amis.com>
Reply-To: Fabrizio Nesti <nesti@medialab.sissa.it>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Neil Brown <neilb@cse.unsw.edu.au>, <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from didot.sissa.it ([147.122.2.50])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18lvM0-0008Lk-00
	for <nfs@lists.sourceforge.net>; Thu, 20 Feb 2003 10:23:28 -0800
To: Eric Whiting <ewhiting@amis.com>
In-Reply-To: <3E53C55D.1FCF2982@amis.com>
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

>I just tried your tar -xf cvs-1.11.5.tar test and I see numbers like yours
> (except I don't see super fast solaris NFS numbers)
> Client	Server		Time
> -------------------------------------
> solaris7	2.4.20		27.3
> solaris7	solaris9	26.9
> solaris9	solaris7	25.3
> 2.4.18	2.4.20		 7.0 (defaults to async mounts right?)
> 2.4.20	2.4.18		15.1
> linux local (no NFS)		 1.2 (including sync)

Hello, your third line is indeed strange to us.
These are our times, in the full range of situations, still for tar xf.
We'll try some other tests (dd and bonnie) tomorrow.

    Client	Server	             Time (sec)                  TCP/UDP
-------------------------------------------------------------------------
1)  2.4.18	solaris7               7 (rw=32k)   (7 for rw=8k)   T
2)  solaris8	solaris7               8 (rw=32k)  (15 for rw=8k)   T
3)  2.4.18	solaris7               7			    U
4)  solaris8	solaris7               15 			    U

5)  2.4.18	2.4.20 (sync)          30 (rw=8k) 		    T
6)  2.4.18	2.4.20 (async)         10 (rw=8k) 		    T
7)  solaris8	2.4.20 (sync)          55 (rw=8k) 60 (rw=1k)	    T
8)  solaris8	2.4.20 (async)         40 (rw=8k) 		    T
9)  2.4.18s	2.4.20 (sync)          15 			    U
A)  2.4.18s	2.4.20 (async)          3			    U
B)  solaris8	2.4.20 (sync)          53 			    U
C)  solaris8	2.4.20 (async)         34 			    U

D)  2.4.18      2.4.18s (sync)         50 (both machines loaded)    U
E)  2.4.18      2.4.18s (async)         3			    U
F)  solaris8    2.4.18s (sync)         87 (both machines loaded)    U
G)  solaris8    2.4.18s (async)        33      		            U

Local Writes (no NFS):
2.4.18s   (Xeon server, RAID5/ext3)     2  (including sync)
2.4.18/20 (Athlon1900DDR test PC, ext3) 3  (including sync)
solaris7  (E250 server, RAID5/UFS+logg) 3  (including sync)

solaris8 client is an U10 (and has no retransmission problems).

Comments:
- TCP does not help the present linux server. (on the contrary for pure
  linux it's worse).
- For pure solaris, wsize=32k doubles the TCP speed, otherwise comparable
  to UDP performance. We may try to enable it for linux also..
- Does solaris default to async? (Strange, but there's no server side flag).
  If not, solaris is _very_ fast.

-- 
In other words, we switched from a SUN Enterprise250 to a quad Xeon (Dell),
to find performance loss from case 2) to G).  :(

Hoping in the best,
ciao,
Fabrizio


PS: Some nfsstat -m as seen from the solaris8 client.

1,2) solaris 7 server via TCP
 from didot:/export/backup
 Flags:         vers=3,proto=tcp,sec=sys,hard,intr,link,symlink,acl,
		rsize=<....>,wsize=<.....>,retrans=5,timeo=600
 Attr cache:    acregmin=3,acregmax=60,acdirmin=30,acdirmax=60

3,4) Solaris 7 server via UDP
 Flags:         vers=3,proto=udp,sec=sys,hard,intr,link,symlink,acl,
		rsize=8192,wsize=8192,retrans=5,timeo=11
 Attr cache:    acregmin=3,acregmax=60,acdirmin=30,acdirmax=60
 Lookups:       srtt=7 (17ms), dev=3 (15ms), cur=2 (40ms)
 Reads:         srtt=9 (22ms), dev=6 (30ms), cur=4 (80ms)
 Writes:        srtt=7 (17ms), dev=3 (15ms), cur=2 (40ms)
 All:           srtt=7 (17ms), dev=3 (15ms), cur=2 (40ms)

5,6,7,8) Linux server via TCP:
 Flags:         vers=3,proto=tcp,sec=none,hard,intr,link,symlink,acl,
		rsize=8192,wsize=8192,retrans=5,timeo=600
 Attr cache:    acregmin=3,acregmax=60,acdirmin=30,acdirmax=60

9,A,B,C,D,E,F,G) Linux servers via UDP
 Flags:         vers=3,proto=udp,sec=none,hard,intr,link,symlink,
		rsize=8192,wsize=8192,retrans=5,timeo=11
 Attr cache:    acregmin=3,acregmax=60,acdirmin=30,acdirmax=60
 Lookups:       srtt=7 (17ms), dev=3 (15ms), cur=2 (40ms)
 Reads:         srtt=7 (17ms), dev=4 (20ms), cur=2 (40ms)
 Writes:        srtt=7 (17ms), dev=3 (15ms), cur=2 (40ms)
 All:           srtt=7 (17ms), dev=3 (15ms), cur=2 (40ms)





  Client	Server		Time (sec)
-----------------------------------------------
TCP:
1)  2.4.18	solaris7	   7 (rw=32k)   (7 for rw=8k)
2)  solaris8	solaris7	   8 (rw=32k)  (15 for rw=8k)
3)  2.4.18	2.4.20 (sync)      30 (rw=8k)
4)  2.4.18	2.4.20 (async)     10 (rw=8k)
5)  solaris8	2.4.20 (sync)      55 (rw=8k) 60 (rw=1k)
6)  solaris8	2.4.20 (async)     40 (rw=8k)
UDP:
7)  2.4.18	solaris7	   7.5
8)  solaris8	solaris7	   15
9)  2.4.18s	2.4.20 (sync)      15
A)  2.4.18s	2.4.20 (async)     2.5
B)  solaris8	2.4.20 (sync)      53
C)  solaris8	2.4.20 (async)     34

9)  2.4.18      2.4.18s (sync)      50 (both machines loaded)
A)  2.4.18      2.4.18s (async)     2.6
B)  solaris8    2.4.18s (sync)      87 (both machines loaded)
C)  solaris8    2.4.18s (async)     33








-------------------------------------------------------
This SF.net email is sponsored by: SlickEdit Inc. Develop an edge.
The most comprehensive and flexible code editor you can use.
Code faster. C/C++, C#, Java, HTML, XML, many more. FREE 30-Day Trial.
www.slickedit.com/sourceforge
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: Performance Woes...
Date: Wed, 5 Jun 2002 15:05:23 +1000 (EST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15613.39955.215475.311267@notabene.cse.unsw.edu.au>
References: <0a1701c20c49$a57f6250$6701a8c0@c1886657a>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17FSz5-0006KQ-00
	for <nfs@lists.sourceforge.net>; Tue, 04 Jun 2002 22:05:24 -0700
Received: From notabene ([129.94.211.194] == dulcimer.orchestra.cse.unsw.EDU.AU)
	(for <admin@webmersion.com>) (for <nfs@lists.sourceforge.net>) By
	tone With Smtp ; Wed, 5 Jun 2002 15:05:14 +1000
To: "Matt Heaton" <admin@webmersion.com>
In-Reply-To: message from Matt Heaton on Tuesday June 4
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

On Tuesday June 4, admin@webmersion.com wrote:
> Hi All, I am having some trouble determining whether it is my NFS server or Client that is the bottleneck.  I have 10 web servers hooked up to 2 NFS servers.
> The clients all run Redhat 7.2 with 2.4.18 with NFSALL patch applied, and the servers are redhat 7.2 with the 2.4.18 kernel.  I am using UDP.
> 
> My problem is that my web servers when doing a "vmstat 1" get many blocked processes.  See below.
> 
> I can't really get ANY kind of good reading to whether or not an NFS
> server is overloaded or not.  Besides iostat and nfsstat are there
> any good tools?!?! 
> I am going crazy trying to test.  Please help.  If you are an NFS
> guru feel free to give me a call at (801) 361-1177 (Cell phone).  I
> am happy to pay!  

Try:
# cat /proc/net/rpc/nfsd

I get:

rc 19779 29251958 135512291
fh 2376 163053154 6932683 1437 0
io 3259963919 553169354
th 94 21542 3554.490 1121.770 915.500 831.020 341.850 210.850 141.590 52.500 56.460 564.230
ra 256 4059797 19063 10367 7587 5209 3618 2408 1820 1396 734 498054
net 164789163 164789562 0 0
rpc 164785911 2835 2835 0 0
proc2 18 1057931 115172462 24952465 0 13386753 143713 5627467 0 3166880 338554 282079 89827 33325 9448 8796 5118 384934 122775
proc3 22 1 0 47 1271 1315 0 657 169 36 0 0 0 10 0 32 4 79 0 19 0 0 30


The "th" line might be interesting. It shows how many total seconds
that 0-10%, or 10-20% or ... of the threads were busy.
Note that the early numbers are orders of magnitude larger than the
later numbers.  This is good.  What do you get?

Try
  while : ; do netstat -n -u -a | grep :2049 ; sleep 1; done

I get:
udp      348      0 0.0.0.0:2049            0.0.0.0:*                           
udp     1740      0 0.0.0.0:2049            0.0.0.0:*                           
udp        0      0 0.0.0.0:2049            0.0.0.0:*                           
udp        0      0 0.0.0.0:2049            0.0.0.0:*                           
udp     2088      0 0.0.0.0:2049            0.0.0.0:*                           
udp     1044      0 0.0.0.0:2049            0.0.0.0:*                           
udp        0      0 0.0.0.0:2049            0.0.0.0:*                           
udp     2436      0 0.0.0.0:2049            0.0.0.0:*                           
       ^^^^^^

Note this column of numbers.  If it hits a ceiling at 65536, you have
a problem that can be fixed.  See the NFS FAQ, or show me the numbers
and I will explain.

NeilBrown

_______________________________________________________________

Don't miss the 2002 Sprint PCS Application Developer's Conference
August 25-28 in Las Vegas -- http://devcon.sprintpcs.com/adp/index.cfm

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

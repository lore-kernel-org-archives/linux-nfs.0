From: Philippe =?ISO-8859-1?B?R3JhbW91bGzp?= <philippe.gramoulle@mmania.com>
Subject: Re: Maximum number of nfsd daemons?
Date: Thu, 1 Aug 2002 19:43:39 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20020801194339.76fbfb11.philippe.gramoulle@mmania.com>
References: <FB5B6B9A4BA0104886C8394BB2B7C7B803ACAD5A@TOMBO.legato.com>
	<15688.47255.83237.874274@notabene.cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from ns.aspic.com ([213.193.2.5] helo=off.aspic.com)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17aJzQ-00010U-00
	for <nfs@lists.sourceforge.net>; Thu, 01 Aug 2002 10:43:56 -0700
To: nfs@lists.sourceforge.net
In-Reply-To: <15688.47255.83237.874274@notabene.cse.unsw.edu.au>
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


Hi Neil,

On Thu, 1 Aug 2002 14:27:03 +1000 (EST)
Neil Brown <neilb@cse.unsw.edu.au> wrote:

  |  Send me the content of that file and I will interpret bits for you.
  |  
  |  NeilBrown
  |  

I shamelessly take the opportunity to ask you to have at the following /proc/net/rpc/nfsd figures :o)

Quick description of our setup : NFS clients & server are Linux only (all at least
2.4.19pre6) , 100Mbs switched network, no router between server & clients,
clients and server are using NFSV3 UDP.

64 nfsd processes on the server ,around 40 to 50 clients.
(server is a 1GHz SMP 1go 1Go RAM)

# cat /proc/net/rpc/nfsd 
rc 75545 57811921 1425095899
fh 841380 1483195871 0 3806 22127
io 947166859 1044180197
th 64 1701313 122616.020 45017.680 17551.390 8336.110 5302.600 2744.440
 2160.200 1545.790 1213.580 5346.700
ra 128 517548125 17409328 11625583 8052404 5724124 5052943 4025961 3561989
 2949267 2450055 227670791
net 1483010914 1483010914 0 0
rpc 1482983365 27549 27549 0 0
proc2 18 27540 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
proc3 22 27546 -1121099198 3805380 1366334119 342864898 352 806090436 42699347
 6410085 439142 11 0 3627641 250110 655750 0 3473989 16097 2780770 2780468 0 21798882

We experience a lot of "NFS server not responding" so i wonder if we don't come close to a limit.
I see an average of 8 Mbs on eth0 so it doesn't look like the network is the problem.
( only one 100Mbs interface on the NFS server )

Thanks.

Philippe.


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

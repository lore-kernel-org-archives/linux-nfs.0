From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: Maximum number of nfsd daemons?
Date: Wed, 7 Aug 2002 21:04:22 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15696.65206.947132.844146@notabene.cse.unsw.edu.au>
References: <FB5B6B9A4BA0104886C8394BB2B7C7B803ACAD5A@TOMBO.legato.com>
	<15688.47255.83237.874274@notabene.cse.unsw.edu.au>
	<20020801194339.76fbfb11.philippe.gramoulle@mmania.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17cObf-0001n6-00
	for <nfs@lists.sourceforge.net>; Wed, 07 Aug 2002 04:03:59 -0700
Received: From notabene ([129.94.242.45] == bartok.orchestra.cse.unsw.EDU.AU)
	(for <philippe.gramoulle@mmania.com>)
	(for <nfs@lists.sourceforge.net>) By tone With Smtp ;
	Wed, 7 Aug 2002 21:03:50 +1000
To: Philippe =?ISO-8859-1?B?R3JhbW91bGzp?= <philippe.gramoulle@mmania.com>
In-Reply-To: message from Philippe Gramoullé on Thursday August 1
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

On Thursday August 1, philippe.gramoulle@mmania.com wrote:
> 
> Hi Neil,
> 
> On Thu, 1 Aug 2002 14:27:03 +1000 (EST)
> Neil Brown <neilb@cse.unsw.edu.au> wrote:
> 
>   |  Send me the content of that file and I will interpret bits for you.
>   |  
>   |  NeilBrown
>   |  
> 
> I shamelessly take the opportunity to ask you to have at the
> following /proc/net/rpc/nfsd figures :o)

Then you should address the email to me, not just to the list.  I can
easily get behind on mailing list mail...

> 
> Quick description of our setup : NFS clients & server are Linux only (all at least
> 2.4.19pre6) , 100Mbs switched network, no router between server & clients,
> clients and server are using NFSV3 UDP.
> 
> 64 nfsd processes on the server ,around 40 to 50 clients.
> (server is a 1GHz SMP 1go 1Go RAM)
> 
> # cat /proc/net/rpc/nfsd 
> rc 75545 57811921 1425095899
> fh 841380 1483195871 0 3806 22127
> io 947166859 1044180197
> th 64 1701313 122616.020 45017.680 17551.390 8336.110 5302.600 2744.440
>  2160.200 1545.790 1213.580 5346.700

Looks a bit busy.  I feel that the fact that the last number is bigger
than the preceding few is significant.  You would probably expect some
sort of Poisson (spelling?) distribution here.  However having a peek
at the end suggests that for a lot of those 5000 seconds the server
was over-loaded and really wanted to use more threads.
The fact that nearly two million requests used that last thread
suggests this as well.  Now there were over a billion requests
altogether so most of the time your server was doing fine, but when a
peak load came it, it didn't cope.

I would increase the number of threads.  Probably up to 128.

The usage counts don't get zeroed when you do that (maybe they
should..) so you need to take a copy of what they were just before you
up the thread count, and then subtract that from what you look at in a
few days..

> ra 128 517548125 17409328 11625583 8052404 5724124 5052943 4025961 3561989
>  2949267 2450055 227670791
> net 1483010914 1483010914 0 0
> rpc 1482983365 27549 27549 0 0
> proc2 18 27540 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
> proc3 22 27546 -1121099198 3805380 1366334119 342864898 352 806090436 42699347
>  6410085 439142 11 0 3627641 250110 655750 0 3473989 16097 2780770 2780468 0 21798882
> 
> We experience a lot of "NFS server not responding" so i wonder if we don't come close to a limit.
> I see an average of 8 Mbs on eth0 so it doesn't look like the network is the problem.
> ( only one 100Mbs interface on the NFS server )

"NFS server not responding" can be due to the receive queue filling up
on the NFS server.
 while true; do netstat -nta | grep :2049 ; sleep 1; done

Watch the first column of numbers.  If it frequently hits a ceiling at
65536 or near there, you are losing packets.

  rpc.nfsd 0
  echo 262144 > /proc/sys/net/core/rmem_default
  echo 262144 > /proc/sys/net/core/rmem_max
  rpc.nfsd 128
  echo 65536 > /proc/sys/net/core/rmem_default
  echo 65536 > /proc/sys/net/core/rmem_max

should fix that.

NeilBrown
  
 
> 
> Thanks.
> 
> Philippe.
> 
> 
> -------------------------------------------------------
> This sf.net email is sponsored by:ThinkGeek
> Welcome to geek heaven.
> http://thinkgeek.com/sf
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

From: Philippe =?ISO-8859-1?B?R3JhbW91bGzp?= <philippe.gramoulle@mmania.com>
Subject: Re: Maximum number of nfsd daemons?
Date: Wed, 7 Aug 2002 15:07:21 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20020807150721.1736ec6f.philippe.gramoulle@mmania.com>
References: <FB5B6B9A4BA0104886C8394BB2B7C7B803ACAD5A@TOMBO.legato.com>
	<15688.47255.83237.874274@notabene.cse.unsw.edu.au>
	<20020801194339.76fbfb11.philippe.gramoulle@mmania.com>
	<15696.65206.947132.844146@notabene.cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: nfs <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from ns.aspic.com ([213.193.2.5] helo=off.aspic.com)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17cQXD-0001mE-00
	for <nfs@lists.sourceforge.net>; Wed, 07 Aug 2002 06:07:31 -0700
To: Neil Brown <neilb@cse.unsw.edu.au>
In-Reply-To: <15696.65206.947132.844146@notabene.cse.unsw.edu.au>
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

On Wed, 7 Aug 2002 21:04:22 +1000
Neil Brown <neilb@cse.unsw.edu.au> wrote:

  |  Then you should address the email to me, not just to the list.  I can
  |  easily get behind on mailing list mail...

Ok, will do next time :o)

  |  > # cat /proc/net/rpc/nfsd 
  |  > rc 75545 57811921 1425095899
  |  > fh 841380 1483195871 0 3806 22127
  |  > io 947166859 1044180197
  |  > th 64 1701313 122616.020 45017.680 17551.390 8336.110 5302.600 2744.440
  |  >  2160.200 1545.790 1213.580 5346.700
  |  

  |  Now there were over a billion requests
  |  altogether so most of the time your server was doing fine, but when a
  |  peak load came it, it didn't cope.

This is indeed what we observed.

  |  
  |  I would increase the number of threads.  Probably up to 128.

This is what i did actually, and since then the servers are doing really good
even during peak hours, and no more warning messages.

  |  
  |  The usage counts don't get zeroed when you do that (maybe they
  |  should..) so you need to take a copy of what they were just before you
  |  up the thread count, and then subtract that from what you look at in a
  |  few days..

I've noticed that. Actually, i had to reboot one of them so i can read directly the figures
right now:

# uptime

14:40:33 up 22:45,  1 user,  load average: 1.64, 1.92, 1.94

# cat /proc/net/rpc/nfsd 

rc 218 486371 43878936
fh 1519133 42854538 0 659 1345
io 2725711409 2096612340
th 128 0 20.000 1.750 0.020 0.010 0.000 0.000 0.000 0.000 0.000 0.000
ra 256 609800 18945 8551 4061 2134 1456 1077 687 439 161 250781
net 44365742 44365802 0 0
rpc 44365507 229 229 0 0
proc2 18 229 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
proc3 22 229 25036678 24989 11489150 778515 0 6318090 360723 48596 5727 0 0 37396 4022 5136 0 27909 0 22837 22837 0 182478

 
  |  
  |  "NFS server not responding" can be due to the receive queue filling up
  |  on the NFS server.
  |   while true; do netstat -nta | grep :2049 ; sleep 1; done

i'm not using TCP right now :o) but will do very soon as i've just build a kernel with all
your patches.

  |  
  |  Watch the first column of numbers.  If it frequently hits a ceiling at
  |  65536 or near there, you are losing packets.
  |  
  |    rpc.nfsd 0
  |    echo 262144 > /proc/sys/net/core/rmem_default
  |    echo 262144 > /proc/sys/net/core/rmem_max
  |    rpc.nfsd 128
  |    echo 65536 > /proc/sys/net/core/rmem_default
  |    echo 65536 > /proc/sys/net/core/rmem_max
  |  
  |  should fix that.
  |  
  |  NeilBrown

well, i already added that in the nfs-kernel-server starting script as this was cleary said
in the NFS HOWTO on SF.

But when switching from 64 to 128 i forgot to do so. So i've just did again what's written above,
and everythin fine now.

Thanks,

Philippe.


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

From: Goutham Kurra <kurrag1@yahoo.com>
Subject: strange behavior with gigE switch and 2.4.22 kernel
Date: Sat, 21 Aug 2004 14:04:27 -0700 (PDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040821210427.8014.qmail@web20528.mail.yahoo.com>
References: <Pine.LNX.4.60.0408201303120.7569@harp.ngdc.noaa.gov>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Byd2L-0005dD-Rp
	for nfs@lists.sourceforge.net; Sat, 21 Aug 2004 14:04:29 -0700
Received: from web20528.mail.yahoo.com ([216.136.227.63])
	by sc8-sf-mx1.sourceforge.net with smtp (Exim 4.34)
	id 1Byd2J-0007VU-GB
	for nfs@lists.sourceforge.net; Sat, 21 Aug 2004 14:04:29 -0700
To: nfs@lists.sourceforge.net
In-Reply-To: <Pine.LNX.4.60.0408201303120.7569@harp.ngdc.noaa.gov>
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



I have the following configuration:

1. linux nfs client kernel 2.4.22 with nfs (client,
sunrpc, lockd) patches applied from trond's 2.4.22
patches. (have run connectathon on this with linux nfs
server backend successfully)

2. netapp nfs server (F760).

There's a gigE switch inbetween the client and server.

With a gigE switch in between, the 2.4.22 client
mounts the filesystem, but hangs indefinitely on a
'ls' on the mount. tcpdump shows that the readdir
request is being retransmitted over and over again.

When I replace the gigE switch with a 100/FE switch,
everything works great.

When I keep the gigE switch and use a stock redhat 9
(kernel 2.4.20-6) linux client, everything seems to
work well too.

So here's the problematic combination: linux 2.4.22
(with or without trond's patches), gigE switch in
between, and netapp nfs filer.

Any ideas on what's going on, or how I should begin to
troubleshoot/debug it?

thanks,
goutham



		
__________________________________
Do you Yahoo!?
Yahoo! Mail - Helps protect you from nasty viruses.
http://promotions.yahoo.com/new_mail


-------------------------------------------------------
SF.Net email is sponsored by Shop4tech.com-Lowest price on Blank Media
100pk Sonic DVD-R 4x for only $29 -100pk Sonic DVD+R for only $33
Save 50% off Retail on Ink & Toner - Free Shipping and Free Gift.
http://www.shop4tech.com/z/Inkjet_Cartridges/9_108_r285
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

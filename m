From: "Jim Dennis" <jdennis@cadence.com>
Subject: RE: NFS digest: Re: Update: NFS over a Win2k Server NAT Router with
Date: Thu, 27 Apr 2006 13:46:13 -0700
Message-ID: <920746F6DF728345915EF4D6DA610D0F011123EE@MAILSJ2.global.cadence.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from [10.3.1.94] (helo=sc8-sf-list2-new.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FZDNf-0007fx-7W
	for nfs@lists.sourceforge.net; Thu, 27 Apr 2006 13:46:31 -0700
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1FZDNf-00086M-8y
	for nfs@lists.sourceforge.net; Thu, 27 Apr 2006 13:46:31 -0700
Received: from isvw3.cadence.com ([158.140.2.61] helo=mx-sanjose2.Cadence.COM)
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1FZDNd-0003pi-VI
	for nfs@lists.sourceforge.net; Thu, 27 Apr 2006 13:46:31 -0700
Received: from MAILSJ2.global.cadence.com (localhost [127.0.0.1])
	by mx-sanjose2.Cadence.COM (8.12.9/8.12.9) with ESMTP id k3RKkSjI022783
	for <nfs@lists.sourceforge.net>; Thu, 27 Apr 2006 13:46:29 -0700 (PDT)
To: <nfs@lists.sourceforge.net>
Sender: nfs-admin@lists.sourceforge.net
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

=20
> Message: 11
> From: "Michael Lackner" <thrawn@xin.at>
> Subject: Re: [NFS] Update: NFS over a Win2k Server NAT Router with
"DMZ":nfs: server not responding, still trying

> Hello.

> Maybe that might help resolving the issue? I did some tcpdump on
client
> and fileserver. As expected, after the nfs readdir, there is no
response
> coming from the fileserver.

> On the fileserver itself i found this:
> =3D=3D=3D
 ...
> 20:23:57.284227 CLIENTBEHINDNAT > FILESERVER: icmp: CLIENTBEHINDNAT
unreachable - need to frag (mtu 1500) (ttl 128, id 4037, len 56)
> =3D=3D=3D

What's that ICMP doing there?=20

 Michael Lackner,

 That's from a kernel feature called "Path MTU discovery"

 Linux and other modern TCP/IP stacks try to negotiate the optimal MTU
for any given connection
 by use of the IP "DF" (don't fragment) option.  Packets are initially
set to the local interface
 MTU with DF ... and the TCP/IP subsystem then listens for these ICMP
"need to fragment" responses.
 It then tries a lower MTU and re-sends the dropped packets.

 Bad, broken, stupid firewalls and packet filters block these PMTU ICMP
responses which then causes
 problems such as yours.

 Thanks for playing.  Fix the firewall (get Microsoft to correct the
issue ... be it in the
 configuration or the code itself). A Google search on PMTU and/or the
phrase "path MTU discovery"
 or PMTU-D should return a number of useful documents on the topic.
Here's the first couple that
 looked good to me: http://alive.znep.com/~marcs/mtu/ and
http://www.netheaven.com/pmtu.html.

JDennis


-------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

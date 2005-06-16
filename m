From: Yuan Xu <yuan@pauli.utmb.edu>
Subject: NFS cross mount DHCP and static IP linux boxes
Date: Thu, 16 Jun 2005 13:42:26 -0500
Message-ID: <1118947346.13289.36.camel@pauli.utmb.edu>
Reply-To: yuan@pauli.utmb.edu
Mime-Version: 1.0
Content-Type: text/plain
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DizK1-0005wK-4L
	for nfs@lists.sourceforge.net; Thu, 16 Jun 2005 11:42:37 -0700
Received: from mx4.utmb.edu ([129.109.195.9])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DizJy-0000d2-Ke
	for nfs@lists.sourceforge.net; Thu, 16 Jun 2005 11:42:37 -0700
Received: from pauli.utmb.edu (pauli.utmb.edu [129.109.59.102])
	by mx4.utmb.edu (8.12.11/8.12.11) with ESMTP id j5GIgRHS018345
	for <nfs@lists.sourceforge.net>; Thu, 16 Jun 2005 13:42:27 -0500
To: NFS <nfs@lists.sourceforge.net>
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


Dear all
 
I just upgraded one of my linux box to CF4 running 2.6.11-1.1369_FC4smp
and cross mounted NFS worked fine without any problems. However when the
machine is moved to a new building with different sub domain and was
started as dhcp client then the NFS does not work any more either as NFS
server or as a NFS client although I have added the dhcp client's IP
number to both the NFS server and client machines' hosts files, have put
hosts.deny to deny nothing, hosts.allow to allow everything on both
machines, have exported file use the dhcp IP not the domain name etc, I
always got from the dhcp machine when mounting a static NFS server

mount: curie:/home/people failed, reason given by server: Permission
denied

and got when try to mount from a static IP box to the the dhcp machine
mount: RPC: Port mapper failure - RPC: Unable to receive

or
mount: RPC: Remote system error - No route to host

and did

rpcinfo -p my_dhcp_machine 
from a machine with static IP and

got
rpcinfo: can't contact portmapper: RPC: Remote system error - No route
to host

Any suggestions for solving those problems?

PS, This is my first time to do so and it may be so easy for you guys.


Yuan






-------------------------------------------------------
SF.Net email is sponsored by: Discover Easy Linux Migration Strategies
from IBM. Find simple to follow Roadmaps, straightforward articles,
informative Webcasts and more! Get everything you need to get up to
speed, fast. http://ads.osdn.com/?ad_id=7477&alloc_id=16492&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
